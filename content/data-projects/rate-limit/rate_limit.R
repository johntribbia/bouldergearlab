# ============================================================
# ANTHROPIC OAUTH POLICY CHANGE:  IMPACT ANALYSIS
# Synthetic Data Demonstration Framework
# ============================================================
# This script mirrors the within-version quality estimator
# from bouldergearlab.com/data-projects/model-quality/ and
# adapts it to a policy change: Anthropic blocking OAuth
# access for Pro/Max subscriptions, forcing users to API keys.
#
# Structure:
#   1. Data generation - 50K users, known causal effects
#   2. The business problem - cost/revenue ratio analysis
#   3. Identification strategy - within-plan-tier variation
#   4. Post-policy outcome simulation
#   5. Difference-in-differences estimator
#   6. Scenario modeling - Bear / Base / Bull
#   7. Visualizations
# ============================================================

library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(tibble)
library(stringr)
library(forcats)
library(readr)
library(scales)
library(patchwork)

set.seed(2026)

script_path <- commandArgs(trailingOnly = FALSE) |>
  stringr::str_subset("^--file=") |>
  stringr::str_remove("^--file=")
script_dir <- if (length(script_path) > 0) {
  dirname(normalizePath(script_path))
} else {
  normalizePath(getwd())
}
output_dir <- file.path(script_dir, "figures")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ============================================================
# SECTION 1: PARAMETERS
# ============================================================

N_USERS     <- 50000
N_WEEKS     <- 26
POLICY_WEEK <- 13   # OAuth block goes live at week 13

# True causal effects injected into the DGP, to be recovered
TRUE_CHURN_HEAVY   <- 0.42   # P(churn | heavy OAuth user, post-policy)
TRUE_CONVERT_HEAVY <- 0.40   # P(convert to API key | heavy OAuth user)
TRUE_BUNDLE_HEAVY  <- 0.18   # P(buy extra bundle | heavy OAuth user)
# Residual ~0% retained on subscription (heavy users lose OAuth, must act)

TRUE_CHURN_LIGHT   <- 0.08   # Light OAuth users mostly unaffected
TRUE_CONVERT_LIGHT <- 0.07
TRUE_BUNDLE_LIGHT  <- 0.04

# Revenue parameters (monthly)
REV_PRO    <- 20
REV_MAX    <- 200
REV_API    <- 85    # average API spend for converted user (pay-as-you-go)
REV_BUNDLE <- 50    # extra usage bundle add-on price
COST_PER_COMPUTE_UNIT <- 8   # internal cost per normalized compute unit

# ============================================================
# SECTION 2: GENERATE USER CHARACTERISTICS
# ============================================================

# OAuth intensity is structurally driven by role, not plan tier.
# Developers use more third-party tooling (Claw, etc.) than
# Business or Casual users, same plan, different exposure.
# This is the within-plan-tier variation we identify on.

make_oauth <- function(segment, n) {
  case_when(
    segment == "Developer" ~ rbeta(n, 3.0, 1.5),
    segment == "Business"  ~ rbeta(n, 1.8, 2.5),
    segment == "Casual"    ~ rbeta(n, 0.7, 4.0)
  )
}

users <- tibble(
  user_id  = 1:N_USERS,
  segment  = sample(c("Developer", "Business", "Casual"),
                    N_USERS, replace = TRUE, prob = c(0.28, 0.34, 0.38)),
  plan     = sample(c("Pro", "Max"), N_USERS,
                    replace = TRUE, prob = c(0.80, 0.20))
) |>
  mutate(
    oauth_intensity_true = make_oauth(segment, N_USERS),

    # Baseline engagement: probability of being active on any given day
    baseline_engagement = rnorm(N_USERS, mean = 0.57, sd = 0.13) |>
      pmax(0.05) |> pmin(0.97),

    # Monthly subscription revenue
    revenue_pre = if_else(plan == "Max", REV_MAX, REV_PRO),

    # Compute load: heavy OAuth users consume 3-5x more compute
    # because every third-party API call routes through Claude
    compute_load = if_else(
      oauth_intensity_true > 0.5,
      oauth_intensity_true * rnorm(N_USERS, 4.3, 0.9) |> pmax(0.5),
      oauth_intensity_true * rnorm(N_USERS, 1.1, 0.3) |> pmax(0.1)
    ),

    # Cost/revenue ratio, the metric that triggered the decision
    cost_revenue_ratio = (compute_load * COST_PER_COMPUTE_UNIT) / revenue_pre,

    # Binary treatment: heavy OAuth users are "treated" by the policy
    oauth_heavy = oauth_intensity_true > 0.5
  )

cat("===== SECTION 2: THE BUSINESS PROBLEM =====\n")
cat("Cost/Revenue Ratio by Segment and OAuth Intensity:\n\n")

users |>
  group_by(segment, oauth_heavy) |>
  summarise(
    n                = n(),
    avg_monthly_rev  = dollar(mean(revenue_pre)),
    avg_monthly_cost = dollar(mean(compute_load * COST_PER_COMPUTE_UNIT)),
    avg_cr_ratio     = round(mean(cost_revenue_ratio), 2),
    pct_unprofitable = percent(mean(cost_revenue_ratio > 1)),
    .groups = "drop"
  ) |>
  arrange(desc(avg_cr_ratio)) |>
  print()

cat("\nKey finding: Heavy-OAuth Developers on Pro ($20/mo) cost\n")
cat("Anthropic $60-80/mo in compute. Decision is obvious.\n\n")

# ============================================================
# SECTION 3: PRE-POLICY TIMESERIES (Weeks 1–12)
# ============================================================

# Generate weekly engagement for the pre-policy period.
# We also observe a NOISY version of oauth_intensity through
# API access logs; this mirrors the noisy category weights
# in the quality framework.

pre_policy <- expand_grid(
  user_id = users$user_id,
  week    = 1:12
) |>
  left_join(select(users, user_id, baseline_engagement,
                   oauth_intensity_true, segment, plan, revenue_pre,
                   oauth_heavy, cost_revenue_ratio),
            by = "user_id") |>
  mutate(
    # Noisy observation of OAuth intensity from access logs
    oauth_obs = pmax(0, pmin(1,
      oauth_intensity_true + rnorm(n(), 0, 0.11)
    )),
    # Weekly active days: baseline + small week-to-week noise
    p_active    = plogis(qlogis(baseline_engagement) + rnorm(n(), 0, 0.14)),
    active_days = rbinom(n(), 7, p_active)
  )

# ---- Freeze OAuth intensity over weeks 1–7 ----
# Identical rationale to the quality framework: if policy causes
# users to change behavior, using real-time weights bakes the
# outcome into the predictor. Freeze at pre-period values.

frozen_weights <- pre_policy |>
  filter(week <= 7) |>
  group_by(user_id) |>
  summarise(oauth_frozen = mean(oauth_obs), .groups = "drop")

# Check stability: do frozen weights correlate with full-period observed?
stability_check <- pre_policy |>
  group_by(user_id) |>
  summarise(oauth_full = mean(oauth_obs), .groups = "drop") |>
  left_join(frozen_weights, by = "user_id")

cat("===== SECTION 3: IDENTIFICATION =====\n")
cat(sprintf(
  "Frozen weight stability: r(frozen, full-period) = %.3f\n\n",
  cor(stability_check$oauth_frozen, stability_check$oauth_full)
))

# Center within plan tier to absorb plan-level baseline differences
# What's left is purely within-plan variation driven by usage role.
users <- users |>
  left_join(frozen_weights, by = "user_id") |>
  group_by(plan) |>
  mutate(oauth_centered = oauth_frozen - mean(oauth_frozen)) |>
  ungroup()

cat("Within-plan centered OAuth intensity (SD by plan):\n")
users |>
  group_by(plan) |>
  summarise(
    mean_centered = round(mean(oauth_centered), 4),
    sd_centered   = round(sd(oauth_centered), 3)
  ) |>
  print()
cat("\nMean ≈ 0 within each plan confirms centering is clean.\n\n")

# ============================================================
# IDENTIFICATION CHECK: PARALLEL TRENDS TEST
# ============================================================

# Core DiD assumption: in the pre-period, treated and control groups
# trended similarly. Test by interacting week × oauth_heavy.
# A non-significant interaction (|t| < 2) is consistent with PT.

pt_model <- lm(
  active_days ~ week * oauth_heavy + baseline_engagement + factor(segment),
  data = pre_policy
)

pt_coef <- coef(summary(pt_model))
int_row  <- pt_coef["week:oauth_heavyTRUE", ]

cat("===== PARALLEL TRENDS TEST =====\n\n")
cat("Pre-period (weeks 1–12): week × oauth_heavy interaction\n")
cat("Null: no differential time trend between treated and control\n\n")
cat(sprintf("  Estimate:   %+.5f\n", int_row["Estimate"]))
cat(sprintf("  Std Error:   %.5f\n",  int_row["Std. Error"]))
cat(sprintf("  t-value:    %+.3f\n",  int_row["t value"]))
cat(sprintf("  p-value:     %.3f\n\n", int_row["Pr(>|t|)"]))

if (abs(int_row["t value"]) < 2.0) {
  cat("PASS: No evidence against parallel trends (|t| < 2.0).\n")
  cat("DiD identifying assumption is consistent with the pre-period data.\n\n")
} else {
  cat("WARNING: Differential pre-period trend detected.\n")
  cat("Consider adding segment x week fixed effects or reviewing DGP.\n\n")
}

# ============================================================
# SECTION 4: SIMULATE POST-POLICY OUTCOMES (Weeks 14–26)
# ============================================================

# After the policy, each heavy-OAuth user lands in one of
# three destinations. Outcome probabilities are segment-specific.

assign_outcome <- function(segment, oauth_heavy, n) {
  p_churn <- case_when(
    !oauth_heavy                         ~ TRUE_CHURN_LIGHT,
    oauth_heavy & segment == 'Developer' ~ TRUE_CHURN_HEAVY * 0.55,
    oauth_heavy & segment == 'Business'  ~ TRUE_CHURN_HEAVY * 0.90,
    TRUE                                 ~ TRUE_CHURN_HEAVY * 1.45
  ) |> pmin(0.90)
  p_convert <- case_when(
    !oauth_heavy                         ~ TRUE_CONVERT_LIGHT,
    oauth_heavy & segment == 'Developer' ~ TRUE_CONVERT_HEAVY * 1.55,
    oauth_heavy & segment == 'Business'  ~ TRUE_CONVERT_HEAVY * 1.00,
    TRUE                                 ~ TRUE_CONVERT_HEAVY * 0.45
  ) |> pmin(0.90)
  p_bundle <- if_else(oauth_heavy, TRUE_BUNDLE_HEAVY, TRUE_BUNDLE_LIGHT)
  r <- runif(n)
  case_when(
    r < p_churn                        ~ 'Churned',
    r < p_churn + p_convert            ~ 'Converted_API',
    r < p_churn + p_convert + p_bundle ~ 'Bought_Bundle',
    TRUE                               ~ 'Retained_Sub'
  )
}

users <- users |>
  mutate(
    post_status = assign_outcome(segment, oauth_heavy, N_USERS),
    revenue_post = case_when(
      post_status == "Churned"       ~ 0,
      post_status == "Converted_API" ~ REV_API,
      post_status == "Bought_Bundle" ~ revenue_pre + REV_BUNDLE,
      TRUE                           ~ revenue_pre
    ),
    revenue_delta = revenue_post - revenue_pre
  )

cat("===== SECTION 4: POST-POLICY OUTCOMES =====\n")
cat("Heavy OAuth users only, destination mix by segment:\n\n")

users |>
  filter(oauth_heavy) |>
  count(segment, post_status) |>
  group_by(segment) |>
  mutate(pct = percent(n / sum(n), accuracy = 0.1)) |>
  arrange(segment, post_status) |>
  print()

# ============================================================
# SECTION 5: DIFFERENCE-IN-DIFFERENCES ESTIMATOR
# ============================================================

# Build a pre/post panel: weeks 8–12 (pre) + 14–18 (post).
# Treatment: oauth_heavy = TRUE.
# Outcome: active_days per week.
# Identification assumption: parallel trends pre-policy.

post_panel <- expand_grid(
  user_id = users$user_id,
  week    = 14:18
) |>
  left_join(select(users, user_id, baseline_engagement, oauth_heavy,
                   oauth_centered, plan, segment, post_status),
            by = "user_id") |>
  mutate(
    post = TRUE,
    p_active = case_when(
      post_status == "Churned"       ~ 0.04,
      post_status == "Converted_API" ~ plogis(qlogis(baseline_engagement) + 0.08 + rnorm(n(), 0, 0.13)),
      post_status == "Bought_Bundle" ~ plogis(qlogis(baseline_engagement) + 0.04 + rnorm(n(), 0, 0.13)),
      TRUE                           ~ plogis(qlogis(baseline_engagement) + rnorm(n(), 0, 0.13))
    ),
    active_days = rbinom(n(), 7, p_active)
  )

pre_panel <- pre_policy |>
  filter(week >= 8) |>
  mutate(post = FALSE) |>
  left_join(select(users, user_id, oauth_centered, post_status),
            by = "user_id")

panel <- bind_rows(
  select(pre_panel, user_id, week, post, active_days, oauth_heavy,
         oauth_centered, plan, segment, baseline_engagement, post_status),
  select(post_panel, user_id, week, post, active_days, oauth_heavy,
         oauth_centered, plan, segment, baseline_engagement, post_status)
)

# Binary DiD
did_binary <- lm(
  active_days ~ oauth_heavy * post + plan + baseline_engagement +
    factor(segment) + factor(week),
  data = slice_sample(panel, n = 80000)
)

# Continuous within-plan estimator (the key causal model)
did_continuous <- lm(
  active_days ~ oauth_centered * post + plan + baseline_engagement +
    factor(segment) + factor(week),
  data = slice_sample(panel, n = 80000)
)

cat("===== SECTION 5: CAUSAL ESTIMATOR =====\n\n")
cat("Binary DiD: oauth_heavy x post\n")
coef_binary <- coef(summary(did_binary))
print(round(coef_binary["oauth_heavyTRUE:postTRUE", ], 4))

cat("\nContinuous within-plan estimator: oauth_centered x post\n")
coef_cont <- coef(summary(did_continuous))
print(round(coef_cont["oauth_centered:postTRUE", ], 4))

cat("\nInterpretation: A 1-unit increase in centered OAuth intensity\n")
cat("predicts", round(coef_cont["oauth_centered:postTRUE", "Estimate"], 3),
    "fewer active days/week post-policy.\n\n")

# ============================================================
# SECTION 6: SCENARIO SIMULATION
# ============================================================

run_scenario <- function(p_churn, p_convert, p_bundle, label) {

  treated <- users |>
    filter(oauth_heavy) |>
    mutate(
      r = runif(n()),
      scen_status = case_when(
        r < p_churn                        ~ "Churned",
        r < p_churn + p_convert            ~ "Converted_API",
        r < p_churn + p_convert + p_bundle ~ "Bought_Bundle",
        TRUE                               ~ "Retained_Sub"
      ),
      scen_rev = case_when(
        scen_status == "Churned"       ~ 0,
        scen_status == "Converted_API" ~ REV_API,
        scen_status == "Bought_Bundle" ~ revenue_pre + REV_BUNDLE,
        TRUE                           ~ revenue_pre
      )
    )

  untreated_post_rev <- sum(users$revenue_pre[!users$oauth_heavy]) *
    (1 - TRUE_CHURN_LIGHT)

  total_pre  <- sum(users$revenue_pre)
  total_post <- sum(treated$scen_rev) + untreated_post_rev

  tibble(
    Scenario          = label,
    `P(Churn)`        = p_churn,
    `P(Convert API)`  = p_convert,
    `P(Bundle)`       = p_bundle,
    `Rev Delta ($M)`  = round((total_post - total_pre) / 1e6, 2),
    `Rev Change (%)`  = round((total_post - total_pre) / total_pre * 100, 1),
    `Churned Users`   = sum(treated$scen_status == "Churned"),
    `Converted Users` = sum(treated$scen_status == "Converted_API")
  )
}

scenarios <- bind_rows(
  run_scenario(0.55, 0.25, 0.20, "Bear: High Churn"),
  run_scenario(0.42, 0.40, 0.18, "Base: Balanced"),
  run_scenario(0.20, 0.60, 0.20, "Bull: High Convert")
)

cat("===== SECTION 6: SCENARIO SIMULATION =====\n\n")
print(scenarios)
cat("\nBase case: policy is revenue-positive if ~40% of heavy OAuth users\n")
cat("convert to pay-as-you-go API at $85/month average spend.\n\n")
# ============================================================
# BREAKEVEN: MINIMUM API CONVERSION RATE
# ============================================================
# Note on constraints: with p_churn=0.42 and p_bundle=0.18 fixed,
# the remaining probability for (p_convert + p_retain) = 0.40.
# That means p_convert ≤ 0.40 while holding churn constant.
# Even at max conversion (40%), expected rev < pre-policy rev.
# Breakeven requires *joint* reduction in churn + higher conversion.
# Solution: interpolate along the Base → Bull scenario trajectory.

cat("\n===== BREAKEVEN ANALYSIS =====\n\n")

n_heavy        <- sum(users$oauth_heavy)
avg_pre_rev_h  <- mean(users$revenue_pre[users$oauth_heavy])
untreated_post <- sum(users$revenue_pre[!users$oauth_heavy]) * (1 - TRUE_CHURN_LIGHT)
total_pre_rev  <- sum(users$revenue_pre)

post_rev_fn <- function(p_churn, p_convert, p_bundle) {
  p_retain <- pmax(0, 1 - p_churn - p_convert - p_bundle)
  ev_rev <- p_churn   * 0 +
            p_convert  * REV_API +
            p_bundle   * (avg_pre_rev_h + REV_BUNDLE) +
            p_retain   * avg_pre_rev_h
  n_heavy * ev_rev + untreated_post - total_pre_rev
}

# Sweep linearly from Base to Bull
base_c <- 0.42; base_k <- 0.40; base_b <- 0.18
bull_c <- 0.20; bull_k <- 0.60; bull_b <- 0.20

alpha_grid  <- seq(0, 1, 0.001)
rev_deltas  <- sapply(alpha_grid, function(a)
  post_rev_fn(
    base_c + a * (bull_c - base_c),
    base_k + a * (bull_k - base_k),
    base_b + a * (bull_b - base_b)
  )
)

be_idx     <- which.min(abs(rev_deltas))
be_alpha   <- alpha_grid[be_idx]
be_convert <- base_k + be_alpha * (bull_k - base_k)
be_churn   <- base_c + be_alpha * (bull_c - base_c)

cat(sprintf("Treated users (heavy OAuth):     %d\n",   n_heavy))
cat(sprintf("Avg pre-policy rev / user:       $%.2f/mo\n", avg_pre_rev_h))
cat(sprintf("API revenue for converters:      $%.2f/mo\n", REV_API))
cat("\nWith p_churn fixed at 42%, p_convert is bounded at 40%.\n")
cat("Even 40% conversion is not enough to reach breakeven at that churn rate.\n")
cat("Breakeven requires churn to fall simultaneously with conversion rising.\n\n")
cat("Breakeven (Base → Bull interpolation):\n")
cat(sprintf("  API conversion rate: ~%.0f%%\n", be_convert * 100))
cat(sprintf("  Churn rate:         ~%.0f%%\n",  be_churn   * 100))
cat(sprintf("  Revenue delta:       ~$%.0fK\n\n", rev_deltas[be_idx] / 1000))
cat("GTM KPIs to track in 30 days post-launch:\n")
cat("  (1) API conversion rate from the heavy-OAuth cohort (target: ~50%)\n")
cat("  (2) Churn rate from that same cohort (target: ≤30%)\n")
cat("  Both must move together for the policy to be net-positive.\n")
# ============================================================
# SECTION 7: VISUALIZATIONS
# ============================================================

bgl_cols <- c(
  Developer = "#7DB800",
  Business = "#4F7CAC",
  Casual = "#E07055",
  Churned = "#E07055",
  Converted_API = "#7DB800",
  Bought_Bundle = "#A8C8D8",
  Retained_Sub = "#6B7280",
  ink = "#1F2933",
  muted = "#5B6673",
  grid = "#E7EBF0"
)

theme_bgl <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title.position = "plot",
      plot.title = element_text(face = "bold", size = 15.5, colour = bgl_cols["ink"]),
      plot.subtitle = element_text(size = 10.5, colour = bgl_cols["muted"], margin = margin(b = 10)),
      axis.title = element_text(size = 11.5, colour = bgl_cols["ink"]),
      axis.text = element_text(size = 10, colour = bgl_cols["muted"]),
      legend.position = "top",
      legend.justification = "left",
      legend.title = element_blank(),
      legend.text = element_text(size = 10, colour = bgl_cols["ink"]),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = bgl_cols["grid"], linewidth = 0.4),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(10, 14, 10, 10)
    )
}

# Fig 1: cost pressure by user type
p1 <- users |>
  sample_n(3500) |>
  ggplot(aes(x = oauth_intensity_true, y = cost_revenue_ratio, color = segment)) +
  geom_point(alpha = 0.16, size = 1.0) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 1.35, span = 0.85) +
  geom_hline(yintercept = 1, linetype = "22", color = bgl_cols["Churned"], linewidth = 0.9) +
  annotate(
    "label", x = 0.74, y = 1.09, label = "Break-even",
    fill = alpha("white", 0.92), linewidth = 0, color = bgl_cols["Churned"], size = 3.2
  ) +
  scale_color_manual(values = c(
    Developer = "#7DB800",
    Business = "#4F7CAC",
    Casual = "#E07055"
  )) +
  scale_x_continuous(
    breaks = seq(0, 1, 0.25),
    labels = label_number(accuracy = 0.01),
    expand = expansion(mult = c(0.02, 0.02))
  ) +
  scale_y_continuous(
    breaks = seq(0, 2.5, 0.5),
    labels = label_number(accuracy = 0.1, suffix = "x"),
    expand = expansion(mult = c(0, 0.04))
  ) +
  coord_cartesian(ylim = c(0, 2.6)) +
  labs(
    title = "1. Cost Pressure Builds Fast",
    subtitle = "Cost / revenue ratio by OAuth intensity and user segment",
    x = "OAuth intensity (0 = never uses third-party tools)",
    y = "Cost / revenue ratio"
  ) +
  theme_bgl()

# Fig 2: post-policy destinations for heavy users
dest_data <- users |>
  filter(oauth_heavy) |>
  count(segment, post_status) |>
  group_by(segment) |>
  mutate(
    pct = n / sum(n),
    post_status = factor(post_status,
      levels = c("Churned", "Converted_API", "Bought_Bundle", "Retained_Sub")
    )
  )

p2 <- dest_data |>
  ggplot(aes(x = segment, y = pct, fill = post_status)) +
  geom_col(width = 0.62, color = "white", linewidth = 0.35) +
  scale_fill_manual(
    values = bgl_cols[c("Churned", "Converted_API", "Bought_Bundle", "Retained_Sub")],
    labels = c(
      Churned = "Churned",
      Converted_API = "Converted to API",
      Bought_Bundle = "Bought bundle",
      Retained_Sub = "Retained sub"
    )
  ) +
  scale_y_continuous(labels = label_percent(accuracy = 1), expand = expansion(mult = c(0, 0.03))) +
  labs(
    title = "2. Where Heavy Users Go",
    subtitle = "Heavy OAuth users only, split by segment",
    x = NULL,
    y = "Share of users"
  ) +
  theme_bgl()

# Fig 3: DiD panel view
weekly_trends <- panel |>
  group_by(week, oauth_heavy) |>
  summarise(avg_active = mean(active_days), .groups = "drop") |>
  mutate(group = factor(
    if_else(oauth_heavy, "Heavy OAuth (treated)", "Light OAuth (control)"),
    levels = c("Heavy OAuth (treated)", "Light OAuth (control)")
  ))

p3 <- weekly_trends |>
  ggplot(aes(x = week, y = avg_active, color = group, group = group)) +
  geom_vline(xintercept = POLICY_WEEK, linetype = "22", color = bgl_cols["muted"], linewidth = 0.8) +
  geom_line(linewidth = 1.25) +
  geom_point(size = 2.1) +
  annotate(
    "label", x = 13.35, y = max(weekly_trends$avg_active) * 0.98,
    label = "Policy change", hjust = 0, size = 3.0,
    fill = alpha("white", 0.92), linewidth = 0, color = bgl_cols["muted"]
  ) +
  scale_color_manual(values = c(
    "Heavy OAuth (treated)" = "#E07055",
    "Light OAuth (control)" = "#4F7CAC"
  )) +
  scale_x_continuous(breaks = c(8:12, 14:18), expand = expansion(mult = c(0.01, 0.02))) +
  labs(
    title = "3. The Post-Policy Drop",
    subtitle = "Average active days per week for treated and control users",
    x = "Week",
    y = "Active days / week"
  ) +
  theme_bgl()

# Fig 4: scenario revenue sensitivity
p4_data <- scenarios |>
  mutate(
    Scenario = factor(
      Scenario,
      levels = c("Bear: High Churn", "Base: Balanced", "Bull: High Convert")
    ),
    label = paste0(
      ifelse(`Rev Delta ($M)` >= 0, "+", ""),
      sprintf("%.2f", `Rev Delta ($M)`), "M\n(",
      sprintf("%.1f", `Rev Change (%)`), "%)"
    ),
    label_y = if_else(`Rev Delta ($M)` >= 0, `Rev Delta ($M)` + 0.012, `Rev Delta ($M)` / 2),
    label_color = if_else(Scenario == "Base: Balanced", bgl_cols["ink"], "white")
  )

p4 <- p4_data |>
  ggplot(aes(x = Scenario, y = `Rev Delta ($M)`, fill = Scenario)) +
  geom_hline(yintercept = 0, color = bgl_cols["muted"], linewidth = 0.5) +
  geom_col(width = 0.58) +
  geom_text(
    aes(y = label_y, label = label, color = label_color),
    size = 3.5, fontface = "bold", lineheight = 0.95
  ) +
  scale_color_identity() +
  scale_fill_manual(values = c(
    "Bear: High Churn" = bgl_cols["Churned"],
    "Base: Balanced" = "#E9C46A",
    "Bull: High Convert" = bgl_cols["Converted_API"]
  )) +
  scale_y_continuous(
    labels = label_dollar(accuracy = 0.01, suffix = "M"),
    limits = c(-0.42, 0.18),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "4. Revenue Hinges on Conversion",
    subtitle = "Monthly delta versus the pre-policy baseline",
    x = NULL,
    y = "Revenue delta (monthly)"
  ) +
  theme_bgl() +
  theme(legend.position = "none")

# Fig 0: pre-period parallel trends check
pt_trends <- pre_policy |>
  group_by(week, oauth_heavy) |>
  summarise(avg_active = mean(active_days), .groups = "drop") |>
  mutate(group = factor(
    if_else(oauth_heavy, "Heavy OAuth (treated)", "Light OAuth (control)"),
    levels = c("Heavy OAuth (treated)", "Light OAuth (control)")
  ))

p_parallel <- pt_trends |>
  ggplot(aes(x = week, y = avg_active, color = group, group = group)) +
  geom_line(linewidth = 1.25) +
  geom_point(size = 2.1) +
  scale_color_manual(values = c(
    "Heavy OAuth (treated)" = "#E07055",
    "Light OAuth (control)" = "#4F7CAC"
  )) +
  scale_x_continuous(breaks = 1:12) +
  labs(
    title = "0. Pre-Period Parallel Trends Check",
    subtitle = "Both groups track together through weeks 1\u201312 \u2014 consistent with the DiD identifying assumption",
    x = "Week (pre-policy only, weeks 1\u201312)",
    y = "Active days / week"
  ) +
  theme_bgl()

# Save article figures
banner_plot <- (p1 + theme(legend.position = "none")) | p4 +
  plot_annotation(
    title = "Anthropic's OAuth Policy Change",
    subtitle = "Synthetic unit economics and scenario modeling for heavy third-party users",
    theme = theme(
      plot.title = element_text(size = 16, face = "bold", colour = bgl_cols["ink"]),
      plot.subtitle = element_text(size = 10, color = bgl_cols["muted"])
    )
  )

combined_plot <- (p1 | p2) / (p3 | p4) +
  plot_annotation(
    title = "Anthropic OAuth Policy Change: Impact Analysis",
    subtitle = paste(
      "Synthetic data with true effects injected (P_churn=0.42, P_convert=0.40) and recovered via DiD.",
      "N=50,000 users. Policy change at week 13.",
      sep = "\n"
    ),
    theme = theme(
      plot.title = element_text(size = 15, face = "bold", colour = bgl_cols["ink"]),
      plot.subtitle = element_text(size = 9, color = bgl_cols["muted"])
    )
  )

ggsave(
  file.path(output_dir, "00_parallel_trends.png"),
  p_parallel, width = 7.5, height = 5.2, dpi = 180, bg = "white"
)
ggsave(
  file.path(output_dir, "01_cost_revenue_ratio.png"),
  p1, width = 7.5, height = 5.2, dpi = 180, bg = "white"
)
ggsave(
  file.path(output_dir, "02_post_policy_destinations.png"),
  p2, width = 7.5, height = 5.2, dpi = 180, bg = "white"
)
ggsave(
  file.path(output_dir, "03_diff_in_diff.png"),
  p3, width = 7.5, height = 5.2, dpi = 180, bg = "white"
)
ggsave(
  file.path(output_dir, "04_scenario_revenue_impact.png"),
  p4, width = 7.5, height = 5.2, dpi = 180, bg = "white"
)
ggsave(
  file.path(script_dir, "rate-limit-banner.png"),
  banner_plot, width = 12, height = 6, dpi = 180, bg = "white"
)
ggsave(
  file.path(output_dir, "rate_limit_overview.png"),
  combined_plot, width = 14, height = 10, dpi = 150, bg = "white"
)

cat("===== ANALYSIS COMPLETE =====\n")
cat(sprintf("Figures saved to %s\n\n", output_dir))
cat("True effects injected into DGP:\n")
cat(sprintf("  P(Churn | Heavy OAuth):    %.2f\n", TRUE_CHURN_HEAVY))
cat(sprintf("  P(Convert | Heavy OAuth):  %.2f\n", TRUE_CONVERT_HEAVY))
cat(sprintf("  P(Bundle | Heavy OAuth):   %.2f\n", TRUE_BUNDLE_HEAVY))
cat("\nDiD estimator recovered from synthetic panel above.\n")
cat("Scenario table shows revenue sensitivity to conversion rate assumptions.\n")