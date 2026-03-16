---
title: "The Shape of a Good Answer"
date: 2026-02-25
tags: ['data project']
categories: ['data project']
description: "Most agent evaluations only check whether the final answer was right. That is like judging effort in a mountain race by finish time alone. ARC is a framework for evaluating the full trajectory."
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

/* ── Toggle buttons ── */
.arc-vis-toggle-group { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 16px; }
.arc-vis-toggle {
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
.arc-vis-toggle:hover { border-color: rgba(255,255,255,0.3); color: rgba(255,255,255,0.75); }
.arc-vis-toggle.active { color: var(--predawn) !important; border-color: transparent !important; }

/* ── ARC Definition Block ── */
.arc-def {
  margin: 2.5rem 0;
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 4px;
  overflow: hidden;
}
.arc-row {
  display: grid;
  grid-template-columns: 72px 160px 1fr 1fr;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  align-items: stretch;
}
.arc-row:last-child { border-bottom: none; }
.arc-letter {
  font-family: var(--f-mono);
  font-size: 2.2rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  border-right: 1px solid rgba(255,255,255,0.06);
}
.arc-word {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  padding: 1.4rem 1.2rem;
  border-right: 1px solid rgba(255,255,255,0.06);
  display: flex;
  align-items: center;
  text-transform: uppercase;
}
.arc-target, .arc-measure {
  font-size: 1.25rem;
  font-family: var(--f-mono);
  padding: 1.3rem 1.2rem;
  line-height: 1.65;
  color: rgba(255,255,255,0.38);
}
.arc-target { border-right: 1px solid rgba(255,255,255,0.06); }
.arc-target strong, .arc-measure strong {
  display: block;
  font-size: 1.25rem;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  margin-bottom: 0.5rem;
  color: rgba(255,255,255,0.55);
}
.arc-row-A .arc-letter { background: rgba(125,184,0,0.10); color: var(--moss); }
.arc-row-A .arc-word   { color: var(--moss); }
.arc-row-R .arc-letter { background: rgba(168,200,216,0.10); color: var(--ice); }
.arc-row-R .arc-word   { color: var(--ice); }
.arc-row-C .arc-letter { background: rgba(157,143,232,0.10); color: #9d8fe8; }
.arc-row-C .arc-word   { color: #9d8fe8; }

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

/* ── Pattern text blocks ── */
.arc-text-pattern {
  border-left: 3px solid rgba(255,255,255,0.15);
  padding: 18px 22px;
  margin: 26px 0;
  background: rgba(255,255,255,0.02);
  border-radius: 0 6px 6px 0;
}
.arc-text-pattern.collapse { border-color: #e07055; }
.arc-text-pattern.drift    { border-color: var(--ice); }
.arc-text-pattern.degrade  { border-color: #9d8fe8; }
.arc-text-pattern.recovery { border-color: var(--moss); }
.arc-text-pattern .pattern-title {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: 10px;
}
.arc-text-pattern.collapse  .pattern-title { color: #e07055; }
.arc-text-pattern.drift     .pattern-title { color: var(--ice); }
.arc-text-pattern.degrade   .pattern-title { color: #9d8fe8; }
.arc-text-pattern.recovery  .pattern-title { color: var(--moss); }
.arc-text-pattern p { font-size: 1.05rem; color: rgba(255,255,255,0.6); margin-bottom: 8px; line-height: 1.78; }
.arc-text-pattern .pattern-fix {
  font-family: var(--f-mono);
  font-style: italic;
  font-size: 1.25rem;
  color: rgba(255,255,255,0.38);
  margin-top: 8px;
  margin-bottom: 0;
}

/* ── Warning/info callout boxes ── */
.arc-text-callout {
  background: rgba(125,184,0,0.05);
  border: 1px solid rgba(125,184,0,0.18);
  border-left: 3px solid var(--moss);
  border-radius: 0 6px 6px 0;
  padding: 14px 20px;
  margin: 22px 0;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  color: rgba(255,255,255,0.45);
  line-height: 1.72;
}
.arc-text-callout strong { color: var(--moss); }
.arc-text-callout code {
  background: rgba(255,255,255,0.06);
  color: rgba(255,255,255,0.65);
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 1.1em;
}

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
.arc-score-table .step-scores { font-size: 1.1rem; color: rgba(255,255,255,0.32); }

/* ── Disambiguation table ── */
.arc-disambig-wrap { overflow-x: auto; margin: 24px 0; }
.arc-disambig-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.3);
  margin-bottom: 0.6rem;
}
.arc-disambig-table { width: 100%; border-collapse: collapse; font-family: var(--f-mono); font-size: 1.25rem; }
.arc-disambig-table th {
  background: rgba(255,255,255,0.06);
  color: rgba(255,255,255,0.7);
  padding: 0.9rem 1.1rem;
  text-align: left;
  font-weight: 600;
  letter-spacing: 0.06em;
  font-size: 1.25rem;
  text-transform: uppercase;
  border-right: 1px solid rgba(255,255,255,0.06);
}
.arc-disambig-table th:last-child { border-right: none; }
.arc-disambig-table td {
  padding: 1rem 1.1rem;
  border-bottom: 1px solid rgba(255,255,255,0.05);
  border-right: 1px solid rgba(255,255,255,0.04);
  color: rgba(255,255,255,0.5);
  line-height: 1.65;
  vertical-align: top;
  font-size: 1.25rem;
}
.arc-disambig-table td:last-child { border-right: none; }
.arc-disambig-table tr:last-child td { border-bottom: none; }
.arc-disambig-table td:first-child { color: rgba(255,255,255,0.72); font-weight: 600; }
.arc-disambig-table td:nth-child(3) { color: var(--moss);  background: rgba(125,184,0,0.04); }
.arc-disambig-table td:nth-child(4) { color: var(--ice);   background: rgba(168,200,216,0.04); }

/* ── Flywheel ── */
.arc-flywheel-wrap { margin: 2.2rem 0; }
.arc-flywheel-diagram {
  display: block;
  margin: 0 auto 2rem;
  max-width: 420px;
  width: 100%;
}
.arc-flywheel-cards {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 1px;
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 4px;
  overflow: hidden;
}
.arc-fw-cell { background: rgba(255,255,255,0.02); padding: 1.8rem 1.5rem; }
.arc-fw-letter { font-family: var(--f-mono); font-size: 1.8rem; font-weight: 700; margin-bottom: 0.55rem; }
.arc-fw-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.25);
  margin-bottom: 0.5rem;
}
.arc-fw-body { font-size: 1.25rem; font-family: var(--f-mono); color: rgba(255,255,255,0.38); line-height: 1.68; }

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
.arc-subhead {
  font-size: 1.05rem;
  font-weight: 700;
  color: rgba(255,255,255,0.82);
  margin: 1.8rem 0 0.55rem;
  line-height: 1.55;
  display: block;
}
.arc-hr {
  border: none;
  border-top: 1px solid rgba(255,255,255,0.08);
  margin: 3rem 0;
}

/* ── Responsive ── */
@media (max-width: 680px) {
  .arc-row { grid-template-columns: 52px 130px 1fr; }
  .arc-measure { display: none; }
  .arc-flywheel-cards { grid-template-columns: 1fr; }
}
</style>

<div class="arc-companion-note">
  Assess - Repair - Calibrate (ARC). A framework for long-horizon model diagnostics. 
</div>

*Article by John Tribbia*


I have run Bear Peak in Boulder so many times, I have lost count. The trail from Cragmoor Trailhead gains 2,800 feet in under three miles. I know exactly what a good run on that climb feels like from the inside (spoiler: it hurts regardless). You resist the urge to push hard off the gun. You find a rhythm in the first quarter-mile up the Cragmoor stairs with a shorter stride, consistent breathing, and reading the grade. You build through the middle section where the trail pitches and the less-experienced runners are already blown up. And at the top, when it genuinely hurts and every instinct says to ease off, you hold. Form intact. Effort peaking exactly when it needs to.

That heart rate curve is what I'm talking about. Not the finish time. Not the average. The shape of that curve, rising and peaking and holding, is the thing that tells you whether you managed your effort well or just survived it. A runner who goes out too hard shows a different heart rate profile entirely: a spike in the first ten minutes, then a slow collapse. Maybe even the same finish time, but a completely different story.

A mountain climb is unforgiving. There is no flat section where you recover from a bad start. No downhill to coast on. The terrain compresses the whole problem of pacing into one continuous test. You cannot fake fitness on a climb. The Strava upload will show you the shape of your effort, not just where you finished.

<div class="arc-vis-card">
  <div class="arc-vis-label">Bear Peak · Cragmoor Trailhead to Summit</div>
  <div class="arc-vis-title">Two runs. Same finish time. Completely different story.</div>
  <div class="arc-vis-sub">Heart rate profile over ~40 min · 2,800 ft ascent</div>
  <div class="arc-vis-legend">
    <span><i style="background:#7db800;"></i> The arc (good run)</span>
    <span><i style="background:#e07055;"></i> Went out too hard</span>
  </div>
  <div style="position: relative; width: 100%; height: 360px;">
    <canvas id="hrChart"></canvas>
  </div>
  <p class="arc-vis-note">The arc run peaks at ~163 bpm near the summit and holds. The blowup run spikes to 173 in the first 12 minutes and slowly collapses. Same finish time, same average heart rate, opposite story.</p>
</div>

Watch a language model work through a difficult multi-step task and you notice something similar is missing from how we evaluate it. The quality of its outputs often does not follow that curve. It might go out too fast and commit confidently to a flawed assumption in the first two steps, then spend six more building coherent-sounding reasoning on a wrong foundation. Or it might hold form through the first two-thirds and then fall apart when the task pitches steep and the context window is saturated. Or it might stumble and recover in ways that look more like luck than controlled effort.

The difference between the runner's rising arc and the model's erratic path is not just a performance gap. It is a measurement gap. We are not yet good at describing the shape of how agents succeed or fail across the course of a task. We ask whether they got the answer right at the end. That is like judging a mountain race by finish time alone.

---

## Where This Fits in the Literature

The idea that step-level evaluation beats outcome-only evaluation is not new. Lightman et al. (2023) made this case rigorously in "Let's Verify Step by Step," showing that process reward models trained to score individual reasoning steps rather than just final answers substantially outperform outcome reward models on hard math problems.<sup><a href="#fn1">1</a></sup> Cobbe et al. (2021) laid some of the groundwork with outcome supervision in "Training Verifiers to Solve Math Word Problems."<sup><a href="#fn2">2</a></sup> If you are doing serious RLHF or working on reasoning chain quality, you are probably already thinking in terms of step-level feedback.

ARC is not trying to reinvent that. The distinction worth drawing is that Lightman et al. are solving a <em>training</em> problem: how do you generate the right signal to improve a model during training? ARC is solving a <em>diagnostic</em> problem: once you have a deployed agent producing multi-step outputs, how do you figure out what is actually wrong with it, where in the task it breaks down, and which intervention is likely to fix it? The frameworks address different questions. One shapes the model. The other tells you what shape the model is in and what shape the next training run should target.

The practitioner gap here is real. Most eval tooling in production follows an outcome-only logic even when teams know better. You set up a benchmark, you check final answers, you track a score. The score goes up over time and you ship. What gets missed is <em>how</em> the score goes up: whether the model is genuinely getting better at reasoning through hard tasks, or just getting better at pattern-matching to common task structures. ARC is an attempt to make the diagnostic layer cheap enough that teams actually run it.

---

## ARC

An arc is a shape. Rising, peaking, holding. It is also the name of the framework I'm introducing here for evaluating agents on complex, multi-step tasks.

<div class="arc-def">
  <div class="arc-row arc-row-A">
    <div class="arc-letter">A</div>
    <div class="arc-word">Assess</div>
    <div class="arc-target"><strong>As a target</strong>Build understanding before committing. Orient, gather context, figure out what the problem actually requires.</div>
    <div class="arc-measure"><strong>As a measurement</strong>Detect what happened across the trajectory, verify it was a genuine failure, and confirm the signal is trustworthy before investing in a fix.</div>
  </div>
  <div class="arc-row arc-row-R">
    <div class="arc-letter">R</div>
    <div class="arc-word">Repair</div>
    <div class="arc-target"><strong>As a target</strong>Execute with peak quality. The understanding built in Assess pays off here.</div>
    <div class="arc-measure"><strong>As a measurement</strong>Identify which failure was load-bearing, classify it unambiguously using a verified protocol, and select the correct intervention.</div>
  </div>
  <div class="arc-row arc-row-C">
    <div class="arc-letter">C</div>
    <div class="arc-word">Calibrate</div>
    <div class="arc-target"><strong>As a target</strong>Hold quality through to completion without degrading.</div>
    <div class="arc-measure"><strong>As a measurement</strong>Keep the eval signal honest over time and verify it is pointing at the right thing in the real world.</div>
  </div>
</div>

<div class="arc-vis-card" style="padding: 30px 24px 24px;">
  <div class="arc-vis-label">Framework</div>
  <div class="arc-vis-title">The arc as both target and measurement</div>
  <div class="arc-vis-sub">A good agent traces an arc. ARC tells you when it did not, where it broke, and whether you can trust what you're seeing.</div>
  <svg width="100%" viewBox="0 0 720 290" xmlns="http://www.w3.org/2000/svg" style="display: block; margin-top: 10px;">
    <path d="M 60 185 C 120 105 210 55 280 46 C 328 38 362 36 410 40 C 482 46 568 50 660 52 L 660 192 L 60 192 Z"
          fill="rgba(125,184,0,0.05)" />
    <line x1="48" y1="192" x2="672" y2="192" stroke="rgba(255,255,255,0.10)" stroke-width="1"/>
    <line x1="60"  y1="190" x2="60"  y2="198" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
    <line x1="280" y1="190" x2="280" y2="198" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
    <line x1="410" y1="190" x2="410" y2="198" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
    <line x1="660" y1="190" x2="660" y2="198" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
    <path d="M 60 185 C 120 105 210 55 280 46"
          fill="none" stroke="#7db800" stroke-width="3.5" stroke-linecap="round"/>
    <path d="M 280 46 C 328 38 362 36 410 40"
          fill="none" stroke="#a8c8d8" stroke-width="3.5" stroke-linecap="round"/>
    <path d="M 410 40 C 482 46 568 50 660 52"
          fill="none" stroke="#9d8fe8" stroke-width="3.5" stroke-linecap="round"/>
    <circle cx="280" cy="46" r="5.5" fill="rgba(255,255,255,0.12)" stroke="#7db800" stroke-width="2"/>
    <circle cx="410" cy="40" r="5.5" fill="rgba(255,255,255,0.12)" stroke="#9d8fe8" stroke-width="2"/>
    <line x1="170" y1="76" x2="170" y2="206" stroke="rgba(255,255,255,0.08)" stroke-width="0.8" stroke-dasharray="3,4"/>
    <line x1="345" y1="36" x2="345" y2="206" stroke="rgba(255,255,255,0.08)" stroke-width="0.8" stroke-dasharray="3,4"/>
    <line x1="535" y1="46" x2="535" y2="206" stroke="rgba(255,255,255,0.08)" stroke-width="0.8" stroke-dasharray="3,4"/>
    <rect x="90"  y="208" width="160" height="66" rx="5"
          fill="rgba(125,184,0,0.07)" stroke="#7db800" stroke-width="0.8" stroke-opacity="0.5"/>
    <text x="170" y="228" text-anchor="middle" font-family="'Space Mono', monospace" font-weight="700" font-size="13" fill="#7db800">A - Assess</text>
    <text x="170" y="246" text-anchor="middle" font-family="'Space Mono', monospace" font-size="10" fill="rgba(125,184,0,0.65)">build understanding first</text>
    <rect x="265" y="208" width="160" height="66" rx="5"
          fill="rgba(168,200,216,0.07)" stroke="#a8c8d8" stroke-width="0.8" stroke-opacity="0.5"/>
    <text x="345" y="228" text-anchor="middle" font-family="'Space Mono', monospace" font-weight="700" font-size="13" fill="#a8c8d8">R - Repair</text>
    <text x="345" y="246" text-anchor="middle" font-family="'Space Mono', monospace" font-size="10" fill="rgba(168,200,216,0.65)">peak execution,</text>
    <text x="345" y="259" text-anchor="middle" font-family="'Space Mono', monospace" font-size="10" fill="rgba(168,200,216,0.65)">fix the break</text>
    <rect x="455" y="208" width="160" height="66" rx="5"
          fill="rgba(157,143,232,0.07)" stroke="#9d8fe8" stroke-width="0.8" stroke-opacity="0.5"/>
    <text x="535" y="228" text-anchor="middle" font-family="'Space Mono', monospace" font-weight="700" font-size="13" fill="#9d8fe8">C - Calibrate</text>
    <text x="535" y="246" text-anchor="middle" font-family="'Space Mono', monospace" font-size="10" fill="rgba(157,143,232,0.65)">hold quality,</text>
    <text x="535" y="259" text-anchor="middle" font-family="'Space Mono', monospace" font-size="10" fill="rgba(157,143,232,0.65)">trust the signal</text>
    <text x="60"  y="282" text-anchor="middle" font-family="'Space Mono', monospace" font-size="10" fill="rgba(255,255,255,0.22)">start</text>
    <text x="660" y="282" text-anchor="middle" font-family="'Space Mono', monospace" font-size="10" fill="rgba(255,255,255,0.22)">end</text>
  </svg>
</div>

<div class="arc-callout">
  The ideal agent trajectory and the measurement framework are the same shape. A good agent traces an arc. ARC tells us when it did not, where it broke, and whether we can trust what we're seeing.
</div>

---

## What Goes Wrong

Most agent failures are failures of arc, not ability. The capability is there, but it doesn't deploy in the right shape. When you plot step-by-step quality scores instead of just checking the final answer, four failure patterns emerge repeatedly, all producing similar aggregate scores while calling for completely different interventions.

To make this concrete, imagine four models each scoring around 0.74 on a ten-step task:

<div class="arc-score-wrap">
  <table class="arc-score-table">
    <thead>
      <tr><th>Model</th><th>Aggregate</th><th>Step Scores</th></tr>
    </thead>
    <tbody>
      <tr><td>A</td><td>0.74</td><td class="step-scores">0.90, 0.91, 0.88, 0.60, 0.55, 0.58, 0.61, 0.62, 0.60, 0.58</td></tr>
      <tr><td>B</td><td>0.74</td><td class="step-scores">0.60, 0.58, 0.62, 0.78, 0.82, 0.85, 0.88, 0.87, 0.55, 0.45</td></tr>
      <tr><td>C</td><td>0.74</td><td class="step-scores">0.85, 0.82, 0.78, 0.74, 0.71, 0.68, 0.65, 0.62, 0.58, 0.57</td></tr>
      <tr><td>D</td><td>0.74</td><td class="step-scores">0.88, 0.90, 0.85, 0.40, 0.38, 0.72, 0.85, 0.87, 0.86, 0.89</td></tr>
    </tbody>
  </table>
</div>

<div class="arc-vis-card">
  <div class="arc-vis-label">Agent trajectories</div>
  <div class="arc-vis-title">Four models. Same aggregate score. Four completely different problems.</div>
  <div class="arc-vis-sub">Per-step quality score (0–1) across a 10-step task</div>
  <div class="arc-vis-toggle-group">
    <button class="arc-vis-toggle active" id="tog-a" onclick="toggleModel('a')">A - Early Collapse</button>
    <button class="arc-vis-toggle active" id="tog-b" onclick="toggleModel('b')">B - Late Drift</button>
    <button class="arc-vis-toggle active" id="tog-c" onclick="toggleModel('c')">C - Steady Degradation</button>
    <button class="arc-vis-toggle active" id="tog-d" onclick="toggleModel('d')">D - Recovery</button>
  </div>
  <div style="position: relative; width: 100%; height: 380px;">
    <canvas id="trajChart"></canvas>
  </div>
  <p class="arc-vis-note">The dashed gray line marks the aggregate score of 0.74, identical for all four models. Click a pattern above to show or hide it. The right intervention for each is completely different. Treating them as equivalent wastes a sprint.</p>
</div>

Model A collapses early and grinds through the task on a broken foundation. Model B builds well and then falls apart at the end. Model C is slowly bleeding quality across every step. Model D hits a wall, catches itself, and recovers. A grounding prompt helps Model A. Context management helps Model B. Model D might not need intervention at all.

<div class="arc-text-pattern collapse">
  <div class="pattern-title">Early Collapse</div>
  <p>The model makes a flawed assumption in the first few steps, then produces locally coherent outputs that all build on a wrong foundation. This is the most dangerous pattern because the model is not confused. It is confidently wrong. This is the runner who goes out too hard and does not know it yet.</p>
  <p class="pattern-fix">Intervention: Improve how the model grounds its initial assumptions before committing to an approach.</p>
</div>

<div class="arc-text-pattern drift">
  <div class="pattern-title">Late Drift</div>
  <p>Performance holds through the first two-thirds of the task and then falls sharply. Usually context saturation: the model loses track of earlier constraints as complexity compounds. The runner with strong legs and no fuel left for the ridge.</p>
  <p class="pattern-fix">Intervention: Context management, summarization at intermediate steps, or chunking strategies.</p>
</div>

<div class="arc-text-pattern degrade">
  <div class="pattern-title">Steady Degradation</div>
  <p>Performance declines incrementally across every step. Nothing breaks catastrophically, which is precisely why aggregate scores miss it. Exactly the kind of thing that Strava's average pace hides and the split-by-split view reveals.</p>
  <p class="pattern-fix">Intervention: Requires failure mode classification first. Root cause determines which intervention applies.</p>
</div>

<div class="arc-text-pattern recovery">
  <div class="pattern-title">Recovery After Error</div>
  <p>A dip followed by self-correction. Recovery capability is undervalued. A model that catches and corrects its own mistakes under real conditions may be more deployment-ready than one with a cleaner trajectory on easier evaluations. The runner who catches a root, stumbles, and drives back into rhythm.</p>
  <p class="pattern-fix">Intervention: Measure recovery rate explicitly as a first-class metric.</p>
</div>

<p class="arc-p">Score each step with a zero-to-one judgment, plot the vector, look at the shape.</p>

<hr class="arc-hr"/>

<h2 class="arc-h2">The Measurement Side</h2>

<p class="arc-p">Knowing that an arc broke is only useful if you know the break was real, know what caused it, and know that the thing you're measuring actually matters in the real world. ARC addresses all three.</p>

<h3 class="arc-h3">Assess: Did Something Real Happen?</h3>

<p class="arc-p">The goal of Assess is to produce a trustworthy trajectory: a vector of per-step scores that reflects genuine model behavior, not format recognition. It has two components: building the trajectory and verifying it is real.</p>

<p class="arc-subhead">Building the Trajectory</p>

<p class="arc-p">Select a task suite of 30–50 multi-step tasks representative of your deployment domain. Each task should be decomposable into 4–10 discrete sub-goals with verifiable outputs.</p>

<p class="arc-p"><strong>1. Score each step independently.</strong> Use a privacy preserving No Look Eval (NLE) LLM with a rubric grounded in the sub-goal, not the final answer. Prompt it to return a float 0.0–1.0 with a one-sentence rationale. Never pass the full conversation history to the NLE. Score each step in isolation to avoid halo effects from earlier correct steps.</p>

<pre class="arc-pre"><code># NLE prompt template
nle_prompt = """Given this sub-goal: {subgoal}
And this model output: {step_output}
Score the output 0.0-1.0 for how well it achieves the sub-goal.
Return JSON: {"score": float, "rationale": str}"""</code></pre>

<p class="arc-p"><strong>2. Compute the trajectory vector.</strong> Store scores as a list indexed by step. Compute three slope indicators: early slope (steps 1–N/3), mid slope (steps N/3–2N/3), and late slope (steps 2N/3–N). These three numbers alone will classify most trajectories into one of the four failure patterns.</p>

<pre class="arc-pre"><code>def classify_trajectory(scores):
    n = len(scores)
    s = list(scores)
    t = n // 3
    early_mean = sum(s[:t]) / t
    mid_mean   = sum(s[t:2*t]) / t
    late_mean  = sum(s[2*t:]) / (n - 2*t)
    slope_l    = (s[-1] - s[2*t]) / max(n - 2*t - 1, 1)

    # Check recovery first: dip > 0.20, then returns > 0.10 above the dip
    dips = [i for i in range(1, n-1) if s[i] < s[i-1] - 0.20]
    if dips and s[-1] > s[dips[0]] + 0.10:
        return 'recovery'

    # Early collapse: early section strong, drops and stays low through the end
    if (early_mean - mid_mean) > 0.20 and (early_mean - late_mean) > 0.20:
        return 'early_collapse'

    # Late drift: final segment slopes clearly negative
    if slope_l < -0.12:
        return 'late_drift'

    # Steady degradation: overall score declined without a structural break
    if (s[0] - s[-1]) > 0.15:
        return 'steady_degradation'

    return 'healthy'</code></pre>

<p class="arc-subhead">Verifying the Trajectory is Real</p>

<p class="arc-p"><strong>3. Run surface-feature variation.</strong> Paraphrase each failing task three times with structurally identical content but different wording, examples, and formatting. Re-score. If score variance across variants exceeds 0.15, the model is responding to surface features, not underlying capability.</p>

<div class="arc-text-callout">
  <strong>Threshold:</strong> Variance &gt; 0.15 across 3 paraphrase variants means flag as format artifact. Variance &lt; 0.08 means genuine failure, so proceed to Repair. Assess costs one sprint when you skip it and discover a format artifact three sprints later. It is non-optional.
</div>

<hr class="arc-hr"/>

<h3 class="arc-h3">Repair: Which Failure, and What Fix?</h3>

<p class="arc-p">Repair has three sequential steps: sub-goal weighting, failure localization, and disambiguation. All three must complete before an intervention is selected. Skipping to the intervention based on the symptom alone is the single most common way teams waste a sprint on the wrong fix.</p>

<p class="arc-subhead">Step 1: Weight Sub-Goals by Downstream Impact</p>

<pre class="arc-pre"><code># Downstream impact weighting
# 1 = isolated step (failure affects only this step)
# 2 = shared dependency (failure propagates to 2-3 downstream steps)
# 3 = critical gate (failure invalidates all downstream steps)
weights = [3, 1, 2, 1, 3, 1, 2]   # assign per task
weighted_score = sum(s*w for s,w in zip(scores, weights)) / sum(weights)</code></pre>

<p class="arc-subhead">Step 2: Localize the Break Point</p>

<pre class="arc-pre"><code>def find_break_point(scores):
    baseline = sum(scores[:len(scores)//3]) / (len(scores)//3)
    for i in range(1, len(scores)):
        step_drop = scores[i-1] - scores[i]
        base_drop = baseline    - scores[i]
        if step_drop > 0.20 or base_drop > 0.20:
            return i
    return None</code></pre>

<p class="arc-subhead">Step 3: Run the Disambiguation Protocol</p>

<p class="arc-p">Once you have the break point, run the appropriate probe before assigning a root cause. Five failure types produce overlapping symptoms. The probe is what separates them. Never classify based on symptom alone.</p>

<div class="arc-disambig-wrap">
  <div class="arc-disambig-label">Disambiguation protocol - verify before prescribing</div>
  <table class="arc-disambig-table">
    <thead>
      <tr><th>Symptom</th><th>Likely Cause</th><th>Disambiguator</th><th>Intervention</th></tr>
    </thead>
    <tbody>
      <tr>
        <td>Wrong answer, step 1–2</td>
        <td>Hallucination or goal misread</td>
        <td>Re-run with constraint injection. Persists? Hallucination. Repairs? Goal misread.</td>
        <td>Grounding or clarification prompt</td>
      </tr>
      <tr>
        <td>Correct mid-steps, wrong late</td>
        <td>Context loss or capability gap</td>
        <td>Summarize context at midpoint, re-run tail. Improves? Context loss. Flat? Capability gap.</td>
        <td>Chunking or summarization</td>
      </tr>
      <tr>
        <td>Wrong tool called</td>
        <td>Tool selection or goal misread</td>
        <td>Swap tool descriptions. Persists? Goal misread. Repairs? Tool selection.</td>
        <td>Tool description rewrite or goal clarification</td>
      </tr>
      <tr>
        <td>Gradual decline, all steps</td>
        <td>Context loss or capability gap</td>
        <td>Inject fresh context mid-run. Improves? Context loss. Flat? Capability gap.</td>
        <td>Chunking or curriculum gap</td>
      </tr>
    </tbody>
  </table>
</div>

<div class="arc-text-callout">
  <strong>Minimum probe n:</strong> 5 tasks per symptom before classification.<br/>
  <strong>Log format:</strong> <code>date | task_id | symptom | probe | result | classification | intervention</code><br/><br/>
  The cost of misclassification is asymmetric. A context management fix applied to a capability gap wastes a sprint. A grounding prompt applied to a context loss problem masks the symptom. Verify before you ship.
</div>

<hr class="arc-hr"/>

<h3 class="arc-h3">Calibrate: Can We Trust These Answers Over Time?</h3>

<p class="arc-p">Calibrate has three disciplines, each building on the previous. The first two keep the eval signal internally honest. Most systems skip behavioral grounding. That is where the gap between controlled evaluation and real-world behavior opens.</p>

<p class="arc-subhead">Discipline 1: Internal Signal Integrity</p>

<p class="arc-p"><strong>1. Build and protect a held-out eval set.</strong> Reserve 20% of your task suite, stratified by task type and difficulty, as a held-out set that never touches training data. Rescore this set after every training run alongside your in-distribution set.</p>

<p class="arc-p"><strong>2. Track the held-out gap.</strong> A stable or narrowing gap means the eval signal is trustworthy. A widening gap means surface performance is inflating faster than real capability.</p>

<pre class="arc-pre"><code>gap = in_distribution_score - held_out_score
# gap < 0.05    -> signal healthy
# gap 0.05-0.10 -> watch closely
# gap > 0.10    -> surface inflation likely, pause and investigate</code></pre>

<p class="arc-p"><strong>3. Retire contaminated benchmarks proactively.</strong> Flag any benchmark where the model scores above 0.92 on three consecutive runs. Assume contamination risk and retire it.</p>

<p class="arc-subhead">Discipline 2: Recovery Rate Tracking</p>

<p class="arc-p">Recovery rate is a leading indicator of deployment robustness that most eval systems do not measure. Build it in from the start.</p>

<p class="arc-p"><strong>4. Inject known errors into your eval suite.</strong> For 5–10 tasks per eval run, deliberately introduce a wrong answer or flawed reasoning step at position 3 or 4 in the task sequence. Measure whether it self-corrects within two subsequent steps.</p>

<pre class="arc-pre"><code>recovery_rate = corrected_tasks / error_injection_tasks
# Improving -> model getting more robust
# Degrading  -> potential regression, investigate</code></pre>

<p class="arc-p">A model that achieves 0.85 on clean trajectories but a 0.30 recovery rate is less deployment-ready than one with 0.80 on clean trajectories and a 0.65 recovery rate. Novel production tasks will always introduce errors. Recovery rate tells you what clean-run scores cannot.</p>

<p class="arc-subhead">Discipline 3: Behavioral Grounding</p>

<p class="arc-p">This is the boundary between evaluation and in-the-wild measurement. Run this check monthly.</p>

<p class="arc-p"><strong>5. Sample production transcripts.</strong> Pull 50–100 real user interactions that map to your eval task categories. If you do not have direct transcript access, proxy behavioral signals work: did the user regenerate? Abandon? Continue without editing?</p>

<p class="arc-p"><strong>6. Code transcripts for ARC failure patterns.</strong> Use the same taxonomy. A single coder with the rubric takes roughly two hours for 100 transcripts.</p>

<p class="arc-p"><strong>7. Compare distributions and close the loop.</strong> If distributions diverge by more than 15–20 percentage points on a given pattern, either your eval tasks are not representative of production or your failure taxonomy needs revision.</p>

<pre class="arc-pre"><code>eval: {early_collapse: 0.35, late_drift: 0.28, recovery: 0.22, steady_deg: 0.15}
prod: {early_collapse: 0.12, late_drift: 0.31, recovery: 0.19, steady_deg: 0.38}
steady_degradation diverges 23pp -> add more to eval suite before next run</code></pre>

<p class="arc-p">Behavioral grounding also validates your intervention decisions. If your eval says late-drift is the dominant failure pattern and you apply context management fixes, production should show late-drift declining in subsequent months. An eval can be perfectly calibrated and still measure the wrong thing. Behavioral grounding is how you find out.</p>

<hr class="arc-hr"/>

<h2 class="arc-h2">The Flywheel</h2>

<p class="arc-p">ARC is not a one-time audit. Each rotation deposits something that makes the next rotation faster and more precise.</p>

<div class="arc-flywheel-wrap">
  <svg class="arc-flywheel-diagram" viewBox="0 0 480 480" xmlns="http://www.w3.org/2000/svg" aria-label="ARC flywheel: A to R to C back to A">
    <defs>
      <marker id="arr-a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
        <path d="M0,0 L0,6 L8,3 z" fill="#7db800" fill-opacity="0.8"/>
      </marker>
      <marker id="arr-r" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
        <path d="M0,0 L0,6 L8,3 z" fill="#a8c8d8" fill-opacity="0.8"/>
      </marker>
      <marker id="arr-c" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
        <path d="M0,0 L0,6 L8,3 z" fill="#9d8fe8" fill-opacity="0.8"/>
      </marker>
    </defs>
    <path d="M 240 240 L 240 85 A 155 155 0 0 1 377.5 317.5 Z"
          fill="rgba(125,184,0,0.07)" stroke="rgba(125,184,0,0.2)" stroke-width="1"/>
    <path d="M 240 240 L 377.5 317.5 A 155 155 0 0 1 102.5 317.5 Z"
          fill="rgba(168,200,216,0.07)" stroke="rgba(168,200,216,0.2)" stroke-width="1"/>
    <path d="M 240 240 L 102.5 317.5 A 155 155 0 0 1 240 85 Z"
          fill="rgba(157,143,232,0.07)" stroke="rgba(157,143,232,0.2)" stroke-width="1"/>
    <circle cx="240" cy="240" r="155" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1"/>
    <circle cx="240" cy="240" r="72" fill="#0a0d14" stroke="rgba(255,255,255,0.10)" stroke-width="1"/>
    <text x="240" y="234" text-anchor="middle" font-family="'Space Mono', monospace" font-size="14" font-weight="700" fill="rgba(255,255,255,0.5)" letter-spacing="0.12em">ARC</text>
    <text x="240" y="254" text-anchor="middle" font-family="'Space Mono', monospace" font-size="11" fill="rgba(255,255,255,0.25)">flywheel</text>
    <circle cx="240"   cy="85"    r="30" fill="#0a0d14" stroke="#7db800" stroke-width="2.5"/>
    <circle cx="377.5" cy="317.5" r="30" fill="#0a0d14" stroke="#a8c8d8" stroke-width="2.5"/>
    <circle cx="102.5" cy="317.5" r="30" fill="#0a0d14" stroke="#9d8fe8" stroke-width="2.5"/>
    <text x="240"   y="93"    text-anchor="middle" font-family="'Space Mono', monospace" font-size="22" font-weight="700" fill="#7db800">A</text>
    <text x="377.5" y="325.5" text-anchor="middle" font-family="'Space Mono', monospace" font-size="22" font-weight="700" fill="#a8c8d8">R</text>
    <text x="102.5" y="325.5" text-anchor="middle" font-family="'Space Mono', monospace" font-size="22" font-weight="700" fill="#9d8fe8">C</text>
    <text x="240"   y="44"    text-anchor="middle" font-family="'Space Mono', monospace" font-size="13" font-weight="700" fill="#7db800">Assess</text>
    <text x="424"   y="356"   text-anchor="middle" font-family="'Space Mono', monospace" font-size="13" font-weight="700" fill="#a8c8d8">Repair</text>
    <text x="56"    y="356"   text-anchor="middle" font-family="'Space Mono', monospace" font-size="13" font-weight="700" fill="#9d8fe8">Calibrate</text>
    <path d="M 264 101 A 145 145 0 0 1 362 298" fill="none" stroke="#7db800" stroke-width="2" stroke-opacity="0.75" marker-end="url(#arr-a)"/>
    <path d="M 352 335 A 145 145 0 0 1 128 335" fill="none" stroke="#a8c8d8" stroke-width="2" stroke-opacity="0.75" marker-end="url(#arr-r)"/>
    <path d="M 118 298 A 145 145 0 0 1 216 101" fill="none" stroke="#9d8fe8" stroke-width="2" stroke-opacity="0.75" marker-end="url(#arr-c)"/>
  </svg>
  <div class="arc-flywheel-cards">
    <div class="arc-fw-cell">
      <div class="arc-fw-letter" style="color:#7db800">A</div>
      <div class="arc-fw-label">Deposits</div>
      <div class="arc-fw-body">A growing library of classified trajectory patterns, a bank of adversarial paraphrase probes, and variance benchmarks by task type. Failure shapes that required careful manual diagnosis in run one get recognized automatically in run ten.</div>
    </div>
    <div class="arc-fw-cell">
      <div class="arc-fw-letter" style="color:#a8c8d8">R</div>
      <div class="arc-fw-label">Deposits</div>
      <div class="arc-fw-body">A validated disambiguation log: a record of which probes worked, which symptoms mapped to which root causes in your domain, and which interventions held up on held-out sets. The protocol gets faster and more accurate with every entry.</div>
    </div>
    <div class="arc-fw-cell">
      <div class="arc-fw-letter" style="color:#9d8fe8">C</div>
      <div class="arc-fw-label">Deposits</div>
      <div class="arc-fw-body">A progressively sharper eval signal and a growing body of behavioral validation evidence. The gap metric builds a baseline. The retirement log shows which benchmarks have a shelf life. Recovery rate trends tell you whether the model is getting more robust or just more accurate on easy paths.</div>
    </div>
  </div>
</div>

<div class="arc-callout plum">
  Each time you go around the arc, it gets faster and harder to fool. Checklists reset. ARC compounds. It gets better at the hardest part: knowing which lever to pull and whether the signal points at the right thing.
</div>

<hr class="arc-hr"/>

<p class="arc-p">The framework describes what a good trajectory looks like and how to classify deviations from it. But a classification system is itself an instrument and instruments fail in specific ways. The next post does what you should do with any new tool before trusting it in production: deliberately tries to break it. The classifier gets stress-tested against synthetic trajectories at increasing noise levels, and the failure modes are documented precisely. Knowing the operating envelope of your measurement tool is part of trusting it.</p>

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

/* ── CHART 1: Bear Peak Heart Rate ── */
const mountainPlugin = {
  id: 'mountain',
  beforeDatasetsDraw(chart) {
    const ctx = chart.ctx;
    const { left, top, width, height } = chart.chartArea;
    ctx.save();
    const ridge = [
      [0, 1.00],
      [0.08, 0.85], [0.18, 0.70], [0.28, 0.56],
      [0.38, 0.42], [0.48, 0.29], [0.58, 0.18],
      [0.68, 0.10], [0.78, 0.05], [0.88, 0.02],
      [1.00, 0.01],
      [1.00, 1.00]
    ];
    ctx.beginPath();
    ridge.forEach(([nx, ny], i) => {
      const x = left + nx * width;
      const y = top  + ny * height;
      i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
    });
    ctx.closePath();
    ctx.fillStyle = 'rgba(255,255,255,0.04)';
    ctx.fill();
    ctx.fillStyle = 'rgba(255,255,255,0.18)';
    ctx.font = '600 11px Space Mono, monospace';
    ctx.textAlign = 'center';
    ctx.fillText('\u25b2 BEAR PEAK', left + 0.88 * width, top + 0.02 * height + 16);
    ctx.restore();
  }
};

new Chart(document.getElementById('hrChart'), {
  type: 'line',
  plugins: [mountainPlugin],
  data: {
    labels: ['0:00','0:04','0:08','0:12','0:16','0:20','0:24','0:28','0:32','0:36','0:40'],
    datasets: [
      {
        label: 'The arc (good run)',
        data: [128, 137, 144, 150, 155, 158, 160, 162, 163, 163, 163],
        borderColor: '#7db800', backgroundColor: 'rgba(125,184,0,0.08)',
        fill: true, tension: 0.4, borderWidth: 2.8,
        pointRadius: 3.5, pointHoverRadius: 6,
        pointBackgroundColor: '#7db800',
        pointBorderColor: 'rgba(10,13,20,0.9)', pointBorderWidth: 1.5
      },
      {
        label: 'Went out too hard',
        data: [133, 158, 169, 173, 170, 164, 156, 148, 141, 137, 134],
        borderColor: '#e07055', backgroundColor: 'rgba(224,112,85,0.07)',
        fill: true, tension: 0.4, borderWidth: 2.8,
        pointRadius: 3.5, pointHoverRadius: 6,
        pointBackgroundColor: '#e07055',
        pointBorderColor: 'rgba(10,13,20,0.9)', pointBorderWidth: 1.5
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
        callbacks: {
          title: ctx => 'Elapsed: ' + ctx[0].label,
          label: ctx => ' ' + ctx.dataset.label + ':  ' + ctx.parsed.y + ' bpm'
        }
      }
    },
    scales: {
      x: {
        grid: { color: 'rgba(255,255,255,0.05)', drawTicks: false },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', maxRotation: 0 },
        title: { display: true, text: 'Elapsed time', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', padding: { top: 8 } }
      },
      y: {
        min: 120, max: 182,
        grid: { color: 'rgba(255,255,255,0.05)' },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', stepSize: 10, callback: v => v + ' bpm' },
        title: { display: true, text: 'Heart rate', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)' }
      }
    }
  }
});

/* ── CHART 2: Agent Trajectory Patterns ── */
const modelData = {
  a: { label: 'Model A \u2014 early collapse',     color: '#e07055', data: [0.90, 0.91, 0.88, 0.60, 0.55, 0.58, 0.61, 0.62, 0.60, 0.58] },
  b: { label: 'Model B \u2014 late drift',         color: '#a8c8d8', data: [0.60, 0.58, 0.62, 0.78, 0.82, 0.85, 0.88, 0.87, 0.55, 0.45] },
  c: { label: 'Model C \u2014 steady degradation', color: '#9d8fe8', data: [0.85, 0.82, 0.78, 0.74, 0.71, 0.68, 0.65, 0.62, 0.58, 0.57] },
  d: { label: 'Model D \u2014 recovery',           color: '#7db800', data: [0.88, 0.90, 0.85, 0.40, 0.38, 0.72, 0.85, 0.87, 0.86, 0.89] }
};

function makeDataset(key) {
  const m = modelData[key];
  return {
    label: m.label, data: m.data,
    borderColor: m.color, backgroundColor: m.color + '14',
    fill: false, tension: 0.25, borderWidth: 2.8,
    pointRadius: 4.5, pointHoverRadius: 7,
    pointBackgroundColor: m.color,
    pointBorderColor: 'rgba(10,13,20,0.9)', pointBorderWidth: 1.5,
    hidden: false, modelKey: key
  };
}

const trajChart = new Chart(document.getElementById('trajChart'), {
  type: 'line',
  data: {
    labels: ['Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10'],
    datasets: [
      makeDataset('a'), makeDataset('b'), makeDataset('c'), makeDataset('d'),
      {
        label: 'Aggregate baseline (0.74)',
        data: [0.74,0.74,0.74,0.74,0.74,0.74,0.74,0.74,0.74,0.74],
        borderColor: 'rgba(255,255,255,0.22)', backgroundColor: 'transparent',
        fill: false, borderDash: [6,4], borderWidth: 1.5,
        tension: 0, pointRadius: 0, pointHoverRadius: 0, modelKey: 'baseline'
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
        filter: item => item.dataset.modelKey !== 'baseline',
        callbacks: { label: ctx => ' ' + ctx.dataset.label + ':  ' + ctx.parsed.y.toFixed(2) }
      }
    },
    scales: {
      x: {
        grid: { color: 'rgba(255,255,255,0.05)', drawTicks: false },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)' },
        title: { display: true, text: 'Task step', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', padding: { top: 8 } }
      },
      y: {
        min: 0.30, max: 1.02,
        grid: { color: 'rgba(255,255,255,0.05)' },
        ticks: { font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)', stepSize: 0.1, callback: v => v.toFixed(1) },
        title: { display: true, text: 'Quality score', font: { size: 11, family: 'Space Mono, monospace' }, color: 'rgba(255,255,255,0.32)' }
      }
    }
  }
});

/* Toggle logic */
const activeKeys = new Set(['a', 'b', 'c', 'd']);
const toggleColors = { a: '#e07055', b: '#a8c8d8', c: '#9d8fe8', d: '#7db800' };

function toggleModel(key) {
  const btn = document.getElementById('tog-' + key);
  const isOn = activeKeys.has(key);
  if (isOn) {
    activeKeys.delete(key);
    btn.classList.remove('active');
    btn.style.background = 'rgba(255,255,255,0.04)';
    btn.style.color = toggleColors[key];
    btn.style.borderColor = toggleColors[key];
  } else {
    activeKeys.add(key);
    btn.classList.add('active');
    btn.style.background = toggleColors[key];
    btn.style.color = '#0a0d14';
    btn.style.borderColor = 'transparent';
  }
  trajChart.data.datasets.forEach(ds => {
    if (ds.modelKey && ds.modelKey !== 'baseline') ds.hidden = !activeKeys.has(ds.modelKey);
  });
  trajChart.update();
}

document.querySelectorAll('.arc-vis-toggle').forEach(btn => {
  const key = btn.id.replace('tog-', '');
  if (toggleColors[key]) {
    btn.style.background = toggleColors[key];
    btn.style.color = '#0a0d14';
    btn.style.borderColor = 'transparent';
  }
});
</script>