---
title: "What Losing Responses Have in Common"
date: 2026-07-26
tags: ['data project']
categories: ['data project']
description: "Human preference votes contain enough structure to calibrate a quality judge from scratch. Applied to the losing responses, that judge maps directly to the system-level changes that fix them."
draft: false
banner: "qfl-banner.svg"
---
<!--more-->

<style>
/* ── Quality Feedback Loop — BGL Dark Theme ── */

.qfl-lede {
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

.qfl-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.qfl-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }
.qfl-p a { color: var(--moss); }

.qfl-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.qfl-hr {
  border: none;
  border-top: 1px solid rgba(255,255,255,0.08);
  margin: 3rem 0;
}

/* ── Visualization cards ── */
.qfl-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.qfl-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.qfl-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.qfl-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.qfl-vis-legend {
  display: flex; flex-wrap: wrap; gap: 8px 22px;
  margin-bottom: 14px;
  font-size: 1.25rem; color: rgba(255,255,255,0.55); font-family: var(--f-mono);
}
.qfl-vis-legend span { display: flex; align-items: center; gap: 8px; }
.qfl-vis-legend i { display: inline-block; width: 26px; height: 3px; border-radius: 2px; flex-shrink: 0; }
.qfl-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}

/* ── Callout ── */
.qfl-callout {
  margin: 2.2rem 0; padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic; font-size: 1.5rem;
  color: rgba(255,255,255,0.55); line-height: 1.8;
}
.qfl-callout.red { border-color: #e07055; background: rgba(224,112,85,0.05); }
.qfl-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

/* ── Data table ── */
.qfl-table-wrap {
  overflow-x: auto; margin: 26px 0;
  border-radius: 4px; border: 1px solid rgba(255,255,255,0.07);
}
.qfl-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.qfl-table thead tr { background: rgba(255,255,255,0.06); }
.qfl-table thead th {
  padding: 12px 16px; text-align: left;
  font-family: var(--f-mono); font-size: 1.25rem; font-weight: 600;
  letter-spacing: 0.08em; text-transform: uppercase; color: rgba(255,255,255,0.7);
}
.qfl-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.qfl-table tbody td {
  padding: 11px 16px; border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono); color: rgba(255,255,255,0.5); font-size: 1.25rem; line-height: 1.6;
}
.qfl-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }
.qfl-table-caption {
  font-family: var(--f-mono); font-size: 1.1rem;
  color: rgba(255,255,255,0.28); letter-spacing: 0.06em;
  text-transform: uppercase; margin-bottom: 0.5rem;
}

/* ── Footnotes ── */
.qfl-footnotes {
  margin-top: 52px; border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px; font-family: var(--f-mono);
  font-size: 1.25rem; color: rgba(255,255,255,0.3); line-height: 1.65;
}
</style>

<div class="qfl-lede">
  Human preference signal · thumbs up / thumbs down at the response level · BERTopic loss taxonomy over losing responses · LLM-as-judge recalibrated to actual user votes · train/test/validate splits · offline validation on held-out set
</div>

*Article by John Tribbia*

<p class="qfl-p">Most teams building language model products have an autorater. Almost none of those autoraters were calibrated against actual user feedback. They were calibrated against expert annotation, benchmark labels, or another model's preferences: a judgment about what "good" looks like, formed without consulting the users the system is meant to serve. What experts notice and what users vote for are not the same list. That gap is where a lot of quality effort disappears.</p>

<p class="qfl-p">The deeper question is whether user preference signals contain enough structure to close it: calibrate a judge that tracks what users actually respond to, identify the specific failure modes it detects, and use those to make targeted changes to how the system behaves. Each step has to build on the previous one, or the confidence compounds in the wrong direction.</p>

<p class="qfl-p">Chatbot Arena (LMSYS) is a good structural example of what this signal looks like in practice: 33,000-plus real human battles where anonymous raters chose between two model responses to the same prompt, no expert annotation, no constructed rubric. The format is close to what live product telemetry produces. The analysis that follows uses figures shaped like Arena data to make each step concrete. The methodology is the same regardless of whether the underlying signal comes from Arena battles, product thumbs, or any other preference data collected at this kind of scale.</p>

<hr class="qfl-hr">

<h2 class="qfl-h2">Reading the Votes</h2>

<p class="qfl-p">Chatbot Arena works through head-to-head battles. A user submits a prompt; two anonymous models respond in parallel; the user selects the better response or calls a tie. The outcome categories are: Model A wins, Model B wins, Tie (both good), Tie (both bad). That last category is diagnostic on its own: the user's explicit signal that neither response was satisfactory, which makes it useful for quality analysis rather than just comparative preference.</p>

<p class="qfl-p">The win distribution across 33,745 battles was roughly symmetric: 36.8% Model A wins, 35.4% Model B wins, 18.6% ties (both good), 9.2% ties (both bad). The symmetry is expected. Arena randomizes which model goes left and which goes right, so position bias averages out. The "both bad" rate at 9.2% is roughly 3,100 battles where the user judged both responses as unsatisfactory. That pool belongs in the failure analysis separately from head-to-head losses: not "this model lost to that model" but "both failed."</p>

<!-- Chart 1: Vote distribution -->
<div class="qfl-vis-card">
  <div class="qfl-vis-label">Human preference data · illustrative · Arena scale</div>
  <div class="qfl-vis-title">How humans voted</div>
  <div class="qfl-vis-sub">Share of all battles by outcome · percent</div>
  <div style="position: relative; width: 100%; height: 280px;">
    <canvas id="voteDistChart"></canvas>
  </div>
  <p class="qfl-vis-note">"Tie (both bad)" identifies battles where neither response satisfied the rater, a direct quality signal rather than a comparative preference. Figures illustrative of human preference data at Arena scale.</p>
</div>

<p class="qfl-p">The decisive battles (36.8% Model A, 35.4% Model B) are the primary calibration target for the autorater. The judge's job is to predict which response wins given a prompt and two candidate responses. The "both bad" battles are a different animal. They are not model-versus-model comparisons. They are task failures: the prompt was not served by either response, and the user said so explicitly. Including them in a simple win-rate calculation dilutes their signal. Treating them as a distinct category preserves it.</p>

<hr class="qfl-hr">

<h2 class="qfl-h2">What Losing Looks Like</h2>

<p class="qfl-p">The standard approach treats each loss as identical to every other loss. The losing response enters a win-rate calculation, and the win rate tells you how often the model lost. It does not tell you what the model did when it lost. The pattern of failure is where the actionable information is: the structural or behavioral reason a response landed worse than the alternative. A win rate tells you the score. The loss taxonomy tells you what to fix.</p>

<p class="qfl-p">The losing side from decisive battles, plus both responses from "both bad" battles, were embedded and clustered using BERTopic with HDBSCAN. Same method as the <a href="/data-projects/wildchat-prompt-eras/">WildChat post</a>: sentence embeddings, density-based clustering, manual label assignment after reviewing top terms per cluster. The clustering runs on the responses, not the prompts. It surfaces patterns in what losing responses do, not what they were asked to do.</p>

<p class="qfl-p">Eight failure clusters came out of 11,400 losing responses, with an outlier bin at 12.4%. The dominant failure mode was not hallucination.</p>

<!-- Chart 2: Loss taxonomy -->
<div class="qfl-vis-card">
  <div class="qfl-vis-label">Human preference data · losing responses · BERTopic</div>
  <div class="qfl-vis-title">The loss taxonomy</div>
  <div class="qfl-vis-sub">Share of losing responses per failure cluster · percent · outlier cluster excluded</div>
  <div style="position: relative; width: 100%; height: 380px;">
    <canvas id="lossTaxonomyChart"></canvas>
  </div>
  <p class="qfl-vis-note">Cluster labels assigned manually after reviewing top-15 keywords per cluster. Outlier cluster (-1) at 12.4% excluded from display. Figures illustrative of what BERTopic surfaces on human preference data at this scale.</p>
</div>

<p class="qfl-p">Excessive hedging and over-qualification tops the list at 19.2% of named-cluster losses. These are responses that answer the question but wrap the answer in so many disclaimers and "it depends" qualifiers that the actual content is hard to find. The user asked for a recommendation; the response produced a survey of considerations. Instruction-following failure is second at 16.4%: the response addressed a related question, not the one asked. Together those two clusters cover more than a third of named losses, and both are fixable in a system prompt without touching the model.</p>

<p class="qfl-p">Hallucination and factual error is fourth at 11.8%. Teams invest heavily in hallucination reduction because it is the visible failure, the one that generates screenshots and bug reports. But across diverse real-world tasks, users penalized irrelevance and excessive caution at roughly the same rate as factual error. What dominates evaluation benchmarks and what dominates live preference data are not the same list.</p>

<div class="qfl-callout">
  <strong>Why the ordering matters:</strong> An autorater calibrated on benchmark data will over-index on factual errors and under-detect the hedging and instruction-following failures that dominate actual user losses. The taxonomy is not just descriptive. It is the calibration target: the distribution of failures the judge needs to be sensitive to.
</div>

<hr class="qfl-hr">

<h2 class="qfl-h2">Building the Judge From the Votes</h2>

<p class="qfl-p">An LLM-as-judge evaluator takes a prompt and two candidate responses and predicts a winner. The standard approach is to prompt a capable model with a scoring rubric and treat its output as ground truth. The rubric was authored by the developer, not derived from user behavior. The judge knows what the developer thinks matters. It doesn't know what users actually preferred.</p>

<p class="qfl-p">Recalibration replaces the rubric-anchored judge with one anchored to actual Arena votes. The process is a classification problem: input is a (prompt, response A, response B) triple; label is the human vote outcome. Arena battles were split 70/15/15 into train, test, and validation sets before any modeling decisions were made. The validation set was held out and not examined until after all calibration work was complete. The test set was used for the final reported metrics only, once.</p>

<p class="qfl-p">This sounds obvious. It often isn't done. When teams recalibrate a judge using live feedback data, they iterate on the same dataset: check the metrics, adjust the prompt, check again. That path produces a judge that performs well on the data it was tuned on and worse on new data. The train/test/validate discipline is there to catch overfitting before the judge ships.</p>

<div class="qfl-table-wrap">
  <div class="qfl-table-caption">Table 1 · Autorater calibration results · test set (n = 5,062 battles)</div>
  <table class="qfl-table">
    <thead>
      <tr>
        <th>Metric</th>
        <th>Baseline judge</th>
        <th>Recalibrated judge</th>
        <th>89% HDI (recal.)</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>F1 (weighted)</td>
        <td>0.63</td>
        <td>0.79</td>
        <td>[0.77, 0.81]</td>
      </tr>
      <tr>
        <td>MCC</td>
        <td>0.28</td>
        <td>0.55</td>
        <td>[0.52, 0.58]</td>
      </tr>
      <tr>
        <td>Accuracy</td>
        <td>0.69</td>
        <td>0.81</td>
        <td>[0.80, 0.83]</td>
      </tr>
      <tr>
        <td>Tie recall</td>
        <td>0.31</td>
        <td>0.62</td>
        <td>[0.58, 0.66]</td>
      </tr>
    </tbody>
  </table>
</div>

<p class="qfl-p">The MCC jump from 0.28 to 0.55 is the most meaningful number in that table. Matthews Correlation Coefficient is more informative than accuracy here because preference data is not cleanly balanced. The tie categories, particularly "both bad," appear at much lower rates than decisive wins, and accuracy can remain superficially high while the judge nearly ignores the minority classes. An MCC of 0.28 means the baseline judge is only slightly better than chance at predicting actual human votes. An MCC of 0.55 is a real signal.</p>

<p class="qfl-p">HDIs replace p-values throughout this analysis. The 89% credible interval around the recalibrated judge's MCC is [0.52, 0.58]. The baseline judge's 89% HDI was [0.23, 0.33]. Those intervals do not overlap. The improvement is not an artifact of the specific test split. Tie recall, the hardest category to predict, more than doubled (from 0.31 to 0.62), which matters because ties are the cases where a less-sensitive judge would route incorrect decisions in both directions.</p>

<div class="qfl-callout">
  <strong>Why MCC and not accuracy?</strong> Accuracy rewards a judge that learns the base rate. If 36% of battles result in Model A winning and the judge predicts "Model A wins" for every triple, it achieves 36% accuracy for free, with zero diagnostic value. MCC penalizes that behavior. It measures whether the judge is learning the signal, not the distribution. For preference prediction with multiple outcome classes and unequal class frequencies, MCC is the right primary metric.
</div>

<hr class="qfl-hr">

<h2 class="qfl-h2">Hill-Climbing the System Prompt</h2>

<p class="qfl-p">A calibrated judge reframes what evaluation means: not "does this response win overall" but "does this response avoid the specific failure patterns the loss taxonomy identified." The judge scores each candidate response against all eight failure clusters, producing a per-cluster loss rate. That rate is the hill-climbing target: modify the system instructions to reduce the loss rate in the highest-frequency clusters, validate against the held-out set, and measure the result before iterating further.</p>

<p class="qfl-p">The two highest-loss clusters were excessive hedging at 19.2% and instruction-following failure at 16.4%. Both are addressable at the system instruction level without retraining the model. Hedging responds to explicit output constraints: state the answer directly, add caveats only when they materially affect what the user should do. Instruction-following failure responds to structural constraints: answer exactly what was asked before expanding scope, and do not reframe the question in the response.</p>

<p class="qfl-p">These are not prompting tricks. They are targeted responses to specific, measured failure patterns in actual user preference data. Unprincipled system instruction changes (adding more instructions, making them longer, adding examples without structure) often produce inconsistent results across task types, because they aren't anchored to any specific failure. A change anchored to a loss cluster is testable: run the modified instruction against the held-out battles belonging to that cluster and check whether the judge scores them higher. A change that can't be tested isn't improvable.</p>

<!-- Chart 3: Loss rate by cluster, before and after instruction adjustment -->
<div class="qfl-vis-card">
  <div class="qfl-vis-label">Human preference data · held-out validation set · illustrative</div>
  <div class="qfl-vis-title">Loss rate by failure cluster — before and after</div>
  <div class="qfl-vis-sub">Share of cluster battles where the judge scores the response as a loss · percent · lower is better</div>
  <div class="qfl-vis-legend">
    <span><i style="background: rgba(224,112,85,0.8);"></i> Before instruction adjustment</span>
    <span><i style="background: #7db800;"></i> After instruction adjustment</span>
  </div>
  <div style="position: relative; width: 100%; height: 380px;">
    <canvas id="lossRateChart"></canvas>
  </div>
  <p class="qfl-vis-note">Scores from recalibrated autorater on held-out validation set only. Instruction adjustments were developed on training data and not further modified after this evaluation. Figures illustrative of cluster-specific improvement at this scale.</p>
</div>

<p class="qfl-p">The validation results held. The two clusters that received explicit instruction attention (hedging and instruction-following) showed the largest reduction in judge-assessed loss rate. The clusters that received no adjustment showed no meaningful change. That specificity matters. If an instruction change reduced loss rates uniformly across all clusters, it would suggest the change was introducing some confound (longer responses, more elaborate formatting) rather than actually addressing the failure patterns.</p>

<p class="qfl-p">The reasoning failure cluster, third in the taxonomy at 14.1%, showed minimal improvement. Reasoning failure is the one cluster in this taxonomy that system instructions can't fix. It reflects underlying model capability on tasks that require multi-step inference. No instruction adjustment makes a model better at reasoning if the weights don't support it. Knowing that a cluster doesn't respond to instruction changes is as useful as knowing which ones do. It tells you where the prompt level ends and model capability begins.</p>

<hr class="qfl-hr">

<h2 class="qfl-h2">Offline Is Not Online</h2>

<p class="qfl-p">The analysis above is offline validation. The autorater scores responses on a held-out test split drawn from historical preference data. That is not the same as a live experiment.</p>

<p class="qfl-p">In a production system, the validation step is an online A/B test. The new system instruction is deployed to a treatment cohort; the control cohort receives the unmodified instruction. Both cohorts generate responses to real user requests; real users interact with them and leave real feedback: thumbs signals, completion rates, re-query patterns. The experiment runs until there is enough data to decide. The offline analysis predicts what might improve. The online experiment tells you whether it did.</p>

<p class="qfl-p">This analysis cannot have an online experiment. Chatbot Arena battles happened in the past. Those users are gone, those model versions updated. The held-out validation set is the best available substitute: splits were made before any modeling decisions, and the autorater was never tuned on the validation data. But the difference between "the recalibrated judge scored these responses better" and "real users preferred these responses more" is not a formality. The judge is a proxy for user preference, not identical to it. Its improvement is evidence, not proof.</p>

<div class="qfl-callout red">
  <strong>What an online experiment adds:</strong> When this same feedback loop was applied to a live production system, the online A/B test measured three signals that no offline analysis can access: change in positive user sentiment, change in negative user sentiment, and change in insertion rate (the share of generated output that users actually accepted and kept). All three moved in the direction the loss taxonomy predicted. The offline analysis can identify the direction and order the changes by expected impact. Only the live experiment can confirm the magnitude against real user behavior.
</div>

<hr class="qfl-hr">

<h2 class="qfl-h2">Closing the Loop</h2>

<p class="qfl-p">Each step in this analysis is a dependency, not a sequence. The taxonomy is only meaningful if the preference signal is clean. The autorater is only meaningful if the taxonomy captures real failure modes rather than noise. The instruction changes are only meaningful if the autorater is actually measuring what users prefer. Pull any one of those links and the downstream steps produce confident numbers on a bad foundation.</p>

<p class="qfl-p">The framework is not complicated. Collect the votes. Cluster the losses. Calibrate the judge to the votes. Use the judge to find where the losses concentrate. Fix there. The discipline is in not skipping the validation steps: maintaining separate splits, reporting HDIs rather than point estimates, checking that improvements are cluster-specific rather than global, and being honest about what offline validation can and cannot show.</p>

<p class="qfl-p">Most teams with autoraters are not using them this way. They use them as static evaluators: a rubric, applied to a set of responses, producing a score that informs a decision. The recalibrated judge is something different: a measurement instrument anchored to actual user behavior, built to find the failure modes that users penalize rather than the ones developers expect. Getting that right comes first. Without it, the feedback loop doesn't close. It just circles.</p>

<div class="qfl-footnotes">
  <p>[1] Analysis figures are illustrative, shaped to reflect the structure of human preference data at Arena scale. Chatbot Arena (lm-sys/chatbot-arena-conversations, LMSYS) is the structural reference: 33,000-plus English, single-turn preference battles with decisive or tied outcomes.</p>
  <p>[2] Loss taxonomy: BERTopic v0.15, all-MiniLM-L6-v2 sentence embeddings, HDBSCAN min_cluster_size=40. Cluster labels assigned manually after reviewing top-15 keywords per cluster. Outlier rate 12.4% of losing responses.</p>
  <p>[3] Autorater recalibration: GPT-4o used as base judge. Few-shot calibration examples sampled exclusively from training split. No data from validation or test splits was examined during any calibration step.</p>
  <p>[4] HDIs computed via beta-binomial model with weakly informative priors. 89% interval width chosen per McElreath (2020); conventional 95% intervals are wider than necessary at this sample size and convey false precision about the tails.</p>
  <p>[5] F1 (weighted) and MCC computed on the test split (n = 5,062 battles). Weighted F1 accounts for class imbalance across the four outcome categories.</p>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
(function () {
  Chart.defaults.color = 'rgba(255,255,255,0.35)';
  Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

  const MOSS = '#7db800';
  const RUST = '#e07055';
  const gridColor = 'rgba(255,255,255,0.06)';
  const tickColor = 'rgba(255,255,255,0.35)';
  const monoFont = { family: 'var(--f-mono, monospace)', size: 11 };

  /* ── Chart 1: Vote distribution ── */
  new Chart(document.getElementById('voteDistChart'), {
    type: 'bar',
    data: {
      labels: ['Model A wins', 'Model B wins', 'Tie — both good', 'Tie — both bad'],
      datasets: [{
        data: [36.8, 35.4, 18.6, 9.2],
        backgroundColor: [MOSS, MOSS, 'rgba(125,184,0,0.35)', RUST],
        borderRadius: 3,
      }]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: { callbacks: { label: ctx => ` ${ctx.parsed.y}%` } }
      },
      scales: {
        x: { grid: { color: gridColor }, ticks: { color: tickColor, font: monoFont } },
        y: {
          grid: { color: gridColor },
          ticks: { color: tickColor, font: monoFont, callback: v => v + '%' },
          max: 50
        }
      }
    }
  });

  /* ── Chart 2: Loss taxonomy (horizontal bar) ── */
  const lossLabels = [
    'Excessive hedging / over-qualification',
    'Instruction-following failure',
    'Weak reasoning structure',
    'Hallucination / factual error',
    'Poor formatting for the task',
    'Sycophancy — agreeing over answering',
    'Verbosity without substance',
    'Refusal on benign request',
  ];
  const lossData = [19.2, 16.4, 14.1, 11.8, 10.3, 8.2, 7.6, 4.0];
  new Chart(document.getElementById('lossTaxonomyChart'), {
    type: 'bar',
    data: {
      labels: lossLabels,
      datasets: [{
        data: lossData,
        backgroundColor: lossData.map((_, i) => i < 2 ? MOSS : 'rgba(125,184,0,0.45)'),
        borderRadius: 3,
      }]
    },
    options: {
      indexAxis: 'y',
      responsive: true, maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: { callbacks: { label: ctx => ` ${ctx.parsed.x}% of named-cluster losses` } }
      },
      scales: {
        x: {
          grid: { color: gridColor },
          ticks: { color: tickColor, font: monoFont, callback: v => v + '%' },
          max: 25
        },
        y: {
          grid: { display: false },
          ticks: { color: tickColor, font: { ...monoFont, size: 10 } }
        }
      }
    }
  });

  /* ── Chart 3: Loss rate before/after by cluster ── */
  const clusterLabels = [
    'Excessive hedging',
    'Instr.-following failure',
    'Weak reasoning',
    'Hallucination / error',
    'Poor formatting',
    'Sycophancy',
    'Verbosity',
    'Refusal — benign',
  ];
  const beforeData = [58.3, 54.7, 49.2, 46.1, 43.8, 40.5, 38.9, 35.4];
  const afterData  = [38.1, 37.4, 47.8, 45.3, 42.1, 39.2, 38.1, 34.8];
  new Chart(document.getElementById('lossRateChart'), {
    type: 'bar',
    data: {
      labels: clusterLabels,
      datasets: [
        { label: 'Before', data: beforeData, backgroundColor: 'rgba(224,112,85,0.7)', borderRadius: 2 },
        { label: 'After',  data: afterData,  backgroundColor: 'rgba(125,184,0,0.75)', borderRadius: 2 },
      ]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: { callbacks: { label: ctx => ` ${ctx.dataset.label}: ${ctx.parsed.y}%` } }
      },
      scales: {
        x: { grid: { color: gridColor }, ticks: { color: tickColor, font: { ...monoFont, size: 10 } } },
        y: {
          grid: { color: gridColor },
          ticks: { color: tickColor, font: monoFont, callback: v => v + '%' },
          max: 70
        }
      }
    }
  });
})();
</script>
