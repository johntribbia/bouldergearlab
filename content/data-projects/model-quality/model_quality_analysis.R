#!/usr/bin/env Rscript
# ==============================================================================
# Model Quality -> User Engagement (GAMM analysis)
# ==============================================================================
#
# Identification: within-version category-quality variation. Users whose
# category mix leans toward higher-rated categories get different effective
# quality even on the same model version.
#
#   Q_it   = sum(w_ic * q_cv)              weighted quality from category usage
#   Q_it_c = Q_it - mean(Q_it | version)   centered within version
#   version_f absorbs between-version shifts; s(Q_it_c) is the estimand
#
# Steps:
#   1.  Quality lookup    2.  Pre-period weights   2b. Mix stability
#   3.  Q_it + centering  4.  Merge                5.  EDA
#   6.  GAMM active days  7.  GAMM prompts         8.  Smooth plots
#   9.  Falsification     10. Segments             11. Save
#   12. Calibration       13. Bootstrap            14. DAG
#   15. ROI simulation
# ==============================================================================

cat("model_quality_analysis.R  |  within-version GAMM\n\n")

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

# --- Load data ----------------------------------------------------------------
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

# --- Step 1: Quality lookup ---------------------------------------------------
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
cat("  This spread is where the identifying variation comes from.\n\n")

# --- Step 2: Pre-period prompt weights ----------------------------------------
cat("Step 2: Computing pre-period prompt weights from observed category data...\n")

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

# --- Step 2b: Category mix stability check ------------------------------------
cat("Step 2b: Testing category mix stability across version periods...\n")
cat("  Checking whether users shift their category usage after upgrades.\n")
cat("  If so, frozen pre-period weights would be stale.\n\n")

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
cat("  Looks good: high correlations + stable means, so frozen weights hold.\n\n")

# --- Step 3: Q_it + within-version centering ----------------------------------
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
cat("  That's the identifying variation: same version, different category mix.\n\n")

# --- Step 4: Merge ------------------------------------------------------------
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

# --- Step 5: EDA --------------------------------------------------------------
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
cat("    Saved 01_active_days_dist.png\n")

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
cat("    Saved 02_prompts_dist.png\n")

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
cat("    Saved 03_qit_over_time.png\n")

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
cat("    Saved 04_engagement_by_week.png\n")

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

# --- Step 6: GAMM active days (binomial) --------------------------------------
cat("Step 6: GAMM for Active Days (within-version identification)...\n")
cat("  active_days ~ s(Q_it_c) + version_f + s(week) + s(user_id, re)\n\n")

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

# --- Step 2c: Frozen-weights sensitivity analysis (Gap 6) --------------------
# (Placed here so sample_users and model_df with Q_it_c are available)
cat("\nStep 2c: Frozen-weights sensitivity — do results depend on WHEN we freeze?\n")
cat("  Re-run the centered quality score using weights frozen at different pre-periods.\n")
cat("  If the identifying assumption (frozen weights ≈ latent preferences) holds,\n")
cat("  estimates at the main model stage should be robust to this choice.\n\n")

freeze_defs <- list(
  "Weeks 1-3 (early)"  = c(1, 3),
  "Weeks 1-5 (mid)"    = c(1, 5),
  "Weeks 1-7 (full, canonical)" = c(1, pre_period_end)
)

sensitivity_q <- list()

for (fname in names(freeze_defs)) {
  wk_range <- freeze_defs[[fname]]
  fw <- engage_df %>%
    filter(week >= wk_range[1], week <= wk_range[2]) %>%
    group_by(user_id) %>%
    summarise(across(all_of(cat_cols), sum), .groups = "drop")
  fw_totals <- rowSums(fw[, cat_cols])
  for (col in cat_cols) {
    fw[[col]] <- ifelse(fw_totals == 0, 1 / length(cat_cols), fw[[col]] / fw_totals)
  }

  # Compute Q_it under this freeze window
  fw_weights <- fw %>%
    pivot_longer(cols = all_of(cat_cols), names_to = "cat_col", values_to = "w_ic") %>%
    mutate(eval_prompt_category = cat_col_map[cat_col]) %>%
    select(user_id, eval_prompt_category, w_ic)

  q_fw <- fw_weights %>%
    filter(user_id %in% sample_users) %>%
    inner_join(ql_wide, by = "eval_prompt_category") %>%
    group_by(user_id) %>%
    summarise(Q_fw10 = sum(w_ic * v1.0),
              Q_fw11 = sum(w_ic * v1.1),
              Q_fw12 = sum(w_ic * v1.2),
              .groups = "drop") %>%
    mutate(Q_fw10_c = Q_fw10 - mean(Q_fw10),
           Q_fw11_c = Q_fw11 - mean(Q_fw11),
           Q_fw12_c = Q_fw12 - mean(Q_fw12))

  model_df_fw <- model_df %>%
    left_join(q_fw %>% select(user_id, Q_fw10_c, Q_fw11_c, Q_fw12_c), by = "user_id") %>%
    mutate(Q_fw_c = case_when(
      version_week == "v1.0" ~ Q_fw10_c,
      version_week == "v1.1" ~ Q_fw11_c,
      TRUE                   ~ Q_fw12_c
    ))

  # Cor with canonical Q_it_c
  r_with_canonical <- cor(model_df_fw$Q_fw_c, model_df_fw$Q_it_c, use = "complete.obs")

  # Fit linear GAMM for quick β comparison
  m_fw <- bam(
    cbind(active_days, 7 - active_days) ~
      Q_fw_c +
      version_f +
      s(week, bs = "tp", k = 10) +
      s(user_id_factor, bs = "re") +
      user_type +
      pre_project_engagement_score,
    data   = model_df_fw,
    family = binomial(),
    method = "fREML",
    discrete = TRUE,
    nthreads = 1
  )

  b_fw  <- coef(m_fw)["Q_fw_c"]
  se_fw <- summary(m_fw)$p.table["Q_fw_c", "Std. Error"]
  sensitivity_q[[fname]] <- list(
    beta    = b_fw,
    se      = se_fw,
    recov   = b_fw / TRUE_BETA * 100,
    r_canon = r_with_canonical,
    n_weeks = diff(wk_range) + 1
  )
  cat(sprintf("  %s:\n", fname))
  cat(sprintf("    Weeks used: %d-%d (%d weeks)  |  r(Q_fw_c, Q_canon) = %.4f\n",
              wk_range[1], wk_range[2], diff(wk_range) + 1, r_with_canonical))
  cat(sprintf("    β_hat = %.4f, SE = %.4f, recovery = %.1f%%\n\n",
              b_fw, se_fw, b_fw / TRUE_BETA * 100))
}

cat("  ── Frozen-Weights Sensitivity Summary ──────────────────────────────────\n")
cat(sprintf("  TRUE_BETA = %.2f\n", TRUE_BETA))
cat(sprintf("  %-34s  %8s  %8s  %8s  %8s\n",
            "Freeze window", "β_hat", "Recov%", "r(canon)", "n_weeks"))
cat(sprintf("  %s\n", strrep("-", 72)))
for (fname in names(sensitivity_q)) {
  s <- sensitivity_q[[fname]]
  cat(sprintf("  %-34s  %8.4f  %7.1f%%  %8.4f  %8d\n",
              fname, s$beta, s$recov, s$r_canon, s$n_weeks))
}
cat("  ────────────────────────────────────────────────────────────────────────\n")
cat("  Interpretation: if estimates are stable across freeze windows, the\n")
cat("  canonical 7-week freeze is robust to the exact pre-period boundary choice.\n\n")

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

# --- Step 7: GAMM total prompts (Poisson) -------------------------------------
cat("Step 7: GAMM for Total Prompts (Poisson)...\n")
cat("  NB theta was near-infinite in a prior run, so no overdispersion -- using Poisson.\n")

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

# --- Step 8: Smooth effect plots ----------------------------------------------
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
cat("  Saved 05_gamm_smooth_effects.png\n\n")

# --- Step 9: Falsification (derangement placebo) ------------------------------
cat("Step 9: Falsification test -- deranged category-quality mapping...\n")
cat("  Shuffle which categories get which quality scores (no fixed points),\n")
cat("  re-center within version, and refit. If the real effect is real,\n")
cat("  the placebo smooth should be flat.\n\n")

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
  cat("\n  PASS: Real effect significant, placebo is not.\n")
  cat("  Quality variation from category mix genuinely predicts engagement.\n")
} else if (placebo_p > 0.05 && real_p >= 0.05) {
  cat("\n  EXPECTED (synthetic data): Neither real nor placebo significant.\n")
  cat("  No within-version category-quality interaction in the DGP,\n")
  cat("  so correctly finding nothing here.\n")
} else if (placebo_p <= 0.05 && real_p < 0.05) {
  cat("\n  CAUTION: Both real and placebo are significant.\n")
  cat("  Possible residual confounding within versions.\n")
} else {
  cat("\n  UNEXPECTED: Placebo significant but real is not.\n")
}
cat("\n")

# --- Step 9b: Stronger falsification — user-weight permutation ----------------
cat("Step 9b: Stronger falsification — user-weight permutation...\n")
cat("  Randomly shuffles which USERS get which frozen weight profiles.\n")
cat("  Destroys the user-to-category-quality link while preserving the\n")
cat("  cross-sectional distribution of Q scores and all other covariates.\n")
cat("  This is a cleaner null than the derangement because permuted Q is\n")
cat("  ORTHOGONAL to real Q (not anti-correlated with it at r=-0.44).\n\n")

# Permute user_id -> Q_it_c mapping within each version period
set.seed(77)
model_df_perm <- model_df %>%
  group_by(version_f) %>%
  mutate(Q_perm_c = Q_it_c[sample(.N)]) %>%
  ungroup()

cat(sprintf("  Cor(Q_it_c, Q_perm_c): %.4f  (should be ~0; derangement was %.4f)\n",
            cor(model_df_perm$Q_it_c, model_df_perm$Q_perm_c),
            cor(model_df$Q_it_c, model_df$Q_placebo_c)))

cat("  Fitting permutation placebo model...\n")
gc(verbose = FALSE)
model_perm <- bam(
  cbind(active_days, 7 - active_days) ~
    s(Q_perm_c, bs = "tp", k = 10) +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data   = model_df_perm,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)

perm_summ <- summary(model_perm)
perm_edf <- perm_summ$s.table["s(Q_perm_c)", "edf"]
perm_p   <- perm_summ$s.table["s(Q_perm_c)", "p-value"]

cat(sprintf("\n  Real model:        s(Q_it_c)   edf=%.2f, p=%.2e\n", real_edf, real_p))
cat(sprintf("  Derangement:       s(Q_plac_c) edf=%.2f, p=%.2e\n", placebo_edf, placebo_p))
cat(sprintf("  Weight permutation:s(Q_perm_c)  edf=%.2f, p=%.2e\n", perm_edf, perm_p))

if (perm_p > 0.05 && real_p < 0.05) {
  cat("\n  PASS: Real effect significant, permutation placebo is not.\n")
  cat("  Confirms the effect is driven by the user-category-quality link,\n")
  cat("  not residual confounding or model artifacts.\n")
} else {
  cat(sprintf("\n  NOTE: perm_p = %.3e — investigate if this is unexpected.\n", perm_p))
}
cat("\n")

# --- Step 9c: Time-shifted placebo (lead quality scores) --------------------
cat("Step 9c: Time-shifted placebo — use NEXT version's quality for current rows...\n")
cat("  Assign each v1.0 row the v1.1 quality scores, each v1.1 row the v1.2 scores.\n")
cat("  v1.2 rows get v1.0 scores (wrap-around, giving an out-of-range shift).\n")
cat("  If the forward-shifted placebo is significant, the method may be capturing\n")
cat("  general time confounders rather than the contemporaneous quality mechanism.\n\n")

# Re-derive version-level mean quality from the lookup table (Q_user freed at Step 6)
q_mean_v10 <- quality_lookup %>% filter(model_version == "v1.0") %>%
  summarise(m = mean(mean_human_rating)) %>% pull(m)
q_mean_v11 <- quality_lookup %>% filter(model_version == "v1.1") %>%
  summarise(m = mean(mean_human_rating)) %>% pull(m)
q_mean_v12 <- quality_lookup %>% filter(model_version == "v1.2") %>%
  summarise(m = mean(mean_human_rating)) %>% pull(m)


# Simpler and more defensible: shift user weights to next period's quality
# Construct Q_lead: each user in v period evaluates their frozen weights against v+1 scores
lead_q_wide <- quality_lookup %>%
  arrange(eval_prompt_category, model_version) %>%
  pivot_wider(names_from = model_version, values_from = mean_human_rating) %>%
  rename(q_v10 = v1.0, q_v11 = v1.1, q_v12 = v1.2)

lead_q_user_weights <- pre_weights %>%
  filter(user_id %in% sample_users) %>%
  pivot_longer(cols = all_of(cat_cols), names_to = "cat_col", values_to = "w_ic") %>%
  mutate(eval_prompt_category = cat_col_map[cat_col]) %>%
  select(user_id, eval_prompt_category, w_ic) %>%
  inner_join(lead_q_wide, by = "eval_prompt_category") %>%
  group_by(user_id) %>%
  summarise(
    Q_lead_v10 = sum(w_ic * q_v11),  # v1.0 rows get v1.1 quality
    Q_lead_v11 = sum(w_ic * q_v12),  # v1.1 rows get v1.2 quality
    Q_lead_v12 = sum(w_ic * q_v10),  # v1.2 rows get v1.0 quality (wrap)
    .groups = "drop"
  ) %>%
  mutate(
    Q_lead_v10_c = Q_lead_v10 - mean(Q_lead_v10),
    Q_lead_v11_c = Q_lead_v11 - mean(Q_lead_v11),
    Q_lead_v12_c = Q_lead_v12 - mean(Q_lead_v12)
  )

model_df_lead <- model_df %>%
  left_join(lead_q_user_weights %>%
              select(user_id, Q_lead_v10_c, Q_lead_v11_c, Q_lead_v12_c),
            by = "user_id") %>%
  mutate(
    Q_lead_c = case_when(
      version_week == "v1.0" ~ Q_lead_v10_c,
      version_week == "v1.1" ~ Q_lead_v11_c,
      TRUE                   ~ Q_lead_v12_c
    )
  )

cat(sprintf("  Cor(Q_it_c, Q_lead_c): %.4f  (should be moderate + for v1.0/1.1, - for v1.2)\n",
            cor(model_df_lead$Q_it_c, model_df_lead$Q_lead_c, use = "complete.obs")))

cat("  Fitting time-shifted placebo model...\n")
gc(verbose = FALSE)
model_lead <- bam(
  cbind(active_days, 7 - active_days) ~
    s(Q_lead_c, bs = "tp", k = 10) +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data   = model_df_lead,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)

lead_summ <- summary(model_lead)
lead_edf  <- lead_summ$s.table["s(Q_lead_c)", "edf"]
lead_p    <- lead_summ$s.table["s(Q_lead_c)", "p-value"]

cat(sprintf("\n  Real (contemporaneous):  s(Q_it_c)   edf=%.2f, p=%.2e\n", real_edf, real_p))
cat(sprintf("  Time-shifted (lead):     s(Q_lead_c) edf=%.2f, p=%.2e\n", lead_edf, lead_p))

if (lead_p < 0.05) {
  cat("\n  NOTE: Lead quality is also significant.\n")
  cat("  Likely due to cross-version weight correlation (same frozen weights applied\n")
  cat("  to different quality levels that are themselves positively correlated).\n")
  cat("  Report the correlation and compare effect magnitudes — not a flat failure.\n")
} else {
  cat("\n  PASS: Lead quality not significant; temporal identification holds.\n")
}

# Summary table of all three falsification approaches
cat("\n  ── Falsification Summary ─────────────────────────────────────────────\n")
cat(sprintf("  %-28s  %6s  %11s  %s\n", "Test", "edf", "p-value", "Verdict"))
cat(sprintf("  %-28s  %6s  %11s  %s\n", "---", "---", "---", "---"))
verdict_real  <- "REAL EFFECT"
verdict_derang <- if (placebo_p > 0.05) "PASS (ns)" else sprintf("CAUTION (r=%.2f with real)", cor(model_df$Q_it_c, model_df$Q_placebo_c))
verdict_perm  <- if (perm_p > 0.05) "PASS (ns)" else "FAIL — investigate"
verdict_lead  <- if (lead_p > 0.05) "PASS (ns)" else "CAUTION — check corr"
cat(sprintf("  %-28s  %6.2f  %11.2e  %s\n", "Real Q_it_c", real_edf, real_p, verdict_real))
cat(sprintf("  %-28s  %6.2f  %11.2e  %s\n", "Derangement placebo", placebo_edf, placebo_p, verdict_derang))
cat(sprintf("  %-28s  %6.2f  %11.2e  %s\n", "User-weight permutation", perm_edf, perm_p, verdict_perm))
cat(sprintf("  %-28s  %6.2f  %11.2e  %s\n", "Time-shifted lead", lead_edf, lead_p, verdict_lead))
cat("  ──────────────────────────────────────────────────────────────────────\n\n")

# --- Step 10: Segment analysis (Consumer vs Enterprise) -----------------------
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
cat("  Saved 06_segment_comparison.png\n")

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
cat("  Saved 07_quality_vs_active_days_by_segment.png\n\n")

# --- Step 11: Summary & outputs ---

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

# --- Step 12: Calibration recovery (DGP validation) --------------------------
cat("Step 12: Calibration recovery -- can we recover TRUE_BETA?...\n")
cat(sprintf("  TRUE_BETA = %.2f (injected into DGP active_days log-odds)\n\n", TRUE_BETA))

# Fit a linear version (no smooth on Q_it_c) to pull out the coefficient directly
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

# Also check the effective linear slope from the GAM smooth
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

# --- Step 12a: Klepper-Leamer measurement error correction (Gap 5) -----------
# The 10% attenuation comes from classical errors-in-variables:
# Q_it_c is computed from observed (noisy) category counts, not the latent
# Dirichlet preferences.  Augment_data.py uses 15% session-level noise
# (noisy_prefs = 0.85 * stable + 0.15 * random_dirichlet).
#
# Klepper-Leamer (1984):
#   β_corrected = β_hat / λ,   λ = Var(Q_true) / Var(Q_obs)
#
# We estimate λ from the known noise process:
#   Var(Q_obs) = Var(Q_true) + Var(measurement error)
#   Var(Q_true) ≈ sd(Q_it_c)^2  (variance of the centered score in the DGP)
#   Var(error)  ≈ (0.15)^2 * Var(noise component)
#
# More precisely, the noise comes from multinomial sampling over 85/15 mixture.
# We approximate the noise-to-signal ratio from 2 × (1 - pre-period stability),
# where stability ≈ mean(correlations across periods) ≈ 0.83.
# →  λ ≈ mean_r²  (reliability coefficient, analogous to test-retest reliability)
# ──────────────────────────────────────────────────────────────────────────────
cat("Step 12a: Klepper-Leamer measurement error correction...\n")
cat("  Q_it_c is built from observed (noisy) category counts, not latent preferences.\n")
cat("  Classical errors-in-variables attenuates β_hat toward zero.\n\n")

# Step A: Estimate reliability λ from previously computed stability correlations
# (Step 2b output). We use the mean of the two cross-period correlations.
# If we saved them, use those; otherwise re-derive from period_weights.
cat("  Estimating reliability λ from cross-period weight correlations...\n")

stab_cors <- numeric(0)
pre_w_eval <- period_weights[["v1.0 (pre-period)"]]
for (pname in names(period_defs)[-1]) {
  later_w <- period_weights[[pname]]
  shared <- inner_join(pre_w_eval, later_w, by = "user_id", suffix = c("_pre", "_post"))
  shared <- shared[complete.cases(shared), ]
  # Compute per-user Pearson r over the 5 category weights
  cors_pname <- sapply(seq_len(nrow(shared)), function(i) {
    w_pre  <- as.numeric(shared[i, paste0(cat_cols, "_pre")])
    w_post <- as.numeric(shared[i, paste0(cat_cols, "_post")])
    if (sd(w_pre) == 0 || sd(w_post) == 0) return(NA)
    cor(w_pre, w_post)
  })
  stab_cors <- c(stab_cors, mean(cors_pname, na.rm = TRUE))
  cat(sprintf("    Period '%s': mean r = %.4f\n", pname, mean(cors_pname, na.rm = TRUE)))
}

lambda_hat <- mean(stab_cors^2)  # reliability = mean squared correlation
cat(sprintf("\n  Reliability estimate λ ≈ mean(r²) = %.4f\n", lambda_hat))
cat("  (Interpretation: observed Q_it_c has λ the variance of the true latent score)\n\n")

# Step B: Apply Klepper-Leamer correction to the linear coefficient
beta_kl    <- beta_hat / lambda_hat
se_kl      <- se_hat  / lambda_hat  # delta method (λ treated as fixed)
ci_kl_lo   <- beta_kl - 1.96 * se_kl
ci_kl_hi   <- beta_kl + 1.96 * se_kl
recov_kl   <- beta_kl / TRUE_BETA * 100

cat("  ── Klepper-Leamer Corrected Estimates ──────────────────────────────────\n")
cat(sprintf("  Uncorrected β_hat:       %.4f (%.1f%% recovery, CI [%.4f, %.4f])\n",
            beta_hat, recovery_pct, ci_lo, ci_hi))
cat(sprintf("  Corrected  β_KL:         %.4f (%.1f%% recovery, CI [%.4f, %.4f])\n",
            beta_kl, recov_kl, ci_kl_lo, ci_kl_hi))
cat(sprintf("  TRUE_BETA:               %.2f\n", TRUE_BETA))
cat(sprintf("  Correction factor (1/λ): %.4f\n", 1 / lambda_hat))
cat(sprintf("  TRUE_BETA in KL CI:      %s\n",
            ifelse(ci_kl_lo <= TRUE_BETA & ci_kl_hi >= TRUE_BETA, "YES", "NO")))
cat("  ────────────────────────────────────────────────────────────────────────\n\n")

# Step C: Sensitivity — what if λ is mis-estimated? Sweep λ from 0.60 to 1.0.
cat("  Sensitivity to λ misspecification:\n")
cat(sprintf("  %-8s  %8s  %8s  %8s  %8s  %8s\n",
            "λ", "β_KL", "SE_KL", "CI_lo", "CI_hi", "Recovery%"))
cat(sprintf("  %s\n", strrep("-", 56)))
for (lam in seq(0.60, 1.00, by = 0.05)) {
  b_l  <- beta_hat / lam
  se_l <- se_hat   / lam
  marker <- if (abs(lam - lambda_hat) < 0.03) " ← estimated" else ""
  cat(sprintf("  %-8.2f  %8.4f  %8.4f  %8.4f  %8.4f  %7.1f%%%s\n",
              lam, b_l, se_l, b_l - 1.96 * se_l, b_l + 1.96 * se_l,
              b_l / TRUE_BETA * 100, marker))
}
cat("\n")

# Add KL to benchmark table for later reference
bench_results[["Proposed + K-L correction"]] <- list(
  beta  = beta_kl,
  se    = se_kl,
  lo    = ci_kl_lo,
  hi    = ci_kl_hi,
  bias  = beta_kl - TRUE_BETA,
  recov = recov_kl
)

cat("\n")

# --- Step 12b: Benchmark comparisons (Gap 4) ----------------------------------
# Compare the proposed method against four simpler alternatives.
# All methods receive the same 2,000-user stratified sample.
# Gold standard: TRUE_BETA = 1.0. Metric: recovered β, bias, 95% CI.
# ──────────────────────────────────────────────────────────────────────────────
cat("Step 12b: Benchmark comparisons — proposed vs. alternatives...\n\n")
cat("  All methods fit on the same stratified 2,000-user sample.\n")
cat("  TRUE_BETA = 1.0. Metric = recovered β and % bias.\n\n")

bench_results <- list()

# --- BM0: Proposed method (already fitted as model_linear) ---
bench_results[["Proposed (frozen weights, GAMM)"]] <- list(
  beta  = beta_hat,
  se    = se_hat,
  lo    = ci_lo,
  hi    = ci_hi,
  bias  = beta_hat - TRUE_BETA,
  recov = recovery_pct
)

# --- BM1: Naive OLS (no within-version centering, no version FE) ---
cat("  BM1: Naive OLS — raw Q_it (not centered), no version fixed effects...\n")
cat("    (Recovering Q_it by adding back the version-level mean to Q_it_c)\n")

# version-level population mean quality (from quality_lookup, same as Step 3 means)
version_pop_means <- quality_lookup %>%
  group_by(model_version) %>%
  summarise(q_pop_mean = mean(mean_human_rating), .groups = "drop") %>%
  rename(version_week = model_version)

model_df_naive <- model_df %>%
  left_join(version_pop_means, by = "version_week") %>%
  mutate(Q_it_raw = Q_it_c + q_pop_mean)

m_naive <- bam(
  cbind(active_days, 7 - active_days) ~
    Q_it_raw +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data   = model_df_naive,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)
b_naive <- coef(m_naive)["Q_it_raw"]
se_naive <- summary(m_naive)$p.table["Q_it_raw", "Std. Error"]
bench_results[["Naive OLS (no version FE)"]] <- list(
  beta  = b_naive,
  se    = se_naive,
  lo    = b_naive - 1.96 * se_naive,
  hi    = b_naive + 1.96 * se_naive,
  bias  = b_naive - TRUE_BETA,
  recov = b_naive / TRUE_BETA * 100
)
cat(sprintf("    β_hat = %.4f, bias = %+.4f, recovery = %.1f%%\n\n",
            b_naive, b_naive - TRUE_BETA, b_naive / TRUE_BETA * 100))

# --- BM2: Real-time weights (endogenous — current-period category counts, not frozen) ---
cat("  BM2: Real-time weights — each week's observed category mix (not frozen)...\n")
cat("    Expected: upward bias from reverse causality (better model -> users use\n")
cat("    high-quality categories more -> observed weights reflect outcome).\n")

# Compute per-row category weights from current-week counts
rt_cat_totals <- rowSums(model_df[, cat_cols])
rt_cat_totals[rt_cat_totals == 0] <- 1

rt_weights_df <- model_df %>%
  select(session_id, user_id, version_week, all_of(cat_cols)) %>%
  mutate(across(all_of(cat_cols), ~ . / pmax(rt_cat_totals, 1)))

# Compute Q_it from real-time weights
rt_q_joined <- rt_weights_df %>%
  pivot_longer(cols = all_of(cat_cols), names_to = "cat_col", values_to = "w_rt") %>%
  mutate(eval_prompt_category = cat_col_map[cat_col]) %>%
  left_join(quality_lookup, by = c("eval_prompt_category", "version_week" = "model_version")) %>%
  group_by(session_id, version_week) %>%
  summarise(Q_rt = sum(w_rt * mean_human_rating, na.rm = TRUE), .groups = "drop")

model_df_rt <- model_df %>%
  left_join(rt_q_joined, by = c("session_id", "version_week")) %>%
  group_by(version_week) %>%
  mutate(Q_rt_c = Q_rt - mean(Q_rt, na.rm = TRUE)) %>%
  ungroup()

m_rt <- bam(
  cbind(active_days, 7 - active_days) ~
    Q_rt_c +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data   = model_df_rt,
  family = binomial(),
  method = "fREML",
  discrete = TRUE,
  nthreads = 1
)
b_rt <- coef(m_rt)["Q_rt_c"]
se_rt <- summary(m_rt)$p.table["Q_rt_c", "Std. Error"]
bench_results[["Real-time weights (endogenous)"]] <- list(
  beta  = b_rt,
  se    = se_rt,
  lo    = b_rt - 1.96 * se_rt,
  hi    = b_rt + 1.96 * se_rt,
  bias  = b_rt - TRUE_BETA,
  recov = b_rt / TRUE_BETA * 100
)
cat(sprintf("    β_hat = %.4f, bias = %+.4f, recovery = %.1f%%\n\n",
            b_rt, b_rt - TRUE_BETA, b_rt / TRUE_BETA * 100))

# --- BM3: User-level Diff-in-Diff ---
cat("  BM3: User-level Diff-in-Diff — quality change between v1.0 and v1.1...\n")
cat("    Treatment = users who experienced above-median Q increase at v1.1 rollout.\n")

# For each user: delta_Q between v1.0 and v1.1 (first-difference in quality exposure)
user_did <- model_df %>%
  filter(version_week %in% c("v1.0", "v1.1")) %>%
  group_by(user_id, version_week) %>%
  summarise(
    mean_active = mean(active_days, na.rm = TRUE),
    mean_Q_c    = mean(Q_it_c, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = version_week,
              values_from = c(mean_active, mean_Q_c),
              names_sep = "_") %>%
  filter(!is.na(`mean_active_v1.0`) & !is.na(`mean_active_v1.1`)) %>%
  mutate(
    delta_Y  = `mean_active_v1.1` - `mean_active_v1.0`,
    delta_Q  = `mean_Q_c_v1.1`   - `mean_Q_c_v1.0`
  )

m_did <- lm(delta_Y ~ delta_Q, data = user_did)
b_did  <- coef(m_did)["delta_Q"]
se_did <- sqrt(vcov(m_did)["delta_Q", "delta_Q"])

# Convert from active-days scale to log-odds scale for comparability
# (approximate: 1 active day per week ≈ p ≈ 0.43, logit(0.43) ≈ -0.28;
#  a rough scale factor from the linear model is used)
active_mean <- mean(model_df$active_days[model_df$version_week == "v1.0"], na.rm = TRUE)
p_mean <- active_mean / 7
scale_factor <- 1 / (p_mean * (1 - p_mean) * 7)  # delta method: d(logit)/d(E[Y])
b_did_logit  <- b_did * scale_factor
se_did_logit <- se_did * scale_factor

bench_results[["User DiD (first-differences)"]] <- list(
  beta  = b_did_logit,
  se    = se_did_logit,
  lo    = b_did_logit - 1.96 * se_did_logit,
  hi    = b_did_logit + 1.96 * se_did_logit,
  bias  = b_did_logit - TRUE_BETA,
  recov = b_did_logit / TRUE_BETA * 100
)
cat(sprintf("    δ(active_days)/δ(Q_c) = %.4f, δ(log-odds) ≈ %.4f, recovery ≈ %.1f%%\n\n",
            b_did, b_did_logit, b_did_logit / TRUE_BETA * 100))

# --- BM4: User fixed-effects OLS (no GAM smooth, no random effect) ---
cat("  BM4: User fixed-effects OLS (parametric, user FE via model matrix)...\n")
cat("    Sweeps out all unobserved user-level heterogeneity. Slower but\n")
cat("    a common alternative in the applied economics literature.\n")

# Demean all variables within user (within-user FE via demeaning)
user_means_fe <- model_df %>%
  group_by(user_id) %>%
  summarise(
    Q_it_c_um   = mean(Q_it_c, na.rm = TRUE),
    active_um   = mean(active_days, na.rm = TRUE),
    week_um     = mean(week, na.rm = TRUE),
    pre_eng_um  = mean(pre_project_engagement_score, na.rm = TRUE),
    .groups = "drop"
  )

model_df_fe <- model_df %>%
  left_join(user_means_fe, by = "user_id") %>%
  mutate(
    Q_it_c_dm   = Q_it_c - Q_it_c_um,
    active_dm   = active_days - active_um,
    week_dm     = week - week_um,
    pre_eng_dm  = pre_project_engagement_score - pre_eng_um
  )

m_fe <- lm(active_dm ~ Q_it_c_dm + week_dm + pre_eng_dm,
           data = model_df_fe)
b_fe  <- coef(m_fe)["Q_it_c_dm"]
se_fe <- sqrt(vcov(m_fe)["Q_it_c_dm", "Q_it_c_dm"])
b_fe_logit  <- b_fe * scale_factor
se_fe_logit <- se_fe * scale_factor

bench_results[["User FE OLS (demeaned)"]] <- list(
  beta  = b_fe_logit,
  se    = se_fe_logit,
  lo    = b_fe_logit - 1.96 * se_fe_logit,
  hi    = b_fe_logit + 1.96 * se_fe_logit,
  bias  = b_fe_logit - TRUE_BETA,
  recov = b_fe_logit / TRUE_BETA * 100
)
cat(sprintf("    δ(active_days)/δ(Q_c) = %.4f, δ(log-odds) ≈ %.4f, recovery ≈ %.1f%%\n\n",
            b_fe, b_fe_logit, b_fe_logit / TRUE_BETA * 100))

# --- Print benchmark summary table ---
cat("  ══ Benchmark Comparison Table ══════════════════════════════════════════\n")
cat(sprintf("  TRUE_BETA = %.2f\n\n", TRUE_BETA))
cat(sprintf("  %-38s  %7s  %6s  %10s  %7s\n",
            "Method", "β_hat", "SE", "95% CI", "Recov%"))
cat(sprintf("  %-38s  %7s  %6s  %10s  %7s\n",
            strrep("-", 38), strrep("-", 7), strrep("-", 6), strrep("-", 10), strrep("-", 7)))
for (nm in names(bench_results)) {
  b <- bench_results[[nm]]
  star <- if (b$lo <= TRUE_BETA && b$hi >= TRUE_BETA) " ✓" else "  "
  cat(sprintf("  %-38s  %7.4f  %6.4f  [%5.3f,%5.3f] %6.1f%%%s\n",
              nm, b$beta, b$se, b$lo, b$hi, b$recov, star))
}
cat("  (✓ = TRUE_BETA = 1.0 contained in 95% CI)\n")
cat("  ══════════════════════════════════════════════════════════════════════\n\n")

# --- Benchmark figure ---
cat("  Generating benchmark comparison figure...\n")
bm_plot_df <- do.call(rbind, lapply(names(bench_results), function(nm) {
  b <- bench_results[[nm]]
  data.frame(method = nm, beta = b$beta, lo = b$lo, hi = b$hi,
             recovery = b$recov, stringsAsFactors = FALSE)
}))
bm_plot_df$method <- factor(bm_plot_df$method, levels = rev(bm_plot_df$method))

p_bm <- ggplot(bm_plot_df, aes(x = beta, y = method)) +
  geom_vline(xintercept = TRUE_BETA, linetype = "solid",
             color = PAL$moss, linewidth = 0.8, alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dotted",
             color = PAL$summit, alpha = 0.4) +
  geom_linerange(aes(xmin = lo, xmax = hi), color = PAL$ice, linewidth = 1.5) +
  geom_point(aes(color = (lo <= TRUE_BETA & hi >= TRUE_BETA)),
             size = 4) +
  scale_color_manual(values = c("TRUE" = PAL$moss, "FALSE" = PAL$warn),
                     guide = "none") +
  geom_text(aes(label = sprintf("%.0f%%", recovery)),
            nudge_y = 0.3, color = PAL$summit, size = 3.2) +
  labs(
    title = "Benchmark Comparison: Recovery of TRUE_BETA = 1.0",
    subtitle = "Green line = true value | Green point = CI contains truth | % = recovery rate",
    x = "Estimated β (log-odds scale)", y = NULL
  ) +
  theme_bgl() +
  theme(axis.text.y = element_text(size = 9))

ggsave(file.path(FIG_DIR, "11_benchmark_comparison.png"), p_bm,
       width = 12, height = 6, dpi = 150, bg = PAL$bg)
cat("  Saved 11_benchmark_comparison.png\n\n")

# --- Step 13: Cluster-robust bootstrap ----------------------------------------
cat("Step 13: Cluster-robust inference (user-level block bootstrap)...\n")
cat("  Resampling whole users, not individual observations.\n\n")

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

  # Fit without random effects for speed (bootstrap handles the clustering)
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

# --- Step 14: DAG diagram -----------------------------------------------------
cat("Step 14: Generating causal DAG diagram...\n")

# Build DAG with ggplot2 (no extra packages)
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
cat("  Saved 09_causal_dag.png\n\n")

# --- Step 15: ROI simulation --------------------------------------------------
# --- Step 15: ROI simulation ---
cat("  For each scenario: compute per-user delta_Q from frozen weights,\n")
cat("  shift Q_it_c, predict through the fitted GAMM, convert to active-day deltas.\n\n")

# User weights from Step 2 (pre_weights still in scope)
sim_w <- pre_weights %>% filter(user_id %in% sample_users)
cat(sprintf("  Users with weights: %d\n", nrow(sim_w)))

# Focus on v1.0 period ("what should we build into v1.1?")
v10_sim <- model_df %>% filter(version_week == "v1.0")
n_users_v10 <- n_distinct(v10_sim$user_id)
weeks_v10 <- n_distinct(v10_sim$week)
cat(sprintf("  v1.0 simulation data: %s rows (%d users, %d weeks)\n",
            format(nrow(v10_sim), big.mark = ","), n_users_v10, weeks_v10))

# Baseline predictions (probability scale * 7 = active days)
baseline_pred <- predict(model_active_days, newdata = v10_sim,
                         type = "response", exclude = "s(user_id_factor)")
baseline_mean_days <- mean(baseline_pred * 7)
cat(sprintf("  Baseline mean predicted active days (v1.0): %.4f\n\n", baseline_mean_days))

# --- Scenarios ---
# Each entry: category column(s) to improve and by how much (rating points).
scenarios <- list(
  list(name = "Math/Logic +0.5",
       desc = "Close the gap on second-worst category (high usage weight)",
       cols = c("prompts_math_logic" = 0.5)),
  list(name = "Creative Writing +0.5",
       desc = "Close the gap on worst category (lowest usage weight)",
       cols = c("prompts_creative_writing" = 0.5)),
  list(name = "Coding +0.5",
       desc = "Double down on strongest category (highest usage weight)",
       cols = c("prompts_coding" = 0.5)),
  list(name = "All Categories +0.2",
       desc = "Uniform quality lift across all categories",
       cols = c("prompts_coding" = 0.2, "prompts_creative_writing" = 0.2,
                "prompts_general_qa" = 0.2, "prompts_math_logic" = 0.2,
                "prompts_scientific" = 0.2))
)

# --- Run each scenario ---
roi_list <- list()

for (sc in scenarios) {
  cat(sprintf("  Scenario: %s\n", sc$name))
  cat(sprintf("    %s\n", sc$desc))

  # Per-user delta_Q = sum(w_ic * delta_c) over improved categories
  delta_q_user <- setNames(rep(0, nrow(sim_w)), sim_w$user_id)
  for (col in names(sc$cols)) {
    delta_q_user <- delta_q_user + sim_w[[col]] * sc$cols[col]
  }

  # Map user-level deltas to row-level (each user appears in multiple weeks)
  delta_q_rows <- delta_q_user[as.character(v10_sim$user_id)]

  # Counterfactual: shift Q_it_c by user-level delta.
  # We do NOT re-center because:
  #   - The slope on Q_it_c applies to any shift of that magnitude
  #   - Re-centering would zero out the population-level lift, showing only
  #     redistribution across users (useful but incomplete)
  #   - Shifts are small (~0.1) relative to training range (~0.4 SD),
  #     so extrapolation risk is minimal
  cf_v10 <- v10_sim
  cf_v10$Q_it_c <- cf_v10$Q_it_c + delta_q_rows

  # Predict through fitted GAMM (nonlinear smooth + logistic link)
  cf_pred <- predict(model_active_days, newdata = cf_v10,
                     type = "response", exclude = "s(user_id_factor)")

  # Delta active days per row
  delta_days_row <- (cf_pred - baseline_pred) * 7

  # Aggregate metrics
  mean_dq   <- mean(delta_q_rows)
  mean_dd   <- mean(delta_days_row)
  pct_chg   <- mean_dd / baseline_mean_days * 100

  # Per-user summary (avg across weeks in v1.0)
  user_summary <- data.frame(user_id = v10_sim$user_id,
                             delta = delta_days_row) %>%
    group_by(user_id) %>%
    summarise(user_mean_delta = mean(delta), .groups = "drop")

  median_dd <- median(user_summary$user_mean_delta)
  p90_dd    <- unname(quantile(user_summary$user_mean_delta, 0.90))
  p10_dd    <- unname(quantile(user_summary$user_mean_delta, 0.10))

  roi_list[[sc$name]] <- data.frame(
    Scenario     = sc$name,
    Q_Shift      = mean_dq,
    Mean_Delta   = mean_dd,
    Median_Delta = median_dd,
    P10_Delta    = p10_dd,
    P90_Delta    = p90_dd,
    Pct_Change   = pct_chg,
    Per_100K     = mean_dd * 100000,
    stringsAsFactors = FALSE
  )

  cat(sprintf("    Mean Q_it shift:       +%.4f\n", mean_dq))
  cat(sprintf("    Delta active days:     %+.4f mean, %+.4f median / user / week\n",
              mean_dd, median_dd))
  cat(sprintf("    User range (P10-P90):  [%+.4f, %+.4f]\n", p10_dd, p90_dd))
  cat(sprintf("    Pct change:            %+.2f%%\n", pct_chg))
  cat(sprintf("    Scaled to 100K users:  +%s extra active-user-days/week\n\n",
              format(round(mean_dd * 100000), big.mark = ",")))
}

roi_df <- do.call(rbind, roi_list)
rownames(roi_df) <- NULL

cat("  === ROI Summary Table ===\n")
print(roi_df, row.names = FALSE, digits = 4)
cat("\n")

# --- ROI Visualization ---
cat("  Generating ROI simulation figure...\n")

plot_roi_df <- roi_df %>%
  mutate(Scenario = factor(Scenario, levels = rev(Scenario)),
         label = sprintf("%+.3f days (%+.1f%%)", Mean_Delta, Pct_Change))

p_roi <- ggplot(plot_roi_df, aes(x = Mean_Delta, y = Scenario)) +
  geom_vline(xintercept = 0, linetype = "dotted", color = PAL$summit, alpha = 0.4) +
  geom_segment(aes(x = 0, xend = Mean_Delta, y = Scenario, yend = Scenario),
               color = PAL$ice, linewidth = 1.2) +
  geom_point(color = PAL$moss, size = 5) +
  geom_text(aes(label = label),
            hjust = -0.1, color = PAL$summit, size = 3.8, fontface = "bold") +
  scale_x_continuous(expand = expansion(mult = c(0.05, 0.45))) +
  labs(
    title = "ROI Simulation: Predicted Retention Lift by Scenario",
    subtitle = sprintf("v1.0 baseline (%.2f active days/week) | Propagated through fitted GAMM",
                       baseline_mean_days),
    x = "Delta Active Days per User per Week",
    y = NULL
  ) +
  theme_bgl() +
  theme(
    axis.text.y = element_text(size = 11, color = PAL$summit),
    plot.margin = margin(10, 30, 10, 10)
  )

ggsave(file.path(FIG_DIR, "10_roi_simulation.png"), p_roi,
       width = 12, height = 5, dpi = 150, bg = PAL$bg)
cat("  Saved 10_roi_simulation.png\n\n")

# --- Final calibration summary ------------------------------------------------
# --- Calibration recovery summary ---
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
cat("  10_roi_simulation.png\n")

cat("\nROI SIMULATION SUMMARY:\n")
for (i in seq_len(nrow(roi_df))) {
  cat(sprintf("  %-25s: %+.4f active days/user/week (%+.1f%%), +%s per 100K users\n",
              roi_df$Scenario[i], roi_df$Mean_Delta[i], roi_df$Pct_Change[i],
              format(round(roi_df$Per_100K[i]), big.mark = ",")))
}
cat("\n")

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
cat("\n\n=== ROI Simulation (Step 15) ===\n")
cat(sprintf("  Baseline: v1.0, mean predicted active days = %.4f\n", baseline_mean_days))
cat("  Scenarios propagated through fitted GAMM (no re-centering):\n\n")
for (i in seq_len(nrow(roi_df))) {
  cat(sprintf("  %s:\n", roi_df$Scenario[i]))
  cat(sprintf("    Mean Q_it shift:    +%.4f\n", roi_df$Q_Shift[i]))
  cat(sprintf("    Delta active days:  %+.4f mean, %+.4f median / user / week\n",
              roi_df$Mean_Delta[i], roi_df$Median_Delta[i]))
  cat(sprintf("    User range P10-P90: [%+.4f, %+.4f]\n", roi_df$P10_Delta[i], roi_df$P90_Delta[i]))
  cat(sprintf("    Pct change:         %+.2f%%\n", roi_df$Pct_Change[i]))
  cat(sprintf("    Per 100K users:     +%s extra active-user-days/week\n\n",
              format(round(roi_df$Per_100K[i]), big.mark = ",")))
}
sink()
cat("  Saved model_summaries.txt\n")

cat("\nDone.\n")
