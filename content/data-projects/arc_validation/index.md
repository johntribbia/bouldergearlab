---
title: "Stress-Testing the Arc"
date: 2026-03-01
tags: ['data project']
categories: ['data project']
description: "A classification framework is itself an instrument, and instruments fail in specific ways. Before putting ARC into production, the right move is to deliberately try to break it and document exactly where it does."
banner: "arc-validation-banner.svg"
draft: false
---
<!--more-->

<style>
/* ── ARC Article — BGL Dark Theme ── */

.arc-companion-note {
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
.arc-companion-note a { color: var(--moss); border-bottom: none; }

/* ── Visualization cards ── */
.arc-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.arc-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.arc-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.arc-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.arc-vis-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 22px;
  margin-bottom: 14px;
  font-size: 1.25rem;
  color: rgba(255,255,255,0.55);
  font-family: var(--f-mono);
}
.arc-vis-legend span { display: flex; align-items: center; gap: 8px; }
.arc-vis-legend i { display: inline-block; width: 26px; height: 3px; border-radius: 2px; flex-shrink: 0; }
.arc-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}

/* ── Pull-quote callouts ── */
.arc-callout {
  margin: 2.2rem 0;
  padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic;
  font-size: 1.5rem;
  color: rgba(255,255,255,0.55);
  line-height: 1.8;
}
.arc-callout.ice  { border-color: var(--ice);  background: rgba(168,200,216,0.05); }
.arc-callout.plum { border-color: #9d8fe8; background: rgba(157,143,232,0.05); }

/* ── Aggregate score table ── */
.arc-score-wrap {
  overflow-x: auto;
  margin: 26px 0;
  border-radius: 4px;
  border: 1px solid rgba(255,255,255,0.07);
}
.arc-score-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.arc-score-table thead tr { background: rgba(255,255,255,0.06); }
.arc-score-table thead th {
  padding: 12px 16px;
  text-align: left;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.7);
}
.arc-score-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.arc-score-table tbody td {
  padding: 11px 16px;
  border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono);
  color: rgba(255,255,255,0.48);
  font-size: 1.25rem;
}
.arc-score-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }

/* ── Code blocks ── */
.arc-pre {
  background: rgba(0,0,0,0.45);
  color: rgba(255,255,255,0.65);
  border-radius: 6px;
  padding: 20px 22px;
  font-size: 1.1rem;
  font-family: var(--f-mono);
  line-height: 1.68;
  overflow-x: auto;
  margin: 20px 0;
  border: 1px solid rgba(255,255,255,0.06);
  white-space: pre;
  word-break: normal;
  word-wrap: normal;
}
.arc-pre code {
  display: block;
  background: transparent;
  padding: 0;
  border-radius: 0;
  border: none;
  color: inherit;
  font-size: inherit;
  white-space: pre;
  word-break: normal;
  word-wrap: normal;
}

/* ── Validation result table ── */
.arc-val-wrap {
  overflow-x: auto;
  margin: 24px 0;
  border-radius: 4px;
  border: 1px solid rgba(255,255,255,0.07);
}
.arc-val-table { width: 100%; border-collapse: collapse; font-family: var(--f-mono); font-size: 1.1rem; }
.arc-val-table thead tr { background: rgba(255,255,255,0.06); }
.arc-val-table thead th {
  padding: 10px 14px;
  text-align: left;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  font-size: 1.1rem;
  color: rgba(255,255,255,0.65);
  border-right: 1px solid rgba(255,255,255,0.05);
}
.arc-val-table thead th:last-child { border-right: none; }
.arc-val-table tbody td {
  padding: 10px 14px;
  border-top: 1px solid rgba(255,255,255,0.05);
  border-right: 1px solid rgba(255,255,255,0.04);
  color: rgba(255,255,255,0.45);
  vertical-align: top;
  line-height: 1.5;
}
.arc-val-table tbody td:last-child { border-right: none; }
.arc-val-table tbody td:first-child { color: rgba(255,255,255,0.75); font-weight: 600; }
.arc-val-v1  { color: #e07055 !important; }
.arc-val-v3  { color: var(--moss) !important; }
.arc-val-note { font-size: 1rem; color: rgba(255,255,255,0.3); font-style: italic; }

/* ── Boundary condition cards ── */
.arc-bound {
  margin: 1.8rem 0;
  padding: 1.4rem 1.7rem;
  border-left: 3px solid rgba(255,255,255,0.18);
  background: rgba(255,255,255,0.02);
  border-radius: 0 6px 6px 0;
}
.arc-bound-title {
  font-family: var(--f-mono);
  font-size: 1.1rem;
  font-weight: 700;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  margin-bottom: 10px;
}
.arc-bound p { font-size: 1.5rem; color: rgba(255,255,255,0.55); margin-bottom: 8px; line-height: 1.78; }
.arc-bound .bound-fix {
  font-family: var(--f-mono);
  font-style: italic;
  font-size: 1.25rem;
  color: rgba(255,255,255,0.32);
  margin-top: 8px;
  margin-bottom: 0;
}
.arc-bound code {
  background: rgba(255,255,255,0.06);
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 0.9em;
  color: rgba(255,255,255,0.65);
}
.arc-bound.b1 { border-color: #9d8fe8; }
.arc-bound.b2 { border-color: #e07055; }
.arc-bound.b3 { border-color: #a8c8d8; }
.arc-bound.b1 .arc-bound-title { color: #9d8fe8; }
.arc-bound.b2 .arc-bound-title { color: #e07055; }
.arc-bound.b3 .arc-bound-title { color: #a8c8d8; }

/* ── Section body prose (pure-HTML sections) ── */
.arc-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.arc-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }
.arc-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}
.arc-h3 {
  font-family: var(--f-mono);
  font-size: 1.05rem;
  font-weight: 700;
  letter-spacing: 0.09em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.65);
  margin: 2.4rem 0 0.85rem;
}
.arc-hr {
  border: none;
  border-top: 1px solid rgba(255,255,255,0.08);
  margin: 3rem 0;
}

/* ── References / footnotes ── */
.arc-footnotes { margin-top: 52px; border-top: 1px solid rgba(255,255,255,0.08); padding-top: 26px; }
.arc-footnotes h2 {
  font-size: 1.25rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: rgba(255,255,255,0.28);
  border-bottom: none;
  margin-top: 0;
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.arc-footnotes ol { padding-left: 22px; font-size: 1.25rem; color: rgba(255,255,255,0.35); line-height: 1.65; font-family: var(--f-mono); }
.arc-footnotes ol li { margin-bottom: 12px; }
.arc-footnotes a { color: var(--moss); }

/* ── Responsive ── */
@media (max-width: 680px) {
  .arc-row { grid-template-columns: 52px 130px 1fr; }
  .arc-measure { display: none; }
}
</style>

<div class="arc-companion-note">
  This is the second post in the ARC series. The first post, <a href="../arc/">The Shape of a Good Answer</a>, introduces the framework — what a good agent trajectory looks like and how to classify when it breaks. This post stress-tests the classifier itself.
</div>

*Article by John Tribbia*

There is a second problem on Bear Peak that I did not mention in the first post. You can run a perfect arc — controlled start, building rhythm, holding form through the summit and still not know it, if your heart rate monitor is lying to you. The Garmin spikes to 190 on a flat section. The GPS trace shows a detour you did not take. Trusting the instrument is a separate problem from running the right shape, and it requires its own kind of rigor. You calibrate a GPS watch against known distances. You verify the heart rate sensor against a chest strap. You do not ship the data until you understand what the errors look like.

The same separation applies to ARC. The <a href="../arc/">previous post</a> described what a good agent trajectory looks like and how to classify deviations from it. This one does what you should do with any new instrument before trusting it in production: deliberately tries to break it. The classifier gets stress-tested against synthetic trajectories at increasing noise levels. The failure modes are documented precisely. Knowing the operating envelope of your measurement tool is part of trusting the measurement.

---

<h2 class="arc-h2">Testing the Framework</h2>

<p class="arc-p">The most honest thing you can do with a new framework is try to break it. We generated 1,500 synthetic trajectories (300 per pattern) labeled each one with its true failure type, ran them through the classifier, and checked how often it got the right answer. The test used the four trajectories defined in the previous post as base signals, then added noise at increasing levels to map the performance envelope.</p>

<p class="arc-p">It took three versions to get a clean classifier. The path there is worth documenting, because it validates the framework in a way that a single clean result would not.</p>

<h3 class="arc-h3">Step 1: Run the Classifier on Its Own Examples</h3>

<p class="arc-p">Before touching noise levels or bulk trials, the obvious first test is: does <code>classify_trajectory()</code> correctly label the four example trajectories shown in the first post?</p>

<div class="arc-score-wrap">
  <table class="arc-score-table">
    <thead>
      <tr><th>Model</th><th>Expected</th><th>V1 Returns</th><th>Status</th></tr>
    </thead>
    <tbody>
      <tr>
        <td>A</td>
        <td style="color:rgba(255,255,255,0.45);">early_collapse</td>
        <td style="color:rgba(255,255,255,0.45);">steady_degradation</td>
        <td style="color:#e07055; font-weight:700;">✗ wrong</td>
      </tr>
      <tr>
        <td>B</td>
        <td style="color:rgba(255,255,255,0.45);">late_drift</td>
        <td style="color:rgba(255,255,255,0.45);">healthy</td>
        <td style="color:#e07055; font-weight:700;">✗ wrong</td>
      </tr>
      <tr>
        <td>C</td>
        <td style="color:rgba(255,255,255,0.45);">steady_degradation</td>
        <td style="color:rgba(255,255,255,0.45);">steady_degradation</td>
        <td style="color:#7db800; font-weight:700;">✓ correct</td>
      </tr>
      <tr>
        <td>D</td>
        <td style="color:rgba(255,255,255,0.45);">recovery</td>
        <td style="color:rgba(255,255,255,0.45);">recovery</td>
        <td style="color:#7db800; font-weight:700;">✓ correct</td>
      </tr>
    </tbody>
  </table>
</div>

<p class="arc-p">Two of four fail. Both have the same root cause. The original classifier checks the slope <em>within</em> each segment to detect early_collapse and late_drift. But both patterns, as they appear in the example data, are <em>cross-segment</em> drops — invisible to within-segment arithmetic.</p>

<p class="arc-p"><strong>Model A:</strong> early = [0.90, 0.91, 0.88], within-segment slope = −0.007. The collapse happens at step 4, after the early segment ends. The slope check reaches −0.007, far from the −0.15 threshold, and falls through to <code>steady_degradation</code>.</p>

<p class="arc-p"><strong>Model B:</strong> late = [0.88, 0.87, 0.55, 0.45], per-step slope = −0.1075. The threshold is −0.15. Close but not there. Falls through every branch and returns <code>healthy</code>.</p>

<h3 class="arc-h3">Step 2: Three Rounds to Get It Right</h3>

<p class="arc-p"><strong>V1 → V2:</strong> The obvious fix for early_collapse is to compare segment means instead of within-segment slope: if the early-third mean drops substantially by the mid-third, flag it. That works. early_collapse classification jumps from 0% to 67% accuracy. But it immediately breaks recovery. Recovery trajectories also have a large early-to-mid drop before they correct. The mean comparison cannot tell them apart because it is not looking at what happens in the final third.</p>

<p class="arc-p"><strong>V2 → V3:</strong> The fix requires two changes together. First, check recovery <em>before</em> early_collapse: recovery has to clear the gate first. Second, add a confirming condition to early_collapse: the early mean must exceed both the mid mean <em>and</em> the late mean by more than 0.20. A recovery trajectory has a high late mean, so it does not get caught. Early collapse stays low through the end, so it does. Both conditions together resolve the confusion entirely.</p>

<p class="arc-p">The iteration matters because it demonstrates that the framework caught a real bug rather than a contrived one. Fixing it required understanding the structural difference between the patterns, not just adjusting a threshold.</p>

<h3 class="arc-h3">V3: The Validated Classifier</h3>

<pre class="arc-pre"><code>def classify_trajectory(scores):
    n = len(scores)
    s = list(scores)
    t = n // 3
    early_mean = sum(s[:t]) / t
    mid_mean   = sum(s[t:2*t]) / t
    late_mean  = sum(s[2*t:]) / (n - 2*t)
    slope_l    = (s[-1] - s[2*t]) / max(n - 2*t - 1, 1)

    # 1. Recovery first: dip > 0.20, then climbs back > 0.10 above the dip
    dips = [i for i in range(1, n-1) if s[i] < s[i-1] - 0.20]
    if dips and s[-1] > s[dips[0]] + 0.10:
        return 'recovery'

    # 2. Early collapse: early strong, drops and stays low through mid AND late
    if (early_mean - mid_mean) > 0.20 and (early_mean - late_mean) > 0.20:
        return 'early_collapse'

    # 3. Late drift: final segment slopes clearly negative
    if slope_l < -0.12:
        return 'late_drift'

    # 4. Steady degradation: overall decline without a structural break
    if (s[0] - s[-1]) > 0.15:
        return 'steady_degradation'

    return 'healthy'</code></pre>

<p class="arc-p">All four article trajectories now classify correctly. At N=1,500 independently-generated synthetic trajectories across five patterns, V3 achieves 80% overall accuracy and a macro F1 of 0.79. Recovery classifies at near-perfect precision; the weaker patterns — early_collapse, late_drift, and steady_degradation — cluster around F1 = 0.70–0.75, reflecting genuine boundary ambiguity between categories rather than classifier bugs.</p>

<div class="arc-val-wrap">
  <table class="arc-val-table">
    <thead>
      <tr><th>Pattern</th><th>V1 F1</th><th>V3 F1</th><th>What changed</th></tr>
    </thead>
    <tbody>
      <tr>
        <td>early_collapse</td>
        <td class="arc-val-v1">0.00</td>
        <td class="arc-val-v3">0.68</td>
        <td class="arc-val-note">Segment mean comparison replaces within-segment slope; mild collapses still bleed into steady_degradation</td>
      </tr>
      <tr>
        <td>late_drift</td>
        <td style="color:rgba(255,255,255,0.55);">—</td>
        <td style="color:rgba(255,255,255,0.55);">0.70</td>
        <td class="arc-val-note">Gradual late drops fall below the slope threshold and read as healthy</td>
      </tr>
      <tr>
        <td>steady_degradation</td>
        <td style="color:rgba(255,255,255,0.55);">—</td>
        <td style="color:rgba(255,255,255,0.55);">0.75</td>
        <td class="arc-val-note">Acts as a catch-all; absorbs misclassified early_collapse and late_drift cases</td>
      </tr>
      <tr>
        <td>recovery</td>
        <td class="arc-val-v3">—</td>
        <td class="arc-val-v3">0.98</td>
        <td class="arc-val-note">Recovery-first ordering protects this branch; large cliff signal is distinctive</td>
      </tr>
      <tr>
        <td>healthy</td>
        <td style="color:rgba(255,255,255,0.55);">—</td>
        <td style="color:rgba(255,255,255,0.55);">0.84</td>
        <td class="arc-val-note">Mild late drifts below the slope threshold land here — acceptable by design</td>
      </tr>
    </tbody>
  </table>
</div>

<p class="arc-p">The F1 scores for early_collapse, late_drift, and steady_degradation cluster in the 0.68–0.75 range on independently-generated synthetic trajectories. The common failure mode is boundary ambiguity: a mild early collapse that doesn't drop far enough reads as steady_degradation; a gradual late drift that stays above the slope threshold reads as healthy; a noisy steady decline gets misattributed to whichever structural pattern the noise mimics. These are not classifier bugs to chase — they reflect cases where the signal is genuinely below the detection threshold. Recovery is the exception: its large single-step cliff (>0.20) is structurally distinctive and classifies at F1 = 0.98 even on hard independently-drawn samples. The noise sweep in the next section shows that these same patterns hold under measurement noise, with recovery remaining robust well above σ = 0.15 while the other three cross the 80% reliability floor around σ = 0.08.</p>

<h3 class="arc-h3">How Noise Degrades Classification</h3>

<p class="arc-p">The noise sweep uses the four article trajectories as base signals, adds Gaussian noise at five levels from σ = 0.02 to σ = 0.15, and runs 5,000 trials per cell. σ represents the combined measurement noise from your NLE scorer plus natural step-to-step variation — the ambient noise floor of any real evaluation run.</p>

<div class="arc-vis-card">
  <div class="arc-vis-label">Synthetic validation · V3 classifier · 5,000 trials per cell</div>
  <div class="arc-vis-title">Classification accuracy vs. NLE measurement noise (σ)</div>
  <div class="arc-vis-sub">Article example trajectories as base signals · Gaussian noise · 4 failure patterns</div>
  <div class="arc-vis-legend">
    <span><i style="background:#e07055;"></i> Early Collapse</span>
    <span><i style="background:#a8c8d8;"></i> Late Drift</span>
    <span><i style="background:#9d8fe8;"></i> Steady Degradation</span>
    <span><i style="background:#7db800;"></i> Recovery</span>
  </div>
  <div style="position: relative; width: 100%; height: 340px;">
    <canvas id="noiseChart"></canvas>
  </div>
  <p class="arc-vis-note">The dashed line marks 80% accuracy — a practical reliability floor for production use. All three non-recovery patterns cross it at σ = 0.08. Recovery stays above 80% even at σ = 0.15. At σ = 0.08 the gap between the strongest and weakest patterns is 25 percentage points. Measure your NLE scorer's own variance before treating classifier output as actionable.</p>
</div>

<h3 class="arc-h3">Three Boundary Conditions</h3>

<div class="arc-bound b1">
  <div class="arc-bound-title">Boundary 1 — Steady degradation requires a low-noise scorer</div>
  <p>Steady degradation is the pattern most sensitive to measurement noise. At σ = 0.05 accuracy is 95%; by σ = 0.08 it drops to 76%, and by σ = 0.11 it is at 58%. The detection logic — <code>s[0] − s[-1] > 0.15</code> — has the smallest signal margin of the four branches. Any trajectory with a higher start than finish qualifies, so noisy early_collapse and late_drift trajectories bleed into this bucket under measurement variance.</p>
  <p class="bound-fix">Fix: Run 10–15 duplicate scorings on the same step outputs to estimate your NLE's σ before committing to a task suite. If σ > 0.06, steady_degradation results are not reliably actionable - flag them as unresolved and pull a manual sample before intervening.</p>
</div>

<div class="arc-bound b2">
  <div class="arc-bound-title">Boundary 2 — Recovery detection measures cliff size, not recovery</div>
  <p>Recovery is the most robust pattern across all noise levels, staying above 80% even at σ = 0.15. But that robustness comes from the size of a single-step drop in the base trajectory (0.45 points), not from anything general about detecting self-correction. A genuine recovery that unfolds across two smaller drops (−0.12, then −0.12) produces no entry in <code>dips</code> and gets silently classified as steady_degradation. Real agent self-correction often unfolds gradually. The classifier is detecting the presence of a cliff, not the act of recovering.</p>
  <p class="bound-fix">Fix: Replace the pairwise dip detector with a 2-step rolling minimum: <code>min(s[i-1], s[i]) &lt; s[i-2] - 0.15</code>, which catches recoveries that compress across two steps without requiring a single-step cliff.</p>
</div>

<div class="arc-bound b3">
  <div class="arc-bound-title">Boundary 3 — Task length below 7 steps breaks segment estimation</div>
  <p>The simulation used n = 10. At n = 5, <code>n//3 = 1</code>, so the early segment is a single score and the late segment is two scores. Both early_mean and slope_l are computed from samples of size 1–2, where one noisy observation can swing the entire result. Classification accuracy at n = 5 falls roughly 25 percentage points below the n = 10 baseline for all four patterns.</p>
  <p class="bound-fix">Fix: Require n ≥ 7 before running the classifier. If the task naturally decomposes into fewer steps, aggregate adjacent step pairs to produce a longer effective sequence before scoring.</p>
</div>

<p class="arc-p">The validated classifier operates reliably within a specific envelope: trajectories of 7 or more steps, NLE scorer variance below σ = 0.08, and failure events that compress into a single step. Outside that envelope it degrades in predictable ways. Knowing the failure mode of your measurement tool is part of trusting it. A heart rate monitor that drifts at altitude is still useful — you just need to know where it starts lying.</p>

<hr class="arc-hr"/>

<h2 class="arc-h2">What Comes Next</h2>

<p class="arc-p">The simulation above validates classifier behavior and maps its operating envelope on synthetic data. The next post builds on the same validation strategy used in <a href="../model-quality-overview/">earlier work on model quality and user retention</a> — baking a known causal effect into a synthetic dataset so the estimator can be checked against ground truth.</p>

<p class="arc-p">The goal is the same: show that the ARC estimator recovers the right answer, characterize where it falls short, and build something teams can actually instrument in production. The disambiguation protocol will be validated against ground-truth failure labels. The behavioral grounding discipline will be tested empirically by checking whether the quality dimensions ARC identifies as load-bearing in eval actually surface as predictive factors in production engagement data.</p>

<p class="arc-p">That last test is the one that closes the loop between controlled evaluation and the real world.</p>

<p class="arc-p"><em>No training data, model weights, or proprietary systems are involved in this analysis. Full technical specification is in the companion document.</em></p>

<div class="arc-footnotes">
  <h2>References</h2>
  <ol>
    <li id="fn1">Lightman, H., Kosaraju, V., Burda, Y., Edwards, H., Baker, B., Lee, T., Leike, J., Schulman, J., Sutskever, I., and Cobbe, K. (2023). "Let's Verify Step by Step." <em>arXiv preprint arXiv:2305.20050</em>. <a href="https://arxiv.org/abs/2305.20050" target="_blank" rel="noopener">https://arxiv.org/abs/2305.20050</a></li>
    <li id="fn2">Cobbe, K., Kosaraju, V., Bavarian, M., Chen, M., Jun, H., Kaiser, L., Plappert, M., Tworek, J., Hilton, J., Nakano, R., Hesse, C., and Schulman, J. (2021). "Training Verifiers to Solve Math Word Problems." <em>arXiv preprint arXiv:2110.14168</em>. <a href="https://arxiv.org/abs/2110.14168" target="_blank" rel="noopener">https://arxiv.org/abs/2110.14168</a></li>
  </ol>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
/* ── Shared chart defaults for BGL dark theme ── */
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

/* ── CHART: Noise vs. Classification Accuracy (V3) ── */
new Chart(document.getElementById('noiseChart'), {
  type: 'line',
  data: {
    labels: ['\u03c3 = 0.02', '\u03c3 = 0.05', '\u03c3 = 0.08', '\u03c3 = 0.11', '\u03c3 = 0.15'],
    datasets: [
      {
        label: 'Early Collapse',
        data: [1.00, 0.94, 0.76, 0.61, 0.46],
        borderColor: '#e07055', backgroundColor: 'rgba(224,112,85,0.07)',
        fill: false, tension: 0.3, borderWidth: 2.8,
        pointRadius: 5, pointHoverRadius: 7,
        pointBackgroundColor: '#e07055',
        pointBorderColor: 'rgba(10,13,20,0.9)', pointBorderWidth: 1.5
      },
      {
        label: 'Late Drift',
        data: [0.99, 0.84, 0.72, 0.63, 0.57],
        borderColor: '#a8c8d8', backgroundColor: 'rgba(168,200,216,0.07)',
        fill: false, tension: 0.3, borderWidth: 2.8,
        pointRadius: 5, pointHoverRadius: 7,
        pointBackgroundColor: '#a8c8d8',
        pointBorderColor: 'rgba(10,13,20,0.9)', pointBorderWidth: 1.5
      },
      {
        label: 'Steady Degradation',
        data: [1.00, 0.95, 0.76, 0.58, 0.44],
        borderColor: '#9d8fe8', backgroundColor: 'rgba(157,143,232,0.07)',
        fill: false, tension: 0.3, borderWidth: 2.8,
        pointRadius: 5, pointHoverRadius: 7,
        pointBackgroundColor: '#9d8fe8',
        pointBorderColor: 'rgba(10,13,20,0.9)', pointBorderWidth: 1.5
      },
      {
        label: 'Recovery',
        data: [1.00, 1.00, 0.97, 0.94, 0.90],
        borderColor: '#7db800', backgroundColor: 'rgba(125,184,0,0.07)',
        fill: false, tension: 0.3, borderWidth: 2.8,
        pointRadius: 5, pointHoverRadius: 7,
        pointBackgroundColor: '#7db800',
        pointBorderColor: 'rgba(10,13,20,0.9)', pointBorderWidth: 1.5
      },
      {
        label: '80% reliability floor',
        data: [0.80, 0.80, 0.80, 0.80, 0.80],
        borderColor: 'rgba(255,255,255,0.20)', backgroundColor: 'transparent',
        fill: false, borderDash: [6, 4], borderWidth: 1.5,
        tension: 0, pointRadius: 0, pointHoverRadius: 0
      }
    ]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    interaction: { mode: 'index', intersect: false },
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: 'rgba(10,13,20,0.96)',
        titleColor: 'rgba(255,255,255,0.55)', bodyColor: 'rgba(255,255,255,0.55)',
        titleFont: { size: 12, family: 'Space Mono, monospace' },
        bodyFont:  { size: 12, family: 'Space Mono, monospace' },
        padding: 12, borderColor: 'rgba(255,255,255,0.08)', borderWidth: 1,
        filter: item => item.dataset.label !== '80% reliability floor',
        callbacks: {
          label: ctx => ' ' + ctx.dataset.label + ':  ' + (ctx.parsed.y * 100).toFixed(0) + '%'
        }
      }
    },
    scales: {
      x: {
        grid: { color: 'rgba(255,255,255,0.05)', drawTicks: false },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', maxRotation: 0 },
        title: { display: true, text: 'Noise level (\u03c3)', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', padding: { top: 8 } }
      },
      y: {
        min: 0.35, max: 1.05,
        grid: { color: 'rgba(255,255,255,0.05)' },
        ticks: {
          font: { size: 11, family: 'Space Mono, monospace' },
          color: 'rgba(255,255,255,0.32)',
          stepSize: 0.1,
          callback: v => (v * 100).toFixed(0) + '%'
        },
        title: { display: true, text: 'Classification accuracy', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)' }
      }
    }
  }
});
</script>