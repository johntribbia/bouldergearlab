---
title: "Retention Can't Tell You Whether a Kid Is Learning"
date: 2026-10-22
tags: ['data project']
categories: ['data project']
description: "In a synthetic staggered rollout of two learner features, a daily-streak feature wins on retention by a wide margin while a guided-tutoring mode wins on task success and learning, so retention alone would pick the wrong feature for teenagers."
banner: "lv-banner.svg"
draft: false
---
<!--more-->

<style>
/* ── Retention Can't Tell You Whether a Kid Is Learning — BGL Dark Theme ── */

.lv-lede {
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

.lv-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.lv-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }

.lv-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.lv-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.lv-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.lv-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.lv-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.lv-vis-legend {
  display: flex; flex-wrap: wrap; gap: 8px 22px;
  margin-bottom: 14px;
  font-size: 1.25rem; color: rgba(255,255,255,0.55); font-family: var(--f-mono);
}
.lv-vis-legend span { display: flex; align-items: center; gap: 8px; }
.lv-vis-legend i { display: inline-block; width: 26px; height: 3px; border-radius: 2px; flex-shrink: 0; }
.lv-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}
.lv-vis-panel-label {
  font-family: var(--f-mono);
  font-size: 1.15rem;
  color: rgba(255,255,255,0.45);
  margin: 18px 0 6px;
}

.lv-callout {
  margin: 2.2rem 0; padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic; font-size: 1.5rem;
  color: rgba(255,255,255,0.55); line-height: 1.8;
}
.lv-callout.red { border-color: #e07055; background: rgba(224,112,85,0.05); }
.lv-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

.lv-table-wrap {
  overflow-x: auto; margin: 26px 0;
  border-radius: 4px; border: 1px solid rgba(255,255,255,0.07);
}
.lv-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.lv-table thead tr { background: rgba(255,255,255,0.06); }
.lv-table thead th {
  padding: 12px 16px; text-align: left;
  font-family: var(--f-mono); font-size: 1.25rem; font-weight: 600;
  letter-spacing: 0.08em; text-transform: uppercase; color: rgba(255,255,255,0.7);
}
.lv-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.lv-table tbody td {
  padding: 11px 16px; border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono); color: rgba(255,255,255,0.5); font-size: 1.25rem; line-height: 1.6;
}
.lv-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }
.lv-table-caption {
  font-family: var(--f-mono); font-size: 1.1rem;
  color: rgba(255,255,255,0.28); letter-spacing: 0.06em;
  text-transform: uppercase; margin-bottom: 0.5rem;
}

.lv-footnotes {
  margin-top: 52px; border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px; font-family: var(--f-mono);
  font-size: 1.25rem; color: rgba(255,255,255,0.3); line-height: 1.65;
}
</style>

<div class="lv-lede">
  Synthetic data: 40,000 learners aged 13 and up in 200 school and community clusters, 20 weeks, two features rolled out in waves with no randomization. The true effects are known because I wrote them.
</div>

*Article by John Tribbia*

Picture a 14-year-old who opens a learning app every day for two months. On a retention chart she looks like a success. She might be working through problems each night. She might also be tapping in for a minute before bed to keep a streak going. Both show up in the logs as a returning user.

Most teams reach for retention first because it's easy to compute. My view is that for young learners it can't settle the question by itself, since a kid who keeps coming back may be learning or may just have a habit, and the retention number is the same either way.

To test that, I built a fake product with two features and a known answer. One is a daily streak with reminders. The other is a guided mode where the assistant asks scaffolding questions instead of handing over answers. I rolled them out in waves, the way real products usually ship, and tried to recover what each one did using a four-layer scorecard instead of retention alone.

> **What this is.** None of this is real user data. I generated it from a mechanism I defined, so I can check every estimate against the truth, and the effect sizes are made up and shouldn't be quoted. What carries over to real products is the measurement problem: nobody flipped a coin, the calendar is the school year, and the outcome you care about isn't the one the logs record. I left out under-13 users on purpose and I'm not touching policy or safety questions, since this is a value and growth analysis.

---

<h2 class="lv-h2">The setup</h2>

<p class="lv-p">The simulation has 200 clusters of 200 learners each, which you can think of as schools or after-school programs. Half the clusters get the streak feature and half get guided mode. Within each half, 25 clusters go live in week 5, 25 in week 9 and 25 in week 13, and the last 25 haven't been reached by week 20. Learners fall into three age bands: 13–15 (30%), 16–17 (30%) and 18+ (40%). The two younger bands follow the school calendar closely, with an exam bump in weeks 9–10, a winter-break dip in weeks 15–16 and another exam bump near the end, while adults barely move with it.</p>

<p class="lv-p">The waves aren't random. Clusters with higher baseline engagement go first, as they would in a real rollout that starts with the schools whose teachers asked for it. Early-wave clusters sit about 0.29 logit points above average on baseline engagement and the last group sits 0.33 below, which is the kind of gap a randomized holdout would have removed and this design has to handle some other way.</p>

<p class="lv-p">Not everyone who is exposed uses the feature. About 70% of 13–15 learners adopt streaks against 30% of adults, and about 44% of 13–15 learners adopt guided mode against 59% of adults. Effects apply only to adopters, so adoption shapes every result below.</p>

<p class="lv-p">To keep learning separate from visits, each learner has a hidden skill level that grows with practice, and a normal active day adds a fixed amount. The streak feature adds extra active days, but I made those days worth a quarter as much and only a fifth of them end with a completed task. Guided mode barely changes how often people show up. It raises what an active day is worth by 70 to 110 percent for adopters, depending on age, and it raises the share of days that finish a task.</p>

---

<h2 class="lv-h2">A scorecard with four layers</h2>

<p class="lv-p">I measure each feature at four layers and read them separately for each age band, since the same number can mean different things at 14 and at 24.</p>

<div class="lv-table-wrap">
  <div class="lv-table-caption">The four layers and how each is measured here</div>
  <table class="lv-table">
    <thead><tr><th>Layer</th><th>Question</th><th>Measure</th><th>What changes by age</th></tr></thead>
    <tbody>
      <tr><td>Activation</td><td>Did exposed learners actually start using it?</td><td>Share of exposed learners who adopt</td><td>Teens take up streaks readily, adults mostly ignore them</td></tr>
      <tr><td>Task success</td><td>Do sessions end with something finished?</td><td>Completed tasks per active day</td><td>Same definition, but a 13-year-old's task is shorter than an adult's</td></tr>
      <tr><td>Learning progress</td><td>Is the learner getting better at the thing?</td><td>Score on a short checkpoint, in SD units</td><td>Needs an age-appropriate assessment, and a single quiz won't do</td></tr>
      <tr><td>Durable retention</td><td>Are they still coming back, weeks later?</td><td>Weekly active rate and active days per week, 6–8 weeks after launch</td><td>Daily use is a habit signal for teens and a heavy-use signal for adults</td></tr>
    </tbody>
  </table>
</div>

<p class="lv-p">The learning checkpoint is shown to a random half of learners each week, whether or not they were active. If it were an opt-in quiz, engaged people would take it, and a feature that changes who is engaged would change who takes the quiz as well. Randomizing who sees it costs some precision and avoids that.</p>

---

<h2 class="lv-h2">Why the obvious comparisons fail</h2>

<p class="lv-p">Without a holdout, two comparisons come to mind first. You can compare a cluster to its own past, or you can compare clusters that have the feature to clusters that don't. Here they fail in opposite directions.</p>

<div class="lv-vis-card">
  <div class="lv-vis-label">Fig 1 / Selection</div>
  <div class="lv-vis-title">Weekly Active Rate, Streak Clusters</div>
  <div class="lv-vis-sub">Week-5 wave vs. clusters not yet reached · all ages</div>
  <div class="lv-vis-legend">
    <span><i style="background:#7db800"></i>Launched in week 5</span>
    <span><i style="background:#a8c8d8"></i>Not yet reached</span>
  </div>
  <div style="position: relative; width: 100%; height: 300px;">
    <canvas id="lvChartRaw"></canvas>
  </div>
  <div class="lv-vis-note">Before anything ships, the early clusters are about 11 points more active. Both groups dip at the winter break and rise around exams.</div>
</div>

<p class="lv-p">Comparing treated clusters to untreated ones mixes the feature with the fact that the early clusters were already more engaged. For streaks among 13–15 learners that comparison says the feature added 17.5 points of weekly activity. Comparing a cluster to its own past mixes the feature with the calendar and with background drift in engagement, and it says streaks added 2.2 points. Because I wrote the simulation, I can compute the true effect, and it is about 9 points.</p>

---

<h2 class="lv-h2">What I used instead</h2>

<p class="lv-p">The fix is difference-in-differences with a not-yet-treated comparison group. For each launch wave, I take the change in a cluster's outcome from the week before launch to a later week and subtract the same change for clusters that hadn't launched by that later week. The calendar hits both groups the same way and the level gap between them cancels, which leaves the feature. I average across waves and resample whole clusters 200 times for the intervals.</p>

<p class="lv-p">The assumption doing the work is parallel trends, meaning that without the feature the early clusters would have moved the way the later ones did. I can't prove that, but the weeks before launch give some evidence, since the estimated effect there should be zero and it is.</p>

<div class="lv-vis-card">
  <div class="lv-vis-label">Fig 2 / Streaks vs. guided, ages 13–15</div>
  <div class="lv-vis-title">Retention and Learning, Week by Week After Launch</div>
  <div class="lv-vis-sub">Difference-in-differences estimates with 95% bands · week 0 is launch</div>

  <div class="lv-vis-panel-label">Streaks · change in weekly active rate (pp)</div>
  <div style="position: relative; width: 100%; height: 200px;"><canvas id="lvStreakActive"></canvas></div>
  <div class="lv-vis-panel-label">Streaks · change in checkpoint score (SD)</div>
  <div style="position: relative; width: 100%; height: 200px;"><canvas id="lvStreakLearn"></canvas></div>
  <div class="lv-vis-panel-label">Guided mode · change in weekly active rate (pp)</div>
  <div style="position: relative; width: 100%; height: 200px;"><canvas id="lvGuidedActive"></canvas></div>
  <div class="lv-vis-panel-label">Guided mode · change in checkpoint score (SD)</div>
  <div style="position: relative; width: 100%; height: 200px;"><canvas id="lvGuidedLearn"></canvas></div>

  <div class="lv-vis-note">Streaks lift activity within two weeks and keep it up, while their learning line stays near zero. Guided mode barely moves activity and its learning line keeps climbing.</div>
</div>

<p class="lv-p">The streak panels are the ones I'd show a skeptical product manager. Weekly activity rises about 10 points and stays up through the ten weeks I can observe, which is the shape most launch reviews hope for, and learning measured the same way doesn't follow it.</p>

---

<h2 class="lv-h2">The scorecard</h2>

<p class="lv-p">Here is every feature and age band across the four layers, measured 6 to 8 weeks after exposure. Activation is the adoption rate among exposed learners and the other columns are estimated effects with 95% intervals.</p>

<div class="lv-table-wrap">
  <div class="lv-table-caption">Effects 6–8 weeks after launch, difference-in-differences</div>
  <table class="lv-table">
    <thead><tr><th>Feature · age</th><th>Activation</th><th>Task success (pp)</th><th>Learning (SD)</th><th>Active rate (pp)</th><th>Active days / wk</th></tr></thead>
    <tbody>
      <tr><td>Streaks · 13–15</td><td>70%</td><td>−9.5 ± 2.0</td><td>+0.05 ± 0.06</td><td>+10.2 ± 1.8</td><td>+0.83 ± 0.07</td></tr>
      <tr><td>Streaks · 16–17</td><td>65%</td><td>−7.4 ± 1.6</td><td>+0.04 ± 0.05</td><td>+8.9 ± 1.6</td><td>+0.67 ± 0.06</td></tr>
      <tr><td>Streaks · 18+</td><td>30%</td><td>−0.1 ± 1.6</td><td>+0.07 ± 0.05</td><td>+1.8 ± 1.3</td><td>+0.04 ± 0.05</td></tr>
      <tr><td>Guided · 13–15</td><td>44%</td><td>+7.3 ± 2.0</td><td>+0.14 ± 0.06</td><td>+2.6 ± 1.8</td><td>+0.07 ± 0.06</td></tr>
      <tr><td>Guided · 16–17</td><td>44%</td><td>+4.8 ± 2.1</td><td>+0.07 ± 0.05</td><td>+4.0 ± 1.8</td><td>+0.02 ± 0.06</td></tr>
      <tr><td>Guided · 18+</td><td>59%</td><td>+9.1 ± 1.4</td><td>+0.24 ± 0.05</td><td>+5.4 ± 1.7</td><td>+0.30 ± 0.05</td></tr>
    </tbody>
  </table>
</div>

<p class="lv-p">Ranked by active rate, streaks beat guided mode by about four to one among 13–15 learners. Ranked by task success the order flips. Streaks lower the share of active days that finish a task by almost 10 points, because the extra days are short check-ins, while guided mode raises it by 7. Learning points the same way as task success, although for 13–15 the gap between the two features (0.05 versus 0.14 SD) is within the noise. I wouldn't decide on learning alone for that age band, but task success and learning together agree, which is why I want more than one layer.</p>

<div class="lv-callout red">
  <strong>Streaks did build a habit</strong>, and that may be worth having. The habit didn't bring learning with it, though, and a retention-only dashboard would have called streaks the winner.
</div>

<p class="lv-p">The age split matters as well. Most adults don't adopt streaks, so streaks do little for them, and guided mode is the stronger feature for adults on every layer. The tradeoff shows up in the two younger bands, and a single blended number would bury it.</p>

---

<h2 class="lv-h2">How much the naive read gets wrong on learning</h2>

<p class="lv-p">Learning is where the naive comparisons do the most damage. Everyone in the simulation improves over time, so a before-and-after comparison credits the feature with ordinary growth.</p>

<div class="lv-vis-card">
  <div class="lv-vis-label">Fig 3 / Estimates</div>
  <div class="lv-vis-title">Streaks, Ages 13–15: Four Reads on Learning</div>
  <div class="lv-vis-sub">Change in checkpoint score, SD units</div>
  <div style="position: relative; width: 100%; height: 280px;">
    <canvas id="lvChartLearnNaive"></canvas>
  </div>
  <div class="lv-vis-note">The before/after comparison says streaks added 0.26 SD, the true effect is 0.02, and difference-in-differences lands at 0.05.</div>
</div>

<p class="lv-p">A team using before and after would conclude that streaks produced a quarter of a standard deviation of learning, about what guided mode does for adults. In the simulation streaks produced almost none of it. Learners were improving with time regardless.</p>

---

<h2 class="lv-h2">Where this can still be wrong</h2>

<p class="lv-p">Parallel trends is an assumption, so I tested what happens when it fails. If early-wave clusters were trending up faster than later ones by 0.01 logit points a week, the streak retention estimate for 13–15 learners rises to 12.5 points against a true effect of about 9. The guided-mode estimate for 16–17 learners goes from 4.0 to 6.5 points when the true effect is about 1. Biases of 3 to 5 points are as large as the guided-mode retention effects I'm trying to measure, so small retention differences deserve a lot of caution.</p>

<p class="lv-p">Learning has a related problem. Skill accumulates, and engaged clusters accumulate it faster, so early clusters would have pulled ahead a little even without the feature. The learning estimates sit above the true values in all six cells by 0.01 to 0.07 SD. For adults on streaks, a true effect of zero shows up as +0.07 with an interval that just excludes zero. The pre-launch check didn't flag this. Modeling each cluster's pre-launch growth rate would probably fix it, and I haven't done that here.</p>

<p class="lv-p">The simulation also simplifies in other ways. Adopters are a fixed trait here, while a real product would have to infer who is actually using the feature. Learners within a cluster don't influence each other, which breaks down once siblings or classmates share accounts or compete on streaks. A short checkpoint is a crude measure of learning, and the streak effect never fades, though real streak features often do.</p>

---

<h2 class="lv-h2">What I'd recommend</h2>

<p class="lv-p">For adults the answer is simple, because guided mode wins on every layer and most of them ignore streaks anyway. For 13–17 I wouldn't choose between the two features on retention, since retention alone would pick streaks. I'd ship guided mode where it improves task success and learning, and I'd keep streaks only if the team values the habit for its own sake. I'd also redesign the streak so that it counts only days with a completed task, which makes the extra days contain real work. That change can be tested the same way in the next wave, with the same four layers.</p>

<p class="lv-p">If I could add one instrument, I'd add a checkpoint calibrated by age band and shown to a random sample of learners every few weeks. It's the cheapest layer on the scorecard to build, and it's the one the other layers get checked against.</p>

<div class="lv-footnotes">
  <strong>Code and data.</strong> Simulation and analysis: <code>scripts/learner_value_analysis.py</code>. Results: <code>content/data-projects/learner-value/data/results.json</code>. Cluster-by-segment-by-week panel: <code>cluster_week_panel.csv</code> (12,000 rows, seed 42).<br><br>
  <strong>Method notes.</strong> Estimates follow a Callaway–Sant'Anna-style design: for each launch wave g and week t, the change from week g−1 to week t is compared between wave-g clusters and clusters not yet treated at t (or ever treated), then averaged across waves weighted by cluster count. Intervals are 1.96 × the standard deviation of 200 cluster bootstrap replicates. "Durable" window is weeks 6–8 after exposure (the 13th-week wave contributes weeks 6–7 only). Task success is completed tasks divided by active days. Learning is the mean checkpoint score in a cluster-week among a random 50% sample of learners, with measurement noise of 0.4 SD. The true effects come from the counterfactual paths in the same simulation, averaged over treated learner-weeks in the same window. The robustness check adds 0.01 logit/week of extra trend to early-wave clusters.
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

const lvMono = { size: 11, family: 'Space Mono, monospace' };
function lvTooltip(suffix) {
  return {
    backgroundColor: 'rgba(10,13,20,0.96)',
    titleColor: 'rgba(255,255,255,0.55)', bodyColor: 'rgba(255,255,255,0.55)',
    titleFont: lvMono, bodyFont: lvMono,
    padding: 12, borderColor: 'rgba(255,255,255,0.08)', borderWidth: 1,
    callbacks: { label: ctx => ' ' + ctx.dataset.label + ':  ' + ctx.parsed.y + suffix }
  };
}
function lvY(title, extra) {
  return Object.assign({
    grid: { color: 'rgba(255,255,255,0.05)' },
    ticks: { font: lvMono, color: 'rgba(255,255,255,0.32)' },
    title: { display: true, text: title, font: lvMono, color: 'rgba(255,255,255,0.32)' }
  }, extra || {});
}
function lvX(title) {
  return {
    grid: { display: false },
    ticks: { font: lvMono, color: 'rgba(255,255,255,0.5)' },
    title: title ? { display: true, text: title, font: lvMono, color: 'rgba(255,255,255,0.32)' } : undefined
  };
}
const lvWeeks = Array.from({ length: 20 }, (_, i) => i + 1);
const lvEvents = Array.from({ length: 15 }, (_, i) => i - 4);

/* ── Fig 1: selection ── */
new Chart(document.getElementById('lvChartRaw'), {
  type: 'line',
  data: {
    labels: lvWeeks,
    datasets: [
      { label: 'Launched in week 5', data: [91.8,91.5,91.1,90.6,92.5,92.6,93.5,93.9,95.2,94.8,92.4,93.1,92.1,92.2,84.3,84.3,91.7,92.7,93.1,90.9],
        borderColor: '#7db800', backgroundColor: '#7db800', borderWidth: 2.5, pointRadius: 2, tension: 0.25 },
      { label: 'Not yet reached', data: [82.6,81.8,80.5,81.1,79.8,79.7,79.8,79.5,83.8,84.4,77.3,76.8,77.1,76.2,62.3,61.6,75.3,81.4,80.8,73.4],
        borderColor: '#a8c8d8', backgroundColor: '#a8c8d8', borderWidth: 2.5, pointRadius: 2, tension: 0.25 }
    ]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: lvTooltip('%') },
    scales: { x: lvX('Week'), y: lvY('Active in the week (%)', { min: 55, max: 100 }) }
  }
});

/* ── Fig 2: event studies with bands ── */
function lvEvent(id, est, ci, color, fill, unit, ymin, ymax) {
  const up = est.map((v, i) => +(v + ci[i]).toFixed(3));
  const lo = est.map((v, i) => +(v - ci[i]).toFixed(3));
  new Chart(document.getElementById(id), {
    type: 'line',
    data: {
      labels: lvEvents,
      datasets: [
        { label: 'Estimate', data: est, borderColor: color, backgroundColor: color, borderWidth: 2.5, pointRadius: 2, tension: 0.2, order: 1 },
        { label: 'Upper', data: up, borderWidth: 0, pointRadius: 0, fill: '+1', backgroundColor: fill, order: 2 },
        { label: 'Lower', data: lo, borderWidth: 0, pointRadius: 0, fill: false, order: 3 }
      ]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false }, tooltip: { filter: i => i.datasetIndex === 0, backgroundColor: 'rgba(10,13,20,0.96)',
        titleColor: 'rgba(255,255,255,0.55)', bodyColor: 'rgba(255,255,255,0.55)', titleFont: lvMono, bodyFont: lvMono,
        callbacks: { label: ctx => ' ' + ctx.parsed.y + unit } } },
      scales: { x: lvX('Weeks since launch'), y: lvY(unit.trim(), { min: ymin, max: ymax }) }
    }
  });
}
const lvCiPP = [1.8,2.0,2.1,0,1.9,2.1,2.0,1.8,2.2,2.2,2.4,2.3,2.2,2.5,3.4];
lvEvent('lvStreakActive',
  [-0.7,-1.2,0.3,0,2.1,4.4,9.1,11.1,5.7,5.0,8.8,12.5,9.3,7.1,10.4],
  lvCiPP, '#e07055', 'rgba(224,112,85,0.15)', ' pp', -8, 20);
lvEvent('lvStreakLearn',
  [-0.067,-0.022,0.023,0,-0.013,-0.009,0.018,0.014,0.047,0.031,0.045,0.066,0.042,0.041,0.088],
  [0.066,0.063,0.059,0,0.052,0.066,0.063,0.058,0.071,0.060,0.064,0.057,0.090,0.084,0.094],
  '#e07055', 'rgba(224,112,85,0.15)', ' SD', -0.2, 0.4);
lvEvent('lvGuidedActive',
  [-0.3,-0.6,0.6,0,-0.4,-0.8,2.9,2.6,-0.9,-1.7,3.6,2.9,1.1,-1.5,3.5],
  [1.9,1.7,1.8,0,1.7,1.6,1.8,1.7,2.2,1.8,2.3,2.2,2.5,2.2,3.2],
  '#7db800', 'rgba(125,184,0,0.15)', ' pp', -8, 20);
lvEvent('lvGuidedLearn',
  [0.006,-0.013,-0.057,0,-0.036,-0.003,-0.031,0.053,0.046,0.097,0.111,0.106,0.212,0.256,0.250],
  [0.059,0.056,0.066,0,0.061,0.078,0.074,0.064,0.072,0.078,0.072,0.072,0.097,0.101,0.090],
  '#7db800', 'rgba(125,184,0,0.15)', ' SD', -0.2, 0.4);

/* ── Fig 3: four reads on learning ── */
new Chart(document.getElementById('lvChartLearnNaive'), {
  type: 'bar',
  data: {
    labels: ['Before / after', 'Treated vs. untreated', 'Diff-in-diff', 'True effect'],
    datasets: [{
      label: 'Change in score',
      data: [0.26, 0.15, 0.05, 0.02],
      backgroundColor: ['rgba(224,112,85,0.4)', 'rgba(224,112,85,0.4)', 'rgba(125,184,0,0.3)', 'rgba(168,200,216,0.35)'],
      borderColor: ['#e07055', '#e07055', '#7db800', '#a8c8d8'],
      borderWidth: 1.5, borderRadius: 4, maxBarThickness: 80
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: lvTooltip(' SD') },
    scales: { x: lvX(), y: lvY('SD', { min: 0, max: 0.3 }) }
  }
});
</script>
