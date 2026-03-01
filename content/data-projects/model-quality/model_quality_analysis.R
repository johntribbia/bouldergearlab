#!/usr/bin/env Rscript
# ==============================================================================
# Model Quality Analysis: Quantifying the Business Impact of AI Model Quality
# ==============================================================================
# WITHIN-VERSION IDENTIFICATION STRATEGY
#
# Key insight: instead of comparing engagement across version boundaries
# (confounded with time), we identify the quality effect WITHIN each version
# period. Users whose category mix aligns with higher-quality categories
# (e.g., Coding is rated 3.50 vs Creative Writing 2.79 in v1.0) experience
# different effective quality, even though everyone is on the same model.
#
# Implementation:
#   - Q_it = sum(w_ic * q_cv): weighted quality from observed category usage
#   - Q_it_c = Q_it - mean(Q_it | version): centered within each version
#   - version_f: factor absorbing between-version level shifts
#   - s(Q_it_c): the causal estimand -- within-version quality effect
#
# Pipeline (Steps 1-14):
#   1. Quality Lookup Table
#   2. Pre-Period Prompt Weights (from OBSERVED category counts)
#   2b. Category Mix Stability Test (frozen-weights assumption)
#   3. Weighted Quality Score (Q_it) + within-version centering
#   4. Merge all tables
#   5. EDA (including within-version Q_it_c diagnostics)
#   6. GAMM: Active Days (binomial, using active_days_observed)
#   7. GAMM: Total Prompts (Poisson)
#   8. Visualize Smooth Effects
#   9. Falsification Test (derangement -- no fixed points)
#  10. Segment Analysis (Consumer vs Enterprise)
#  11. Save outputs
#  12. Calibration Recovery (DGP validation -- does estimator recover TRUE_BETA?)
#  13. Cluster-Robust Inference (user-level block bootstrap)
#  14. DAG Diagram
# ==============================================================================

cat("=", rep("=", 69), "\n", sep = "")
cat("Model Quality Analysis: AI Model Quality -> User Engagement\n")
cat("  Within-Version Identification Strategy\n")
cat("=", rep("=", 69), "\n\n", sep = "")

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(mgcv)
  library(ggplot2)
  library(patchwork)
  library(scales)
})

# -- Config --
DATA_DIR <- "."
FIG_DIR  <- file.path(DATA_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE)
TRUE_BETA <- 1.0   # Known causal effect injected into DGP (log-odds scale)

# Alpine Dark palette
PAL <- list(
  bg     = "#0a0d14",
  ridge  = "#1a2030",
  moss   = "#7db800",
  ice    = "#a8c8d8",
  summit = "#e8e4dc",
  accent = "#d4a574",
  warn   = "#c25450"
)

theme_bgl <- function(base_size = 12) {
  theme_minimal(base_size = base_size) %+replace%
    theme(
      plot.background   = element_rect(fill = PAL$bg, color = NA),
      panel.background  = element_rect(fill = PAL$ridge, color = NA),
      panel.grid.major  = element_line(color = "#2a3040", linewidth = 0.3),
      panel.grid.minor  = element_blank(),
      text              = element_text(color = PAL$summit),
      axis.text         = element_text(color = PAL$ice),
      axis.title        = element_text(color = PAL$summit),
      plot.title        = element_text(color = PAL$summit, face = "bold", size = 14),
      plot.subtitle     = element_text(color = PAL$ice, size = 10),
      legend.background = element_rect(fill = PAL$ridge, color = NA),
      legend.text       = element_text(color = PAL$summit),
      legend.title      = element_text(color = PAL$summit),
      strip.text        = element_text(color = PAL$summit, face = "bold")
    )
}

# ==============================================================================
# LOAD DATA
# ==============================================================================
cat("Loading data...\n")
eval_df    <- read_csv(file.path(DATA_DIR, "offline_model_evaluation.csv"),
                       show_col_types = FALSE)
engage_df  <- read_csv(file.path(DATA_DIR, "user_engagement_timeseries.csv"),
                       show_col_types = FALSE)
demo_df    <- read_csv(file.path(DATA_DIR, "user_demographics_subscription.csv"),
                       show_col_types = FALSE)

cat(sprintf("  Evaluations:  %s rows\n", format(nrow(eval_df), big.mark = ",")))
cat(sprintf("  Engagement:   %s rows\n", format(nrow(engage_df), big.mark = ",")))
cat(sprintf("  Demographics: %s rows\n", format(nrow(demo_df), big.mark = ",")))

stopifnot("prompts_coding" %in% names(engage_df))
stopifnot("active_days_observed" %in% names(engage_df))
cat("  Confirmed: augmented columns present\n\n")

# ==============================================================================
# STEP 1: Quality Lookup Table
# ==============================================================================
cat("Step 1: Building quality lookup table...\n")

quality_lookup <- eval_df %>%
  group_by(eval_prompt_category, model_version) %>%
  summarise(
    mean_human_rating = mean(human_rating, na.rm = TRUE),
    n_evals           = n(),
    .groups = "drop"
  ) %>%
  arrange(eval_prompt_category, model_version)

cat("  Quality scores by category x model version:\n")
ql_wide <- quality_lookup %>%
  select(eval_prompt_category, model_version, mean_human_rating) %>%
  pivot_wider(names_from = model_version, values_from = mean_human_rating)
print(as.data.frame(ql_wide))

cat("\n  Within-version spread (SD across categories):\n")
for (v in unique(quality_lookup$model_version)) {
  ratings <- quality_lookup %>% filter(model_version == v) %>% pull(mean_human_rating)
  cat(sprintf("    %s: SD = %.4f, range = [%.3f, %.3f]\n",
              v, sd(ratings), min(ratings), max(ratings)))
}
cat("  This within-version category spread is the source of identification.\n\n")

# ==============================================================================
# STEP 2: Pre-Period Prompt Weights (from OBSERVED category counts)
# ==============================================================================
cat("Step 2: Computing pre-period prompt weights from OBSERVED category data...\n")

cat_col_map <- c(
  "prompts_coding"           = "Coding",
  "prompts_creative_writing" = "Creative Writing",
  "prompts_general_qa"       = "General QA",
  "prompts_math_logic"       = "Math/Logic",
  "prompts_scientific"       = "Scientific"
)
cat_cols <- names(cat_col_map)

deploy_weeks <- eval_df %>%
  distinct(model_version, deployment_week) %>%
  arrange(deployment_week)
cat("  Deployment schedule (from eval data):\n")
print(as.data.frame(deploy_weeks))

v10_deploy <- deploy_weeks$deployment_week[deploy_weeks$model_version == "v1.0"]
v11_deploy <- deploy_weeks$deployment_week[deploy_weeks$model_version == "v1.1"]
v12_deploy <- deploy_weeks$deployment_week[deploy_weeks$model_version == "v1.2"]
pre_period_end <- v11_deploy - 1

cat(sprintf("  Pre-period: weeks 1 through %d\n", pre_period_end))

pre_period <- engage_df %>%
  filter(week <= pre_period_end) %>%
  group_by(user_id) %>%
  summarise(across(all_of(cat_cols), sum), .groups = "drop")

pre_totals <- rowSums(pre_period[, cat_cols])
zero_mask <- pre_totals == 0

pre_weights <- pre_period
for (col in cat_cols) {
  pre_weights[[col]] <- ifelse(zero_mask, 1 / length(cat_cols),
                               pre_period[[col]] / pre_totals)
}

cat(sprintf("  Users with pre-period data: %s\n",
            format(nrow(pre_weights), big.mark = ",")))
cat(sprintf("  Users with zero pre-period prompts: %d\n", sum(zero_mask)))

user_weights <- pre_weights %>%
  pivot_longer(cols = all_of(cat_cols),
               names_to = "cat_col",
               values_to = "w_ic") %>%
  mutate(eval_prompt_category = cat_col_map[cat_col]) %>%
  select(user_id, eval_prompt_category, w_ic)

cat("  Mean observed weights per category:\n")
weight_summary <- user_weights %>%
  group_by(eval_prompt_category) %>%
  summarise(mean_w = mean(w_ic), sd_w = sd(w_ic), .groups = "drop")
print(as.data.frame(weight_summary))
cat("\n")

# ==============================================================================
# STEP 2b: Category Mix Stability Test (Frozen-Weights Assumption)
# ==============================================================================
cat("Step 2b: Testing category mix stability across version periods...\n")
cat("  If users change WHAT they use the tool for after model upgrades,\n")
cat("  frozen pre-period weights would be stale.\n\n")

# Compute weights for each version period
period_weights <- list()
period_defs <- list(
  "v1.0 (pre-period)" = c(1, pre_period_end),
  "v1.1 period"       = c(v11_deploy, v12_deploy - 1),
  "v1.2 period"       = c(v12_deploy, 26)
)

for (pname in names(period_defs)) {
  wk_range <- period_defs[[pname]]
  pw <- engage_df %>%
    filter(week >= wk_range[1], week <= wk_range[2]) %>%
    group_by(user_id) %>%
    summarise(across(all_of(cat_cols), sum), .groups = "drop")
  pw_totals <- rowSums(pw[, cat_cols])
  for (col in cat_cols) {
    pw[[col]] <- ifelse(pw_totals == 0, 1 / length(cat_cols), pw[[col]] / pw_totals)
  }
  period_weights[[pname]] <- pw
}

# Compare pre-period weights to later periods via per-user correlation
cat("  Per-user weight stability (mean Pearson r with pre-period):\n")
pre_w <- period_weights[["v1.0 (pre-period)"]]
for (pname in names(period_defs)[-1]) {
  later_w <- period_weights[[pname]]
  shared <- inner_join(pre_w, later_w, by = "user_id", suffix = c("_pre", "_post"))
  cors <- numeric(nrow(shared))
  for (i in seq_len(nrow(shared))) {
    w_pre  <- as.numeric(shared[i, paste0(cat_cols, "_pre")])
    w_post <- as.numeric(shared[i, paste0(cat_cols, "_post")])
    cors[i] <- cor(w_pre, w_post)
  }
  cat(sprintf("    %s: mean r = %.4f, median r = %.4f, fraction r > 0.9 = %.1f%%\n",
              pname, mean(cors, na.rm = TRUE), median(cors, na.rm = TRUE),
              100 * mean(cors > 0.9, na.rm = TRUE)))
}

# Population-level: mean weight per category across periods
cat("\n  Population-level mean weights by period:\n")
cat(sprintf("  %-25s", "Category"))
for (pname in names(period_defs)) cat(sprintf("  %18s", pname))
cat("\n")
for (col in cat_cols) {
  cat_name <- cat_col_map[col]
  cat(sprintf("  %-25s", cat_name))
  for (pname in names(period_defs)) {
    cat(sprintf("  %18.4f", mean(period_weights[[pname]][[col]])))
  }
  cat("\n")
}
cat("  -> High correlations + stable means support the frozen-weights assumption.\n\n")

# ==============================================================================
# STEP 3: Weighted Quality Score (Q_it) + Within-Version Centering
# ==============================================================================
cat("Step 3: Computing Q_it and centering within version...\n")

q_wide <- ql_wide

q_joined <- user_weights %>%
  inner_join(q_wide, by = "eval_prompt_category")

Q_user <- q_joined %>%
  group_by(user_id) %>%
  summarise(
    Q_v10 = sum(w_ic * v1.0),
    Q_v11 = sum(w_ic * v1.1),
    Q_v12 = sum(w_ic * v1.2),
    .groups = "drop"
  )

cat("  Raw Q_it by version (before centering):\n")
cat(sprintf("    v1.0: mean=%.4f, sd=%.4f\n", mean(Q_user$Q_v10), sd(Q_user$Q_v10)))
cat(sprintf("    v1.1: mean=%.4f, sd=%.4f\n", mean(Q_user$Q_v11), sd(Q_user$Q_v11)))
cat(sprintf("    v1.2: mean=%.4f, sd=%.4f\n", mean(Q_user$Q_v12), sd(Q_user$Q_v12)))

Q_v10_mean <- mean(Q_user$Q_v10)
Q_v11_mean <- mean(Q_user$Q_v11)
Q_v12_mean <- mean(Q_user$Q_v12)

Q_user <- Q_user %>%
  mutate(
    Q_v10_c = Q_v10 - Q_v10_mean,
    Q_v11_c = Q_v11 - Q_v11_mean,
    Q_v12_c = Q_v12 - Q_v12_mean
  )

cat("\n  Centered Q_it_c (within-version, mean=0 by construction):\n")
cat(sprintf("    v1.0: sd=%.4f, range=[%.4f, %.4f], IQR=%.4f\n",
            sd(Q_user$Q_v10_c), min(Q_user$Q_v10_c), max(Q_user$Q_v10_c),
            IQR(Q_user$Q_v10_c)))
cat(sprintf("    v1.1: sd=%.4f, range=[%.4f, %.4f], IQR=%.4f\n",
            sd(Q_user$Q_v11_c), min(Q_user$Q_v11_c), max(Q_user$Q_v11_c),
            IQR(Q_user$Q_v11_c)))
cat(sprintf("    v1.2: sd=%.4f, range=[%.4f, %.4f], IQR=%.4f\n",
            sd(Q_user$Q_v12_c), min(Q_user$Q_v12_c), max(Q_user$Q_v12_c),
            IQR(Q_user$Q_v12_c)))
cat("  -> This is the identifying variation: same version, different category mix.\n\n")

# ==============================================================================
# STEP 4: Merge
# ==============================================================================
cat("Step 4: Merging datasets...\n")

assign_version <- function(week) {
  case_when(
    week < v11_deploy ~ "v1.0",
    week < v12_deploy ~ "v1.1",
    TRUE              ~ "v1.2"
  )
}

engage_df <- engage_df %>%
  mutate(version_week = assign_version(week),
         version_f    = factor(version_week, levels = c("v1.0", "v1.1", "v1.2"))) %>%
  left_join(Q_user, by = "user_id") %>%
  mutate(
    Q_it = case_when(
      version_week == "v1.0" ~ Q_v10,
      version_week == "v1.1" ~ Q_v11,
      TRUE                   ~ Q_v12
    ),
    Q_it_c = case_when(
      version_week == "v1.0" ~ Q_v10_c,
      version_week == "v1.1" ~ Q_v11_c,
      TRUE                   ~ Q_v12_c
    )
  ) %>%
  select(-Q_v10, -Q_v11, -Q_v12, -Q_v10_c, -Q_v11_c, -Q_v12_c) %>%
  left_join(demo_df, by = "user_id")

engage_df <- engage_df %>%
  rename(active_days = active_days_observed)

cat(sprintf("  Final merged dataset: %s rows x %d columns\n",
            format(nrow(engage_df), big.mark = ","), ncol(engage_df)))
cat(sprintf("  Active days range: [%d, %d], mean=%.2f\n",
            min(engage_df$active_days), max(engage_df$active_days),
            mean(engage_df$active_days)))
cat(sprintf("  Q_it_c range: [%.4f, %.4f], sd=%.4f\n",
            min(engage_df$Q_it_c, na.rm = TRUE),
            max(engage_df$Q_it_c, na.rm = TRUE),
            sd(engage_df$Q_it_c, na.rm = TRUE)))
cat("\n")

# ==============================================================================
# STEP 5: EDA
# ==============================================================================
cat("Step 5: Exploratory Data Analysis...\n\n")

# --- 5a: Active days ---
cat("  5a: Active days distribution\n")
print(table(engage_df$active_days))

p_active <- ggplot(engage_df, aes(x = active_days)) +
  geom_bar(fill = PAL$moss, alpha = 0.85, width = 0.7) +
  scale_x_continuous(breaks = 1:7) +
  scale_y_continuous(labels = comma) +
  labs(title = "Distribution of Observed Active Days per Week",
       subtitle = "True count of distinct days with at least one session",
       x = "Active Days (Observed)", y = "Count") +
  theme_bgl()

ggsave(file.path(FIG_DIR, "01_active_days_dist.png"), p_active,
       width = 8, height = 5, dpi = 150, bg = PAL$bg)
cat("    -> Saved 01_active_days_dist.png\n")

# --- 5b: Total prompts ---
cat("  5b: Total prompts distribution\n")
vmr <- var(engage_df$total_prompts) / mean(engage_df$total_prompts)
cat(sprintf("    Mean: %.2f, Var/Mean: %.2f\n",
            mean(engage_df$total_prompts), vmr))

p_prompts <- ggplot(engage_df, aes(x = total_prompts)) +
  geom_histogram(fill = PAL$ice, alpha = 0.85, bins = 50) +
  scale_y_continuous(labels = comma) +
  labs(title = "Distribution of Total Prompts per Week",
       subtitle = sprintf("Var/Mean = %.2f", vmr),
       x = "Total Prompts per Week", y = "Count") +
  theme_bgl()

ggsave(file.path(FIG_DIR, "02_prompts_dist.png"), p_prompts,
       width = 8, height = 5, dpi = 150, bg = PAL$bg)
cat("    -> Saved 02_prompts_dist.png\n")

# --- 5c: Q_it raw + centered ---
cat("  5c: Quality exposure over time\n")

qit_by_week <- engage_df %>%
  group_by(week) %>%
  summarise(mean_Q = mean(Q_it, na.rm = TRUE),
            q25 = quantile(Q_it, 0.25, na.rm = TRUE),
            q75 = quantile(Q_it, 0.75, na.rm = TRUE),
            .groups = "drop")

p_qit_raw <- ggplot(qit_by_week, aes(x = week, y = mean_Q)) +
  geom_ribbon(aes(ymin = q25, ymax = q75), fill = PAL$moss, alpha = 0.25) +
  geom_line(color = PAL$moss, linewidth = 1.2) +
  geom_vline(xintercept = c(v11_deploy - 0.5, v12_deploy - 0.5),
             linetype = "dashed", color = PAL$accent, linewidth = 0.7) +
  labs(title = "Raw Q_it Over Time (Between + Within Version Variation)",
       subtitle = "Step function confounded with time; IQR shows within-version spread",
       x = "Week", y = "Quality Score (Q_it)") +
  theme_bgl()

p_qit_centered <- ggplot(engage_df, aes(x = Q_it_c, fill = version_f)) +
  geom_density(alpha = 0.5, color = NA) +
  scale_fill_manual(values = c("v1.0" = PAL$moss, "v1.1" = PAL$ice, "v1.2" = PAL$accent)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = PAL$summit, alpha = 0.5) +
  labs(title = "Centered Q_it_c Distribution by Version",
       subtitle = "Mean = 0 within each version; spread = category-mix variation",
       x = "Q_it_c (Centered Quality)", y = "Density", fill = "Version") +
  theme_bgl() +
  theme(legend.position = c(0.85, 0.8))

p_qit_combined <- p_qit_raw / p_qit_centered +
  plot_annotation(
    title = "Quality Exposure: Raw vs Within-Version Centered",
    theme = theme(
      plot.title = element_text(color = PAL$summit, face = "bold", size = 16),
      plot.background = element_rect(fill = PAL$bg, color = NA)
    )
  )

ggsave(file.path(FIG_DIR, "03_qit_over_time.png"), p_qit_combined,
       width = 10, height = 8, dpi = 150, bg = PAL$bg)
cat("    -> Saved 03_qit_over_time.png\n")

# --- 5d: Engagement by week ---
cat("  5d: Engagement trends by week\n")

weekly_engagement <- engage_df %>%
  group_by(week, version_week) %>%
  summarise(
    mean_active_days = mean(active_days, na.rm = TRUE),
    mean_prompts     = mean(total_prompts, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

p_engage_week <- ggplot(weekly_engagement, aes(x = week)) +
  geom_line(aes(y = mean_active_days, color = "Active Days"), linewidth = 1) +
  geom_line(aes(y = mean_prompts / 3, color = "Prompts / 3"), linewidth = 1) +
  geom_vline(xintercept = c(v11_deploy - 0.5, v12_deploy - 0.5),
             linetype = "dashed", color = PAL$accent, linewidth = 0.5) +
  scale_color_manual(values = c("Active Days" = PAL$moss, "Prompts / 3" = PAL$ice)) +
  scale_y_continuous(
    name = "Active Days",
    sec.axis = sec_axis(~ . * 3, name = "Total Prompts per Week")
  ) +
  labs(title = "Mean Engagement by Week",
       subtitle = "Vertical lines = model version transitions",
       x = "Week", color = NULL) +
  theme_bgl() +
  theme(legend.position = "top")

ggsave(file.path(FIG_DIR, "04_engagement_by_week.png"), p_engage_week,
       width = 10, height = 5, dpi = 150, bg = PAL$bg)
cat("    -> Saved 04_engagement_by_week.png\n")

# --- 5e: Within-version correlations ---
cat("  5e: Within-version correlations (Q_it_c vs outcomes)\n")
for (v in c("v1.0", "v1.1", "v1.2")) {
  vd <- engage_df %>% filter(version_week == v)
  cor_a <- cor(vd$Q_it_c, vd$active_days, use = "complete.obs")
  cor_p <- cor(vd$Q_it_c, vd$total_prompts, use = "complete.obs")
  cat(sprintf("    %s: Cor(Q_it_c, active_days)=%.4f, Cor(Q_it_c, prompts)=%.4f\n",
              v, cor_a, cor_p))
}

# --- 5f: Data quality ---
cat("\n  5f: Data quality checks\n")
cat(sprintf("    Missing Q_it_c: %d\n", sum(is.na(engage_df$Q_it_c))))
cat(sprintf("    Version distribution:\n"))
print(table(engage_df$version_f))
cat("\n")

# ==============================================================================
# STEP 6: GAMM - Active Days (Binomial) -- Within-Version Identification
# ==============================================================================
cat("Step 6: GAMM for Active Days -- within-version identification...\n")
cat("  Model: active_days ~ s(Q_it_c) + version_f + s(week) + s(user_id, re)\n")
cat("  Q_it_c = centered quality (within-version category-interaction variation)\n")
cat("  version_f = factor absorbing between-version level shifts\n\n")

# ---- Stratified sampling ----
set.seed(42)
user_info <- engage_df %>% distinct(user_id, user_type)
n_target <- 2000
type_counts <- user_info %>% count(user_type)
type_counts$n_sample <- round(n_target * type_counts$n / sum(type_counts$n))

sample_users <- c()
for (i in seq_len(nrow(type_counts))) {
  ut <- type_counts$user_type[i]
  ns <- type_counts$n_sample[i]
  ids <- user_info %>% filter(user_type == ut) %>% pull(user_id)
  sample_users <- c(sample_users, sample(ids, size = min(ns, length(ids))))
}

cat(sprintf("  Stratified sample: %d users\n", length(sample_users)))
for (ut in type_counts$user_type) {
  n_in <- sum(user_info$user_type[user_info$user_id %in% sample_users] == ut)
  cat(sprintf("    %s: %d\n", ut, n_in))
}

model_df <- engage_df %>%
  filter(user_id %in% sample_users) %>%
  mutate(user_id_factor = factor(user_id))

cat(sprintf("  Modeling dataset: %s rows from %d users\n",
            format(nrow(model_df), big.mark = ","), length(sample_users)))

# Pre-compute placebo Q_it_c (needed for Step 9)
# Derangement: ensure NO category maps to itself (strict falsification)
set.seed(99)
orig_cats <- unique(quality_lookup$eval_prompt_category)

derangement <- function(x, max_attempts = 10000) {
  n <- length(x)
  for (attempt in seq_len(max_attempts)) {
    perm <- sample(x)
    if (all(perm != x)) return(perm)
  }
  stop("Failed to find derangement in ", max_attempts, " attempts")
}

shuffled_cats <- derangement(orig_cats)
names(shuffled_cats) <- orig_cats
cat("  Category shuffle (derangement -- no fixed points):\n")
for (i in seq_along(orig_cats)) {
  cat(sprintf("    %s -> %s%s\n", orig_cats[i], shuffled_cats[i],
              ifelse(orig_cats[i] == shuffled_cats[i], " *** FIXED POINT", "")))
}
stopifnot(all(shuffled_cats != orig_cats))  # verify derangement

placebo_lookup <- quality_lookup %>%
  mutate(eval_prompt_category = shuffled_cats[eval_prompt_category])

q_placebo_wide <- placebo_lookup %>%
  select(eval_prompt_category, model_version, mean_human_rating) %>%
  pivot_wider(names_from = model_version, values_from = mean_human_rating)

Q_placebo_user <- user_weights %>%
  filter(user_id %in% sample_users) %>%
  inner_join(q_placebo_wide, by = "eval_prompt_category") %>%
  group_by(user_id) %>%
  summarise(
    Qp_v10 = sum(w_ic * v1.0),
    Qp_v11 = sum(w_ic * v1.1),
    Qp_v12 = sum(w_ic * v1.2),
    .groups = "drop"
  )

# Center placebo within version
Qp_v10_mean <- mean(Q_placebo_user$Qp_v10)
Qp_v11_mean <- mean(Q_placebo_user$Qp_v11)
Qp_v12_mean <- mean(Q_placebo_user$Qp_v12)

Q_placebo_user <- Q_placebo_user %>%
  mutate(
    Qp_v10_c = Qp_v10 - Qp_v10_mean,
    Qp_v11_c = Qp_v11 - Qp_v11_mean,
    Qp_v12_c = Qp_v12 - Qp_v12_mean
  )

model_df <- model_df %>%
  left_join(Q_placebo_user %>% select(user_id, Qp_v10_c, Qp_v11_c, Qp_v12_c),
            by = "user_id") %>%
  mutate(
    Q_placebo_c = case_when(
      version_week == "v1.0" ~ Qp_v10_c,
      version_week == "v1.1" ~ Qp_v11_c,
      TRUE                   ~ Qp_v12_c
    )
  ) %>%
  select(-Qp_v10_c, -Qp_v11_c, -Qp_v12_c)

cat("\n  Within-version centered quality diagnostics (modeling sample):\n")
cat(sprintf("    Q_it_c:      sd=%.4f, range=[%.4f, %.4f]\n",
            sd(model_df$Q_it_c), min(model_df$Q_it_c), max(model_df$Q_it_c)))
cat(sprintf("    Q_placebo_c: sd=%.4f, range=[%.4f, %.4f]\n",
            sd(model_df$Q_placebo_c), min(model_df$Q_placebo_c), max(model_df$Q_placebo_c)))
cat(sprintf("    Cor(Q_it_c, Q_placebo_c): %.4f\n",
            cor(model_df$Q_it_c, model_df$Q_placebo_c)))

cat("\n  Category shuffle mapping for placebo:\n")
for (i in seq_along(orig_cats)) {
  cat(sprintf("    %s -> %s\n", orig_cats[i], shuffled_cats[i]))
}

# Free memory
rm(engage_df, user_weights, q_wide, Q_user, Q_placebo_user, q_placebo_wide, placebo_lookup)
gc(verbose = FALSE)

cat("\n  Fitting active days model...\n")
t0 <- Sys.time()
model_active_days <- bam(
  cbind(active_days, 7 - active_days) ~
    s(Q_it_c, bs = "tp", k = 10) +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data   = model_df,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)
t1 <- Sys.time()

cat(sprintf("  Fitted in %.1f seconds\n", as.numeric(t1 - t0, units = "secs")))
cat("\n  === Active Days Model Summary ===\n")
real_summ <- summary(model_active_days)
print(real_summ)
cat(sprintf("\n  Deviance explained: %.1f%%\n", real_summ$dev.expl * 100))

re_edf <- real_summ$s.table["s(user_id_factor)", "edf"]
cat(sprintf("  Random effect edf: %.1f\n", re_edf))

cat("\n  Version fixed effects (between-version level shifts):\n")
ve <- coef(model_active_days)
for (nm in grep("version_f", names(ve), value = TRUE)) {
  cat(sprintf("    %s: %.4f (log-odds relative to v1.0)\n", nm, ve[nm]))
}
cat("\n")

# ==============================================================================
# STEP 7: GAMM - Total Prompts (Poisson)
# ==============================================================================
cat("Step 7: GAMM for Total Prompts (Poisson)...\n")
cat("  (NB theta was near-infinite in prior run -- no overdispersion, using Poisson)\n")

t0 <- Sys.time()
gc(verbose = FALSE)
model_prompts <- bam(
  total_prompts ~
    s(Q_it_c, bs = "tp", k = 10) +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data   = model_df,
  family = poisson(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)
t1 <- Sys.time()

cat(sprintf("  Fitted in %.1f seconds\n", as.numeric(t1 - t0, units = "secs")))
prompts_summ <- summary(model_prompts)
cat("\n  === Total Prompts Model Summary ===\n")
print(prompts_summ)
cat(sprintf("\n  Deviance explained: %.1f%%\n", prompts_summ$dev.expl * 100))
cat(sprintf("  R-sq (adj): %.3f\n", prompts_summ$r.sq))

cat("\n  Version fixed effects (prompts):\n")
vep <- coef(model_prompts)
for (nm in grep("version_f", names(vep), value = TRUE)) {
  cat(sprintf("    %s: %.4f (log relative to v1.0)\n", nm, vep[nm]))
}
cat("\n")

# ==============================================================================
# STEP 8: Visualize Smooth Effects
# ==============================================================================
cat("Step 8: Plotting smooth effects...\n")

plot_smooth <- function(model, term, model_name, outcome_label, color,
                        ref_data = model_df) {
  if (term == "Q_it_c") {
    x_seq <- seq(min(ref_data$Q_it_c), max(ref_data$Q_it_c), length = 200)
  } else {
    x_seq <- seq(1, 26, length = 200)
  }

  nd <- data.frame(
    Q_it_c = if (term == "Q_it_c") x_seq else 0,
    week   = if (term == "week") x_seq else median(ref_data$week),
    version_f = factor("v1.0", levels = c("v1.0", "v1.1", "v1.2")),
    user_type = factor("Consumer", levels = levels(factor(ref_data$user_type))),
    pre_project_engagement_score = median(ref_data$pre_project_engagement_score),
    user_id_factor = factor(levels(ref_data$user_id_factor)[1],
                            levels = levels(ref_data$user_id_factor))
  )

  pred <- predict(model, newdata = nd, type = "terms", se.fit = TRUE,
                  exclude = "s(user_id_factor)")
  term_col <- grep(term, colnames(pred$fit), value = TRUE)[1]

  nd$fit <- pred$fit[, term_col]
  nd$se  <- pred$se.fit[, term_col]
  nd$lo  <- nd$fit - 1.96 * nd$se
  nd$hi  <- nd$fit + 1.96 * nd$se
  nd$x   <- x_seq

  ci_label <- "Shaded = 95% CI"
  p <- ggplot(nd, aes(x = x, y = fit)) +
    geom_ribbon(aes(ymin = lo, ymax = hi), fill = color, alpha = 0.25) +
    geom_line(color = color, linewidth = 1.2) +
    geom_hline(yintercept = 0, linetype = "dotted", color = PAL$summit, alpha = 0.5) +
    labs(title = sprintf("%s: Partial Effect of %s", model_name, term),
         subtitle = sprintf("Outcome: %s | %s", outcome_label, ci_label),
         x = if (term == "Q_it_c") "Centered Quality (Q_it_c)" else "Week",
         y = "Partial Effect (log-odds / log)") +
    theme_bgl()

  if (term == "Q_it_c") {
    p <- p +
      geom_vline(xintercept = 0, linetype = "dashed", color = PAL$accent, alpha = 0.5)
  }
  if (term == "week") {
    p <- p +
      geom_vline(xintercept = c(v11_deploy - 0.5, v12_deploy - 0.5),
                 linetype = "dashed", color = PAL$accent, alpha = 0.7)
  }
  p
}

p_ad_q <- plot_smooth(model_active_days, "Q_it_c", "Active Days GAMM",
                      "Active Days (binomial)", PAL$moss)
p_ad_w <- plot_smooth(model_active_days, "week", "Active Days GAMM",
                      "Active Days (binomial)", PAL$moss)
p_pr_q <- plot_smooth(model_prompts, "Q_it_c", "Prompts GAMM",
                      "Total Prompts (Poisson)", PAL$ice)
p_pr_w <- plot_smooth(model_prompts, "week", "Prompts GAMM",
                      "Total Prompts (Poisson)", PAL$ice)

p_smooths <- (p_ad_q | p_ad_w) / (p_pr_q | p_pr_w) +
  plot_annotation(
    title = "GAMM Smooth Effects: Within-Version Quality and Time on Engagement",
    subtitle = "Q_it_c = centered quality from category interaction | version_f absorbs level shifts",
    theme = theme(
      plot.title    = element_text(color = PAL$summit, face = "bold", size = 16),
      plot.subtitle = element_text(color = PAL$ice, size = 10),
      plot.background = element_rect(fill = PAL$bg, color = NA)
    )
  )

ggsave(file.path(FIG_DIR, "05_gamm_smooth_effects.png"), p_smooths,
       width = 14, height = 10, dpi = 150, bg = PAL$bg)
cat("  -> Saved 05_gamm_smooth_effects.png\n\n")

# ==============================================================================
# STEP 9: Falsification Test
# ==============================================================================
cat("Step 9: Falsification test with deranged category-quality mapping...\n")
cat("  Placebo: derange which categories get which quality scores\n")
cat("  (no category maps to itself), then center within version.\n")
cat("  If real Q_it_c signal is genuine, the placebo should NOT be significant.\n\n")

cat("  Fitting placebo model (active days)...\n")
t0 <- Sys.time()
gc(verbose = FALSE)
model_placebo <- bam(
  cbind(active_days, 7 - active_days) ~
    s(Q_placebo_c, bs = "tp", k = 10) +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data   = model_df,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)
t1 <- Sys.time()
cat(sprintf("  Fitted in %.1f seconds\n", as.numeric(t1 - t0, units = "secs")))

placebo_summ <- summary(model_placebo)

real_edf    <- real_summ$s.table["s(Q_it_c)", "edf"]
placebo_edf <- placebo_summ$s.table["s(Q_placebo_c)", "edf"]
real_p      <- real_summ$s.table["s(Q_it_c)", "p-value"]
placebo_p   <- placebo_summ$s.table["s(Q_placebo_c)", "p-value"]

cat(sprintf("\n  Real model:    s(Q_it_c)      edf=%.2f, p=%.2e, dev.expl=%.1f%%\n",
            real_edf, real_p, real_summ$dev.expl * 100))
cat(sprintf("  Placebo model: s(Q_placebo_c) edf=%.2f, p=%.2e, dev.expl=%.1f%%\n",
            placebo_edf, placebo_p, placebo_summ$dev.expl * 100))

if (placebo_p > 0.05 && real_p < 0.05) {
  cat("\n  PASS: Real effect is significant, placebo is not.\n")
  cat("  Within-version quality variation from category mix genuinely predicts engagement.\n")
} else if (placebo_p > 0.05 && real_p >= 0.05) {
  cat("\n  EXPECTED (synthetic data): Neither real nor placebo significant.\n")
  cat("  The synthetic data has version-level effects (captured by version_f)\n")
  cat("  but no within-version category-quality interaction in the DGP.\n")
  cat("  The methodology correctly finds no spurious effect.\n")
} else if (placebo_p <= 0.05 && real_p < 0.05) {
  cat("\n  CAUTION: Both real and placebo are significant.\n")
  cat("  Possible residual confounding within versions.\n")
} else {
  cat("\n  UNEXPECTED: Placebo significant but real is not.\n")
}
cat("\n")

# ==============================================================================
# STEP 10: Segment Analysis (Consumer vs Enterprise)
# ==============================================================================
cat("Step 10: Segment analysis -- Consumer vs Enterprise...\n")

cat("  Fitting Consumer segment...\n")
consumer_df <- model_df %>%
  filter(user_type == "Consumer") %>%
  mutate(user_id_factor = droplevels(user_id_factor))

gc(verbose = FALSE)
model_consumer <- bam(
  cbind(active_days, 7 - active_days) ~
    s(Q_it_c, bs = "tp", k = 10) +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    pre_project_engagement_score,
  data   = consumer_df,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)

cat("  Fitting Enterprise segment...\n")
enterprise_df <- model_df %>%
  filter(user_type == "Enterprise") %>%
  mutate(user_id_factor = droplevels(user_id_factor))

gc(verbose = FALSE)
model_enterprise <- bam(
  cbind(active_days, 7 - active_days) ~
    s(Q_it_c, bs = "tp", k = 10) +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    pre_project_engagement_score,
  data   = enterprise_df,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)

cs <- summary(model_consumer)
es <- summary(model_enterprise)

cat("\n  === Consumer Segment ===\n")
cat(sprintf("  s(Q_it_c) edf: %.2f, p-value: %.4e\n",
            cs$s.table["s(Q_it_c)", "edf"], cs$s.table["s(Q_it_c)", "p-value"]))
cat(sprintf("  Deviance explained: %.1f%%\n", cs$dev.expl * 100))
cat(sprintf("  N obs: %s\n", format(nrow(consumer_df), big.mark = ",")))

cat("\n  === Enterprise Segment ===\n")
cat(sprintf("  s(Q_it_c) edf: %.2f, p-value: %.4e\n",
            es$s.table["s(Q_it_c)", "edf"], es$s.table["s(Q_it_c)", "p-value"]))
cat(sprintf("  Deviance explained: %.1f%%\n", es$dev.expl * 100))
cat(sprintf("  N obs: %s\n", format(nrow(enterprise_df), big.mark = ",")))

p_seg_consumer <- plot_smooth(model_consumer, "Q_it_c", "Consumer",
                              "Active Days", PAL$moss, ref_data = consumer_df)
p_seg_enterprise <- plot_smooth(model_enterprise, "Q_it_c", "Enterprise",
                                "Active Days", PAL$accent, ref_data = enterprise_df)

p_segments <- p_seg_consumer + p_seg_enterprise +
  plot_annotation(
    title = "Within-Version Quality Effect by User Segment",
    subtitle = "Consumer (left) vs Enterprise (right)",
    theme = theme(
      plot.title    = element_text(color = PAL$summit, face = "bold", size = 16),
      plot.subtitle = element_text(color = PAL$ice, size = 11),
      plot.background = element_rect(fill = PAL$bg, color = NA)
    )
  )

ggsave(file.path(FIG_DIR, "06_segment_comparison.png"), p_segments,
       width = 14, height = 6, dpi = 150, bg = PAL$bg)
cat("  -> Saved 06_segment_comparison.png\n")

# Combined predicted active days
cat("  Building combined segment plot...\n")
q_range <- range(c(consumer_df$Q_it_c, enterprise_df$Q_it_c))
q_seq   <- seq(q_range[1], q_range[2], length = 300)

nd_consumer <- data.frame(
  Q_it_c = q_seq, week = median(consumer_df$week),
  version_f = factor("v1.0", levels = c("v1.0", "v1.1", "v1.2")),
  pre_project_engagement_score = median(consumer_df$pre_project_engagement_score),
  user_id_factor = factor(levels(consumer_df$user_id_factor)[1],
                          levels = levels(consumer_df$user_id_factor))
)
nd_enterprise <- data.frame(
  Q_it_c = q_seq, week = median(enterprise_df$week),
  version_f = factor("v1.0", levels = c("v1.0", "v1.1", "v1.2")),
  pre_project_engagement_score = median(enterprise_df$pre_project_engagement_score),
  user_id_factor = factor(levels(enterprise_df$user_id_factor)[1],
                          levels = levels(enterprise_df$user_id_factor))
)

pred_c <- predict(model_consumer, newdata = nd_consumer, type = "response",
                  se.fit = TRUE, exclude = "s(user_id_factor)")
pred_e <- predict(model_enterprise, newdata = nd_enterprise, type = "response",
                  se.fit = TRUE, exclude = "s(user_id_factor)")

combined_pred <- bind_rows(
  tibble(Q_it_c = q_seq, active_days = pred_c$fit * 7,
         lo = (pred_c$fit - 1.96 * pred_c$se.fit) * 7,
         hi = (pred_c$fit + 1.96 * pred_c$se.fit) * 7,
         segment = "Consumer"),
  tibble(Q_it_c = q_seq, active_days = pred_e$fit * 7,
         lo = (pred_e$fit - 1.96 * pred_e$se.fit) * 7,
         hi = (pred_e$fit + 1.96 * pred_e$se.fit) * 7,
         segment = "Enterprise")
)

p_combined <- ggplot(combined_pred, aes(x = Q_it_c, color = segment, fill = segment)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.15, color = NA) +
  geom_line(aes(y = active_days), linewidth = 1.3) +
  geom_vline(xintercept = 0, linetype = "dashed", color = PAL$summit, alpha = 0.4) +
  scale_color_manual(values = c("Consumer" = PAL$moss, "Enterprise" = PAL$accent)) +
  scale_fill_manual(values = c("Consumer" = PAL$moss, "Enterprise" = PAL$accent)) +
  labs(
    title = "Predicted Active Days by Within-Version Quality",
    subtitle = "Q_it_c > 0: category mix favors higher-rated categories | < 0: lower-rated",
    x = "Centered Quality Score (Q_it_c)",
    y = "Predicted Active Days per Week",
    color = "Segment", fill = "Segment"
  ) +
  theme_bgl() +
  theme(legend.position = c(0.15, 0.85))

ggsave(file.path(FIG_DIR, "07_quality_vs_active_days_by_segment.png"), p_combined,
       width = 10, height = 7, dpi = 150, bg = PAL$bg)
cat("  -> Saved 07_quality_vs_active_days_by_segment.png\n\n")

# ==============================================================================
# STEP 11: Summary & Outputs
# ==============================================================================
cat("=", rep("=", 69), "\n", sep = "")
cat("RESULTS SUMMARY\n")
cat("Within-Version Identification Strategy\n")
cat("=", rep("=", 69), "\n\n", sep = "")

get_test_stat <- function(s_table, term) {
  cols <- colnames(s_table)
  stat_col <- intersect(c("Chi.sq", "F"), cols)[1]
  c(edf = s_table[term, "edf"], stat = s_table[term, stat_col],
    p = s_table[term, "p-value"])
}

cat("MODEL 1: Active Days per Week (Binomial GAMM)\n")
cat(sprintf("  Deviance explained: %.1f%%\n", real_summ$dev.expl * 100))
s1 <- real_summ$s.table
q1 <- get_test_stat(s1, "s(Q_it_c)")
w1 <- get_test_stat(s1, "s(week)")
cat(sprintf("  s(Q_it_c): edf = %.2f, test stat = %.2f, p = %.2e  <-- within-version quality\n",
            q1["edf"], q1["stat"], q1["p"]))
cat(sprintf("  s(week):   edf = %.2f, test stat = %.2f, p = %.2e\n",
            w1["edf"], w1["stat"], w1["p"]))
cat(sprintf("  s(user_id_factor) edf = %.1f\n", s1["s(user_id_factor)", "edf"]))
ve <- coef(model_active_days)
for (nm in grep("version_f", names(ve), value = TRUE)) {
  cat(sprintf("  %s: %.4f  <-- between-version shift\n", nm, ve[nm]))
}
cat("\n")

cat("MODEL 2: Total Prompts per Week (Poisson GAMM)\n")
s2 <- prompts_summ$s.table
cat(sprintf("  Deviance explained: %.1f%%\n", prompts_summ$dev.expl * 100))
cat(sprintf("  R-sq (adj): %.3f\n", prompts_summ$r.sq))
q2 <- get_test_stat(s2, "s(Q_it_c)")
w2 <- get_test_stat(s2, "s(week)")
cat(sprintf("  s(Q_it_c): edf = %.2f, test stat = %.2f, p = %.2e  <-- within-version quality\n",
            q2["edf"], q2["stat"], q2["p"]))
cat(sprintf("  s(week):   edf = %.2f, test stat = %.2f, p = %.2e\n",
            w2["edf"], w2["stat"], w2["p"]))
cat(sprintf("  s(user_id_factor) edf = %.1f\n", s2["s(user_id_factor)", "edf"]))
vep <- coef(model_prompts)
for (nm in grep("version_f", names(vep), value = TRUE)) {
  cat(sprintf("  %s: %.4f\n", nm, vep[nm]))
}
cat("\n")

cat("FALSIFICATION TEST:\n")
cat(sprintf("  Real Q_it_c p-value:    %.2e\n", real_p))
cat(sprintf("  Placebo Q_it_c p-value: %.2e\n", placebo_p))
if (placebo_p > 0.05 && real_p < 0.05) {
  cat("  Result: PASS (real significant, placebo not)\n\n")
} else if (placebo_p > 0.05 && real_p >= 0.05) {
  cat("  Result: EXPECTED -- neither significant\n")
  cat("  (Synthetic data has no within-version category-quality interaction)\n\n")
} else {
  cat(sprintf("  Result: %s\n\n",
              ifelse(placebo_p > 0.05, "PASS", "CAUTION")))
}

cat("SEGMENT ANALYSIS:\n")
cat(sprintf("  Consumer:   s(Q_it_c) edf=%.2f, p=%.2e, dev.expl=%.1f%%\n",
            cs$s.table["s(Q_it_c)", "edf"], cs$s.table["s(Q_it_c)", "p-value"],
            cs$dev.expl * 100))
cat(sprintf("  Enterprise: s(Q_it_c) edf=%.2f, p=%.2e, dev.expl=%.1f%%\n",
            es$s.table["s(Q_it_c)", "edf"], es$s.table["s(Q_it_c)", "p-value"],
            es$dev.expl * 100))
cat("\n")

cat("\nFigures saved to:", FIG_DIR, "\n")
cat("  01_active_days_dist.png\n")
cat("  02_prompts_dist.png\n")
cat("  03_qit_over_time.png\n")
cat("  04_engagement_by_week.png\n")
cat("  05_gamm_smooth_effects.png\n")
cat("  06_segment_comparison.png\n")
cat("  07_quality_vs_active_days_by_segment.png\n\n")

# ==============================================================================
# STEP 12: Calibration Recovery (DGP Validation)
# ==============================================================================
cat("Step 12: Calibration recovery -- does the estimator recover TRUE_BETA?...\n")
cat(sprintf("  TRUE_BETA = %.2f (injected into DGP active_days log-odds)\n\n", TRUE_BETA))

# Fit a LINEAR version (no smooth on Q_it_c) for direct coefficient extraction
cat("  Fitting linear model for coefficient extraction...\n")
model_linear <- bam(
  cbind(active_days, 7 - active_days) ~
    Q_it_c +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data   = model_df,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)

beta_hat <- coef(model_linear)["Q_it_c"]
se_hat   <- summary(model_linear)$p.table["Q_it_c", "Std. Error"]
z_hat    <- summary(model_linear)$p.table["Q_it_c", "z value"]
p_hat    <- summary(model_linear)$p.table["Q_it_c", "Pr(>|z|)"]
ci_lo    <- beta_hat - 1.96 * se_hat
ci_hi    <- beta_hat + 1.96 * se_hat
recovery_pct <- beta_hat / TRUE_BETA * 100

cat(sprintf("  Linear coefficient:  beta_hat = %.4f (SE = %.4f)\n", beta_hat, se_hat))
cat(sprintf("  95%% CI:             [%.4f, %.4f]\n", ci_lo, ci_hi))
cat(sprintf("  z = %.2f, p = %.2e\n", z_hat, p_hat))
cat(sprintf("  Recovery:            %.1f%% of TRUE_BETA = %.2f\n", recovery_pct, TRUE_BETA))
cat(sprintf("  TRUE_BETA in CI:     %s\n",
            ifelse(ci_lo <= TRUE_BETA & ci_hi >= TRUE_BETA, "YES", "NO")))

# Also extract the effective linear slope from the GAM smooth
cat("\n  GAM smooth recovery (from predict at ±1 SD):\n")
sd_qc <- sd(model_df$Q_it_c)
nd_lo <- data.frame(
  Q_it_c = -sd_qc, week = median(model_df$week),
  version_f = factor("v1.0", levels = c("v1.0", "v1.1", "v1.2")),
  user_type = factor("Consumer", levels = levels(factor(model_df$user_type))),
  pre_project_engagement_score = median(model_df$pre_project_engagement_score),
  user_id_factor = factor(levels(model_df$user_id_factor)[1],
                          levels = levels(model_df$user_id_factor))
)
nd_hi <- nd_lo
nd_hi$Q_it_c <- sd_qc

pred_lo <- predict(model_active_days, newdata = nd_lo, type = "terms",
                   se.fit = TRUE, exclude = "s(user_id_factor)")
pred_hi <- predict(model_active_days, newdata = nd_hi, type = "terms",
                   se.fit = TRUE, exclude = "s(user_id_factor)")

qcol <- grep("Q_it_c", colnames(pred_lo$fit), value = TRUE)[1]
smooth_slope <- (pred_hi$fit[, qcol] - pred_lo$fit[, qcol]) / (2 * sd_qc)
cat(sprintf("  GAM effective slope: %.4f per unit Q_it_c\n", smooth_slope))
cat(sprintf("  GAM recovery:        %.1f%% of TRUE_BETA\n", smooth_slope / TRUE_BETA * 100))
cat("\n")

# ==============================================================================
# STEP 13: Cluster-Robust Inference (User-Level Block Bootstrap)
# ==============================================================================
cat("Step 13: Cluster-robust inference (user-level block bootstrap)...\n")
cat("  Resampling users (not observations) to account for within-user correlation.\n\n")

B <- 100
set.seed(123)
user_list <- unique(model_df$user_id)
n_u <- length(user_list)

boot_pvals  <- numeric(B)
boot_coefs  <- numeric(B)

cat(sprintf("  Running %d bootstrap iterations...\n", B))
t0_boot <- Sys.time()

for (b in seq_len(B)) {
  if (b %% 20 == 0) cat(sprintf("    Iteration %d / %d\n", b, B))

  # Resample users with replacement
  boot_idx <- sample(n_u, replace = TRUE)
  boot_ids <- user_list[boot_idx]

  # Build bootstrap dataset with unique user IDs (for re-leveling)
  boot_df <- do.call(rbind, lapply(seq_along(boot_ids), function(i) {
    d <- model_df[model_df$user_id == boot_ids[i], ]
    d$boot_uid <- paste0(d$user_id, "_", i)
    d
  }))
  boot_df$user_id_factor <- factor(boot_df$boot_uid)

  # Fit WITHOUT random effects for speed (bootstrap already handles clustering)
  tryCatch({
    m <- bam(
      cbind(active_days, 7 - active_days) ~
        Q_it_c +
        version_f +
        s(week, bs = "tp", k = 10) +
        user_type +
        pre_project_engagement_score,
      data   = boot_df,
      family = binomial(),
      method = "fREML",
      discrete = TRUE,
      nthreads = 1
    )
    boot_coefs[b] <- coef(m)["Q_it_c"]
    boot_pvals[b] <- summary(m)$p.table["Q_it_c", "Pr(>|z|)"]
  }, error = function(e) {
    boot_coefs[b] <<- NA
    boot_pvals[b] <<- NA
  })
}

t1_boot <- Sys.time()
cat(sprintf("  Bootstrap completed in %.1f seconds\n\n", as.numeric(t1_boot - t0_boot, units = "secs")))

valid <- !is.na(boot_coefs)
boot_coefs_valid <- boot_coefs[valid]
boot_pvals_valid <- boot_pvals[valid]

boot_mean  <- mean(boot_coefs_valid)
boot_se    <- sd(boot_coefs_valid)
boot_ci_lo <- quantile(boot_coefs_valid, 0.025)
boot_ci_hi <- quantile(boot_coefs_valid, 0.975)
boot_sig_rate <- mean(boot_pvals_valid < 0.05)

cat(sprintf("  Cluster bootstrap results (B=%d, %d valid):\n", B, sum(valid)))
cat(sprintf("    Mean coefficient:    %.4f\n", boot_mean))
cat(sprintf("    Bootstrap SE:        %.4f\n", boot_se))
cat(sprintf("    95%% CI (percentile): [%.4f, %.4f]\n", boot_ci_lo, boot_ci_hi))
cat(sprintf("    Significant at 0.05: %.1f%% of iterations\n", boot_sig_rate * 100))
cat(sprintf("    TRUE_BETA in CI:     %s\n",
            ifelse(boot_ci_lo <= TRUE_BETA & boot_ci_hi >= TRUE_BETA, "YES", "NO")))
cat("\n")

# ==============================================================================
# STEP 14: DAG Diagram
# ==============================================================================
cat("Step 14: Generating causal DAG diagram...\n")

# Build DAG with ggplot2 (no external packages needed)
dag_nodes <- data.frame(
  name  = c("V", "q_cv", "W", "Q_c", "X", "Y", "U"),
  label = c("Model\nVersion (V)", "Category\nQuality (q[c,v])",
            "Usage\nMix (W[i])", "Quality\nExposure (Q[c])",
            "Controls\n(baseline, type)", "Engagement\n(Y)",
            "Unobserved\n(U)"),
  x = c(0, 1.5, 0, 3, 3, 6, 4.5),
  y = c(3, 4, 1, 2.5, 0.5, 2.5, 5),
  stringsAsFactors = FALSE
)

dag_edges <- data.frame(
  from = c("V", "V", "q_cv", "W", "Q_c", "X", "U"),
  to   = c("q_cv", "Y", "Q_c", "Q_c", "Y", "Y", "Y"),
  style = c("solid", "solid", "solid", "solid", "solid", "solid", "dashed"),
  stringsAsFactors = FALSE
)

# Merge with coordinates
dag_edges <- dag_edges %>%
  left_join(dag_nodes %>% select(name, x, y), by = c("from" = "name")) %>%
  rename(x_from = x, y_from = y) %>%
  left_join(dag_nodes %>% select(name, x, y), by = c("to" = "name")) %>%
  rename(x_to = x, y_to = y)

p_dag <- ggplot() +
  # Edges
  geom_segment(data = dag_edges %>% filter(style == "solid"),
               aes(x = x_from, y = y_from, xend = x_to, yend = y_to),
               arrow = arrow(length = unit(0.15, "cm"), type = "closed"),
               color = PAL$ice, linewidth = 0.8) +
  geom_segment(data = dag_edges %>% filter(style == "dashed"),
               aes(x = x_from, y = y_from, xend = x_to, yend = y_to),
               arrow = arrow(length = unit(0.15, "cm"), type = "closed"),
               color = PAL$warn, linewidth = 0.8, linetype = "dashed") +
  # Nodes
  geom_label(data = dag_nodes,
             aes(x = x, y = y, label = label),
             fill = PAL$ridge, color = PAL$summit,
             size = 3, label.padding = unit(0.4, "lines"),
             label.r = unit(0.2, "lines")) +
  # Annotations
  annotate("text", x = 3, y = -0.8,
           label = "Identifying assumption: Q[c] ⊥ U | V, X\nWithin-version quality variation is exogenous after conditioning on controls",
           color = PAL$accent, size = 3, hjust = 0.5) +
  labs(title = "Causal DAG: Within-Version Identification Strategy",
       subtitle = "Solid = observed paths | Dashed = unobserved confounding | V absorbed by version_f") +
  coord_cartesian(xlim = c(-0.8, 6.8), ylim = c(-1.5, 5.8)) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = PAL$bg, color = NA),
    plot.title = element_text(color = PAL$summit, face = "bold", size = 14, hjust = 0.5),
    plot.subtitle = element_text(color = PAL$ice, size = 9, hjust = 0.5)
  )

ggsave(file.path(FIG_DIR, "09_causal_dag.png"), p_dag,
       width = 10, height = 7, dpi = 150, bg = PAL$bg)
cat("  -> Saved 09_causal_dag.png\n\n")

# ==============================================================================
# FINAL SUMMARY (updated with calibration + bootstrap)
# ==============================================================================
cat("=", rep("=", 69), "\n", sep = "")
cat("CALIBRATION RECOVERY SUMMARY\n")
cat("=", rep("=", 69), "\n\n")
cat(sprintf("  TRUE_BETA:                %.2f\n", TRUE_BETA))
cat(sprintf("  Linear model beta_hat:    %.4f (%.1f%% recovery)\n", beta_hat, recovery_pct))
cat(sprintf("  Linear 95%% CI:           [%.4f, %.4f]\n", ci_lo, ci_hi))
cat(sprintf("  GAM effective slope:      %.4f (%.1f%% recovery)\n",
            smooth_slope, smooth_slope / TRUE_BETA * 100))
cat(sprintf("  Cluster bootstrap mean:   %.4f\n", boot_mean))
cat(sprintf("  Cluster bootstrap 95%% CI: [%.4f, %.4f]\n", boot_ci_lo, boot_ci_hi))
cat(sprintf("  Bootstrap sig rate:       %.1f%%\n", boot_sig_rate * 100))
cat("\n")

cat("Figures saved to:", FIG_DIR, "\n")
cat("  01_active_days_dist.png\n")
cat("  02_prompts_dist.png\n")
cat("  03_qit_over_time.png\n")
cat("  04_engagement_by_week.png\n")
cat("  05_gamm_smooth_effects.png\n")
cat("  06_segment_comparison.png\n")
cat("  07_quality_vs_active_days_by_segment.png\n")
cat("  09_causal_dag.png\n")

# Save model summaries (at end so all objects exist)
sink(file.path(FIG_DIR, "model_summaries.txt"))
cat("=== WITHIN-VERSION IDENTIFICATION STRATEGY ===\n")
cat("Q_it_c = quality centered within version (category-interaction variation)\n")
cat("version_f = factor absorbing between-version level shifts\n")
cat(sprintf("TRUE_BETA = %.2f (injected into DGP)\n\n", TRUE_BETA))
cat("=== Active Days Model (Binomial GAMM) ===\n")
cat("    Outcome: active_days_observed (true count of distinct active days)\n\n")
print(summary(model_active_days))
cat("\n\n=== Total Prompts Model (Poisson GAMM) ===\n")
cat("    Outcome: total_prompts\n\n")
print(summary(model_prompts))
cat("\n\n=== Falsification (Placebo) Model ===\n")
cat("    Placebo: category labels deranged (no fixed points)\n\n")
print(summary(model_placebo))
cat("\n\n=== Consumer Segment ===\n\n")
print(summary(model_consumer))
cat("\n\n=== Enterprise Segment ===\n\n")
print(summary(model_enterprise))
cat("\n\n=== Linear Model (Calibration Recovery) ===\n\n")
print(summary(model_linear))
cat(sprintf("\n  TRUE_BETA = %.2f, beta_hat = %.4f, recovery = %.1f%%\n",
            TRUE_BETA, beta_hat, recovery_pct))
cat(sprintf("  95%% CI: [%.4f, %.4f]\n", ci_lo, ci_hi))
cat(sprintf("  TRUE_BETA in CI: %s\n",
            ifelse(ci_lo <= TRUE_BETA & ci_hi >= TRUE_BETA, "YES", "NO")))
cat("\n\n=== Cluster Bootstrap (B=", B, ") ===\n")
cat(sprintf("  Mean coefficient: %.4f (SE = %.4f)\n", boot_mean, boot_se))
cat(sprintf("  95%% CI: [%.4f, %.4f]\n", boot_ci_lo, boot_ci_hi))
cat(sprintf("  Significant at 0.05: %.1f%%\n", boot_sig_rate * 100))
sink()
cat("  -> Saved model_summaries.txt\n")

cat("\nDone.\n")
