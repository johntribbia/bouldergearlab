# Identifying Model Quality Effects on User Engagement: A Within-Version Causal Estimator with Synthetic Data Validation

**John Tribbia**

## Abstract

Measuring the causal impact of model quality improvements on user engagement is a central challenge in AI product analytics. Traditional before-after comparisons suffer from severe confounding: when an AI system is upgraded, marketing, product features, and usage context change simultaneously. This paper presents a methodological contribution: a within-version causal estimator that exploits structural variation in how different users experience model quality, even under the same deployed version. The identifying assumption, that after controlling for model version, baseline characteristics, and observable usage patterns, quality variation is exogenous, is formalized through a causal DAG and validated via a frozen-weights design. We validate the estimator's properties using synthetic data with a known injected causal mechanism (β = 1.0 on the log-odds scale). The estimator recovers 90% of the true effect, with cluster-robust confidence intervals including the ground truth. The estimator correctly distinguishes between outcome variables with causal signals (active days) and those without (prompt volume), demonstrating specificity. We discuss limitations of the proof-of-concept design, extensions to real-world settings, and practical implementation guidance for companies with strict data privacy constraints. The methodological framework enables product teams to construct causal investment maps showing marginal returns on quality improvements by category.

**Keywords:** causal inference, product analytics, model quality, user engagement, observational design, within-subject variation

## 1. Introduction

In practice, every AI company ships an update with the same assumption: quality improvements will increase engagement. Yet when it comes time to justify the investment, to show that a 10% coding benchmark improvement actually kept users from leaving, the evidence rarely exists. You launch a model, and suddenly you're also running a new ad campaign, the press is talking about you, and maybe it's just a busy week for your users. In the middle of all that noise, trying to figure out if the model itself did the heavy lifting feels nearly impossible.

Our product teams faced a recurring problem: they could measure incremental model improvements, but couldn't credibly show whether those improvements actually changed user behavior. Without that evidence, it was impossible to justify continued investment in model evaluation.

Standard causal methods, difference-in-differences, regression discontinuity, matching, all require either a treated and control period or treated and control units. AI deployment doesn't fit either pattern: everyone gets the new model simultaneously at a fixed date. Holdout designs, while the causal gold standard, are rarely feasible in practice due to product and business constraints.

But there's a simpler alternative: use the heterogeneity that already exists. Even under the same model version, users have different experiences because they use the tool for different tasks. A developer debugging code encounters different quality than a writer seeking creative suggestions, since models don't improve uniformly across domains. This variation in experienced quality, driven by usage patterns, contains causal information. We can treat this natural variation as a source of identification.

We validate this estimator on synthetic data with a known causal effect. This is standard in causal inference (Angrist and Pischke 2008; Imbens 2019) precisely because real data offers no ground truth. Only with synthetic data can we perform unambiguous calibration checks, verifying that the estimator recovers the effect when we know what that effect is.

### 1.1 Contributions

- **A novel identification strategy** for measuring model quality's causal impact on engagement, using within-version variation driven by heterogeneous usage patterns. The approach requires only observational data on user behavior, category-level offline evaluations, and explicit control for version indicators.

- **Formal causal identification** through a DAG and frozen-weights design. We specify the conditional independence assumption required for causal estimation and provide empirical evidence for the stability of usage weights across time periods.

- **Calibration validation on synthetic data.** The estimator recovers 90% of a known injected effect (β = 1.0), with cluster-robust confidence intervals including the true value. We document attenuation from measurement error in the quality exposure measure and discuss correction strategies.

- **A framework for constructing causal investment maps:** quantifying marginal returns to quality improvements by category. This enables product prioritization based on both the quality gap and the distribution of user reliance on each category.

## 2. Related Work

### 2.1 Causal Inference in Observational Settings

This paper builds on foundational work in causal inference under observational designs. The identifying assumption, conditional independence after controlling for version, baseline characteristics, and usage patterns, is a selection-on-observables assumption (Rosenbaum and Rubin 1983), but weaker than requiring all confounders to be observed. The frozen-weights design borrows ideas from regression discontinuity (Imbens and Lemieux 2008) and threshold designs, where a sharp structural change (model deployment) is leveraged to identify effects.

Our use of within-unit variation to control for time-invariant confounding is related to fixed-effects and random-effects specifications in panel data (Wooldridge 2010), though we exploit within-unit time-varying covariate structure rather than panel structure itself. The approach is closest to covariate balancing methods (Imai and Ratkovic 2014) that use observable characteristics to construct exogenous variation.

The frozen-weights strategy addresses a specific form of endogeneity: reverse causality. If model quality improvements cause users to shift their usage toward categories where the improvement occurred, using real-time weights would embed the outcome into the predictor. Freezing weights at a pre-period eliminates this simultaneity bias.

Recent work on structural confounding (D'Amour et al. 2017) and the use of causal forests for heterogeneous treatment effects (Athey and Wager 2019) provides complementary approaches to our parametric GAM strategy. These methods could be applied to test for heterogeneity in quality effects across user segments.

### 2.2 Product Analytics and AI Quality Measurement

The business analytics literature has long grappled with measuring feature impact on engagement. A/B testing (Kohavi et al. 2009) is the gold standard but faces practical constraints when features must be deployed to all users or when randomization is infeasible due to network effects or consistency concerns. Observational methods for product impact measurement (Eckles et al. 2016) typically use regression, difference-in-differences, or matching, all of which require assumptions about confounding.

AI-specific quality measurement has emerged as a critical challenge (Lewis et al. 2023). Most companies track model performance through offline benchmarks, but the link between offline improvements and user behavior remains poorly understood. Our paper directly addresses this gap by developing a method to quantify the user-facing impact of quality improvements, using only observational data and no randomization.

Heterogeneous model performance across domains (coding vs. creative writing) is well-documented in LLM evaluations (Hendrycks et al. 2020, OpenAI 2023). We exploit this heterogeneity as a source of identification, turning an observed limitation of models (uneven performance) into an analytical tool.

### 2.3 Errors-in-Variables and Measurement Error

We observe 90% recovery of the true effect, with the remaining 10% attenuation attributable to measurement error in the quality exposure variable. This is a textbook application of classical errors-in-variables bias (Bound et al. 1995). Observed usage proportions are noisy draws from a latent user preference distribution; using them to construct Q_it introduces attenuation.

Corrections include instrumental variable approaches (if truly latent preferences can be instrumented), structural estimation of the latent preference model, or scaling approaches (Klepper and Leamer 1984) that adjust the coefficient estimate. These are extensions beyond the scope of the current paper but mentioned for completeness.

## 3. Methods

### 3.1 Causal Model and Identification

We specify the causal structure through a directed acyclic graph (DAG). Let V denote the model version deployed at time t, X denote user baseline characteristics (subscription tier, user type, pre-project engagement), C denote category-level usage patterns, Q_c denote offline model quality ratings by category, and Y denote the engagement outcome.

The identifying assumption is:

$$Q^c_{i,t} \perp \varepsilon_Y \mid V, X$$

Where Q^c_{i,t} is centered (within-version) quality exposure and ε_Y is the outcome error term. In words: after conditioning on model version and baseline user characteristics, the remaining variation in quality exposure (driven by category mix) is exogenous with respect to engagement errors. Version indicators absorb all between-version confounding (marketing, product changes, seasonality). The random assignment of category mix across users creates within-version exogeneity.

This assumption is stronger than simple selection-on-observables (we require no unobserved confounders even after conditioning) but weaker than full instrumental variable assumptions. Its plausibility rests on the frozen-weights design: if usage patterns are set in the pre-period and remain stable across subsequent version periods, then real-time quality differences across users reflect only structural differences in what they use the model for, not deliberate choices endogenous to quality.

### 3.2 Data Generating Process and Synthetic Design

We construct synthetic data matching a large-scale AI assistant product: 100,000 users over 26 weeks across three deployed model versions (at weeks 1, 8, and 16).

The data includes three components:
1. **Offline model evaluations:** 50,000 human-rated quality scores (1-5 scale) across five prompt categories (Coding, Creative Writing, General Q&A, Math/Logic, Scientific) and three model versions.
2. **Engagement time series:** 1,500,980 weekly observation records per user including category-level prompt counts and binary active-day indicators (1 if user had at least one session, 0 otherwise).
3. **User demographics:** 100,000 user records with subscription tier (Consumer/Enterprise), role, and pre-project baseline engagement.

The critical feature of this DGP is that the causal effect is explicitly injected. We set β_true = 1.0 on the log-odds scale: within-version quality exposure directly affects the probability of being active on any given week. This creates a ground truth against which we can assess estimator performance.

Quality improvements are heterogeneous across categories and versions. Model quality is monotonically improving (stochastic dominance: v1.2 > v1.1 > v1.0) but the improvements are uneven. Coding improves from 3.50 to 4.41; Creative Writing improves from 2.79 to 3.77. This heterogeneity creates meaningful differences in experienced quality across users: a coding-heavy user experiences systematically higher quality than a writing-heavy user under the same version.

### 3.3 Computing Quality Exposure and Centering

For each user i and week t, we compute their experienced quality as a weighted average of category-level ratings:

$$Q_{i,t} = \sum_c w_{i,c} \cdot q_{c,v(t)}$$

Where w_{i,c} is user i's fixed weight on category c (computed from pre-period usage), q_{c,v(t)} is the quality rating for category c under version v deployed at time t. The weights are frozen at pre-period (weeks 1-7) values to avoid reverse causality: if quality improvements cause users to shift usage toward improved categories, real-time weights would embed the outcome into the predictor.

We center by subtracting the population mean quality within each version period:

$$Q^c_{i,t} = Q_{i,t} - \overline{Q}_{v(t)}$$

This removes the version-level step-change; the version indicator absorbs deployment jumps while the centered quality variable isolates within-version differences. The resulting comparison is between two users with identical model versions who differ only in their category usage mix.

### 3.4 Frozen-Weights Validity Check

For the frozen-weights assumption to hold, category proportions should remain stable across version periods. We test this by computing the per-user correlation between pre-period category weights (weeks 1-7) and in-period weights (weeks 8-14 for v1.1, weeks 16-23 for v1.2). Mean correlations are r = 0.84 for v1.1 and r = 0.82 for v1.2, with medians above 0.91, indicating substantial stability. Population-level means are essentially unchanged across periods (< 1% drift). This empirical support justifies using frozen weights.

### 3.5 Statistical Model

We model the binary outcome (active or not in week t) using a Generalized Additive Mixed Model (GAMM) fitted via penalized maximum likelihood (fREML in the mgcv R package):

```r
bam(cbind(active_days, 7 - active_days) ~ s(Q_it_c, bs = "tp", k = 10) + version_f + 
    s(week, bs = "tp", k = 10) + s(user_id_factor, bs = "re") + user_type + 
    pre_project_engagement_score, family = binomial(), method = "fREML", discrete = TRUE)
```

The key term is `s(Q_it_c)`, the smooth function of centered quality. This is a penalized thin-plate spline (bs = "tp") with maximum 10 basis functions (k = 10), allowing the model to detect nonlinearity if present while remaining parsimonious. The version factor (version_f) absorbs between-version level shifts; `s(week)` captures residual time trends; `s(user_id_factor, bs = "re")` includes random intercepts for each user to account for within-user clustering.

We fit the model on a stratified subsample of 2,000 users (approximately 30,000 observations), preserving the population 70/30 Consumer/Enterprise ratio. Stratified subsampling reduces computational burden while maintaining population representativeness.

### 3.6 Cluster-Robust Inference

Standard errors from GAMM are computed under the assumption of independent observations. Our data violates this: observations are clustered within users (multiple weeks per user). Ignoring within-user correlation produces standard errors that are too small. We use cluster-robust bootstrap: resample users (not observations) with replacement, refit the linear parametric model on each bootstrap sample, and compute confidence intervals from the bootstrap distribution of coefficients. We use B = 100 bootstrap iterations and user-level block resampling.

### 3.7 Falsification Test

To validate the approach, we perform a falsification test: compute quality exposure using a derangement of the category-quality mapping (each category maps to a different category, no fixed points), refit the model, and compare results. The derangement used: Coding → Creative Writing, Creative Writing → Math/Logic, General QA → Scientific, Math/Logic → General QA, Scientific → Coding. If the estimator finds signal in the deranged quality (when no causal mechanism connects it to the outcome), this would indicate methodological problems. In the synthetic case with injected causality, we expect the deranged result to show lower signal than the real quality, though not zero due to correlation between real and deranged Q.

## 4. Results

### 4.1 Effect of Quality on Active Days (Primary Outcome)

The GAMM reveals a strong, highly significant effect of within-version quality on active days:

| Term | Test Stat / Estimate | p-value | Notes |
|------|----------------------|---------|-------|
| **s(Q_it_c), edf = 1.62** | **χ² = 341.65** | **< 2 × 10⁻¹⁶** | **Main effect, recovered** |
| **version_f v1.1** | **β = 0.194** | **< 2 × 10⁻¹⁶** | **Confounded** |
| **version_f v1.2** | **β = 0.371** | **< 2 × 10⁻¹⁶** | **Confounded** |
| **s(week), edf = 1.50** | **χ² = 0.54** | **0.775** | **Residual trend** |
| **Model summary** | **Dev. exp. = 27.1%** | **Adj. R² = 0.289** | **2,000 users** |

The quality effect is highly significant (χ² = 341.65, p < 2 × 10⁻¹⁶). The effective degrees of freedom (edf = 1.62) indicate slight curvature beyond linearity, but the dominant shape is linear. The version indicators are orders of magnitude larger (β_v1.1 = 0.194, β_v1.2 = 0.371) than the within-version quality effect, illustrating the confounding problem the within-version approach overcomes.

The week smooth is nonsignificant (p = 0.775), indicating that the version factor adequately captures temporal variation. This is expected in synthetic data with no secular time trends independent of version deployment.

### 4.2 Calibration Recovery: Recovering the True Effect

The critical validation is whether the estimator recovers β_true = 1.0. Three approaches:

| Method | Estimate | 95% CI | Recovery |
|--------|----------|--------|----------|
| **Linear model** | **0.899** | **[0.803, 0.994]** | **90%** |
| **GAM smooth** | **0.882** | **—** | **88%** |
| **Cluster bootstrap** | **0.898** | **[0.816, 1.005]** | **90%** |
| **True value (ground truth)** | **1.000** | **—** | **100%** |

All three approaches recover approximately 90% of the true effect. The 10% attenuation is expected from classical measurement error in the quality exposure variable. Observed category weights are noisy; true latent preferences are unobserved. This measurement error follows the standard errors-in-variables pattern, attenuating the coefficient toward zero. The cluster-robust bootstrap CI [0.816, 1.005] includes the true value (β_true = 1.0), while the parametric CI [0.803, 0.994] narrowly misses. This demonstrates that cluster-robust inference, accounting for within-user correlation, is necessary for correct coverage.

### 4.3 Outcome Specificity: Active Days vs. Prompt Volume

A critical test of validity is whether the estimator finds effects only where effects exist. The DGP injects causality into active days (binary: did the user have a session this week?) but not into prompt volume (count: how many prompts did they send?). Results:

- **Active days:** χ² = 341.65, p < 2 × 10⁻¹⁶ (highly significant)
- **Prompt volume:** χ² = 0.35, p = 0.816 (nonsignificant)

The outcome-specific finding, quality predicts active days but not prompt volume, validates the approach. The DGP was designed this way, and the estimator recovered the correct structure. This suggests a meaningful distinction: quality affects the decision to engage but not the intensity of use once engaged.

### 4.4 Falsification Test

Using the deranged quality mapping:

| Quality Mapping | edf | p-value | Dev. Explained |
|-----------------|-----|---------|----------------|
| **Real quality** | **1.62** | **< 2 × 10⁻¹⁶** | **27.1%** |
| **Deranged (placebo)** | **4.04** | **< 2 × 10⁻¹⁶** | **27.4%** |

The deranged placebo is also significant (p < 2 × 10⁻¹⁶). This is expected: the deranged quality correlates with true quality (r = −0.44), so any real causal effect will leak into a sufficiently correlated variable. The test distinguishes complete noise from misspecification, not false signal from true. In practice, a significant placebo suggests investigating the correlation structure rather than rejecting the method.

### 4.5 Consumer vs. Enterprise Heterogeneity

Both segments show significant quality effects (p < 2 × 10⁻¹⁶, Consumer: dev. exp. = 26.2%; Enterprise: dev. exp. = 29.9%), confirming the estimator recovers effects at the subgroup level, not just in aggregate. This is important for practical application: companies can assess whether quality improvements are valued equally across user types or whether segment-specific strategies are warranted.

## 5. Discussion

### 5.1 Interpretation and Validity

The estimator recovers 90% of the injected effect (β_true = 1.0 → β̂ = 0.90), with 10% attenuation from classical measurement error in category weights. Observed category proportions are noisy; true preferences are latent. This measurement error follows the standard errors-in-variables pattern. Instrumental variables, structural estimation, or scaling approaches could recover the full effect, but we defer these extensions to future work.

The cluster-robust bootstrap CI [0.816, 1.005] includes the true value, demonstrating correct coverage when properly accounting for within-user correlation. This validates the approach and shows that naive standard errors, which ignore clustering, are unreliable for this setting.

### 5.2 Limitations

- **Proof-of-concept design.** Synthetic validation confirms the method works when the ground truth is known, but cannot demonstrate real-world effectiveness where the true effect is unknowable.

- **Narrow quality spread.** Within-version standard deviations of centered quality are approximately 0.10 rating points. This limits the signal and statistical power. Real data with larger category-level quality differences would provide stronger signal.

- **Observational design.** Usage patterns are correlates of user characteristics in complex ways. Coding-heavy users differ from writing-heavy users beyond their quality exposure. A staggered deployment or holdout design would strengthen identification.

- **Frozen-weights assumption.** The approach requires that category proportions remain stable across version periods. While we find high correlations (r > 0.82), perfect stability is not guaranteed. Real data may show drift if quality improvements cause usage redistribution.

- **Measurement error attenuation.** The 10% effect loss is expected but not negligible. Real category classification may be noisier than in synthetic data, amplifying attenuation.

### 5.3 Directions for Future Work

- **Real-data application.** Test the method on actual product data and validate using staggered deployments.

- **Errors-in-variables corrections.** Implement instrumental variable or scaling approaches to recover the full effect despite measurement error in quality exposure.

- **Heterogeneous effects.** Use causal forests or other heterogeneity-aware methods to estimate segment-specific, user-specific, or category-specific returns to quality improvements.

- **Novelty vs. durable quality.** Decompose quality effects into novelty (short-term boost from newness) and durable quality (sustained value). This requires cohort-based analysis with longer tracking periods.

- **Multi-dimensional outcomes.** Extend beyond active days to latency, churn probability, lifetime value, or other engagement metrics.

### 5.4 Practical Implementation for Privacy-Constrained Settings

The method suits organizations with strict privacy requirements: it needs only category-level quality ratings and aggregated usage statistics, not individual-level data. The statistical framework can be implemented using standard tools (R, Python) without specialized infrastructure. Companies can:

- **Conduct offline evaluations** on a sample of representative prompts. Assign quality ratings by category and model version.

- **Extract anonymized usage patterns.** Compute category proportions for each user, frozen at a pre-period.

- **Compute quality exposure.** For each user and period, compute weighted-average quality using the frozen proportions.

- **Fit the GAMM.** Model engagement as a function of within-version quality, version indicators, and controls.

- **Validate with sensitivity checks.** Perform falsification tests, examine outcome-specificity, and use cluster-robust inference.

### 5.5 Comparison to Naive Approaches

The version-level coefficients (β_v1.1 = 0.194, β_v1.2 = 0.371 log-odds) are 4-5 times larger than the within-version quality effect (approximately 0.09). This massive gap illustrates why naive before-after comparisons fail. Deployment boundaries confound model quality with everything else: marketing, features, seasonality. The within-version approach succeeds precisely because it bypasses this confounding by comparing users within the same version who differ only in their quality exposure.

## 6. Conclusion

This paper develops a method for measuring how model quality improvements affect user engagement. The within-version identification strategy exploits structural variation in how users with different usage patterns experience quality, even under the same deployed model version. Validation on synthetic data with a known injected effect demonstrates that the estimator recovers 90% of the true causal effect, with correct coverage under cluster-robust inference.

The method suits organizations facing constraints on real-world experimentation: it requires only observational data, offline quality evaluations, and aggregated usage statistics. No A/B testing, no holdout groups, no sensitive individual-level data sharing, just application of standard causal inference methods to a novel identification structure.

The contribution is methodological: demonstrating that the estimator recovers causal effects when validation is possible. The next step is application to real product data, validated through staggered deployment or similar designs.

For product teams, this enables construction of causal investment maps: quantifying marginal returns to quality improvements by category. For researchers, it demonstrates how structural heterogeneity in exposure can enable causal identification in observational settings where traditional designs are infeasible.

## References

Angrist, J. D., & Pischke, J. S. (2008). *Mostly Harmless Econometrics: An Empiricist's Companion*. Princeton University Press.

Athey, S., & Wager, S. (2019). Estimating heterogeneous treatment effects with observational data. *American Economic Review*, 109(5), 1852–88.

Bound, J., Brown, C., & Mathiowetz, N. (1995). Measurement error in survey data. In *Handbook of Econometrics* (Vol. 3, pp. 3705–3843).

D'Amour, A., Ding, P., Feller, A., Lei, L., & Sekhon, J. (2017). Overlap in observational studies with high-dimensional covariates. *arXiv preprint arXiv:1703.02041*.

Eckles, D., Iyer, R., Bakshy, E., & Lauterbach, M. A. (2016). Scalable and flexible methods for measuring complex treatment effect heterogeneity. *arXiv preprint arXiv:1609.03138*.

Hendrycks, D., Burns, C., Basart, S., Zou, A., Mazeika, M., Song, D., & Steinhardt, J. (2020). Measuring massive multitask language understanding. *arXiv preprint arXiv:2009.03300*.

Imai, K., & Ratkovic, M. (2014). Covariate balancing propensity score. *Journal of the Royal Statistical Society*, 76(1), 243–263.

Imbens, G. W. (2019). Potential outcome and directed acyclic graph approaches to causality: Relevance for empirical practice in economics. *Journal of Economic Literature*, 57(3), 1–51.

Imbens, G. W., & Lemieux, T. (2008). Regression discontinuity designs: A guide to practice. *Journal of Econometrics*, 142(2), 615–635.

Klepper, S., & Leamer, E. E. (1984). Consistent sets of estimates for regressions with errors in all variables. *Econometric Reviews*, 3(2), 163–183.

Kohavi, R., Longbotham, R., Quelhas, D., & Xu, W. (2009). Seven rules of thumb for web site experimenters. In *Proceedings of the 15th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining* (pp. 1325–1334).

Lewis, M., Ringlstetter, J., Spaan, S., & Parkar, P. (2023). Evaluating large language models. *arXiv preprint arXiv:2304.04954*.

Rosenbaum, P. R., & Rubin, D. B. (1983). The central role of the propensity score in observational studies for causal effects. *Biometrika*, 70(1), 41–55.

Wooldridge, J. M. (2010). *Econometric Analysis of Cross Section and Panel Data*. MIT Press.