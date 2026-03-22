---
title: "Model Quality — Journal Revision Workbook"
date: 2026-03-22
tags: ['data project']
categories: ['data project']
description: "Working document for revising the model quality paper toward Journal of Data Science submission. Tracks reviewer feedback, gap analysis, and revision tasks."
draft: true
build:
  list: never
  render: always
---

*Internal working document — not for publication*

---

## Overview

This is the revision workbook for the paper *"Does Making AI Smarter Actually Make People Use It More?"* targeting **Journal of Data Science (JDS)**. The original article lives at [data-projects/model-quality](/data-projects/model-quality/).

The core methodology — exploiting within-version heterogeneity in user quality exposure via frozen-weight category-level scoring — was judged methodologically rigorous but **not yet publication-ready**. The reviewer's verdict: very smart proof-of-concept, needs field validation.

This document organizes the feedback into a gap analysis and a revision plan.

---

## Strengths Confirmed (Keep These)

| Strength | Notes |
|---|---|
| Novel framing: within-version heterogeneity | Core insight is the differentiating claim. Keep prominent. |
| Rigorous causal framework | DAG, identification assumption, frozen-weights design, cluster-robust inference — no changes needed. |
| Ground-truth validation via synthetic DGP | Necessary but not sufficient. Keep; add real-data application alongside it. |
| Honest limitations section | Praised as "refreshingly candid." Maintain this tone throughout revision. |

---

## Critical Gaps — Reviewer Assessment

### Gap 1: No Real-World Application *(Blocker)*

> "This is the killer. You've validated on synthetic data where you injected the causal effect yourself. That's necessary but not sufficient. For JDS, reviewers will expect at least a preliminary application to real product data."

**Current state:** Synthetic data only. The DGP was designed to include a quality-to-engagement channel, so finding one validates the methodology but not a substantive claim.

**What's needed:**
- Identify a real dataset (see options below)
- Apply the existing estimator to it
- JDS bar: "Does this work on real problems?" — results do not need to be clean, just real

**Real data options to explore:**

| Option | Feasibility | Notes |
|---|---|---|
| Partner with an AI company | Requires outreach; most likely path for a production-quality paper | |
| Public product/engagement datasets | Lower barrier; check Kaggle, HuggingFace datasets, academic datasets | |
| Personal usage data | Log category + date from own AI use | Very small N; likely illustrative only |
| Open LLM benchmark data + proxy engagement | e.g. LMSYS Chatbot Arena logs + API call data | Would require creative operationalization of "engagement" |

**Action items:**
- [x] Survey available public datasets → `survey_public_datasets.py` (WildChat-1M recommended)
- [x] Define minimum viable real-data application (pseudonymous users + 2 quality tiers)
- [ ] Run WildChat category classification pipeline (zero-shot embedding approach documented in script)
- [ ] Draft outreach email for AI company partnership (template in `survey_public_datasets.py`)

---

### Gap 2: Narrow Empirical Scope

> "One outcome (active days), one synthetic product, one causal effect size (β=1.0). Show generality."

**Current state:**
- 1 outcome variable (active days; prompts is a negative control, not a second outcome)
- 1 simulated product
- 1 β size injected

**What's needed:**
- 2–3 outcome variables (e.g., active days, session length, feature adoption, churn indicator)
- Multiple β sizes to show estimator is calibrated across the range, not just at β=1.0
- Multiple user segments beyond Consumer/Enterprise (already have this partially)

**Action items:**
- [x] Extend `augment_data.py` to inject effects on 2 additional outcomes (`churn_risk_observed`, `session_duration_aug`)
- [x] Multi-beta sweep (β ∈ {0.25, 0.50, 0.75, 1.0, 1.25, 1.50, 2.0}) documented in `augment_data.py`
- [ ] Reframe prompts model: call it "volume" and contrast with "frequency" (active days); both are valid engagement dimensions

---

### Gap 3: Falsification Test Reveals a Problem

> "Your deranged placebo is also significant (p < 2×10⁻¹⁶) due to correlation between real and fake quality (r = -0.44). That's troubling and suggests the method doesn't discriminate as sharply as claimed."

**Current state:** The placebo is significant. The article explains this as "expected behavior" given a real causal effect (correlated deranged scores pick up indirect signal). Reviewer finds this explanation insufficient.

**What's needed:**
A stronger falsification design that *does* discriminate. Options:

| Alternative Falsification | Notes |
|---|---|
| Random permutation of user-level weights (break user-category link) | Destroys the actual source of variation; deranged quality scores become truly orthogonal to real scores |
| Time-shifted placebo (lead/lag quality by one version) | Tests temporal identification; if quality in next version predicts current engagement, the design is flawed |
| Cross-outcome placebo (use prompts model's residuals to predict active days) | Stress-tests the specificity claim |
| Partial derangement series (swap 1, 2, 3, 4, 5 categories) | Shows gradual signal degradation as the derangement gets further from the truth |

**Action items:**
- [x] Implement random user-weight permutation test (Step 9b in R script — Q_perm is orthogonal to real Q, r≈0)
- [x] Implement time-shifted placebo — Step 9c assigns each row the *next* version's quality scores
- [x] Rewrite falsification section: 3-test summary table distinguishes derangement vs permutation vs lead
- [ ] Update article text to explain why permutation > derangement for the null test

---

### Gap 4: No Benchmark Comparisons

> "You don't show what happens if you use real-time weights instead of frozen, apply simpler methods (user-level diff-in-diff, basic OLS), or use alternative methods. Without benchmarks, hard to argue this is the best approach."

**Current state:** No competitor models are included.

**What's needed:**

| Benchmark | Implementation | Why It Matters |
|---|---|---|
| Naive pre–post OLS (no within-version centering) | Simple OLS of active days ~ version indicator | Shows confounded baseline; demonstrates the centering step earns its complexity |
| Real-time weights (not frozen) | Use each week's actual category mix instead of pre-period weights | Quantifies the circularity risk of the alternative |
| User-level diff-in-diff | Weight by change in quality exposure across versions | Common in policy evaluation; helps position the paper relative to DiD literature |
| Basic Fixed Effects OLS | User FE, no smooth, no random effect | Lower-bound on complexity needed |

**Recovery comparison table target:**

| Method | Recovered β | Bias | Notes |
|---|---|---|---|
| Proposed (frozen weights, GAMM) | 0.90 | −10% | |
| Real-time weights | TBD | TBD | Expected: larger bias from endogeneity |
| Naive OLS | TBD | TBD | Expected: substantial upward bias |
| DiD | TBD | TBD | |
| User FE OLS | TBD | TBD | |

**Action items:**
- [x] Implement naive OLS baseline (no version FE, raw Q_it)
- [x] Implement real-time weights variant (current-week category counts, endogenous)
- [x] Implement user-level DiD (first-differences, v1.0→v1.1)
- [x] Implement user fixed-effects OLS (demeaned within-user)
- [x] Build recovery comparison table and figure (`11_benchmark_comparison.png`) in R script (Step 12b)

---

### Gap 5: Measurement Error Not Corrected

> "You lose 10% to classical errors-in-variables, document it, then leave it. Instrumental variables or scaling approaches are mentioned as 'future work.' For publication, pick one and implement it."

**Current state:** 10% attenuation documented and attributed to classical errors-in-variables in $Q^c_{i,t}$ (observed category counts vs. true Dirichlet preferences). Correction is deferred.

**What's needed:** Implement one correction:

| Correction Method | Complexity | Notes |
|---|---|---|
| SIMEX (Simulation Extrapolation) | Medium | Requires known or estimable measurement error variance; straightforward in R (`simex` package) |
| Klepper-Leamer scaling | Low | Assumes measurement error SD; scales coefficient by $(1 + \sigma^2_u / \sigma^2_x)$; easily derived from the data |
| Regression calibration | Medium | Regress true weights on observed proxies; use predicted values in main model |
| IV (session count as instrument) | High | Requires a variable that predicts category weights but doesn't directly affect engagement; hard to find cleanly |

**Recommended path:** Klepper-Leamer scaling is fastest to implement and transparent. Estimate the noise-to-signal ratio from the 15% session-level variation in the DGP, compute the correction factor, compare corrected vs. uncorrected estimates as a table.

**Action items:**
- [x] Implement Klepper-Leamer scaling in R script (Step 12a) — derives λ from cross-period weight correlations
- [x] Sensitivity sweep: λ ∈ {0.60 … 1.00} with marked estimated λ
- [x] `bench_results` updated with "Proposed + K-L correction" entry
- [ ] Update article text: reframe as solved problem, show corrected estimate reaches ~100% recovery

---

### Gap 6: Frozen-Weights Assumption Under-Validated

> "You show stability in synthetic data (r=0.82). But in real data, quality improvements cause users to shift toward better categories — that's your theory of change. How do you know frozen weights aren't contaminated when behavior changes?"

**Current state:** Stability validated via within-synthetic-data correlation (mean r = 0.84 for v1.1, r = 0.82 for v1.2). The paper treats r = 0.82 as sufficient.

**The concern:** If quality improvements cause users to use high-quality categories *more*, then behavior in later versions is partially caused by the treatment. Using later-period weights would bake the outcome into the predictor. But the deeper question is: does the behavioral shift contaminate the *frozen* weights? The answer depends on how much weights drift — and whether that drift is systematic.

**Additional validation needed:**

| Test | What It Shows |
|---|---|
| Sensitivity analysis: weight frozen at different pre-periods | If results are insensitive to whether you freeze at weeks 1–3, 1–5, or 1–7, the assumption is robust |
| Correlation of weight *changes* with quality gain | If users who experienced larger quality gains shifted their category mix more, this is evidence of behavioral response |
| Worst-case bounds: re-run with v1.1 pre-period weights for v1.2 analysis | Shows how much the estimate moves if you use "contaminated" weights |
| Monte Carlo sensitivity: inject behavioral drift into DGP | Simulate users who shift usage by δ% when quality improves; show estimator bias as a function of δ |

**Action items:**
- [x] Add pre-period sensitivity analysis in R script (Step 2c) — freeze at weeks 1–3, 1–5, 1–7; compare β and r(canonical)
- [x] Summary table printed per freeze window with recovery rate and correlation to canonical weights
- [ ] Add behavioral-drift Monte Carlo to `data-generator.py` (simulate users shifting category mix by δ% when quality improves, show estimator bias vs δ)
- [ ] Build frozen-weights sensitivity figure

---

## Journal Targeting

| Journal | Fit | Notes |
|---|---|---|
| **Journal of Data Science (JDS)** | Medium–High (target) | Applied; expects real data + reproducible workflows. Needs Gap 1 closed. |
| **JASA** | High for methodology | Pure methodology; synthetic validation may be sufficient. Less emphasis on real-world application. |
| **Biometrika** | High for methodology | Strong stats theory focus; causal DAG + identification will land well. May not want the "investment map" applied framing. |
| **Annals of Applied Statistics** | High | Good fit for causal methods with empirical motivation. Would want real data or strong simulations. |
| **Management Science** | Medium | If real-world application added; framing around product analytics and ROI would need strengthening. |

**Current recommendation:** If real data (Gap 1) can be added, target JDS or AOAS. If real data is unavailable, pivot to JASA or Biometrika and lean harder into the methodological contribution.

---

## Revision Priority Order

| Priority | Gap | Effort | Impact |
|---|---|---|---|
| 1 | **Real-world application** (Gap 1) | High | Unlocks top-tier applied journals |
| 2 | **Benchmark comparisons** (Gap 4) | Medium | Directly addresses "why this method?" |
| 3 | **Stronger falsification** (Gap 3) | Medium | Addresses the most specific reviewer concern |
| 4 | **Measurement error correction** (Gap 5) | Low–Medium | Closes a known hole; straightforward with K-L scaling |
| 5 | **Broader empirical scope** (Gap 2) | Medium | Adds generality; can be done on synthetic data |
| 6 | **Frozen-weights sensitivity** (Gap 6) | Medium | Strengthens the most theoretically fragile assumption |

---

## File Structure

```
content/data-projects/model-quality-journal/
  index.md                      ← this file (revision workbook)
  survey_public_datasets.py     ← Gap 1: public dataset survey + WildChat feasibility
                                   download + data access request template

content/data-projects/model-quality/
  model_quality_analysis.R      ← extended with:
    Step 2c  Frozen-weights sensitivity (Gap 6): freeze at 1-3, 1-5, 1-7 weeks
    Step 9b  User-weight permutation test (Gap 3): orthogonal null
    Step 9c  Time-shifted placebo (Gap 3): lead quality scores
    Step 12a Klepper-Leamer correction (Gap 5): λ from stability correlations
    Step 12b Benchmark comparisons (Gap 4): naive OLS, real-time weights, DiD, user FE
    Figures: 11_benchmark_comparison.png

  augment_data.py               ← extended with:
    TRUE_BETA_CHURN = -0.6:     churn_risk_observed column (Gap 2)
    TRUE_BETA_DURATION = 0.4:   session_duration_aug column (Gap 2)
    Multi-beta sweep:           β ∈ {0.25 … 2.0} calibration table printed (Gap 2)
```

---

## References to Review

- Klepper, S. & Leamer, E. (1984). Consistent sets of estimates for regressions with errors in all variables. *Econometrica*, 52(1), 163–183.
- Carroll, R.J., Ruppert, D., Stefanski, L.A., & Crainiceanu, C.M. (2006). *Measurement Error in Nonlinear Models: A Modern Perspective*. Chapman & Hall.
- Callaway, B. & Sant'Anna, P.H.C. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*, 225(2), 200–230.
- Wager, S. & Athey, S. (2018). Estimation and inference of heterogeneous treatment effects using random forests. *JASA*, 113(523), 1228–1242.
- Cook, J.R. & Stefanski, L.A. (1994). Simulation-extrapolation estimation in parametric measurement error models. *JASA*, 89(428), 1314–1328.
