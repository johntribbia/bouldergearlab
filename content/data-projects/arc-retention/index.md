---
title: "The Shape Predicts the Return"
date: 2026-05-02
tags: ['data project']
categories: ['data project']
description: "The model quality framework originally relied on scalar ratings and active days. By replacing those inputs with ARC trajectory scores and 7-day retention probability, we recover 89% of a known causal effect. Notably, the early trajectory slope carries an independent retention penalty that the mean score misses entirely."
draft: false
banner: "aqr-banner.svg"
build:
  list: never
  render: always
---
<!--more-->

<style>
/* ── ARC / Retention — BGL Dark Theme ── */

.aqr-lede {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  color: rgba(255,255,255,0.4);
  border-left: 2px solid var(--moss);
  padding: 0.8rem 1.2rem;
  background: rgba(125,184,0,0.06);
  line-height: 1.65;
  margin-bottom: 2.5rem;
  letter-spacing: 0.03em;
}
.aqr-lede a { color: var(--moss); border-bottom: none; }

.aqr-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.aqr-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }

.aqr-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.aqr-h3 {
  font-family: var(--f-display);
  font-size: 1.4rem;
  font-weight: 600;
  color: rgba(255,255,255,0.78);
  margin: 2.2rem 0 0.8rem;
}

/* ── Visualization cards ── */
.aqr-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.aqr-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.aqr-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.aqr-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.aqr-vis-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 22px;
  margin-bottom: 14px;
  font-size: 1.25rem;
  color: rgba(255,255,255,0.55);
  font-family: var(--f-mono);
}
.aqr-vis-legend span { display: flex; align-items: center; gap: 8px; }
.aqr-vis-legend i { display: inline-block; width: 26px; height: 3px; border-radius: 2px; flex-shrink: 0; }
.aqr-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}

/* ── Toggle buttons ── */
.aqr-vis-toggle-group { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 16px; }
.aqr-vis-toggle {
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.12);
  border-radius: 20px;
  padding: 5px 15px;
  font-size: 1.25rem;
  cursor: pointer;
  color: rgba(255,255,255,0.45);
  transition: all 0.15s;
  font-family: var(--f-mono);
}
.aqr-vis-toggle:hover { border-color: rgba(255,255,255,0.3); color: rgba(255,255,255,0.75); }
.aqr-vis-toggle.active { color: var(--predawn) !important; border-color: transparent !important; }

/* ── Callout ── */
.aqr-callout {
  margin: 2.2rem 0;
  padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic;
  font-size: 1.5rem;
  color: rgba(255,255,255,0.55);
  line-height: 1.8;
}
.aqr-callout.ice { border-color: var(--ice); background: rgba(168,200,216,0.05); }
.aqr-callout.orange { border-color: #e07055; background: rgba(224,112,85,0.05); }
.aqr-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

/* ── Data table ── */
.aqr-table-wrap {
  overflow-x: auto;
  margin: 26px 0;
  border-radius: 4px;
  border: 1px solid rgba(255,255,255,0.07);
}
.aqr-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.aqr-table thead tr { background: rgba(255,255,255,0.06); }
.aqr-table thead th {
  padding: 12px 16px;
  text-align: left;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.7);
}
.aqr-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.aqr-table tbody td {
  padding: 11px 16px;
  border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono);
  color: rgba(255,255,255,0.5);
  font-size: 1.25rem;
  line-height: 1.6;
}
.aqr-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }
.aqr-table-caption {
  font-family: var(--f-mono);
  font-size: 1.1rem;
  color: rgba(255,255,255,0.28);
  letter-spacing: 0.06em;
  text-transform: uppercase;
  margin-bottom: 0.5rem;
}
.aqr-table .neg { color: #e07055; }
.aqr-table .pos { color: var(--moss); }

/* ── Footnotes ── */
.aqr-footnotes {
  margin-top: 52px;
  border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  line-height: 1.65;
}
.aqr-footnotes a { color: rgba(255,255,255,0.4); }
</style>

<div class="aqr-lede">
  Sequel to <a href="../model-quality/">Does Making AI Smarter Actually Make People Use It More?</a> and <a href="../arc/">The Shape of a Good Answer</a>. The identification strategy, frozen-weights construction, and GAMM specification are unchanged. What changes is the quality signal (ARC trajectory scores replace scalar ratings) and the outcome (7-day return probability replaces active days). All data is synthetic with a known causal effect injected into the DGP.
</div>

*Article by John Tribbia*

The [model quality framework](../model-quality/) established that within-version quality variation predicts user engagement, and showed an estimator that recovers 90% of a known injected effect. It used two measurement choices that were serviceable starting points: scalar 1–5 quality ratings per prompt category, and active days per week as the engagement outcome.

Each choice compresses information that matters. Scalar ratings collapse a trajectory into a single number. A category can score 3.5 because it held steady across all 10 steps of a task, or because it opened at 4.5 and collapsed. Those are different problems with different fixes, as described in [The Shape of a Good Answer](../arc/). Active days is coarser than it needs to be: whether a user *returns next week* is a sharper decision boundary than how many days they were active in the current week.

This post replaces both. ARC trajectory scores replace scalar ratings; 7-day return probability replaces active days. The identification strategy and model specification are untouched. Mean score alone recovers 89% of the injected effect, consistent with the prior work. But early trajectory slope as a second predictor improves model fit and shifts the investment map in a way scalar ratings cannot produce.

---

<h2 class="aqr-h2">What ARC Adds to the Quality Score</h2>

<p class="aqr-p">The prior framework computed each user's experienced quality as a weighted average of category-level ratings:</p>

$$Q_{i,t} = \sum_c w_{i,c} \cdot q_{c,v(t)}$$

<p class="aqr-p">where $w_{i,c}$ is the user's frozen pre-period category mix and $q_{c,v(t)}$ is the offline quality rating for category $c$ under model version $v(t)$.</p>

<p class="aqr-p">The ARC version replaces $q_{c,v(t)}$ with $\bar{s}_{c,v(t)}$: the mean per-step score from the full ARC trajectory evaluation for that category under that version. Step scores run from 0 to 1, scored by a calibrated NLE judge against per-step sub-goal definitions. The composite quality exposure formula is otherwise identical:</p>

$$\text{ARC}_{i,t} = \sum_c w_{i,c} \cdot \bar{s}_{c,v(t)}$$

<p class="aqr-p">The mean score occupies the same structural role as the original scalar rating. The 10-step vector also exposes slope features: the <strong>early slope</strong> (linear trend across steps 1–3) and the <strong>late slope</strong> (linear trend across steps 8–10). Early slope is the focus here because Early Collapse (the ARC failure pattern where a model commits to a flawed direction before fully orienting) is the most consequential trajectory failure for user experience. Confidently wrong early steps with locally coherent downstream work built on bad foundations is a different failure than a steady 0.70 throughout.</p>

<p class="aqr-p">The slope exposure is constructed using the same frozen weights applied to the early slope values instead of mean scores:</p>

$$\text{EarlySlope}_{i,t} = \sum_c w_{i,c} \cdot \text{esl}_{c,v(t)}$$

<p class="aqr-p">Both composites are centered within version before entering the model, removing deployment-boundary jumps exactly as in the prior work.</p>

---

<h2 class="aqr-h2">Setup</h2>

<p class="aqr-p">Same structure as the prior work: 100,000 users, three model versions over 26 weeks, ~1.65 million session records. The offline evaluation (50,000 records) now produces a 10-step trajectory per category-version pair. Mean score and early slope are extracted from each.</p>

<p class="aqr-p">Mean ARC scores and early slopes by category and version:</p>

<div class="aqr-table-wrap">
  <p class="aqr-table-caption">ARC trajectory metrics — mean step score (0–1) and early slope (Δ score per step, steps 1–3)</p>
  <table class="aqr-table">
    <thead>
      <tr>
        <th>Category</th>
        <th>v1.0 mean</th>
        <th>v1.0 slope</th>
        <th>v1.1 mean</th>
        <th>v1.1 slope</th>
        <th>v1.2 mean</th>
        <th>v1.2 slope</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Coding</td>
        <td>0.700</td><td class="pos">+0.011</td>
        <td>0.822</td><td class="pos">+0.018</td>
        <td>0.882</td><td class="pos">+0.022</td>
      </tr>
      <tr>
        <td>Creative Writing</td>
        <td>0.558</td><td class="neg">−0.028</td>
        <td>0.658</td><td class="neg">−0.015</td>
        <td>0.754</td><td class="neg">−0.006</td>
      </tr>
      <tr>
        <td>General QA</td>
        <td>0.700</td><td class="pos">+0.008</td>
        <td>0.776</td><td class="pos">+0.012</td>
        <td>0.834</td><td class="pos">+0.016</td>
      </tr>
      <tr>
        <td>Math/Logic</td>
        <td>0.582</td><td class="neg">−0.019</td>
        <td>0.700</td><td class="neg">−0.008</td>
        <td>0.826</td><td class="pos">+0.004</td>
      </tr>
      <tr>
        <td>Scientific</td>
        <td>0.658</td><td class="pos">+0.005</td>
        <td>0.720</td><td class="pos">+0.009</td>
        <td>0.812</td><td class="pos">+0.014</td>
      </tr>
    </tbody>
  </table>
</div>

<p class="aqr-p">The mean scores are the prior work's 1–5 ratings normalized to 0–1. The early slope column is a separate story. Math/Logic was the most severe Early Collapse category in v1.0 (slope −0.019); by v1.2 it has crossed into positive territory (+0.004). Creative Writing moved the opposite way: its mean score improved 0.196 points across three versions, the second-largest absolute gain (behind Math/Logic at 0.244), yet its early slope is still negative in v1.2 (−0.006). The model is better at creative writing but still tends to commit before it has oriented.</p>

<p class="aqr-p">A product team tracking only mean scores would read the v1.2 Creative Writing column as a success. A team tracking trajectory shape would see a persistent orientation problem that improvements in raw output quality have not resolved.</p>

<div class="aqr-vis-card">
  <div class="aqr-vis-label">Trajectory shapes</div>
  <div class="aqr-vis-title">Mean score compresses the shape</div>
  <div class="aqr-vis-sub">Per-step ARC scores across a 10-step task — v1.0, by category</div>
  <div class="aqr-vis-toggle-group">
    <button class="aqr-vis-toggle active" id="atog-coding" onclick="aqrToggle('coding')">Coding</button>
    <button class="aqr-vis-toggle active" id="atog-creative" onclick="aqrToggle('creative')">Creative Writing</button>
    <button class="aqr-vis-toggle active" id="atog-qa" onclick="aqrToggle('qa')">General QA</button>
    <button class="aqr-vis-toggle active" id="atog-math" onclick="aqrToggle('math')">Math/Logic</button>
    <button class="aqr-vis-toggle active" id="atog-sci" onclick="aqrToggle('sci')">Scientific</button>
  </div>
  <div class="aqr-vis-legend">
    <span><i style="background:#7db800;"></i> Coding (mean 0.700)</span>
    <span><i style="background:#e07055;"></i> Creative Writing (mean 0.558)</span>
    <span><i style="background:#a8c8d8;"></i> General QA (mean 0.700)</span>
    <span><i style="background:#9d8fe8;"></i> Math/Logic (mean 0.582)</span>
    <span><i style="background:#f5c842;"></i> Scientific (mean 0.658)</span>
  </div>
  <div style="position: relative; width: 100%; height: 340px;">
    <canvas id="aqrTrajChart"></canvas>
  </div>
  <p class="aqr-vis-note">Coding and General QA trace a flat or gently rising arc — both orient before the task steepens. Creative Writing and Math/Logic open high and fall, a signature of Early Collapse. Coding (0.700) and General QA (0.700) have identical mean scores; their trajectories are indistinguishable by the scalar. An NLE scoring each step separately resolves that ambiguity.</p>
</div>

---

<h2 class="aqr-h2">Outcome: 7-Day Return Probability</h2>

<p class="aqr-p">The prior work used active days per week modeled as a bounded proportion (0–7, binomial link). This analysis uses a cleaner binary: given that user $i$ was active in week $t$, did they return in week $t+1$? The 7-day return indicator $r_{i,t} \in \{0,1\}$ is modeled with a logistic link.</p>

<p class="aqr-p">The binary framing maps directly to weekly retention as a business concept. An active-days model asks how engaged users were this week; a return probability model asks whether they came back at all, the decision that compounds into long-run retention and lifetime value.</p>

<p class="aqr-p">The known causal effect injected into the DGP is $\beta_{\text{true}} = 10.0$ log-odds per unit of centered composite ARC score (on the 0–1 scale). With a within-version SD of approximately 0.019, the marginal per-SD effect is 0.19 log-odds. At a baseline return probability of 65%, that translates to roughly 4 percentage points of retention per standard deviation of quality exposure, the same magnitude as the prior work expressed in return-probability units.</p>

<p class="aqr-p">The model:</p>

```r
bam(returned_next_week ~
      s(ARC_it_c, bs = "tp", k = 10) +    # within-version mean ARC (key predictor)
      version_f +                           # absorbs deployment-boundary shifts
      s(week, bs = "tp", k = 10) +         # residual time trends
      s(user_id_factor, bs = "re") +        # user-level random intercepts
      user_type +                           # Consumer vs Enterprise
      pre_project_engagement_score,         # baseline historical engagement
    family = binomial(), method = "fREML", discrete = TRUE)
```

<p class="aqr-p">Fit on a stratified 2,000-user subsample (~30,000 observations), preserving the 70/30 Consumer/Enterprise split from the full panel.</p>

---

<h2 class="aqr-h2">Results</h2>

<h3 class="aqr-h3">Mean ARC Score Predicts Return Probability</h3>

<div class="aqr-table-wrap">
  <table class="aqr-table">
    <thead>
      <tr>
        <th>Term</th>
        <th>Estimate / edf</th>
        <th>Test Stat</th>
        <th>p-value</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>s(ARC_it_c)</td><td>edf = 1.58</td><td>chi-sq = 318.44</td><td>&lt; 2 × 10⁻¹⁶</td></tr>
      <tr><td>version_f v1.1</td><td>B = 0.201</td><td>z = 10.82</td><td>&lt; 2 × 10⁻¹⁶</td></tr>
      <tr><td>version_f v1.2</td><td>B = 0.384</td><td>z = 11.27</td><td>&lt; 2 × 10⁻¹⁶</td></tr>
      <tr><td>s(week)</td><td>edf = 1.44</td><td>chi-sq = 0.47</td><td>0.814</td></tr>
      <tr><td>pre_project_engagement_score</td><td>B = 0.024</td><td>z = 92.18</td><td>&lt; 2 × 10⁻¹⁶</td></tr>
      <tr><td>user_type (Enterprise)</td><td>B = 0.011</td><td>z = 1.04</td><td>0.298</td></tr>
    </tbody>
  </table>
</div>

<p class="aqr-p"><strong>Deviance explained: 26.8% | Adj. R² = 0.284</strong></p>

<p class="aqr-p">The within-version quality effect is highly significant (chi-sq = 318.44, p &lt; 2 × 10⁻¹⁶). The version-level shifts (B = 0.201 and B = 0.384) are larger in absolute magnitude than the within-version smooth, the same structure as the prior work. Those jumps are causally uninterpretable for the same reason: everything changes at a deployment boundary. The smooth on ARC_it_c is doing the interpretable work.</p>

<p class="aqr-p">The residual time trend is flat (p = 0.814). The edf of 1.58 indicates slight curvature, matching the prior work (edf = 1.62), but the dominant relationship is linear. Pre-period engagement is the strongest individual predictor; Enterprise user type adds nothing once baseline engagement is controlled.</p>

<h3 class="aqr-h3">Calibration: Does the Estimator Recover the Right Effect?</h3>

<div class="aqr-table-wrap">
  <table class="aqr-table">
    <thead>
      <tr>
        <th>Method</th>
        <th>β̂</th>
        <th>95% CI</th>
        <th>Recovery</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>Linear parametric (ARC_it_c)</td><td>8.87</td><td>[7.93, 9.81]</td><td>89%</td></tr>
      <tr><td>GAM smooth (effective slope)</td><td>8.71</td><td>—</td><td>87%</td></tr>
      <tr><td>Cluster bootstrap (B=100)</td><td>8.84</td><td>[7.66, 10.02]</td><td>88%</td></tr>
    </tbody>
  </table>
</div>

<p class="aqr-p">The estimator recovers 89% of the true effect (β_true = 10.0). The 11% attenuation is the same mechanism as before: observed usage proportions are noisy estimates of each user's true category preferences, and that measurement error attenuates the exposure coefficient toward zero, textbook errors-in-variables bias. The cluster bootstrap CI [7.66, 10.02] contains the true value; the single-model parametric CI [7.93, 9.81] narrowly excludes it. That asymmetry replicates the prior finding exactly, and the recommendation is unchanged: use cluster-robust inference.</p>

<p class="aqr-p">The falsification check uses user-weight permutation: shuffle quality exposure across users within each version period, breaking all correlation between the composite score and user identity while preserving marginal distributions. The permuted model returns β = −0.82, p = 0.411. No signal where none was planted.</p>

<h3 class="aqr-h3">Early Slope as a Second Predictor</h3>

<p class="aqr-p">Adding early slope alongside mean ARC score tests whether trajectory shape predicts retention independently of average quality level.</p>

<div class="aqr-table-wrap">
  <table class="aqr-table">
    <thead>
      <tr>
        <th>Model</th>
        <th>Predictors</th>
        <th>Dev. Explained</th>
        <th>ΔAIC</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>GAMM-1</td><td>mean ARC score only</td><td>26.8%</td><td>—</td></tr>
      <tr><td>GAMM-2</td><td>mean ARC + early slope</td><td>28.4%</td><td>−34.2</td></tr>
    </tbody>
  </table>
</div>

<p class="aqr-p">Early slope adds 1.6 percentage points of deviance explained and cuts AIC by 34. Both predictors are significant (mean ARC: chi-sq = 276.1, p &lt; 10⁻¹⁶; early slope: chi-sq = 88.7, p = 5.2 × 10⁻¹²) and only modestly correlated (r = 0.34).</p>

<p class="aqr-p">Holding mean ARC score constant, a user whose category mix skews toward Early Collapse-prone categories is less likely to return next week than a user with the same mean score but better orientation quality.</p>

<div class="aqr-callout orange">
  Creative Writing reaches v1.2 with the largest absolute mean score gain across all five categories — 0.196 points over three versions. Its early trajectory slope is still negative in v1.2. A product team tracking only mean scores would read this as the headline success story. The retention model reads it as an optimization that left the harder problem untouched.
</div>

---

<h2 class="aqr-h2">Investment Map in Retention Units</h2>

<p class="aqr-p">Same counterfactual structure as the prior work: recompute each user's composite ARC score with frozen weights, propagate through the fitted model (recovered coefficient 8.87), and read off the P(return) change at the v1.0 baseline of 65%. A "+0.05 improvement" for a category means moving its mean step score from 0.700 to 0.750, roughly the scale of a targeted fine-tuning pass. The early slope scenario is separate: "+0.015" means reducing an Early Collapse pattern toward neutral without changing mean score.</p>

<div class="aqr-table-wrap">
  <p class="aqr-table-caption">Counterfactual retention lift — v1.0 baseline, P(return) = 0.65</p>
  <table class="aqr-table">
    <thead>
      <tr>
        <th>Scenario</th>
        <th>Mean ΔARC</th>
        <th>ΔP(return)</th>
        <th>Per 100K users/week</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>All categories +0.02</td><td>+0.0200</td><td>+4.0 pp</td><td>+4,000</td></tr>
      <tr><td>Coding +0.05</td><td>+0.0123</td><td>+2.4 pp</td><td>+2,400</td></tr>
      <tr><td>Math/Logic +0.05</td><td>+0.0107</td><td>+2.1 pp</td><td>+2,100</td></tr>
      <tr><td>Creative Writing: mean +0.05 + fix early slope (+0.015)</td><td>+0.0076</td><td>+2.1 pp</td><td>+2,100</td></tr>
      <tr><td>Creative Writing +0.05 (mean score only)</td><td>+0.0076</td><td>+1.5 pp</td><td>+1,500</td></tr>
      <tr><td>Creative Writing: fix early slope only (+0.015)</td><td>—</td><td>+0.6 pp</td><td>+600</td></tr>
    </tbody>
  </table>
</div>

<div class="aqr-vis-card">
  <div class="aqr-vis-label">Investment map</div>
  <div class="aqr-vis-title">Predicted retention lift by improvement scenario</div>
  <div class="aqr-vis-sub">ΔP(7-day return) in percentage points — v1.0 baseline</div>
  <div style="position: relative; width: 100%; height: 320px;">
    <canvas id="aqrRoiChart"></canvas>
  </div>
  <p class="aqr-vis-note">The combined Creative Writing scenario (mean improvement + early slope fix) reaches parity with Math/Logic mean-only. Scalar quality rankings make Creative Writing look like the worst investment; trajectory-aware analysis reveals it's undervalued.</p>
</div>

<p class="aqr-p">The targeted improvement order follows usage weights (Coding at 24.6%, Math/Logic at 21.4%, Creative Writing at 15.1%), but the magnitudes aren't derivable from the ordering. You need the fitted model.</p>

<p class="aqr-p">Creative Writing ranks last as a single-category target at 1,500 users per week, matching the prior analysis. But that ranking rests entirely on mean score. When early slope contributes separately, a Creative Writing investment addressing both mean quality and orientation quality returns 2,100 users, on par with Math/Logic. The trajectory penalty was invisible to scalar ratings.</p>

<p class="aqr-p">The broad investment ("All categories +0.02") returns 4,000 users per week, 67% more than the best single-category scenario. Each category gets only a 0.02-point improvement, but it lifts every user rather than only those whose usage mix overlaps the targeted category. The argument for breadth holds across both frameworks.</p>

---

<h2 class="aqr-h2">Limitations</h2>

<p class="aqr-p">This is proof-of-concept on synthetic data. Finding 89% recovery validates the estimator against a known answer, not a claim about any deployed product. On real data the effect could be larger, smaller, or absent.</p>

<p class="aqr-p">The early slope finding also requires infrastructure most teams don't have. Per-step evaluation scores require either a step-level NLE scoring pipeline (as described in the ARC article) or a retrospective decomposition of existing evaluations into early and late phases. Without that, the trajectory features are unobservable.</p>

<p class="aqr-p">Late slope is a natural third predictor but was excluded here: on 10-step tasks, adding both slopes introduces multicollinearity. On longer tasks with more heterogeneous trajectories, a three-predictor model is a reasonable extension.</p>

<p class="aqr-p">The novelty-vs.-durability problem remains. A quality improvement in mean score or trajectory shape might spike retention for the first cohort and taper as the new level becomes expected. Distinguishing a durable gain from a novelty effect requires cohort tracking that can't be derived from the within-version structure used here.</p>

---

## Technical Appendix

- **Analysis code**: `aqr_analysis.R` (R 4.5.2, mgcv, dplyr, ggplot2, patchwork)
- **Data generation**: `aqr_generate_data.py` (Python 3.9, pandas, numpy; generates per-step ARC trajectories with `TRUE_BETA_MEAN = 10.0`, `TRUE_BETA_SLOPE = 12.0`, binary retention outcome)
- **Model fitting**: `mgcv::bam()`, fREML, `discrete = TRUE`, 2,000-user stratified subsample (~30K obs)
- **Cluster bootstrap**: B=100, user-level block resampling, linear parametric model

| File | Records | Description |
|------|---------|-------------|
| `aqr_trajectories.csv` | 50,000 | Per-step ARC scores — category × version × task |
| `aqr_user_demographics.csv` | 100,000 | User characteristics, subscription tier, baseline engagement |
| `aqr_session_logs.csv` | ~1.65M | Weekly session records with category counts and 7-day return indicator |

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

// ── Trajectory chart ──────────────────────────────────────────────────────────

const aqrSteps = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

const aqrTrajData = {
  coding:   [0.68, 0.70, 0.72, 0.72, 0.71, 0.71, 0.70, 0.69, 0.69, 0.68],
  creative: [0.70, 0.66, 0.61, 0.56, 0.52, 0.51, 0.50, 0.50, 0.51, 0.51],
  qa:       [0.70, 0.71, 0.70, 0.70, 0.70, 0.69, 0.70, 0.70, 0.69, 0.70],
  math:     [0.74, 0.70, 0.64, 0.58, 0.54, 0.53, 0.52, 0.52, 0.53, 0.52],
  sci:      [0.65, 0.66, 0.68, 0.68, 0.67, 0.65, 0.65, 0.65, 0.64, 0.65]
};

const aqrColors = {
  coding:   '#7db800',
  creative: '#e07055',
  qa:       '#a8c8d8',
  math:     '#9d8fe8',
  sci:      '#f5c842'
};

const aqrLabels = {
  coding:   'Coding',
  creative: 'Creative Writing',
  qa:       'General QA',
  math:     'Math/Logic',
  sci:      'Scientific'
};

const aqrVisible = { coding: true, creative: true, qa: true, math: true, sci: true };

const aqrTrajChart = new Chart(document.getElementById('aqrTrajChart'), {
  type: 'line',
  data: {
    labels: aqrSteps,
    datasets: Object.keys(aqrTrajData).map(k => ({
      label: aqrLabels[k],
      data: aqrTrajData[k],
      borderColor: aqrColors[k],
      backgroundColor: 'transparent',
      borderWidth: 2.5,
      pointRadius: 3,
      pointBackgroundColor: aqrColors[k],
      tension: 0.3
    }))
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: {
        title: {
          display: true,
          text: 'Task step',
          color: 'rgba(255,255,255,0.3)',
          font: { family: "'Space Mono', monospace", size: 11 }
        },
        grid: { color: 'rgba(255,255,255,0.04)' }
      },
      y: {
        title: {
          display: true,
          text: 'ARC step score (0–1)',
          color: 'rgba(255,255,255,0.3)',
          font: { family: "'Space Mono', monospace", size: 11 }
        },
        min: 0.40,
        max: 0.85,
        grid: { color: 'rgba(255,255,255,0.04)' }
      }
    },
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: {
          label: ctx => ` ${ctx.dataset.label}: ${ctx.parsed.y.toFixed(3)}`
        }
      }
    }
  }
});

function aqrToggle(key) {
  aqrVisible[key] = !aqrVisible[key];
  const btn = document.getElementById('atog-' + key);
  btn.classList.toggle('active');
  const ds = aqrTrajChart.data.datasets.find(d => d.label === aqrLabels[key]);
  if (ds) {
    ds.hidden = !aqrVisible[key];
    aqrTrajChart.update();
  }
  btn.style.background = aqrVisible[key] ? aqrColors[key] : 'rgba(255,255,255,0.04)';
  btn.style.color = aqrVisible[key] ? 'var(--predawn)' : '';
}

// Initialize toggle button colors on load
Object.keys(aqrColors).forEach(k => {
  const btn = document.getElementById('atog-' + k);
  if (btn) {
    btn.style.background = aqrColors[k];
    btn.style.color = 'var(--predawn)';
    btn.style.borderColor = 'transparent';
  }
});

// ── Investment map chart ──────────────────────────────────────────────────────

new Chart(document.getElementById('aqrRoiChart'), {
  type: 'bar',
  data: {
    labels: [
      'All categories +0.02',
      'Coding +0.05',
      'Math/Logic +0.05',
      'CW: mean +0.05 + fix early slope',
      'Creative Writing +0.05 (mean only)',
      'CW: fix early slope only'
    ],
    datasets: [{
      label: 'ΔP(7-day return)',
      data: [4.0, 2.4, 2.1, 2.1, 1.5, 0.6],
      backgroundColor: [
        '#a8c8d8',
        '#7db800',
        '#9d8fe8',
        '#e07055',
        'rgba(224,112,85,0.40)',
        'rgba(224,112,85,0.20)'
      ],
      borderColor: [
        '#a8c8d8',
        '#7db800',
        '#9d8fe8',
        '#e07055',
        '#e07055',
        '#e07055'
      ],
      borderWidth: 1.5,
      borderRadius: 3
    }]
  },
  options: {
    indexAxis: 'y',
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: {
        title: {
          display: true,
          text: 'Δ P(7-day return) — percentage points',
          color: 'rgba(255,255,255,0.3)',
          font: { family: "'Space Mono', monospace", size: 11 }
        },
        grid: { color: 'rgba(255,255,255,0.04)' },
        min: 0,
        max: 5
      },
      y: {
        grid: { display: false },
        ticks: { font: { family: "'Space Mono', monospace", size: 11 } }
      }
    },
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: {
          label: ctx => ` +${ctx.parsed.x.toFixed(1)} pp`
        }
      }
    }
  }
});
</script>

<div class="aqr-footnotes">
  <p><strong>Prior work.</strong> The within-version quality exposure framework, identification strategy, frozen-weights design, and GAMM specification are described in full in <a href="../model-quality/">Does Making AI Smarter Actually Make People Use It More?</a> (Feb. 2026). The ARC trajectory evaluation framework — including the NLE scoring protocol, four failure patterns, and calibration procedure — is described in <a href="../arc/">The Shape of a Good Answer</a> (Feb. 2026).</p>
  <p><strong>Data note.</strong> All data is synthetic. No real users, no proprietary models, no production systems. The injected causal effects are β_true = 10.0 log-odds per unit centered mean ARC score and β_true = 12.0 log-odds per unit centered early slope exposure. The estimator recovers 89% of the mean score effect; early slope recovery was not separately validated against its own β_true in this analysis.</p>
  <p><strong>Software.</strong> R 4.5.2; mgcv (Wood 2017), dplyr, ggplot2, patchwork. Python 3.9; pandas, numpy.</p>
</div>
