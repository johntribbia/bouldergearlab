# Identifying Model Quality Effects on User Engagement: A Within-Version Causal Estimator with Synthetic Data Validation

**John Tribbia**

---

## Abstract

Measuring the causal impact of model quality improvements on user engagement is a central challenge in AI product analytics. Traditional before-after comparisons suffer from severe confounding: when an AI system is upgraded, marketing, product features, and usage context change simultaneously. This paper presents a methodological contribution: a within-version causal estimator that exploits structural variation in how different users experience model quality, even under the same deployed version. The identifying assumption — that after controlling for model version, baseline characteristics, and observable usage patterns, quality variation is exogenous — is formalized through a causal DAG and validated via a frozen-weights design.

We validate the estimator's properties using synthetic data with a known injected causal mechanism (β = 1.0 on the log-odds scale). The estimator recovers approximately 90% of the true effect on the full sample; a Klepper-Leamer errors-in-variables correction (λ̂ = 0.80) pushes the adjusted estimate to β_KL = 1.10 with a 95% confidence interval of [0.86, 1.33] — critically, this interval formally contains the injected ground truth of 1.0, confirming the correction operates at a calibration level and not merely directionally. The estimator correctly distinguishes between outcome variables with causal signals (active days) and those without (prompt volume). A user-weight permutation test confirms the null condition (p = 0.26), while a benchmark comparison shows the proposed method outperforms naive alternatives: 88% recovery vs. 67% (naive OLS without version fixed effects) and 50% (real-time endogenous weights). Frozen-weights sensitivity analysis demonstrates that recovery is monotone in pre-period length, from 77% (3 weeks) to 88% (7 weeks, canonical), quantifying the measurement error reduction from additional pre-period data. We discuss how this attenuation pattern is explained by classical errors-in-variables theory, identify a limitation of time-shifted placebo tests in monotone-quality settings, and provide practical guidance for implementation.

**Keywords:** causal inference, product analytics, model quality, user engagement, observational design, within-subject variation, errors-in-variables, GAMM

---

## 1. Introduction

In practice, every AI company ships an update with the same assumption: quality improvements will increase engagement. Yet when it comes time to justify the investment — to show that a 10% coding benchmark improvement actually kept users from leaving — the evidence rarely exists. When a model launches, you're simultaneously running new ad campaigns, press is covering your announcement, and users may have seasonal activity patterns. Disentangling the model's contribution from that noise is genuinely difficult.

Our product teams faced a recurring problem: they could measure incremental model improvements, but couldn't credibly show whether those improvements actually changed user behavior. Without that evidence, it was impossible to justify continued investment in model evaluation.

Standard causal methods — difference-in-differences, regression discontinuity, matching — all require either a treated and control period or treated and control units. AI deployment doesn't fit either pattern: everyone gets the new model simultaneously at a fixed date. Holdout designs, while the causal gold standard, are rarely feasible in practice due to product and business constraints.

There is a simpler alternative: use the heterogeneity that already exists. Even under the same model version, users have different experiences because they use the tool for different tasks. A developer debugging code encounters different quality than a writer seeking creative suggestions, since models don't improve uniformly across domains. This variation in experienced quality — driven by usage patterns — contains causal information. We can treat this natural variation as a source of identification.

We validate this estimator on synthetic data with a known causal effect. This is standard in causal inference (Angrist and Pischke 2008; Imbens 2019) precisely because real data offers no ground truth. Only with synthetic data can we perform unambiguous calibration checks, verifying that the estimator recovers the effect when we know what that effect is.

### 1.1 Contributions

- **A novel identification strategy** for measuring model quality's causal impact on engagement, using within-version variation driven by heterogeneous usage patterns. The approach requires only observational data on user behavior, category-level offline evaluations, and explicit control for version indicators.

- **Formal causal identification** through a DAG and frozen-weights design. We specify the conditional independence assumption required for causal estimation and provide empirical evidence for the stability of usage weights across time periods.

- **Calibration validation on synthetic data.** The estimator recovers approximately 88–90% of a known injected effect (β = 1.0), with cluster-robust and K-L corrected confidence intervals including the true value. The attenuation pattern follows directly from classical errors-in-variables theory and varies predictably with pre-period length.

- **Strengthened falsification tests.** We replace the derangement placebo with a user-weight permutation test that breaks the correlation between quality exposure and user identity, producing a clean null (r ≈ 0 vs. r = −0.44 for derangement). We identify a structural limitation of time-shifted placebo tests in monotone-quality settings and recommend the permutation approach as more reliable.

- **Klepper-Leamer errors-in-variables correction.** We derive reliability λ from cross-period stability correlations and show the corrected estimate β_KL = 1.10 with a CI that includes the true value, addressing measurement error formally rather than treating attenuation as unexplained.

- **Benchmark comparisons confirming relative advantage.** We fit four alternative estimators — naive OLS, real-time endogenous weights, user-level DiD, and user fixed-effects OLS — and show the proposed method minimizes bias (−12%) versus alternatives that suffer substantially larger biases (−33%, −51%, and wrong-direction inflation for linear approximations of the binomial outcome).

- **A framework for constructing causal investment maps:** quantifying marginal returns to quality improvements by category.

---

## 2. Related Work

### 2.1 Causal Inference in Observational Settings

This paper builds on foundational work in causal inference under observational designs. The identifying assumption — conditional independence after controlling for version, baseline characteristics, and usage patterns — is a selection-on-observables assumption (Rosenbaum and Rubin 1983), but weaker than requiring all confounders to be observed. The frozen-weights design borrows ideas from regression discontinuity (Imbens and Lemieux 2008) and threshold designs, where a sharp structural change (model deployment) is leveraged to identify effects.

Our use of within-unit variation to control for time-invariant confounding is related to fixed-effects and random-effects specifications in panel data (Wooldridge 2010), though we exploit within-unit time-varying covariate structure rather than panel structure itself. The approach is closest to covariate balancing methods (Imai and Ratkovic 2014) that use observable characteristics to construct exogenous variation.

The frozen-weights strategy addresses a specific form of endogeneity: reverse causality. If model quality improvements cause users to shift their usage toward categories where the improvement occurred, using real-time weights would embed the outcome into the predictor. Freezing weights at a pre-period eliminates this simultaneity bias. We quantify this directly: using real-time weights yields only 50% recovery versus 88% for frozen weights (Section 4.6).

Recent work on structural confounding (D'Amour et al. 2017) and the use of causal forests for heterogeneous treatment effects (Athey and Wager 2019) provides complementary approaches to our parametric GAM strategy. These methods could be applied to test for heterogeneity in quality effects across user segments.

### 2.2 Product Analytics and AI Quality Measurement

The business analytics literature has long grappled with measuring feature impact on engagement. A/B testing (Kohavi et al. 2009) is the gold standard but faces practical constraints when features must be deployed to all users or when randomization is infeasible due to network effects or consistency concerns. Observational methods for product impact measurement (Eckles et al. 2016) typically use regression, difference-in-differences, or matching, all of which require assumptions about confounding.

AI-specific quality measurement has emerged as a critical challenge (Lewis et al. 2023). Most companies track model performance through offline benchmarks, but the link between offline improvements and user behavior remains poorly understood. Our paper directly addresses this gap by developing a method to quantify the user-facing impact of quality improvements, using only observational data and no randomization.

Heterogeneous model performance across domains (coding vs. creative writing) is well-documented in LLM evaluations (Hendrycks et al. 2020, OpenAI 2023). We exploit this heterogeneity as a source of identification, turning an observed limitation of models — uneven performance — into an analytical tool.

### 2.3 Errors-in-Variables and Measurement Error

We observe 88–90% recovery of the true effect, with the remaining 10–12% attenuation attributable to measurement error in the quality exposure variable. This is a textbook application of classical errors-in-variables bias (Bound et al. 1995). Observed usage proportions are noisy draws from a latent user preference distribution; using them to construct Q_it_c introduces attenuation. We document this relationship empirically through frozen-weights sensitivity analysis: shorter pre-periods yield noisier weight estimates and correspondingly greater attenuation (Section 3.4 and 4.3).

We now treat this not as unexplained residual but as a solvable measurement problem. The Klepper-Leamer scaling approach (Klepper and Leamer 1984) — estimating reliability λ from cross-period stability correlations and dividing β̂ by λ̂ — yields a corrected estimate that covers the true value. The method has natural extensions to instrumental variable approaches if additional instruments are available.

---

## 3. Methods

### 3.1 Causal Model and Identification

We specify the causal structure through a directed acyclic graph (DAG). Let V denote the model version deployed at time t, X denote user baseline characteristics (subscription tier, user type, pre-project engagement), C denote category-level usage patterns, Q_c denote offline model quality ratings by category, and Y denote the engagement outcome.

The identifying assumption is:

$$Q^c_{i,t} \perp \varepsilon_Y \mid V, X$$

Where $Q^c_{i,t}$ is centered (within-version) quality exposure and $\varepsilon_Y$ is the outcome error term. In words: after conditioning on model version and baseline user characteristics, the remaining variation in quality exposure (driven by category mix) is exogenous with respect to engagement errors. Version indicators absorb all between-version confounding (marketing, product changes, seasonality). The variation in category mix across users provides within-version identification.

This assumption is weaker than full instrumental variable assumptions but requires that no unobserved factor simultaneously drives both category preference and engagement beyond the measured covariates. Its plausibility rests on the frozen-weights design: when usage weights are fixed at pre-period values, they reflect latent structural preferences formed before any quality signal from the current version is observed.

### 3.2 Data Generating Process and Synthetic Design

We construct synthetic data matching a large-scale AI assistant product: 100,000 users over 26 weeks across three deployed model versions (at weeks 1, 8, and 16).

The data includes three components:

1. **Offline model evaluations:** 50,000 human-rated quality scores (1–5 scale) across five prompt categories (Coding, Creative Writing, General Q&A, Math/Logic, Scientific) and three model versions.
2. **Engagement time series:** 1,500,980 weekly observation records per user including category-level prompt counts and binary active-day indicators (1 if user had at least one session, 0 otherwise).
3. **User demographics:** 100,000 user records with subscription tier (Consumer/Enterprise), role, and pre-project baseline engagement.

The critical feature of this DGP is that the causal effect is explicitly injected. We set β_true = 1.0 on the log-odds scale: within-version quality exposure directly affects the probability of being active on any given week. This creates a ground truth against which we can assess estimator performance.

Quality improvements are heterogeneous across categories and versions. Model quality monotonically improves (v1.2 > v1.1 > v1.0) but unevenly: Coding improves from 3.50 to 4.41; Creative Writing from 2.79 to 3.77. This heterogeneity creates meaningful differences in experienced quality across users. We note that this monotone structure has implications for falsification tests, discussed in Section 3.7.

**Additional outcomes for robustness.** Beyond the primary binary outcome (active days), the DGP also injects known effects into churn probability (β_churn = −0.6 on the log-odds scale) and session duration (β_duration = 0.4 on the log scale), enabling multi-outcome calibration checks.

### 3.3 Computing Quality Exposure and Centering

For each user i and week t, we compute their experienced quality as a weighted average of category-level ratings:

$$Q_{i,t} = \sum_c w_{i,c} \cdot q_{c,v(t)}$$

Where $w_{i,c}$ is user i's fixed weight on category c (computed from pre-period usage), and $q_{c,v(t)}$ is the quality rating for category c under version v deployed at time t. Weights are frozen at pre-period (weeks 1–7) values.

We center by subtracting the population mean quality within each version period:

$$Q^c_{i,t} = Q_{i,t} - \bar{Q}_{v(t)}$$

This removes the version-level step-change; the version indicator absorbs deployment jumps while the centered quality variable isolates within-version differences. The resulting comparison is between two users with identical model versions who differ only in their category usage mix.

### 3.4 Frozen-Weights Sensitivity Analysis

The choice of pre-period length is a tuning parameter: longer periods yield more stable weight estimates but require more historical data. We assess sensitivity by refitting the model under three different freeze windows:

| Freeze window | Weeks used | r(Q_fw, Q_canon) | β̂ | Recovery |
|---|---|---|---|---|
| Early | 1–3 | 0.9251 | 0.773 | 77.3% |
| Mid | 1–5 | 0.9759 | 0.819 | 81.9% |
| Full (canonical) | 1–7 | 0.9999 | 0.877 | 87.7% |

Recovery is monotone in pre-period length. The early window (3 weeks) underestimates by 10 percentage points relative to the canonical window. This is mechanically explained by errors-in-variables: a 3-week estimate of usage preferences is noisier than a 7-week estimate, producing greater classical attenuation. The high correlations between freeze-window quality measures and the canonical measure (r = 0.93–1.00) confirm the variation is in noise amplitude, not in the structural preference ranking. In practice, we recommend the longest feasible pre-period before the first quality intervention; 7 weeks is the minimum for negligible attenuation.

### 3.5 Statistical Model

We model the binary outcome (active or not in week t) using a Generalized Additive Mixed Model (GAMM) fitted via penalized maximum likelihood (fREML in the mgcv R package):

```r
bam(cbind(active_days, 7 - active_days) ~ s(Q_it_c, bs = "tp", k = 10) + version_f +
    s(week, bs = "tp", k = 10) + s(user_id_factor, bs = "re") + user_type +
    pre_project_engagement_score, family = binomial(), method = "fREML", discrete = TRUE)
```

The key term is `s(Q_it_c)`, the smooth function of centered quality. This is a penalized thin-plate spline (bs = "tp") with maximum 10 basis functions, allowing the model to detect nonlinearity if present while remaining parsimonious. The version factor (`version_f`) absorbs between-version level shifts; `s(week)` captures residual time trends; `s(user_id_factor, bs = "re")` includes random intercepts for each user to account for within-user clustering.

We fit the model on a stratified subsample of 2,000 users (approximately 30,000 observations), preserving the population 70/30 Consumer/Enterprise ratio.

### 3.6 Cluster-Robust Inference and Klepper-Leamer Correction

**Cluster-robust bootstrap.** Standard errors from GAMM assume independent observations. Our data violates this: observations are clustered within users. We use cluster-robust bootstrap: resample users with replacement, refit the linear parametric model on each bootstrap sample, and compute confidence intervals from the bootstrap distribution. B = 100 bootstrap iterations, user-level block resampling.

**Klepper-Leamer correction.** Observed category counts are noisy measures of latent usage preferences. The reliability of Q_it_c as an instrument for latent quality exposure is estimated from cross-period Pearson correlations (r between Q scores computed from each version period's usage):

$$\hat{\lambda} = \text{mean}\left(r_{v_j, v_k}^2\right) \quad \text{across all version pairs}$$

Cross-period correlations are r = 0.922 (v1.0 vs v1.1), r = 0.943 (v1.1 vs v1.2), and r = 0.812 (v1.0 vs v1.2), yielding λ̂ = 0.80. The corrected estimate is β_KL = β̂ / λ̂ = 1.10.

We present results from both inference methods. The cluster-robust bootstrap CI [0.82, 1.01] provides nominal coverage under the noise model. The K-L corrected CI [0.86, 1.33] formally accounts for measurement error but assumes classical (non-differential) errors.

### 3.7 Falsification Tests

**User-weight permutation test (primary).** We permute Q_it_c values within version groups, shuffling quality exposure across users while preserving the version distribution. The permuted quality score has correlation r ≈ 0 with the real score by construction. If the model finds signal in the permuted variable, the estimator is extracting noise rather than causal variation. This is a stronger null than the derangement approach used in earlier work (r = −0.44 for derangement vs. r ≈ 0 for permutation).

**Time-shifted (lead) placebo.** We construct a quality exposure measure using the *next* version's quality ratings applied to the current period's frozen weights: v1.0-period users get v1.1 quality, v1.1-period users get v1.2 quality, and v1.2-period users wrap to v1.0 quality. In settings where consecutive model quality is uncorrelated, this should produce a null result.

**DGP limitation for the lead test.** In this synthetic DGP, quality improvements are strictly monotone across versions and all categories, so lead quality is strongly correlated with current quality (r = 0.90). The lead test therefore does not provide a clean null and should not be interpreted as a falsification test under these conditions. The permutation test — which destroys all correlation — remains the appropriate null test for this DGP. In real-world settings with non-monotone quality trajectories (where some categories regress or stagnate), the lead/lag test would be more informative.

---

## 4. Results

### 4.1 Effect of Quality on Active Days (Primary Outcome)

The GAMM reveals a strong, highly significant effect of within-version quality on active days:

| Term | Test Stat / Estimate | p-value | Notes |
|------|----------------------|---------|-------|
| **s(Q_it_c), edf = 1.62** | **χ² = 341.65** | **< 2 × 10⁻¹⁶** | **Main effect** |
| **version_f v1.1** | **β = 0.194** | **< 2 × 10⁻¹⁶** | **Version shift (confounded)** |
| **version_f v1.2** | **β = 0.371** | **< 2 × 10⁻¹⁶** | **Version shift (confounded)** |
| **s(week), edf = 1.50** | **χ² = 0.54** | **0.775** | **No residual trend** |
| **Model summary** | **Dev. exp. = 27.1%** | **Adj. R² = 0.289** | **2,000 users** |

The quality effect is highly significant (χ² = 341.65, p < 2 × 10⁻¹⁶). The effective degrees of freedom (edf = 1.62) indicate slight curvature beyond linearity, but the dominant shape is linear. The version indicators are substantially larger (β_v1.1 = 0.194, β_v1.2 = 0.371) than the within-version quality effect — by a factor of 4–5 on the same log-odds scale. This illustrates the confounding problem the within-version approach is designed to overcome.

### 4.2 Calibration Recovery: Recovering the True Effect

The critical validation is whether the estimator recovers β_true = 1.0. Results across estimation methods:

| Method | Estimate | 95% CI | Recovery |
|--------|----------|--------|----------|
| **Linear model** | **0.899** | **[0.803, 0.994]** | **90%** |
| **GAM smooth** | **0.882** | **—** | **88%** |
| **Cluster bootstrap** | **0.898** | **[0.816, 1.005]** | **90%** |
| **K-L corrected** | **1.097** | **[0.862, 1.332]** | **110%** |
| **True value** | **1.000** | **—** | **100%** |

All uncorrected approaches recover approximately 88–90% of the true effect. The attenuation pattern is consistent with classical errors-in-variables: observed category weights are noisy proxies for latent preferences. The K-L corrected estimate (β_KL = 1.097) slightly overcorrects but has a 95% CI [0.862, 1.332] that contains the true value. The cluster-robust bootstrap CI [0.816, 1.005] includes the true value, while the parametric CI [0.803, 0.994] narrowly misses — confirming that cluster-robust inference is necessary for correct coverage.

### 4.3 Frozen-Weights Sensitivity Results

The recovery-versus-freeze-window analysis (Table 1) demonstrates that attenuation is mechanically explained by measurement noise in weight estimation. With only 3 weeks of pre-period data, the quality exposure variable is meaningfully noisier (recovery = 77%), and the canonical 7-week window reduces this to approximately 10–12% total attenuation. The near-perfect correlation between the 7-week and 5-week quality measures (r = 0.976) indicates most of the measurement error reduction occurs in the first five weeks; extending to seven weeks provides modest additional improvement.

This sensitivity analysis serves two purposes: (1) it validates the frozen-weights assumption by showing that recovery is stable as the freeze window approaches the canonical choice, not arbitrary or fragile; (2) it quantifies the minimum pre-period required in practice. Datasets with shorter historical periods should expect greater attenuation, which can be partially corrected via K-L adjustment using λ derived from their available stability correlations.

### 4.4 Outcome Specificity: Active Days vs. Prompt Volume

The DGP injects causality into active days but not into prompt volume. Results:

- **Active days:** χ² = 341.65, p < 2 × 10⁻¹⁶ (highly significant)
- **Prompt volume:** χ² = 0.35, p = 0.816 (non-significant)

The outcome-specific finding — quality predicts active days but not prompt volume — validates the approach. Users respond to quality improvements by showing up more (engagement on the extensive margin: activation) rather than by using the product more intensely once present (intensive margin: prompt count).

### 4.5 Falsification Tests

| Test | β̂ | p-value | Interpretation |
|------|----|---------|----------------|
| **Real quality** | **0.877** | **5.95 × 10⁻²⁰** | Signal detected (expected) |
| **Permuted quality** | **−0.106** | **0.265** | Null confirmed ✓ |
| **Lead quality** | **0.816** | **~0** | DGP artifact (see note) |

The permutation test produces a clean null (β = −0.106, p = 0.265), confirming that when the correlation between quality exposure and user identity is destroyed, the estimator finds no signal. The permuted quality explains only 12% of the real effect in absolute magnitude, consistent with pure noise.

The lead quality test fails to produce a null result (p ≈ 0) because the correlation between current-version and lead-version quality is r = 0.90 in this monotone DGP. The result means that any method that correctly captures the current-quality signal will also find a nearly equivalent signal with lead quality, since they are nearly interchangeable measures. This is not a methodological failure of the estimator — it is a structural property of the DGP, and it motivates the permutation approach as the primary falsification tool.

### 4.6 Benchmark Comparisons

We compare the proposed method to four alternative estimators on the same stratified 2,000-user sample, holding TRUE_BETA = 1.0:

| Method | β̂ | Bias | Recovery |
|--------|-----|------|----------|
| **Proposed (frozen frozen weights, GAMM)** | **0.877** | **−0.123** | **87.7%** |
| Naive OLS (raw Q_it, no version FE) | 0.674 | −0.326 | 67.4% |
| Real-time weights (endogenous) | 0.495 | −0.505 | 49.5% |
| User FE OLS (within-user, linear) | inflated† | — | — |
| User DiD (delta method, linear) | inflated† | — | — |

†BM3 and BM4 use OLS on the count-scale active_{days} outcome (∈ [1,7]) and convert to log-odds via a linear delta method. The resulting coefficients are inflated by a factor of ~4 (the inverse of p̄(1 − p̄)), and the conversion is theoretically invalid for a bounded discrete outcome. Including them demonstrates why linear approximations to binomial outcomes should not be used for this type of analysis; the GAMM with binomial family is the appropriate model.

The proposed method's relative advantage is clear for the two directly comparable methods. The naive OLS approach — which adds back the version-level mean to the centered quality and omits version fixed effects — suffers 33 percentage points more bias than the proposed approach. The endogenous real-time weights approach, which uses current-week category mix (potentially influenced by the outcome), suffers 51 percentage points more bias, consistent with the upward-bias expectation from reverse causality in the weight construction.

### 4.7 Consumer vs. Enterprise Heterogeneity

Both segments show significant quality effects (p < 2 × 10⁻¹⁶; Consumer: dev. exp. = 26.2%; Enterprise: dev. exp. = 29.9%), confirming the estimator recovers effects at the subgroup level. Enterprise users show slightly higher quality sensitivity, consistent with investment patterns in that segment.

### 4.8 Multi-Outcome Calibration

To assess whether the estimator's calibration generalizes beyond the primary outcome, we fit the same GAMM specification to two additional outcomes with known injected effects: churn risk (binary; TRUE_β = −0.6 on the log-odds scale) and session duration (continuous log-scale; TRUE_β = 0.4). All three outcomes use identical model structure and the same frozen pre-period quality weights.

| Outcome | TRUE β | β̂ | 95% CI | Recovery |
|---|---|---|---|---|
| Active days (primary) | 1.000 | 0.877 | [0.689, 1.065] | 87.7% |
| Churn risk | −0.600 | −0.738 | [−1.412, −0.063] | 123.0% |
| Session duration (log) | 0.400 | 0.405 | [0.349, 0.461] | 101.3% |

In all three cases the 95% CI contains the injected true value. Active days show characteristic attenuation attributable to errors-in-variables. Churn risk over-recovers slightly (123%), consistent with higher estimation variance on binary outcomes in this sample size. Session duration recovers to within 1.3% of the true effect with a narrow CI, reflecting lower measurement error for the continuous outcome.

Applying the K-L correction derived from the primary outcome (λ̂ = 0.80) to all three yields β_KL = 1.10 (active days), −0.92 (churn risk), and 0.51 (session duration), with recoveries of 110%, 154%, and 127%, respectively. The over-correction for churn and session duration is expected: the measurement-error parameter λ is calibrated to the primary binary outcome, and its direct application to outcomes with different noise structures produces overcorrection. Outcome-specific λ estimates, derived from each outcome's own weight-stability correlations, would be appropriate in multi-outcome deployments; we treat this as future work.

---

## 5. Discussion

### 5.1 Interpretation and Validity

The estimator recovers approximately 88–90% of the injected true effect (β_true = 1.0 → β̂ ≈ 0.88–0.90). The remaining 10–12% attenuation follows directly from classical errors-in-variables theory: observed category proportions are noisy draws from latent usage preferences, and using them to construct Q_it_c introduces bias toward zero. The Klepper-Leamer correction addresses this mechanically: with estimated reliability λ̂ = 0.80, the corrected estimate β_KL = 1.097 covers the true value, though the CI is wider than the uncorrected version.

Frozen-weights sensitivity confirms the attenuation is a function of pre-period length: shorter windows → noisier weights → greater attenuation, following the expected errors-in-variables relationship. This is not a threat to validity but a characterization of the tradeoff between data availability and measurement precision.

The cluster-robust bootstrap CI [0.816, 1.005] includes the true value. This demonstrates that accounting for within-user correlation in inference is necessary; naive standard errors from GAMM are too small for this setting.

### 5.2 Falsification Framework

Our falsification strategy has two components, each testing a different threat to validity:

1. **Permutation test** (primary): Shuffles quality exposure within versions, breaking all correlation between exposure and user identity. A non-significant result (p = 0.265) confirms the estimator is responding to the causal signal, not to user-identity confounds.

2. **Lead/lag test** (conditional): Substitutes future-version quality for current-version quality. In settings with non-monotone quality trajectories, a significant lead effect would suggest temporal confounding. In monotone settings like our DGP, this test lacks discriminating power and should not be used in isolation.

We recommend both tests for real-world applications. The permutation test provides a reliable null regardless of quality trajectory structure. The lead test provides additional evidence in settings where quality improvements are category-specific and non-monotone — which is more realistic than our synthetic DGP. Real model quality data routinely exhibits this structure (some categories regressing after updates while others improve), which would restore discriminating power to the lead test and enable direct empirical validation of both falsification components simultaneously.

### 5.3 Limitations

- **Proof-of-concept design.** Synthetic validation confirms the method works when the ground truth is known, but cannot demonstrate real-world effectiveness where the true effect is unknowable.

- **Monotone quality DGP.** Our synthetic data features quality improvements that are strictly positive across all categories and versions. Real models often show performance regression in some categories following updates. This makes the synthetic DGP somewhat easier for the estimator (less category quality noise) and means the lead placebo test is not valid for this specific design.

- **Narrow quality spread.** Within-version standard deviations of centered quality are approximately 0.10 rating points. Real data with larger category-level quality differences would provide stronger signal with less relative measurement error.

- **Observational design.** Coding-heavy users differ from writing-heavy users beyond their quality exposure. A staggered deployment or holdout design would strengthen identification.

- **Frozen-weights assumption.** High correlations (r > 0.82) support stability, but imperfect stability contributes to classical attenuation. Real data may show more drift if quality improvements cause usage redistribution.

- **K-L correction assumes classical errors.** The Klepper-Leamer adjustment assumes measurement error is classical (non-differential, uncorrelated with the outcome). Systematic biases in prompt classification would require a different correction strategy.

### 5.4 Directions for Future Work

- **Real-data application.** Test the method on actual product data (e.g., WildChat-1M or similar pseudonymized datasets) and validate using staggered deployments where available.

- **Multi-outcome framework.** Extend calibration recovery to churn probability and session duration, where the DGP also injects known effects (β_churn = −0.6, β_duration = 0.4). These provide additional validation of estimator specificity across outcome types.

- **Category classification pipeline.** In practice, prompt categories are not observed directly but must be inferred. Embedding-based classification introduces additional measurement error that would further attenuate estimates, requiring larger λ corrections.

- **Heterogeneous effects.** Causal forests or other heterogeneity-aware methods could estimate segment-specific, user-specific, or category-specific returns to quality improvements.

- **Novelty vs. durable quality.** Decompose quality effects into short-term novelty boosts and sustained value. This requires cohort analysis with longer tracking periods.

### 5.5 Comparison to Naive Approaches

The version-level coefficients (β_v1.1 = 0.194, β_v1.2 = 0.371) are 4–5 times larger than the within-version quality effect on the same log-odds scale. This illustrates why naive before-after comparisons almost certainly overstate quality's contribution: when everyone receives the new model simultaneously, the deployment event is confounded with everything else that changed — marketing, press coverage, seasonal patterns. The within-version approach succeeds precisely because it compares users within the same version who differ only in their category usage mix.

The benchmark comparison further distinguishes the proposed approach from seemingly simpler alternatives: naive OLS recovers only 67% (omitting version fixed effects conflates version-level confounds with quality effects), and endogenous weights recover only 50% (real-time category mix introduces reverse causality). The proposed method's 88% recovery with a clean theoretical account of the remaining attenuation represents a meaningful improvement.

### 5.6 Practical Implementation

The method suits organizations with strict privacy requirements: it needs only category-level quality ratings and aggregated usage statistics, not individual-level data. Implementation requires:

1. **Offline evaluations:** Sample representative prompts per category and model version; assign quality ratings.
2. **Usage patterns:** Compute category proportions for each user, frozen at a pre-period of at least 5–7 weeks.
3. **Quality exposure:** Weighted-average quality using frozen proportions, centered within version.
4. **GAMM with binomial family:** Version fixed effects, user random effects, and cluster-robust inference.
5. **Sensitivity checks:** Permutation test, frozen-window sensitivity, K-L correction using cross-period stability correlations.

Teams should expect 10–12% attenuation under typical measurement conditions (λ ≈ 0.80–0.90), which can be reported with or without K-L correction based on whether the classical-errors assumption is plausible.

---

## 6. Conclusion

This paper develops and validates a method for measuring how model quality improvements affect user engagement. The within-version identification strategy exploits structural variation in how users with different usage patterns experience quality, even under the same deployed model version.

Validation on synthetic data with a known injected effect demonstrates several properties of the estimator:

- It recovers approximately 88–90% of truth under typical measurement conditions, with attenuation fully explained by classical errors-in-variables in the weight proxy for latent usage preferences.
- Frozen-weights sensitivity analysis quantifies the measurement error reduction from longer pre-periods (77% recovery at 3 weeks → 88% at 7 weeks), providing practical guidance for real implementations.
- The Klepper-Leamer correction recovers the full effect (β_KL = 1.10, CI includes 1.0) when reliability is estimated from cross-period correlations.
- The permutation test confirms the null condition (p = 0.265) more cleanly than the derangement placebo. The lead-quality test lacks discriminating power under monotone quality trajectories and should be used only in settings with non-monotone quality histories.
- The method outperforms naive alternatives: 88% recovery vs. 67% (naive OLS without version FE) and 50% (endogenous real-time weights).

The contribution is methodological: a procedure with known operating characteristics under synthetic validation. The next steps are real-data application and practical extensions to multi-outcome calibration. For product teams, the method enables construction of causal investment maps showing marginal returns to quality improvements by category. For researchers, it demonstrates how structural heterogeneity in exposure can enable causal identification in observational settings where traditional randomized designs are infeasible.

---

## References

Angrist, J. D., & Pischke, J. S. (2008). *Mostly Harmless Econometrics: An Empiricist's Companion*. Princeton University Press.

Athey, S., & Wager, S. (2019). Estimating heterogeneous treatment effects with observational data. *American Economic Review*, 109(5), 1852–88.

Bound, J., Brown, C., & Mathiowetz, N. (1995). Measurement error in survey data. In *Handbook of Econometrics* (Vol. 3, pp. 3705–3843).

D'Amour, A., Ding, P., Feller, A., Lei, L., & Sekhon, J. (2017). Overlap in observational studies with high-dimensional covariates. *arXiv preprint arXiv:1703.02041*.

Eckles, D., Iyer, R., Bakshy, E., & Lauterbach, M. A. (2016). Scalable and flexible methods for measuring complex treatment effect heterogeneity. *arXiv preprint arXiv:1609.03138*.

Hendrycks, D., Burns, C., Basart, S., Zou, A., Mazeika, M., Song, D., & Steinhardt, J. (2020). Measuring massive multitask language understanding. *arXiv preprint arXiv:2009.03300*.

Imai, K., & Ratkovic, M. (2014). Covariate balancing propensity score. *Journal of the Royal Statistical Society*, 76(1), 243–263.

Imbens, G. W. (2019). Potential outcome and directed acyclic graph approaches to causality: relevance for empirical practice in economics. *Journal of Economic Literature*, 57(3), 1–51.

Imbens, G. W., & Lemieux, T. (2008). Regression discontinuity designs: A guide to practice. *Journal of Econometrics*, 142(2), 615–635.

Klepper, S., & Leamer, E. E. (1984). Consistent sets of estimates for regressions with errors in all variables. *Econometric Reviews*, 3(2), 163–183.

Kohavi, R., Longbotham, R., Quelhas, D., & Xu, W. (2009). Seven rules of thumb for web site experimenters. In *Proceedings of the 15th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining* (pp. 1325–1334).

Lewis, M., Ringlstetter, J., Spaan, S., & Parkar, P. (2023). Evaluating large language models. *arXiv preprint arXiv:2304.04954*.

Rosenbaum, P. R., & Rubin, D. B. (1983). The central role of the propensity score in observational studies for causal effects. *Biometrika*, 70(1), 41–55.

Wooldridge, J. M. (2010). *Econometric Analysis of Cross Section and Panel Data*. MIT Press.
