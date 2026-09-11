#!/usr/bin/env Rscript
# ==============================================================================
# generate_refusal_tax_data.R
# -----------------------------
# Synthetic data for "The Refusal Tax" (bouldergearlab
# content/data-projects/refusal-tax).
#
# No public dataset pairs a safety-classifier rollout with user-level
# retention outcomes -- that pairing does not exist to download, so this
# script builds one with a known ground truth, the same pattern used
# elsewhere in this repo (e.g. model-quality/gap_analyses.R). A known causal
# effect (TRUE_FRICTION_BETA) is injected alongside two confounds (an
# academic-calendar churn shock and deliberate malicious-actor departure),
# and the point of the exercise is to show that a naive before/after or
# grouped comparison cannot separate them while a within-version estimator
# with measurement-error correction can.
#
# This is illustrative data built to demonstrate a methodology, not a
# substitute for real safety telemetry. The article discloses this plainly.
#
# Run from repo root: Rscript scripts/generate_refusal_tax_data.R
# Deps: jsonlite
# ==============================================================================

suppressPackageStartupMessages({
  library(jsonlite)
})

ROOT    <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE))), ".."))
OUT_DIR <- file.path(ROOT, "content", "data-projects", "refusal-tax", "data")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

RANDOM_SEED <- 42
set.seed(RANDOM_SEED)

N_USERS               <- 15000
PROMPTS_PER_USER_PRE  <- 20   # used to build noisy split-half intent-share estimates

CATEGORIES <- c("coding", "creative_writing", "academic_biology", "dual_use_biology", "general_qa")

# Classifier patch strength per category, added to per-prompt refusal probability post-rollout.
PATCH_DELTA <- c(
  coding = 0.00,
  creative_writing = 0.01,
  academic_biology = 0.07,   # false-positive prone: academic phrasing looks dual-use-adjacent
  dual_use_biology = 0.85,   # correctly fires on true dual-use prompts
  general_qa = 0.01
)
BASE_REFUSAL_RATE <- c(
  coding = 0.01,
  creative_writing = 0.01,
  academic_biology = 0.012,
  dual_use_biology = 0.04,
  general_qa = 0.01
)

ARCHETYPE_SHARE <- c(general = 0.72, student = 0.25, malicious = 0.03)

# Injected ground truth -- what the article's Tier 3 estimator has to recover.
TRUE_FRICTION_BETA   <- 0.55   # linear-probability churn increase per unit of centered exposure (benign friction)
MACRO_SHOCK_STUDENT  <- 0.045  # academic-calendar churn shock, hits students regardless of refusals
MALICIOUS_LEAVE_BUMP <- 0.55   # deliberate departure after being blocked on a dual-use prompt
BASE_CHURN           <- 0.05   # background 30-day churn unrelated to any of the above

# Draw one Dirichlet vector via normalized independent Gammas.
rdirichlet1 <- function(alpha) {
  g <- rgamma(length(alpha), shape = alpha, rate = 1)
  g / sum(g)
}

draw_intent_shares <- function(archetype) {
  n <- length(archetype)
  shares <- matrix(0, nrow = n, ncol = length(CATEGORIES))
  for (i in seq_len(n)) {
    alpha <- switch(archetype[i],
      student   = c(3, 2, 6, 0.1, 3),    # academic_biology elevated
      malicious = c(2, 1, 1, 6, 2),      # dual_use_biology elevated
      c(4, 4, 0.4, 0.02, 4)              # general population, biology is a minor interest
    )
    shares[i, ] <- rdirichlet1(alpha)
  }
  colnames(shares) <- CATEGORIES
  as.data.frame(shares)
}

sample_prompt_categories <- function(shares_row, n) {
  sample(CATEGORIES, size = n, replace = TRUE, prob = shares_row)
}

refusal_rate <- function(category, post) {
  delta <- if (post) PATCH_DELTA[[category]] else 0.0
  BASE_REFUSAL_RATE[[category]] + delta
}

main <- function() {
  archetype   <- sample(names(ARCHETYPE_SHARE), N_USERS, replace = TRUE, prob = ARCHETYPE_SHARE)
  true_shares <- draw_intent_shares(archetype)

  # ── Split-half noisy intent-share estimates from a finite pre-period sample ──
  half_a_bio     <- numeric(N_USERS)
  half_b_bio     <- numeric(N_USERS)
  full_bio_noisy <- numeric(N_USERS)
  for (i in seq_len(N_USERS)) {
    prompts <- sample_prompt_categories(as.numeric(true_shares[i, ]), PROMPTS_PER_USER_PRE)
    half <- PROMPTS_PER_USER_PRE %/% 2
    half_a <- prompts[seq_len(half)]
    half_b <- prompts[(half + 1):PROMPTS_PER_USER_PRE]
    half_a_bio[i]     <- mean(half_a == "academic_biology")
    half_b_bio[i]     <- mean(half_b == "academic_biology")
    full_bio_noisy[i] <- mean(prompts == "academic_biology")
  }

  split_half_r <- cor(half_a_bio, half_b_bio)
  reliability  <- (2 * split_half_r) / (1 + split_half_r)  # Spearman-Brown, full-period estimate

  # ── Tier 1: telemetry, refusal rate on academic_biology-domain prompts pre vs post ──
  pre_bio_refusal  <- refusal_rate("academic_biology", post = FALSE)
  post_bio_refusal <- refusal_rate("academic_biology", post = TRUE)
  pre_fpr  <- pre_bio_refusal   # all academic_biology prompts here are benign-intent by construction
  post_fpr <- post_bio_refusal

  # ── Per-user post-window refusal flags (did this user get refused at least once) ──
  user_refused_post <- function(shares_row) {
    prompts <- sample_prompt_categories(as.numeric(shares_row), 12)
    refused_any <- FALSE
    refused_dual_use <- FALSE
    for (c in prompts) {
      if (runif(1) < refusal_rate(c, post = TRUE)) {
        refused_any <- TRUE
        if (c == "dual_use_biology") refused_dual_use <- TRUE
      }
    }
    c(refused_any, refused_dual_use)
  }

  refused_any      <- logical(N_USERS)
  refused_dual_use <- logical(N_USERS)
  for (i in seq_len(N_USERS)) {
    r <- user_refused_post(true_shares[i, ])
    refused_any[i]      <- r[1]
    refused_dual_use[i] <- r[2]
  }

  # ── Outcome: churn under the full generative model (linear probability, clipped) ──
  is_student   <- archetype == "student"
  is_malicious <- archetype == "malicious"

  # Friction only acts through the academic_biology component of exposure -- the
  # false-positive-prone half of the patch. The dual_use component drives the
  # malicious-departure mechanism instead, handled separately below.
  true_bio_exposure    <- true_shares$academic_biology * PATCH_DELTA[["academic_biology"]]
  true_bio_exposure_c  <- true_bio_exposure - mean(true_bio_exposure)
  noisy_bio_exposure   <- full_bio_noisy * PATCH_DELTA[["academic_biology"]]
  noisy_bio_exposure_c <- noisy_bio_exposure - mean(noisy_bio_exposure)

  churn_prob <- function(friction_on, macro_on, malicious_on) {
    p <- rep(BASE_CHURN, N_USERS)
    if (macro_on)     p <- p + MACRO_SHOCK_STUDENT * is_student
    if (malicious_on) p <- p + MALICIOUS_LEAVE_BUMP * (is_malicious & refused_dual_use)
    if (friction_on)  p <- p + TRUE_FRICTION_BETA * true_bio_exposure_c
    pmin(pmax(p, 0.0), 1.0)
  }

  # One shared uniform draw per user so every ablation scenario below is a real
  # counterfactual for the same user, not a fresh, uncorrelated random draw.
  u      <- runif(N_USERS)
  p_full <- churn_prob(TRUE, TRUE, TRUE)
  churn  <- u < p_full

  # ── Naive Tier 2 comparison: refused vs never-refused, post-rollout ──
  naive_refused_rate   <- mean(churn[refused_any])
  naive_unrefused_rate <- mean(churn[!refused_any])
  naive_gap            <- naive_refused_rate - naive_unrefused_rate

  # ── Ground-truth decomposition via mechanism ablation on the SAME draws ──
  gap_with <- function(friction_on, macro_on, malicious_on) {
    p <- churn_prob(friction_on, macro_on, malicious_on)
    c_ <- u < p
    mean(c_[refused_any]) - mean(c_[!refused_any])
  }

  gap_full        <- gap_with(TRUE, TRUE, TRUE)
  gap_no_friction  <- gap_with(FALSE, TRUE, TRUE)
  gap_no_macro     <- gap_with(TRUE, FALSE, TRUE)
  gap_no_malicious <- gap_with(TRUE, TRUE, FALSE)

  friction_contribution  <- gap_full - gap_no_friction
  macro_contribution     <- gap_full - gap_no_macro
  malicious_contribution <- gap_full - gap_no_malicious

  # ── Tier 3: within-version logistic regression, restricted to non-malicious users ──
  # Malicious departure is excluded here by design, not modeled away: which category
  # triggered a refusal is known, so users blocked only on dual-use prompts are a
  # separately understood mechanism, not part of the friction estimate.
  benign_mask <- !is_malicious
  churn_b   <- as.integer(churn[benign_mask])
  student_b <- as.integer(is_student[benign_mask])
  exposure_b <- noisy_bio_exposure_c[benign_mask]

  # Naive: exposure alone, no cohort control -- confounded by the academic-calendar shock.
  model_naive <- glm(churn_b ~ exposure_b, family = binomial())
  beta_naive_logodds <- unname(coef(model_naive)["exposure_b"])

  # Controlled: exposure + observable cohort membership (is_student), still on noisy exposure.
  model_ctrl <- glm(churn_b ~ exposure_b + student_b, family = binomial())
  beta_raw_logodds <- unname(coef(model_ctrl)["exposure_b"])
  beta_corrected_logodds <- beta_raw_logodds / reliability

  # Convert the true injected linear-probability beta to an approximate log-odds
  # scale at the sample mean churn rate, so it's comparable to the regression output.
  p_bar <- mean(churn_b)
  true_beta_logodds_equiv <- TRUE_FRICTION_BETA / (p_bar * (1 - p_bar))

  results <- list(
    n_users = N_USERS,
    archetype_share = as.list(ARCHETYPE_SHARE),
    reliability = list(
      split_half_r = round(split_half_r, 3),
      spearman_brown_reliability = round(reliability, 3)
    ),
    tier1_telemetry = list(
      academic_biology_refusal_rate_pre = round(pre_bio_refusal, 4),
      academic_biology_refusal_rate_post = round(post_bio_refusal, 4),
      false_positive_rate_pre = round(pre_fpr, 4),
      false_positive_rate_post = round(post_fpr, 4)
    ),
    tier2_naive = list(
      retention_refused = round(1 - naive_refused_rate, 4),
      retention_unrefused = round(1 - naive_unrefused_rate, 4),
      naive_churn_gap_pp = round(naive_gap * 100, 2)
    ),
    tier3_decomposition_pp = list(
      total_gap = round(gap_full * 100, 2),
      macro_seasonality = round(macro_contribution * 100, 2),
      malicious_departure = round(malicious_contribution * 100, 2),
      benign_friction = round(friction_contribution * 100, 2)
    ),
    tier3_estimator = list(
      beta_naive_nocontrol_logodds = round(beta_naive_logodds, 4),
      beta_raw_controlled_logodds = round(beta_raw_logodds, 4),
      beta_corrected_logodds = round(beta_corrected_logodds, 4),
      true_beta_logodds_equiv = round(true_beta_logodds_equiv, 4),
      naive_pct_of_true = round(100 * beta_naive_logodds / true_beta_logodds_equiv, 1),
      raw_pct_of_true = round(100 * beta_raw_logodds / true_beta_logodds_equiv, 1),
      corrected_pct_of_true = round(100 * beta_corrected_logodds / true_beta_logodds_equiv, 1)
    )
  )

  json_out <- toJSON(results, auto_unbox = TRUE, pretty = TRUE)
  cat(json_out, "\n")
  writeLines(json_out, file.path(OUT_DIR, "results.json"))
  cat(sprintf("\nWrote %s\n", file.path(OUT_DIR, "results.json")))
}

main()
