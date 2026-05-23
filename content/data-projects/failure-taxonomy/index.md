---
title: "The Repair Requires a Diagnosis"
date: 2026-05-23
tags: ['data project']
categories: ['data project']
description: "Detecting that an AI system is failing is the easier problem. A failure taxonomy maps observable loss signals to the system layer responsible and a misrouted repair can make a different failure worse."
draft: false
banner: "ft-banner.svg"
---
<!--more-->

<style>
/* ── Failure Taxonomy — BGL Dark Theme ── */

.ft-lede {
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
.ft-lede a { color: var(--moss); border-bottom: none; }

.ft-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.ft-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }
.ft-p a { color: var(--moss); }

.ft-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.ft-hr {
  border: none;
  border-top: 1px solid rgba(255,255,255,0.08);
  margin: 3rem 0;
}

/* ── Visualization cards ── */
.ft-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.ft-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.ft-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.ft-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.ft-vis-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 22px;
  margin-bottom: 14px;
  font-size: 1.25rem;
  color: rgba(255,255,255,0.55);
  font-family: var(--f-mono);
}
.ft-vis-legend span { display: flex; align-items: center; gap: 8px; }
.ft-vis-legend i { display: inline-block; width: 26px; height: 3px; border-radius: 2px; flex-shrink: 0; }
.ft-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}

/* ── Callout ── */
.ft-callout {
  margin: 2.2rem 0;
  padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic;
  font-size: 1.5rem;
  color: rgba(255,255,255,0.55);
  line-height: 1.8;
}
.ft-callout.red { border-color: #e07055; background: rgba(224,112,85,0.05); }
.ft-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

/* ── Data table ── */
.ft-table-wrap {
  overflow-x: auto;
  margin: 26px 0;
  border-radius: 4px;
  border: 1px solid rgba(255,255,255,0.07);
}
.ft-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.ft-table thead tr { background: rgba(255,255,255,0.06); }
.ft-table thead th {
  padding: 12px 16px;
  text-align: left;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.7);
}
.ft-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.ft-table tbody td {
  padding: 11px 16px;
  border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono);
  color: rgba(255,255,255,0.5);
  font-size: 1.25rem;
  line-height: 1.6;
}
.ft-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }
.ft-table-caption {
  font-family: var(--f-mono);
  font-size: 1.1rem;
  color: rgba(255,255,255,0.28);
  letter-spacing: 0.06em;
  text-transform: uppercase;
  margin-bottom: 0.5rem;
}
.ft-table .residual { color: #e07055; font-style: italic; }
.ft-table a { color: var(--moss); }

/* ── Footnotes ── */
.ft-footnotes {
  margin-top: 52px;
  border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  line-height: 1.65;
}
.ft-footnotes a { color: rgba(255,255,255,0.4); }
</style>

<div class="ft-lede">
  Sequel to <a href="../wildchat-prompt-eras/">How Users Vote With Their Prompts</a>, <a href="../arc-retention/">The Shape Predicts the Return</a>, <a href="../arc/">The Shape of a Good Answer</a>, and <a href="../model-quality/">Does Making AI Smarter Actually Make People Use It More?</a> &nbsp;·&nbsp; N=1,000 synthetic interactions &nbsp;·&nbsp; 5 injected failure types &nbsp;·&nbsp; 3 repair cycles &nbsp;·&nbsp; Failure distribution from MAST (NeurIPS 2025)
</div>

*Article by John Tribbia*

<p class="ft-p">Modern cars log hundreds of fault codes. When a warning light trips, the code tells the mechanic which system threw the fault, not just that something failed. A shop that responded to every warning light by replacing the air filter would fix almost nothing, spend a lot of time doing it, and never understand why the same light came back. The warning light is not the diagnosis. It is the prompt to begin one.</p>

<p class="ft-p">The previous four posts built the instruments. <a href="../model-quality/">Model quality</a> drives retention, and category-level variation is what makes the causal identification work. The <a href="../arc/">trajectory of how a model arrives at its answer</a> carries signal the final score misses. That <a href="../arc-retention/">trajectory shape predicts whether users come back</a>. Users <a href="../wildchat-prompt-eras/">reveal quality gaps through their prompt behavior</a>, without ever filing a bug report.</p>

<p class="ft-p">All four tell you that something is failing. None of them tell you where. A retention dip is an outcome, not a cause.</p>

<hr class="ft-hr">

<h2 class="ft-h2">Failure Rates Are Not Edge Cases</h2>

<p class="ft-p">MAST (NeurIPS 2025, UC Berkeley) analyzed 1,642 multi-agent execution traces across seven state-of-the-art open-source frameworks. Failure rates ranged from 41% to 86.7%. These are not prototype systems. They are the frameworks being deployed in production today.</p>

<p class="ft-p">A separate study of real production agent failures found that parsing failures alone account for roughly 38% of all observed incidents: malformed JSON, missing schema fields, instruction noncompliance. Not 38% of some narrow subcategory. Thirty-eight percent of everything. That single failure type has a specific, tractable repair target: the output formatting instructions in the system prompt. You do not need a model retrain. You need a better instruction.</p>

<p class="ft-p">That is the structural case for a taxonomy. If 38% of your failures route to the same fix, and you are applying the same fix to 100% of your failures, you are burning resources on the 62% while under-investing in the 38% that would actually move the needle. The taxonomy is the routing layer between the signal and the repair.</p>

<hr class="ft-hr">

<h2 class="ft-h2">Mapping Failures to Layers</h2>

<p class="ft-p">A loss taxonomy maps observed failure signals to the system component most likely responsible — routes known failures to the correct repair layer, and surfaces failures that have no existing category. That second function is the one most systems skip.</p>

<p class="ft-p">Read it as a routing table, not a checklist.</p>

<p class="ft-table-caption">Failure Taxonomy · Observable Signals · Repair Routing</p>
<div class="ft-table-wrap">
  <table class="ft-table">
    <thead>
      <tr>
        <th>Failure Pattern</th>
        <th>Observable Signal</th>
        <th>Likely Locus</th>
        <th>Repair Target</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Correct intent, wrong format</td>
        <td>Retry with same content, reformatted</td>
        <td>System prompt</td>
        <td>Output format instructions</td>
      </tr>
      <tr>
        <td>Hallucinated facts, right structure</td>
        <td>User correction follow-up</td>
        <td>Base model knowledge</td>
        <td>RAG layer or targeted fine-tune</td>
      </tr>
      <tr>
        <td>Refused valid request</td>
        <td>Abrupt session end after refusal</td>
        <td>System prompt</td>
        <td>Instruction calibration</td>
      </tr>
      <tr>
        <td>Right answer, wrong step order</td>
        <td>Mid-task rephrase, step backtrack</td>
        <td>Reasoning scaffold</td>
        <td>Chain-of-thought structure</td>
      </tr>
      <tr>
        <td>Works in eval, breaks in production</td>
        <td>Eval-prod quality gap</td>
        <td>Eval distribution</td>
        <td>Eval set expansion</td>
      </tr>
      <tr>
        <td>Fails under long context</td>
        <td>Quality degrades mid-session</td>
        <td>Context management</td>
        <td>Chunking / summarization strategy</td>
      </tr>
      <tr>
        <td class="residual">Unclassified</td>
        <td class="residual">Does not match any row above</td>
        <td class="residual">Unknown</td>
        <td class="residual">Extend the taxonomy</td>
      </tr>
    </tbody>
  </table>
</div>

<p class="ft-p">The last row is the most important. When a failure pattern does not cross-reference cleanly, the temptation is to force it into the nearest existing category. That is the mistake. An unclassified failure is a signal that the taxonomy has a blind spot. Patching the symptom without extending the taxonomy guarantees the next variant of that failure also goes unclassified.</p>

<p class="ft-p">The residual is a metric. A growing residual means the taxonomy is lagging the system. A shrinking residual means the taxonomy is keeping pace. That number belongs on the same dashboard as your quality scores.</p>

<hr class="ft-hr">

<h2 class="ft-h2">Taxonomy-Routed vs. Naive Repair</h2>

<p class="ft-p">The synthetic experiment runs 1,000 simulated production interactions with five injected failure types, proportions drawn from MAST's published distribution: specification misalignment (~25%), reasoning failure (~20%), context management (~18%), output format error (~15%), retrieval and knowledge gap (~12%), and residual unclassified (~10%). Two repair strategies are applied over three cycles.</p>

<p class="ft-p"><strong>Strategy A (Naive)</strong> treats all failures as equivalent. Repair is applied uniformly: the same prompt adjustment across every failure type, regardless of which layer the fault originates from.</p>

<p class="ft-p"><strong>Strategy B (Taxonomy-Routed)</strong> cross-references each failure against the taxonomy before any repair decision is made. Repair is routed to the specific locus identified for that failure type.</p>

<p class="ft-p">Quality is scored per cycle using the weighted-category approach from the model quality post.</p>

<div class="ft-vis-card">
  <div class="ft-vis-label">Synthetic Experiment · N=1,000 · 3 Repair Cycles</div>
  <div class="ft-vis-title">Quality Recovery by Repair Strategy</div>
  <div class="ft-vis-sub">% of injected quality loss recovered across three repair cycles</div>
  <div class="ft-vis-legend">
    <span><i style="background:#7db800;"></i> Taxonomy-Routed</span>
    <span><i style="background:#a8c8d8;"></i> Naive (Uniform)</span>
    <span><i style="background:rgba(255,255,255,0.22); height:1px; border-radius:0;"></i> Full Recovery (100%)</span>
  </div>
  <div style="position: relative; width: 100%; height: 320px;">
    <canvas id="ftRepairChart"></canvas>
  </div>
  <p class="ft-vis-note">Failure type distribution from MAST (NeurIPS 2025). Quality scoring uses the weighted-category method with frozen usage weights from the model quality post. Taxonomy-matched repair recovers 80–90% of injected loss per cycle. Mismatched repair recovers 10–30%.</p>
</div>

<p class="ft-p">After cycle 1, both strategies improve. Naive repair picks up the easy wins first: format errors happen to respond to general prompt tightening, so the early numbers look encouraging regardless of which approach you take.</p>

<p class="ft-p">After cycle 2, the divergence starts. The taxonomy-routed strategy continues recovering. The naive strategy plateaus. The failures that did not respond to the uniform fix are still present, and some that initially appeared to improve have re-emerged in slightly different form because the root layer was never addressed.</p>

<p class="ft-p">After cycle 3, Strategy B has recovered 85% of injected quality loss. Strategy A has recovered 45% and is beginning to regress on failure types whose repair target conflicts with the uniform fix applied to other types.</p>

<div class="ft-callout red">
  <strong>Format instruction tightening</strong> that fixes output errors can over-constrain the system prompt and increase valid-request refusals. A repair that helps one failure type makes a different failure type worse. The taxonomy prevents this class of iatrogenic failure.
</div>

<p class="ft-p">The crossover is not a fluke of the specific numbers chosen. It is a structural property of the problem. When you apply a fix to the wrong layer, you do not merely fail to fix the failure. In some cases you create a new one. That effect is real in the synthetic data, and the mechanism is not synthetic at all.</p>

<hr class="ft-hr">

<h2 class="ft-h2">The Loop in Full</h2>

<p class="ft-p">The complete cycle runs seven steps. The first six appear in most implementations. The seventh is where most implementations stop short.</p>

<p class="ft-p"><strong>Step 1: Baseline.</strong> Establish quality from evals before any user traffic enters the system. The repair cycle measures against it.</p>

<p class="ft-p"><strong>Step 2: Collect.</strong> Aggregate loss patterns from users. Explicit ratings are only part of the signal. Retries, rephrases, session-ending refusals, and low copy rates all carry information about where the system is underperforming.</p>

<p class="ft-p"><strong>Step 3: Cross-reference.</strong> Run losses against the taxonomy to identify the repair locus. Everything downstream depends on getting this right.</p>

<p class="ft-p"><strong>Step 4: Prioritize.</strong> Rank by volume times severity times tractability. Fix the highest-leverage failure first, not the most recently visible one.</p>

<p class="ft-p"><strong>Step 5: Repair.</strong> Target the specific layer: system prompt, RAG configuration, fine-tune, eval set, or context strategy. Not all of these at once.</p>

<p class="ft-p"><strong>Step 6: Test.</strong> Measure quality improvement against baseline. Confirm the repair moved the right metric and did not degrade an adjacent one.</p>

<p class="ft-p"><strong>Step 7: Update the taxonomy.</strong> Classify any failures that did not fit existing categories. Add new rows. Shrink the residual. This is the step most implementations skip.</p>

<p class="ft-p">A system that closes the loop at step 6 improves its current known failures. It stays blind to the next generation because the taxonomy still does not know they exist. Skip Step 7 and the loop can only get better at what it already knows. Without it, the residual grows quietly while everything else looks fine.</p>

<hr class="ft-hr">

<h2 class="ft-h2">Back to the Shop</h2>

<p class="ft-p">A diagnostic shop fixes the right thing the first time, updates its fault code library when a new failure mode comes in, and gets faster over time. A shop without one replaces air filters. Both look like they are working. The difference shows up on the third visit.</p>

<p class="ft-p">The earlier posts built the instruments. The taxonomy connects them to a repair. Without that connection, you have signal and no routing. The monitoring loop becomes a thrash loop.</p>

<p class="ft-p">The question left open is what the residual looks like in real user data: how fast new failure modes accumulate, whether a taxonomy can be built to keep pace, and whether the unclassified share stabilizes or grows. The WildChat dataset has the behavioral traces to start answering that.</p>

<hr class="ft-hr">

<details open>
<summary style="font-family: var(--f-mono); font-size: 1.25rem; color: rgba(255,255,255,0.65); cursor: pointer; margin-bottom: 1rem; letter-spacing: 0.08em; text-transform: uppercase;">Methodological Note</summary>
<div style="padding-top: 1rem;">
<p class="ft-p">N=1,000 synthetic interactions. Five injected failure types with proportions drawn from MAST published percentages (NeurIPS 2025, UC Berkeley).</p>
<p class="ft-p">Quality scoring uses the weighted-category method developed in the model quality post. Weights are frozen at pre-period values. The same GAMM specification is used for scoring consistency across the series.</p>
<p class="ft-p">Repair effectiveness: taxonomy-matched repair recovers 80–90% of injected loss per cycle. Mismatched repair recovers 10–30%. When repair targets conflict across failure types (e.g., format tightening applied to a refusal-heavy distribution), net quality may decrease.</p>
<p class="ft-p">Three repair cycles simulated. No partial matching: a repair either routes to the correct locus or it does not. Code: <a href="#">GitHub repository</a> (link added at publication).</p>
</div>
</details>

<hr class="ft-hr">

<p class="ft-table-caption">This Series</p>
<div class="ft-table-wrap">
  <table class="ft-table">
    <thead>
      <tr>
        <th>Post</th>
        <th>Core Claim</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><a href="../model-quality/">Model Quality</a></td>
        <td>Quality drives retention; category-level variation enables causal identification</td>
      </tr>
      <tr>
        <td><a href="../arc/">ARC</a></td>
        <td>Trajectory shape carries signal the final score misses</td>
      </tr>
      <tr>
        <td><a href="../arc-retention/">ARC-Retention</a></td>
        <td>Trajectory shape predicts 7-day return</td>
      </tr>
      <tr>
        <td><a href="../wildchat-prompt-eras/">WildChat</a></td>
        <td>Users reveal quality gaps through prompt behavior</td>
      </tr>
      <tr>
        <td><strong>This post</strong></td>
        <td><strong>Taxonomy routes loss signals to the right repair layer</strong></td>
      </tr>
      <tr>
        <td><em>Next</em></td>
        <td><em>Emergent failures: measuring taxonomy lag in real user data</em></td>
      </tr>
    </tbody>
  </table>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

(function () {
  const ctx = document.getElementById('ftRepairChart').getContext('2d');
  new Chart(ctx, {
    type: 'line',
    data: {
      labels: ['Cycle 1', 'Cycle 2', 'Cycle 3'],
      datasets: [
        {
          label: 'Taxonomy-Routed',
          data: [62, 75, 85],
          borderColor: '#7db800',
          backgroundColor: 'rgba(125,184,0,0.08)',
          borderWidth: 2.5,
          pointRadius: 5,
          pointBackgroundColor: '#7db800',
          tension: 0.3,
          fill: false
        },
        {
          label: 'Naive (Uniform)',
          data: [55, 55, 45],
          borderColor: '#a8c8d8',
          backgroundColor: 'rgba(168,200,216,0.06)',
          borderWidth: 2.5,
          pointRadius: 5,
          pointBackgroundColor: '#a8c8d8',
          tension: 0.3,
          fill: false
        },
        {
          label: 'Full Recovery',
          data: [100, 100, 100],
          borderColor: 'rgba(255,255,255,0.18)',
          borderWidth: 1.5,
          borderDash: [6, 4],
          pointRadius: 0,
          fill: false
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: {
          grid: { color: 'rgba(255,255,255,0.04)' },
          ticks: {
            color: 'rgba(255,255,255,0.4)',
            font: { family: "'Space Mono', monospace", size: 12 }
          }
        },
        y: {
          min: 0,
          max: 110,
          grid: { color: 'rgba(255,255,255,0.04)' },
          ticks: {
            color: 'rgba(255,255,255,0.4)',
            font: { family: "'Space Mono', monospace", size: 12 },
            callback: function (v) { return v + '%'; }
          },
          title: {
            display: true,
            text: '% quality loss recovered',
            color: 'rgba(255,255,255,0.3)',
            font: { family: "'Space Mono', monospace", size: 11 }
          }
        }
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: function (ctx) { return ' ' + ctx.dataset.label + ': ' + ctx.parsed.y + '%'; }
          }
        }
      }
    }
  });
}());
</script>

<div class="ft-footnotes">
  <p><strong>Prior work.</strong> The within-version quality exposure framework, identification strategy, frozen-weights design, and GAMM specification are described in <a href="../model-quality/">Does Making AI Smarter Actually Make People Use It More?</a> The ARC trajectory evaluation framework is described in <a href="../arc/">The Shape of a Good Answer</a>. The ARC-retention extension is in <a href="../arc-retention/">The Shape Predicts the Return</a>. Behavioral inference from prompt topic shifts is in <a href="../wildchat-prompt-eras/">How Users Vote With Their Prompts</a>.</p>
  <p><strong>Data note.</strong> All data is synthetic. No real users, no proprietary models, no production systems. Failure type proportions are drawn from MAST (Guo et al., NeurIPS 2025). The repair effectiveness parameters (80–90% recovery for taxonomy-matched repair, 10–30% for mismatched repair) are specified in the data-generating process and are not estimated from the data.</p>
  <p><strong>Software.</strong> Python 3.11; numpy, pandas, matplotlib. Code available at the GitHub link above at publication.</p>
</div>
