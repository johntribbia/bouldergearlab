---
title: "The Refusal Tax"
date: 2026-09-10
tags: ['data project']
categories: ['data project']
description: "A synthetic replication of a safety-classifier rollout shows a naive retention comparison overstates the true friction cost of false-positive refusals by roughly twenty times, once malicious-actor departure and an unrelated seasonal confound are separated out."
banner: "rt-banner.svg"
math: true
draft: false
---
<!--more-->

<style>
/* ── The Refusal Tax — BGL Dark Theme ── */

.rt-lede {
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

.rt-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.rt-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }

.rt-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

/* ── Visualization cards ── */
.rt-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.rt-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.rt-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.rt-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.rt-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}

/* ── Callout ── */
.rt-callout {
  margin: 2.2rem 0; padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic; font-size: 1.5rem;
  color: rgba(255,255,255,0.55); line-height: 1.8;
}
.rt-callout.red { border-color: #e07055; background: rgba(224,112,85,0.05); }
.rt-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

/* ── Data table ── */
.rt-table-wrap {
  overflow-x: auto; margin: 26px 0;
  border-radius: 4px; border: 1px solid rgba(255,255,255,0.07);
}
.rt-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.rt-table thead tr { background: rgba(255,255,255,0.06); }
.rt-table thead th {
  padding: 12px 16px; text-align: left;
  font-family: var(--f-mono); font-size: 1.25rem; font-weight: 600;
  letter-spacing: 0.08em; text-transform: uppercase; color: rgba(255,255,255,0.7);
}
.rt-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.rt-table tbody td {
  padding: 11px 16px; border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono); color: rgba(255,255,255,0.5); font-size: 1.25rem; line-height: 1.6;
}
.rt-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }
.rt-table-caption {
  font-family: var(--f-mono); font-size: 1.1rem;
  color: rgba(255,255,255,0.28); letter-spacing: 0.06em;
  text-transform: uppercase; margin-bottom: 0.5rem;
}

/* ── Footnotes ── */
.rt-footnotes {
  margin-top: 52px; border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px; font-family: var(--f-mono);
  font-size: 1.25rem; color: rgba(255,255,255,0.3); line-height: 1.65;
}
.rt-footnotes a { color: var(--moss); border-bottom: none; }
</style>

<div class="rt-lede">
  Synthetic replication of a safety-classifier rollout, built to validate a three-tier evaluation pipeline before it ever touches real telemetry.
</div>

*Article by John Tribbia*

<p class="rt-p">A biosecurity classifier ships, and refusals on biology-adjacent prompts jump from 1.2 percent to 8.2 percent of traffic. Thirty-day retention among the refused group lands 7.2 points below everyone else, the kind of gap that gets a patch rolled back before lunch if nobody reads past the headline.</p>

<p class="rt-p">Almost none of that 7.2-point gap turns out to be a real cost. Most of it is people the classifier was built to remove. A slice of it is an academic calendar that has nothing to do with the patch. What's left, once both of those are pulled out, is one-twentieth the size of the number everyone would have reacted to. Getting from the first number to the second is the exercise below.</p>

---

<h2 class="rt-h2">What's real here and what isn't</h2>

<p class="rt-p">The pressure to ship these classifiers is real. Anthropic's own reporting on disrupted misuse of Claude, spanning cyber operations, biological misuse, and other harm categories, is one instance of why.<sup>1</sup></p>

<p class="rt-p">No public dataset pairs a safety-classifier rollout with user-level retention. That pairing doesn't exist to download, so it's built here with a known effect wired into it on purpose. Fifteen thousand synthetic users are split across three archetypes: general users, students who lean on biology-adjacent language for coursework, and a small population of users probing for genuinely dual-use content. Each user has a frozen pre-period intent share <span>$w_{i,c}$</span> across five prompt categories. A classifier patch goes out at day 30 that correctly suppresses dual-use prompts and, as a side effect, raises the refusal rate on ordinary academic biology writing.</p>

<p class="rt-p">Three mechanisms are injected into the churn outcome, and their true sizes are known because this data was built, not observed: a genuine friction effect from false-positive refusals, a seasonal shock that hits students regardless of whether they were ever refused, and a deliberate departure effect for the small population that got correctly blocked. The question the rest of this post answers is whether a reasonable analysis pipeline can pull those three apart from the outcome data alone, the same way it would have to on real telemetry.</p>

---

<h2 class="rt-h2">Tier 1: what the telemetry says</h2>

<p class="rt-p">The first read is descriptive: track the refusal rate on biology-domain prompts before and after the patch ships. It moves fast and it moves a lot.</p>

<div class="rt-vis-card">
  <div class="rt-vis-label">Tier 1 / Telemetry</div>
  <div class="rt-vis-title">Refusal Rate on Biology-Domain Prompts</div>
  <div class="rt-vis-sub">Pre-rollout vs. post-rollout, academic_biology category</div>
  <div style="position: relative; width: 100%; height: 280px;">
    <canvas id="rtChartRefusal"></canvas>
  </div>
  <div class="rt-vis-note">A nearly sevenfold jump. On its own, this says nothing about whether the users behind it were frustrated, adapting, or leaving.</div>
</div>

<p class="rt-p">That's the whole of what Tier 1 can tell you. It confirms the patch is doing something, and it can't tell you whether that something is a problem.</p>

---

<h2 class="rt-h2">Tier 2: the naive comparison</h2>

<p class="rt-p">The obvious follow-up: do users who got refused actually leave at a higher rate than users who didn't. Split the post-rollout population into two groups by whether they hit at least one refusal, and compare 30-day retention.</p>

<div class="rt-vis-card">
  <div class="rt-vis-label">Tier 2 / Naive Comparison</div>
  <div class="rt-vis-title">30-Day Retention, Refused vs. Never Refused</div>
  <div class="rt-vis-sub">Post-rollout window, no controls</div>
  <div style="position: relative; width: 100%; height: 280px;">
    <canvas id="rtChartRetention"></canvas>
  </div>
  <div class="rt-vis-note">A 7.2-point gap, refused users retained at a meaningfully lower rate.</div>
</div>

<p class="rt-p">This is the number that would go in a postmortem if the analysis stopped here, and it's confounded in two directions at once. Users who trip a dual-use refusal skew toward the population that was already planning to leave once blocked, since getting blocked was the point. Users who trip a false-positive academic refusal skew toward students, and students churn on an academic calendar that has nothing to do with any classifier. Both of those get folded into the same 7.2 points as whatever real friction the false positives caused.</p>

<div class="rt-callout red">
  <strong>The naive number is directionally right and quantitatively almost useless.</strong> It says refusals correlate with leaving. It cannot say how much of that is the classifier working as intended.
</div>

---

<h2 class="rt-h2">Tier 3: isolating the real number</h2>

<p class="rt-p">Two things make the split possible that a plain regression of churn on exposure doesn't get for free. First, which category triggered a refusal is known at the event level, so the population that was correctly blocked on a dual-use prompt can be excluded from the friction estimate rather than averaged into it. That's a separate, already-understood mechanism, not a nuisance parameter to control away. Second, the exposure measure itself is centered within the rollout version, <span>$S_{i,t}^c = S_{i,t} - \bar S_{v(t)}$</span>, so the analysis is asking whether users with an above-average academic-biology mix churn more than other users in the same window, not whether the population churns more after the patch than before.</p>

<p class="rt-p">Neither of those alone is enough. A regression of churn on centered exposure, run across the whole population with no restriction, still returns a coefficient roughly two and a half times the true injected effect. The dual-use-heavy users who left on purpose are still in the sample, and their exposure correlates with the same variable. Restricting to non-malicious users and adding a cohort control for student status brings the coefficient down to 79 percent of the true effect: an undershoot now, from measurement error in the pre-period intent-share estimate itself, which is built from a finite sample of twenty prompts per user and is noisy by construction.</p>

<div class="rt-vis-card">
  <div class="rt-vis-label">Tier 3 / Decomposition</div>
  <div class="rt-vis-title">Decomposing the 7.2-Point Gap</div>
  <div class="rt-vis-sub">Contribution of each mechanism to the naive retention gap, via counterfactual ablation</div>
  <div style="position: relative; width: 100%; height: 280px;">
    <canvas id="rtChartDecomp"></canvas>
  </div>
  <div class="rt-vis-note">Genuine friction accounts for 0.33 of the 7.2 points, about 5 percent of what the naive comparison implied.</div>
</div>

<p class="rt-p">The measurement-error problem has a known fix. Split each user's pre-period prompt history into two halves and correlate the two academic-biology share estimates against each other. That correlation is 0.81, and the Spearman-Brown-corrected reliability of the full-period estimate is 0.90. Dividing the regression coefficient by that reliability is the standard classical-test-theory disattenuation correction, and it moves the estimate from 79 percent of the true effect to 88 percent.</p>

<div class="rt-vis-card">
  <div class="rt-vis-label">Tier 3 / Estimator</div>
  <div class="rt-vis-title">Recovering the True Friction Effect</div>
  <div class="rt-vis-sub">Regression coefficient as a percentage of the known injected effect</div>
  <div style="position: relative; width: 100%; height: 280px;">
    <canvas id="rtChartEstimator"></canvas>
  </div>
  <div class="rt-vis-note">Disattenuation closes part of the gap, not all of it. The honest result, not the tidy one.</div>
</div>

<p class="rt-p">Eighty-eight percent is not a full recovery, and reporting it as one would be the same mistake as the naive number in the other direction. The split-half correction accounts for measurement error in the exposure variable. It does nothing for noise elsewhere in the pipeline: how cleanly a category classifier separates academic from dual-use language, for one. On real telemetry, that residual gap is exactly the line to flag to whoever is deciding how much to trust the number, not the line to explain away.</p>

<div class="rt-table-wrap">
  <div class="rt-table-caption">Estimator progression</div>
  <table class="rt-table">
    <thead>
      <tr><th>Estimate</th><th>Sample</th><th>% of true effect</th></tr>
    </thead>
    <tbody>
      <tr><td>Naive regression</td><td>All users, no controls</td><td>250.6%</td></tr>
      <tr><td>Restricted + cohort control</td><td>Non-malicious users, controls for student status</td><td>78.5%</td></tr>
      <tr><td>Disattenuated</td><td>Same, corrected for split-half reliability</td><td>87.5%</td></tr>
    </tbody>
  </table>
</div>

---

<h2 class="rt-h2">What this changes</h2>

<p class="rt-p">The naive 7.2-point number points a fine-tuning team at the wrong problem: it looks like a UX regression large enough to justify loosening the classifier. Decomposed, the number points at a narrower, cheaper fix instead: tune the classifier specifically against academic-biology phrasing. That recovers something on the order of 0.3 to 0.4 retention points among benign users, without touching the 5.7 points of departure the patch was supposed to cause. Chasing the naive framing would have traded away real threat suppression for a number that was never mostly about friction in the first place.</p>

---

<h2 class="rt-h2">Where this generalizes</h2>

<p class="rt-p">The same three-tier progression applies past this one scenario: descriptive telemetry, a naive observational comparison, then a within-version estimator that separates mechanisms the naive comparison conflates. A few adjacent questions a preparedness function runs into, and roughly how each gets answered:</p>

<div class="rt-table-wrap">
  <div class="rt-table-caption">Adjacent questions, same underlying method</div>
  <table class="rt-table">
    <thead>
      <tr><th>Question</th><th>Method</th></tr>
    </thead>
    <tbody>
      <tr><td>Adversarial drift</td><td>How fast are prompt-encoding evasion techniques shifting after a safeguard ships, tracked via population stability index or embedding-space drift over time.</td></tr>
      <tr><td>Threshold placement</td><td>Where a dual-use classifier's decision boundary should sit to hold false-negative risk near zero while keeping false-positive friction under a fixed budget: cost-weighted precision-recall optimization.</td></tr>
      <tr><td>Capability triggers</td><td>Whether a model has crossed a capability threshold that mandates pre-deployment safeguards: continuous automated eval pipelines against a fixed threshold.</td></tr>
    </tbody>
  </table>
</div>

<p class="rt-p">What stays constant across all three is the discipline in Tier 3: know which mechanism you've excluded on purpose, know which measurement error you've corrected for, and report the part of the gap you can't yet explain instead of rounding it away.</p>

<div class="rt-footnotes">
  <strong>Methodology and disclosure:</strong> All data in this post is synthetic, generated by <code>scripts/generate_refusal_tax_data.R</code> with three known effects wired into the data-generating process (a benign-friction coefficient, a student-cohort seasonal shock, and a malicious-departure bump). Population size: 15,000 users. Random seed fixed at 42 for reproducibility. Run it yourself in <a href="https://colab.research.google.com/github/johntribbia/bouldergearlab/blob/main/notebooks/refusal_tax_data_generator.ipynb" target="_blank" rel="noopener">this Colab notebook</a>. The within-version centering and split-half disattenuation approach follows Tribbia, J. (2026), "Identifying Model Quality Effects on User Engagement: A Within-Version Causal Estimator with Synthetic Data Validation," <em>arXiv:2608.17187</em>, <a href="https://arxiv.org/abs/2608.17187" target="_blank" rel="noopener">arxiv.org/abs/2608.17187</a>, the same estimator applied there to model-quality and engagement is applied here to safety-classifier friction and retention. See also the companion analysis in <a href="/data-projects/model-quality/">Does Making AI Smarter Actually Make People Use It More?</a><br><br>
  <sup>1</sup> Anthropic, <a href="https://www.anthropic.com/threat-intelligence-report-september-2026" target="_blank" rel="noopener">Threat Intelligence Report, September 2026</a>.
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

function rtTooltip(suffix) {
  return {
    backgroundColor: 'rgba(10,13,20,0.96)',
    titleColor: 'rgba(255,255,255,0.55)', bodyColor: 'rgba(255,255,255,0.55)',
    titleFont: { size: 12, family: 'Space Mono, monospace' },
    bodyFont:  { size: 12, family: 'Space Mono, monospace' },
    padding: 12, borderColor: 'rgba(255,255,255,0.08)', borderWidth: 1,
    callbacks: { label: ctx => ' ' + ctx.dataset.label + ':  ' + ctx.parsed.y + suffix }
  };
}

/* ── CHART 1: Tier 1 refusal rate ── */
new Chart(document.getElementById('rtChartRefusal'), {
  type: 'bar',
  data: {
    labels: ['Pre-rollout', 'Post-rollout'],
    datasets: [{
      label: 'Refusal rate',
      data: [1.2, 8.2],
      backgroundColor: ['rgba(168,200,216,0.35)', 'rgba(224,112,85,0.4)'],
      borderColor: ['#a8c8d8', '#e07055'],
      borderWidth: 1.5, borderRadius: 4, maxBarThickness: 90
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: rtTooltip('%') },
    scales: {
      x: { grid: { display: false }, ticks: { font: { size: 12, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.5)' } },
      y: { min: 0, max: 10, grid: { color: 'rgba(255,255,255,0.05)' },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', callback: v => v + '%' },
        title: { display: true, text: 'Refusal rate', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)' } }
    }
  }
});

/* ── CHART 2: Tier 2 naive retention ── */
new Chart(document.getElementById('rtChartRetention'), {
  type: 'bar',
  data: {
    labels: ['Never refused', 'Refused at least once'],
    datasets: [{
      label: '30-day retention',
      data: [94.5, 87.3],
      backgroundColor: ['rgba(125,184,0,0.3)', 'rgba(224,112,85,0.4)'],
      borderColor: ['#7db800', '#e07055'],
      borderWidth: 1.5, borderRadius: 4, maxBarThickness: 90
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: rtTooltip('%') },
    scales: {
      x: { grid: { display: false }, ticks: { font: { size: 12, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.5)' } },
      y: { min: 80, max: 100, grid: { color: 'rgba(255,255,255,0.05)' },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', callback: v => v + '%' },
        title: { display: true, text: '30-day retention', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)' } }
    }
  }
});

/* ── CHART 3: Tier 3 decomposition ── */
new Chart(document.getElementById('rtChartDecomp'), {
  type: 'bar',
  data: {
    labels: ['Malicious departure', 'Academic calendar', 'Genuine friction'],
    datasets: [{
      label: 'Points of the 7.2-pt gap',
      data: [5.7, 0.71, 0.33],
      backgroundColor: ['rgba(157,143,232,0.35)', 'rgba(168,200,216,0.35)', 'rgba(125,184,0,0.4)'],
      borderColor: ['#9d8fe8', '#a8c8d8', '#7db800'],
      borderWidth: 1.5, borderRadius: 4, maxBarThickness: 90
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: rtTooltip(' pts') },
    scales: {
      x: { grid: { display: false }, ticks: { font: { size: 11.5, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.5)' } },
      y: { min: 0, max: 6, grid: { color: 'rgba(255,255,255,0.05)' },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', callback: v => v + ' pts' },
        title: { display: true, text: 'Retention-gap points', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)' } }
    }
  }
});

/* ── CHART 4: Tier 3 estimator progression ── */
new Chart(document.getElementById('rtChartEstimator'), {
  type: 'bar',
  data: {
    labels: ['Naive\n(all users)', 'Restricted +\ncohort control', 'Disattenuated', 'True effect'],
    datasets: [{
      label: '% of true effect',
      data: [250.6, 78.5, 87.5, 100],
      backgroundColor: ['rgba(224,112,85,0.4)', 'rgba(168,200,216,0.3)', 'rgba(168,200,216,0.45)', 'rgba(125,184,0,0.35)'],
      borderColor: ['#e07055', '#a8c8d8', '#a8c8d8', '#7db800'],
      borderWidth: 1.5, borderRadius: 4, maxBarThickness: 80
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: rtTooltip('%') },
    scales: {
      x: { grid: { display: false }, ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.5)' } },
      y: { min: 0, max: 280, grid: { color: 'rgba(255,255,255,0.05)' },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', callback: v => v + '%' },
        title: { display: true, text: '% of true injected effect', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)' } }
    }
  }
});
</script>
