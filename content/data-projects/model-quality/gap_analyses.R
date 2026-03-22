#!/usr/bin/env Rscript
# ==============================================================================
# Gap analyses (Steps 2c, 9b, 9c, 12a, 12b) — focused execution
# Matches the logic in model_quality_analysis.R but uses n=500 to
# complete within the dev-container memory budget (~1.3 GB free).
# Results feed directly into the revised journal draft.
# ==============================================================================

.libPaths(c("~/R/library", .libPaths()))

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(mgcv)
  library(ggplot2)
  library(patchwork)
  library(scales)
})

cat("gap_analyses.R  |  n=500 sample  |  Steps 2c, 9b, 9c, 12a, 12b\n\n")

# --- Constants ---
TRUE_BETA      <- 1.0
RANDOM_SEED    <- 42
N_SAMPLE       <- 500
pre_period_end <- 7
v11_deploy     <- 8
v12_deploy     <- 16

assign_version <- function(week) {
  dplyr::case_when(
    week < v11_deploy ~ "v1.0",
    week < v12_deploy ~ "v1.1",
    TRUE              ~ "v1.2"
  )
}

# --- Load data ---
cat("Loading data...\n")
engage_df  <- read_csv("user_engagement_timeseries.csv",  show_col_types = FALSE)
eval_df    <- read_csv("offline_model_evaluation.csv",    show_col_types = FALSE)
demo_df    <- read_csv("user_demographics_subscription.csv", show_col_types = FALSE)

# Confirm augmented columns exist
stopifnot("active_days_observed" %in% names(engage_df))
cat(sprintf("  Rows: %s  |  augmented columns: OK\n\n",
            format(nrow(engage_df), big.mark = ",")))

# --- Quality lookup ---
quality_lookup <- eval_df %>%
  group_by(eval_prompt_category, model_version) %>%
  summarise(mean_human_rating = mean(human_rating, na.rm = TRUE),
            .groups = "drop")

ql_wide <- quality_lookup %>%
  select(eval_prompt_category, model_version, mean_human_rating) %>%
  pivot_wider(names_from = model_version, values_from = mean_human_rating)

# --- Category columns & map ---
cat_cols    <- c("prompts_coding", "prompts_creative_writing",
                 "prompts_general_qa", "prompts_math_logic", "prompts_scientific")
cat_col_map <- c(
  prompts_coding          = "Coding",
  prompts_creative_writing = "Creative Writing",
  prompts_general_qa      = "General QA",
  prompts_math_logic      = "Math/Logic",
  prompts_scientific      = "Scientific"
)

# --- Pre-period weights (frozen) ---
cat("Computing pre-period weights...\n")
pre_period_counts <- engage_df %>%
  filter(week <= pre_period_end) %>%
  group_by(user_id) %>%
  summarise(across(all_of(cat_cols), sum), .groups = "drop")

totals <- rowSums(pre_period_counts[, cat_cols])
for (col in cat_cols) {
  pre_period_counts[[col]] <- ifelse(totals == 0,
                                     1 / length(cat_cols),
                                     pre_period_counts[[col]] / totals)
}

user_weights <- pre_period_counts %>%
  pivot_longer(cols = all_of(cat_cols),
               names_to  = "cat_col",
               values_to = "w_ic") %>%
  mutate(eval_prompt_category = cat_col_map[cat_col]) %>%
  select(user_id, eval_prompt_category, w_ic)

# --- Q_it + centering ---
cat("Computing Q_it and centering...\n")
Q_user <- user_weights %>%
  inner_join(ql_wide, by = "eval_prompt_category") %>%
  group_by(user_id) %>%
  summarise(Q_v10 = sum(w_ic * v1.0),
            Q_v11 = sum(w_ic * v1.1),
            Q_v12 = sum(w_ic * v1.2),
            .groups = "drop") %>%
  mutate(Q_v10_c = Q_v10 - mean(Q_v10),
         Q_v11_c = Q_v11 - mean(Q_v11),
         Q_v12_c = Q_v12 - mean(Q_v12))

engage_df <- engage_df %>%
  mutate(version_week = assign_version(week),
         version_f    = factor(version_week, levels = c("v1.0", "v1.1", "v1.2"))) %>%
  left_join(Q_user, by = "user_id") %>%
  mutate(
    Q_it_c = dplyr::case_when(
      version_week == "v1.0" ~ Q_v10_c,
      version_week == "v1.1" ~ Q_v11_c,
      TRUE                   ~ Q_v12_c
    )
  ) %>%
  select(-Q_v10, -Q_v11, -Q_v12, -Q_v10_c, -Q_v11_c, -Q_v12_c) %>%
  left_join(demo_df, by = "user_id") %>%
  rename(active_days = active_days_observed)

# --- Stratified sample ---
cat(sprintf("Sampling %d users (stratified by user_type)...\n", N_SAMPLE))
set.seed(RANDOM_SEED)
user_info  <- engage_df %>% distinct(user_id, user_type)
type_counts <- user_info %>% dplyr::count(user_type)
type_counts$n_sample <- round(N_SAMPLE * type_counts$n / sum(type_counts$n))

sample_users <- c()
for (i in seq_len(nrow(type_counts))) {
  ut  <- type_counts$user_type[i]
  ns  <- type_counts$n_sample[i]
  ids <- user_info %>% filter(user_type == ut) %>% pull(user_id)
  sample_users <- c(sample_users, sample(ids, size = min(ns, length(ids))))
}
cat(sprintf("  Sample: %d users\n", length(sample_users)))

model_df <- engage_df %>%
  filter(user_id %in% sample_users) %>%
  mutate(user_id_factor = factor(user_id))

cat(sprintf("  Modeling rows: %s\n\n",
            format(nrow(model_df), big.mark = ",")))

# --- Fit canonical (proposed) model ---
cat("Fitting canonical (proposed) GAMM...\n")
t0 <- proc.time()
model_main <- bam(
  cbind(active_days, 7 - active_days) ~
    Q_it_c +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data     = model_df,
  family   = binomial(),
  method   = "fREML",
  discrete = TRUE,
  nthreads = 1
)
elapsed <- (proc.time() - t0)[["elapsed"]]
beta_hat  <- coef(model_main)["Q_it_c"]
se_hat    <- summary(model_main)$p.table["Q_it_c", "Std. Error"]
ci_lo     <- beta_hat - 1.96 * se_hat
ci_hi     <- beta_hat + 1.96 * se_hat
recovery_pct <- beta_hat / TRUE_BETA * 100

cat(sprintf("  Fitted in %.1f sec\n", elapsed))
cat(sprintf("  β_hat = %.4f, SE = %.4f, 95%% CI = [%.4f, %.4f]\n",
            beta_hat, se_hat, ci_lo, ci_hi))
cat(sprintf("  Recovery = %.1f%%  (TRUE_BETA = %.2f)\n\n",
            recovery_pct, TRUE_BETA))

cat(sprintf("  Model R²(adj) = %.3f,  Dev. explained = %.1f%%\n\n",
            summary(model_main)$r.sq,
            summary(model_main)$dev.expl * 100))


# ==============================================================================
# Multi-outcome calibration (Section 4.8)
# Fit the same within-version GAMM for churn_risk (binary, TRUE_BETA = -0.6)
# and session_duration_aug (log-normal, TRUE_BETA = 0.4).
# Reports point estimate, SE, 95% CI, and recovery for each outcome.
# ==============================================================================
TRUE_BETA_CHURN    <- -0.6
TRUE_BETA_DURATION <-  0.4

cat("Multi-outcome calibration (Section 4.8)...\n")

# --- churn_risk ---
model_churn <- bam(
  churn_risk_observed ~
    Q_it_c +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data     = model_df,
  family   = binomial(),
  method   = "fREML",
  discrete = TRUE,
  nthreads = 1
)

b_churn  <- coef(model_churn)["Q_it_c"]
se_churn <- summary(model_churn)$p.table["Q_it_c", "Std. Error"]
ci_churn_lo <- b_churn - 1.96 * se_churn
ci_churn_hi <- b_churn + 1.96 * se_churn
recov_churn <- b_churn / TRUE_BETA_CHURN * 100

cat(sprintf("  churn_risk:      β=%.4f, SE=%.4f, 95%% CI=[%.4f, %.4f], recovery=%.1f%%\n",
            b_churn, se_churn, ci_churn_lo, ci_churn_hi, recov_churn))

# --- session_duration_aug (log-scale, Gaussian on log) ---
model_dur <- bam(
  log(session_duration_aug) ~
    Q_it_c +
    version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type +
    pre_project_engagement_score,
  data     = model_df,
  method   = "fREML",
  discrete = TRUE,
  nthreads = 1
)

b_dur  <- coef(model_dur)["Q_it_c"]
se_dur <- summary(model_dur)$p.table["Q_it_c", "Std. Error"]
ci_dur_lo <- b_dur - 1.96 * se_dur
ci_dur_hi <- b_dur + 1.96 * se_dur
recov_dur <- b_dur / TRUE_BETA_DURATION * 100

cat(sprintf("  session_duration: β=%.4f, SE=%.4f, 95%% CI=[%.4f, %.4f], recovery=%.1f%%\n",
            b_dur, se_dur, ci_dur_lo, ci_dur_hi, recov_dur))

# --- K-L corrections for churn and duration ---
# Use same lambda_hat from active_days (will be computed in Step 12a below;
# print final summary there). Pre-compute for reporting here:
# lambda will be estimated once Q stability is computed in Step 12a.
# Store raw results for the summary table.
multi_outcome <- list(
  active_days = list(beta = beta_hat, se = se_hat,
                     ci_lo = ci_lo, ci_hi = ci_hi,
                     true = TRUE_BETA, recov = recovery_pct),
  churn_risk  = list(beta = b_churn, se = se_churn,
                     ci_lo = ci_churn_lo, ci_hi = ci_churn_hi,
                     true = TRUE_BETA_CHURN, recov = recov_churn),
  session_dur = list(beta = b_dur, se = se_dur,
                     ci_lo = ci_dur_lo, ci_hi = ci_dur_hi,
                     true = TRUE_BETA_DURATION, recov = recov_dur)
)
cat("\n")


# ==============================================================================
# Step 2c: Frozen-weights sensitivity
# ==============================================================================

freeze_defs <- list(
  "Weeks 1-3 (early)"              = c(1, 3),
  "Weeks 1-5 (mid)"                = c(1, 5),
  "Weeks 1-7 (full, canonical)"    = c(1, pre_period_end)
)

sensitivity_q <- list()

for (fname in names(freeze_defs)) {
  wk_range <- freeze_defs[[fname]]
  fw <- engage_df %>%
    filter(week >= wk_range[1], week <= wk_range[2]) %>%
    group_by(user_id) %>%
    summarise(across(all_of(cat_cols), sum), .groups = "drop")
  fw_totals <- rowSums(fw[, cat_cols])
  for (col in cat_cols)
    fw[[col]] <- ifelse(fw_totals == 0, 1 / length(cat_cols), fw[[col]] / fw_totals)

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
    left_join(q_fw %>% select(user_id, Q_fw10_c, Q_fw11_c, Q_fw12_c),
              by = "user_id") %>%
    mutate(Q_fw_c = dplyr::case_when(
      version_week == "v1.0" ~ Q_fw10_c,
      version_week == "v1.1" ~ Q_fw11_c,
      TRUE                   ~ Q_fw12_c
    ))

  r_with_canonical <- cor(model_df_fw$Q_fw_c, model_df_fw$Q_it_c,
                          use = "complete.obs")

  m_fw <- bam(
    cbind(active_days, 7 - active_days) ~
      Q_fw_c + version_f +
      s(week, bs = "tp", k = 10) +
      s(user_id_factor, bs = "re") +
      user_type + pre_project_engagement_score,
    data = model_df_fw, family = binomial(),
    method = "fREML", discrete = TRUE, nthreads = 1
  )

  b_fw  <- coef(m_fw)["Q_fw_c"]
  se_fw <- summary(m_fw)$p.table["Q_fw_c", "Std. Error"]
  sensitivity_q[[fname]] <- list(
    beta = b_fw, se = se_fw,
    recov   = b_fw / TRUE_BETA * 100,
    r_canon = r_with_canonical,
    n_weeks = diff(wk_range) + 1
  )
  cat(sprintf("  %s: β=%.4f (%.1f%% recovery), r(canon)=%.4f\n",
              fname, b_fw, b_fw / TRUE_BETA * 100, r_with_canonical))
}

cat(sprintf("\n  %-34s  %8s  %7s  %8s\n",
            "Freeze window", "β_hat", "Recov%", "r(canon)"))
cat(sprintf("  %s\n", strrep("-", 65)))
for (nm in names(sensitivity_q)) {
  s <- sensitivity_q[[nm]]
  cat(sprintf("  %-34s  %8.4f  %6.1f%%  %8.4f\n",
              nm, s$beta, s$recov, s$r_canon))
}
cat("\n")


# ==============================================================================
# Step 9b: User-weight permutation test
# ==============================================================================

set.seed(123)
model_df_perm <- model_df %>%
  group_by(version_f) %>%
  mutate(Q_perm_c = Q_it_c[sample(n())]) %>%
  ungroup()

cat(sprintf("  Cor(Q_it_c, Q_perm_c) = %.4f  (should be ≈ 0)\n",
            cor(model_df_perm$Q_it_c, model_df_perm$Q_perm_c)))

model_perm <- bam(
  cbind(active_days, 7 - active_days) ~
    Q_perm_c + version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type + pre_project_engagement_score,
  data = model_df_perm, family = binomial(),
  method = "fREML", discrete = TRUE, nthreads = 1
)

real_p <- summary(model_main)$p.table["Q_it_c",  "Pr(>|z|)"]
perm_p <- summary(model_perm)$p.table["Q_perm_c", "Pr(>|z|)"]
b_perm <- coef(model_perm)["Q_perm_c"]

cat(sprintf("  Real Q_it_c:   β=%.4f, p=%.2e\n", beta_hat, real_p))
cat(sprintf("  Permuted Q:    β=%.4f, p=%.4f\n", b_perm,   perm_p))
cat(sprintf("  Permuted effect = %.1f%% of real\n\n",
            abs(b_perm / beta_hat) * 100))


# ==============================================================================
# Step 9c: Time-shifted (lead) placebo
# ==============================================================================

q_mean_v10 <- ql_wide %>% summarise(across(c(v1.0, v1.1, v1.2), mean))
q_mean_v11 <- q_mean_v10
q_mean_v12 <- q_mean_v10

lead_q_user <- user_weights %>%
  filter(user_id %in% sample_users) %>%
  inner_join(ql_wide, by = "eval_prompt_category") %>%
  group_by(user_id) %>%
  summarise(
    Q_lead10 = sum(w_ic * v1.1),   # v1.0 rows get v1.1 quality (lead)
    Q_lead11 = sum(w_ic * v1.2),   # v1.1 rows get v1.2 quality (lead)
    Q_lead12 = sum(w_ic * v1.0),   # v1.2 rows get v1.0 quality (wrap)
    .groups  = "drop"
  ) %>%
  mutate(
    Q_lead10_c = Q_lead10 - mean(Q_lead10),
    Q_lead11_c = Q_lead11 - mean(Q_lead11),
    Q_lead12_c = Q_lead12 - mean(Q_lead12)
  )

model_df_lead <- model_df %>%
  left_join(lead_q_user %>%
              select(user_id, Q_lead10_c, Q_lead11_c, Q_lead12_c),
            by = "user_id") %>%
  mutate(Q_lead_c = dplyr::case_when(
    version_week == "v1.0" ~ Q_lead10_c,
    version_week == "v1.1" ~ Q_lead11_c,
    TRUE                   ~ Q_lead12_c
  ))

cor_real_vs_lead <- cor(model_df_lead$Q_it_c, model_df_lead$Q_lead_c,
                        use = "complete.obs")
cat(sprintf("  Cor(Q_it_c, Q_lead_c) = %.4f\n", cor_real_vs_lead))

model_lead <- bam(
  cbind(active_days, 7 - active_days) ~
    Q_lead_c + version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type + pre_project_engagement_score,
  data = model_df_lead, family = binomial(),
  method = "fREML", discrete = TRUE, nthreads = 1
)

lead_p <- summary(model_lead)$p.table["Q_lead_c", "Pr(>|z|)"]
b_lead <- coef(model_lead)["Q_lead_c"]

cat(sprintf("  Real Q:  β=%.4f, p=%.2e\n", beta_hat, real_p))
cat(sprintf("  Lead Q:  β=%.4f, p=%.4f\n", b_lead,   lead_p))
cat("\n  Falsification summary:\n")
cat(sprintf("  %-20s  %8s  %12s  %s\n",
            "Test", "β_hat", "p-value", "Interpretation"))
cat(sprintf("  %s\n", strrep("-", 65)))
cat(sprintf("  %-20s  %8.4f  %12.2e  %s\n",
            "Real quality",     beta_hat, real_p, "Signal detected (expected)"))
cat(sprintf("  %-20s  %8.4f  %12.4f  %s\n",
            "Permuted quality", b_perm, perm_p,
            ifelse(perm_p < 0.05, "FAIL: spurious signal", "Pass: null confirmed")))
cat(sprintf("  %-20s  %8.4f  %12.4f  %s\n",
            "Lead (shifted) Q", b_lead, lead_p,
            ifelse(lead_p < 0.05, "FAIL: spurious signal", "Pass: null confirmed")))
cat("\n")


# ==============================================================================
# Step 12a: Klepper-Leamer measurement error correction
# ==============================================================================

# Cross-period correlations to estimate reliability (λ) of Q_it_c
# Use the per-user Q scores across the three versions
q_by_version <- user_weights %>%
  filter(user_id %in% sample_users) %>%
  inner_join(ql_wide, by = "eval_prompt_category") %>%
  group_by(user_id) %>%
  summarise(Q_v10 = sum(w_ic * v1.0),
            Q_v11 = sum(w_ic * v1.1),
            Q_v12 = sum(w_ic * v1.2),
            .groups = "drop")

stab_cors <- c(
  cor(q_by_version$Q_v10, q_by_version$Q_v11),
  cor(q_by_version$Q_v11, q_by_version$Q_v12),
  cor(q_by_version$Q_v10, q_by_version$Q_v12)
)

lambda_hat <- mean(stab_cors^2)   # reliability estimate
beta_kl    <- beta_hat / lambda_hat
se_kl      <- se_hat   / lambda_hat
ci_kl_lo   <- beta_kl - 1.96 * se_kl
ci_kl_hi   <- beta_kl + 1.96 * se_kl

cat(sprintf("  Cross-period correlations:\n"))
cat(sprintf("    r(v1.0, v1.1) = %.4f,  r²=%.4f\n", stab_cors[1], stab_cors[1]^2))
cat(sprintf("    r(v1.1, v1.2) = %.4f,  r²=%.4f\n", stab_cors[2], stab_cors[2]^2))
cat(sprintf("    r(v1.0, v1.2) = %.4f,  r²=%.4f\n", stab_cors[3], stab_cors[3]^2))
cat(sprintf("  Reliability λ̂ = mean(r²) = %.4f\n", lambda_hat))
cat(sprintf("\n  K-L corrected β: β_KL = β_hat / λ̂ = %.4f / %.4f = %.4f\n",
            beta_hat, lambda_hat, beta_kl))
cat(sprintf("  95%% CI for β_KL: [%.4f, %.4f]\n", ci_kl_lo, ci_kl_hi))
cat(sprintf("  Recovery after K-L correction: %.1f%%\n\n",
            beta_kl / TRUE_BETA * 100))

# λ sensitivity sweep
cat("  λ sensitivity sweep:\n")
cat(sprintf("  %-8s  %8s  %8s  %8s  %8s\n",
            "λ", "β_KL", "Recov%", "CI_lo", "CI_hi"))
cat(sprintf("  %s\n", strrep("-", 50)))
for (lam in seq(0.60, 1.00, by = 0.05)) {
  bkl  <- beta_hat / lam
  sekl <- se_hat   / lam
  cat(sprintf("  %-8.2f  %8.4f  %7.1f%%  %8.4f  %8.4f\n",
              lam, bkl, bkl / TRUE_BETA * 100,
              bkl - 1.96 * sekl, bkl + 1.96 * sekl))
}
cat("\n")


# ==============================================================================
# Step 12b: Benchmark comparisons
# ==============================================================================

bench_results <- list()

# BM0: Proposed (already fitted)
bench_results[["Proposed (frozen weights, GAMM)"]] <- list(
  beta = beta_hat, se = se_hat,
  lo = ci_lo, hi = ci_hi,
  bias = beta_hat - TRUE_BETA, recov = recovery_pct
)

# --- BM1: Naive OLS (no version FE) ---
cat("  BM1: Naive OLS — raw Q_it, no version FE...\n")
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
    user_type + pre_project_engagement_score,
  data = model_df_naive, family = binomial(),
  method = "fREML", discrete = TRUE, nthreads = 1
)
b_naive  <- coef(m_naive)["Q_it_raw"]
se_naive <- summary(m_naive)$p.table["Q_it_raw", "Std. Error"]
bench_results[["Naive OLS (no version FE)"]] <- list(
  beta = b_naive, se = se_naive,
  lo = b_naive - 1.96 * se_naive, hi = b_naive + 1.96 * se_naive,
  bias = b_naive - TRUE_BETA, recov = b_naive / TRUE_BETA * 100
)
cat(sprintf("    β=%.4f, bias=%+.4f, recovery=%.1f%%\n\n",
            b_naive, b_naive - TRUE_BETA, b_naive / TRUE_BETA * 100))

# --- BM2: Real-time weights (endogenous current-period weights) ---
cat("  BM2: Real-time weights (endogenous)...\n")
rt_cat_totals <- pmax(rowSums(model_df[, cat_cols]), 1)
rt_weights_df <- model_df %>%
  select(session_id, user_id, version_week, all_of(cat_cols)) %>%
  mutate(across(all_of(cat_cols), ~ . / rt_cat_totals))

rt_q_joined <- rt_weights_df %>%
  pivot_longer(cols = all_of(cat_cols),
               names_to = "cat_col", values_to = "w_rt") %>%
  mutate(eval_prompt_category = cat_col_map[cat_col]) %>%
  left_join(quality_lookup,
            by = c("eval_prompt_category", "version_week" = "model_version")) %>%
  group_by(session_id, version_week) %>%
  summarise(Q_rt = sum(w_rt * mean_human_rating, na.rm = TRUE), .groups = "drop")

model_df_rt <- model_df %>%
  left_join(rt_q_joined, by = c("session_id", "version_week")) %>%
  group_by(version_week) %>%
  mutate(Q_rt_c = Q_rt - mean(Q_rt, na.rm = TRUE)) %>%
  ungroup()

m_rt <- bam(
  cbind(active_days, 7 - active_days) ~
    Q_rt_c + version_f +
    s(week, bs = "tp", k = 10) +
    s(user_id_factor, bs = "re") +
    user_type + pre_project_engagement_score,
  data = model_df_rt, family = binomial(),
  method = "fREML", discrete = TRUE, nthreads = 1
)
b_rt  <- coef(m_rt)["Q_rt_c"]
se_rt <- summary(m_rt)$p.table["Q_rt_c", "Std. Error"]
bench_results[["Real-time weights (endogenous)"]] <- list(
  beta = b_rt, se = se_rt,
  lo = b_rt - 1.96 * se_rt, hi = b_rt + 1.96 * se_rt,
  bias = b_rt - TRUE_BETA, recov = b_rt / TRUE_BETA * 100
)
cat(sprintf("    β=%.4f, bias=%+.4f, recovery=%.1f%%\n\n",
            b_rt, b_rt - TRUE_BETA, b_rt / TRUE_BETA * 100))

# --- BM3: User-level DiD (delta_Y ~ delta_Q) ---
cat("  BM3: User DiD (delta Y ~ delta Q)...\n")
did_df <- model_df %>%
  group_by(user_id, version_f) %>%
  summarise(Y_bar  = mean(active_days),
            Q_bar  = mean(Q_it_c),
            .groups = "drop") %>%
  pivot_wider(id_cols    = user_id,
              names_from  = version_f,
              values_from = c(Y_bar, Q_bar)) %>%
  mutate(
    # average the two version transitions
    delta_Y = ((Y_bar_v1.1 - Y_bar_v1.0) + (Y_bar_v1.2 - Y_bar_v1.1)) / 2,
    delta_Q = ((Q_bar_v1.1 - Q_bar_v1.0) + (Q_bar_v1.2 - Q_bar_v1.1)) / 2
  ) %>%
  filter(complete.cases(delta_Y, delta_Q))

m_did <- lm(delta_Y ~ delta_Q, data = did_df)
b_did  <- coef(m_did)["delta_Q"]
se_did <- summary(m_did)$coefficients["delta_Q", "Std. Error"]
# Convert delta_Y (count scale) approximately to log-odds for comparison
# active_days ∈ [1,7]; mean ≈ 3; p ≈ 3/7 ≈ 0.43; dp/dq ≈ p*(1-p)*b_lo
# beta_lo ≈ b_did / (p*(1-p)) using delta method
p_mean  <- mean(model_df$active_days) / 7
b_did_lo <- b_did / (p_mean * (1 - p_mean))
bench_results[["User DiD (delta method)"]] <- list(
  beta = b_did_lo, se = NA,
  lo = NA, hi = NA,
  bias = b_did_lo - TRUE_BETA, recov = b_did_lo / TRUE_BETA * 100
)
cat(sprintf("    Δ-scale β=%.4f → log-odds ≈%.4f (recovery≈%.1f%%)\n\n",
            b_did, b_did_lo, b_did_lo / TRUE_BETA * 100))

# --- BM4: User FE OLS (within-user demeaning) ---
cat("  BM4: User FE OLS (within-user demeaning)...\n")
fe_df <- model_df %>%
  group_by(user_id) %>%
  mutate(Y_dm  = active_days - mean(active_days),
         Q_dm  = Q_it_c     - mean(Q_it_c),
         wk_dm = week        - mean(week)) %>%
  ungroup()

m_fe <- lm(Y_dm ~ Q_dm + wk_dm, data = fe_df)
b_fe  <- coef(m_fe)["Q_dm"]
se_fe <- summary(m_fe)$coefficients["Q_dm", "Std. Error"]
# Convert OLS active-days effect to log-odds
b_fe_lo <- b_fe / (p_mean * (1 - p_mean))
bench_results[["User FE OLS (within-user)"]] <- list(
  beta = b_fe_lo, se = NA,
  lo = NA, hi = NA,
  bias = b_fe_lo - TRUE_BETA, recov = b_fe_lo / TRUE_BETA * 100
)
cat(sprintf("    OLS β=%.4f → log-odds ≈%.4f (recovery≈%.1f%%)\n\n",
            b_fe, b_fe_lo, b_fe_lo / TRUE_BETA * 100))

# --- Benchmark summary table ---
cat("  Benchmark comparison summary:\n")
cat(sprintf("  TRUE_BETA = %.2f\n", TRUE_BETA))
cat(sprintf("  %-40s  %8s  %8s  %7s\n",
            "Method", "β_hat", "Bias", "Recov%"))
cat(sprintf("  %s\n", strrep("-", 70)))
for (nm in names(bench_results)) {
  br  <- bench_results[[nm]]
  cat(sprintf("  %-40s  %8.4f  %+8.4f  %6.1f%%\n",
              nm, br$beta, br$bias, br$recov))
}
cat("\n")

# ==============================================================================
# Summary
# ==============================================================================

cat("§3.4 Frozen-weights sensitivity:\n")
for (nm in names(sensitivity_q)) {
  s <- sensitivity_q[[nm]]
  cat(sprintf("  %s: β=%.4f, recovery=%.1f%%, r(canon)=%.4f\n",
              nm, s$beta, s$recov, s$r_canon))
}
cat("\n")

cat("§4.1 Main GAMM:\n")
cat(sprintf("  β_hat = %.4f, SE = %.4f\n", beta_hat, se_hat))
cat(sprintf("  Recovery = %.1f%%   CI = [%.4f, %.4f]\n", recovery_pct, ci_lo, ci_hi))
cat("\n")

cat("§4.4 Falsification:\n")
cat(sprintf("  Real quality:     β=%.4f, p=%.2e\n", beta_hat,  real_p))
cat(sprintf("  Permuted quality: β=%.4f, p=%.4f\n", b_perm,    perm_p))
cat(sprintf("  Lead (shifted):   β=%.4f, p=%.4f\n", b_lead,    lead_p))
cat("\n")

cat("§4.5 / §5.1 K-L correction:\n")
cat(sprintf("  λ̂ = %.4f\n", lambda_hat))
cat(sprintf("  β_KL = %.4f, CI = [%.4f, %.4f], recovery = %.1f%%\n",
            beta_kl, ci_kl_lo, ci_kl_hi, beta_kl / TRUE_BETA * 100))
cat("\n")

cat("§4.6 Benchmark recovery:\n")
for (nm in names(bench_results)) {
  br <- bench_results[[nm]]
  cat(sprintf("  %-40s  β=%.4f  recovery=%.1f%%\n", nm, br$beta, br$recov))
}
cat("\n")

cat("§4.8 Multi-outcome calibration (linear model):\n")
cat(sprintf("  %-20s  %8s  %8s  %8s  %8s  %7s\n",
            "Outcome", "TRUE_β", "β_hat", "CI_lo", "CI_hi", "Recov%"))
cat(sprintf("  %s\n", strrep("-", 65)))
for (nm in names(multi_outcome)) {
  mo <- multi_outcome[[nm]]
  cat(sprintf("  %-20s  %8.3f  %8.4f  %8.4f  %8.4f  %6.1f%%\n",
              nm, mo$true, mo$beta, mo$ci_lo, mo$ci_hi, mo$recov))
}
# K-L corrected versions (use lambda_hat from Step 12a)
cat(sprintf("\n  K-L corrected (lambda_hat = %.4f):\n", lambda_hat))
for (nm in names(multi_outcome)) {
  mo <- multi_outcome[[nm]]
  bkl  <- mo$beta / lambda_hat
  sekl <- mo$se   / lambda_hat
  cat(sprintf("  %-20s  β_KL=%.4f  CI=[%.4f, %.4f]  recovery=%.1f%%\n",
              nm, bkl,
              bkl - 1.96 * sekl, bkl + 1.96 * sekl,
              bkl / mo$true * 100))
}
cat("\n")

cat("Done.\n")
