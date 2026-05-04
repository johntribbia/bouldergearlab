---
title: "Against the Trend: Denti-Cal Payments at Children's Dental Group After 2015"
date: 2026-05-03
tags: ["data project"]
categories: ["data project"]
description: "California Denti-Cal records show Anaheim's payment intensity rose after the March 2015 ownership transition while every peer office fell or held flat. The divergence survives difference-in-differences, synthetic control, and every leave-one-out subset."
draft: false
math: false
---
<!--more-->

<style>
.cgd-lede {
  font-family: var(--f-mono);
  font-size: 1.2rem;
  color: rgba(255,255,255,0.42);
  border-left: 2px solid var(--moss);
  padding: 0.8rem 1.2rem;
  background: rgba(125,184,0,0.06);
  line-height: 1.65;
  margin-bottom: 2rem;
}

.cgd-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.cgd-p {
  font-size: 1.5rem;
  line-height: 1.75;
  color: rgba(255,255,255,0.65);
  margin: 0 0 1.4rem;
  display: block;
  width: 100%;
  max-width: 100%;
  min-width: 0;
  white-space: normal;
  word-break: normal;
  overflow-wrap: break-word;
  writing-mode: horizontal-tb;
}

.cgd-p strong { color: rgba(255,255,255,0.88); }

.cgd-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
  width: 100%;
  max-width: 100%;
  min-width: 0;
}

.cgd-vis-label {
  font-family: var(--f-mono);
  font-size: 0.74rem;
  font-weight: 600;
  letter-spacing: 0.09em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}

.cgd-vis-title {
  font-family: var(--f-display);
  font-size: 1.5rem;
  color: rgba(255,255,255,0.88);
  font-weight: 600;
  margin-bottom: 4px;
}

.cgd-vis-sub {
  font-family: var(--f-mono);
  font-size: 1.15rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 12px;
}

.cgd-vis-legend {
  display: flex; flex-wrap: wrap; gap: 14px;
  font-family: var(--f-mono); font-size: 1.1rem;
  color: rgba(255,255,255,0.45);
  margin-bottom: 14px;
}

.cgd-vis-legend span { display: flex; align-items: center; gap: 8px; }
.cgd-vis-legend i {
  display: inline-block; width: 26px; height: 3px;
  border-radius: 2px; flex-shrink: 0;
}

.cgd-vis-note {
  font-family: var(--f-mono);
  font-size: 1.15rem;
  color: rgba(255,255,255,0.3);
  margin-top: 10px; margin-bottom: 0;
  line-height: 1.55;
  display: block;
  width: 100%;
  max-width: 100%;
  min-width: 0;
  white-space: normal;
  word-break: normal;
  overflow-wrap: break-word;
  writing-mode: horizontal-tb;
}

.cgd-callout {
  margin: 2.2rem 0; padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic; font-size: 1.5rem;
  color: rgba(255,255,255,0.55); line-height: 1.8;
  width: 100%;
  max-width: 100%;
  min-width: 0;
  white-space: normal;
  word-break: normal;
  overflow-wrap: break-word;
  writing-mode: horizontal-tb;
}
.cgd-callout.red { border-color: #e07055; background: rgba(224,112,85,0.05); }
.cgd-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

.cgd-hook {
  margin: 1.9rem 0 2.6rem;
  padding: 1.5rem 1.5rem 1.3rem;
  border: 1px solid rgba(125,184,0,0.24);
  border-radius: 10px;
  background:
    radial-gradient(circle at 88% 14%, rgba(125,184,0,0.16), transparent 42%),
    linear-gradient(180deg, rgba(17,24,32,0.9), rgba(10,13,20,0.82));
}

.cgd-hook-kicker {
  font-family: var(--f-mono);
  font-size: 1.05rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 0.6rem;
}

.cgd-hook-title {
  font-family: var(--f-display);
  font-size: 2.05rem;
  line-height: 1.22;
  color: rgba(255,255,255,0.92);
  margin: 0 0 0.8rem;
}

.cgd-hook-text {
  font-size: 1.4rem;
  line-height: 1.72;
  color: rgba(255,255,255,0.65);
  margin: 0;
}

.cgd-impact-grid {
  margin-top: 1.25rem;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}

.cgd-impact-card {
  border: 1px solid rgba(255,255,255,0.08);
  background: rgba(255,255,255,0.025);
  border-radius: 8px;
  padding: 0.85rem 0.95rem;
}

.cgd-impact-value {
  font-family: var(--f-display);
  font-size: 1.75rem;
  color: rgba(255,255,255,0.9);
  line-height: 1.1;
  margin: 0 0 0.22rem;
}

.cgd-impact-value.hot { color: #e07055; }

.cgd-impact-label {
  font-family: var(--f-mono);
  font-size: 1.02rem;
  color: rgba(255,255,255,0.45);
  letter-spacing: 0.02em;
  line-height: 1.38;
}

.cgd-mini-timeline {
  margin-top: 1.05rem;
}

.cgd-mini-timeline text {
  font-family: 'Space Mono', monospace;
  fill: rgba(255,255,255,0.53);
  font-size: 8.6px;
}

@media (max-width: 820px) {
  .cgd-hook-title { font-size: 1.72rem; }
  .cgd-hook-text { font-size: 1.28rem; }
  .cgd-impact-grid { grid-template-columns: 1fr; }
}

.cgd-table-wrap {
  overflow-x: auto;
  margin: 28px 0;
  max-width: 100%;
}
.cgd-table-caption {
  font-family: var(--f-mono); font-size: 1.15rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 8px; letter-spacing: 0.03em;
}
.cgd-table {
  width: 100%; border-collapse: collapse;
  font-family: var(--f-mono); font-size: 1.2rem;
}
.cgd-table th {
  background: rgba(26,32,48,0.9);
  color: rgba(255,255,255,0.7);
  padding: 8px 12px; text-align: left; font-weight: 600;
  border-bottom: 1px solid rgba(255,255,255,0.1);
  white-space: nowrap;
}
.cgd-table td {
  padding: 7px 12px;
  color: rgba(255,255,255,0.5);
  border-bottom: 1px solid rgba(255,255,255,0.04);
}
.cgd-table tr td:first-child {
  color: rgba(255,255,255,0.82); font-weight: 700;
}
.cgd-table tr:hover td { background: rgba(255,255,255,0.02); }
.cgd-table .hi { color: #e07055; }
.cgd-table .lo { color: rgba(255,255,255,0.3); }
.cgd-num {
  white-space: nowrap;
  word-break: normal;
  overflow-wrap: normal;
}

.cgd-footnotes {
  margin-top: 52px;
  border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px;
  font-family: var(--f-mono);
  font-size: 1.15rem;
  color: rgba(255,255,255,0.3);
  line-height: 1.65;
  width: 100%;
  max-width: 100%;
  min-width: 0;
  white-space: normal;
  word-break: normal;
  overflow-wrap: break-word;
  writing-mode: horizontal-tb;
}
</style>

*Article by John Tribbia*

<div class="cgd-lede">
Analysis covers January 2013 – September 2016 · Source: Data obtained under the California Public Records Act · Procedure-level extracts and internal dashboards not used · All data in this article is drawn from shareable state records only.
</div>

<div class="cgd-hook">
  <div class="cgd-hook-kicker">The Finding</div>
  <h2 class="cgd-hook-title">A legal case can feel abstract until the billing pattern moves in the opposite direction.</h2>
  <p class="cgd-hook-text">California paid $62.23 million across ten offices between 2013 and 2016. After March 2015, every office except Anaheim flat-lined or fell—system average down 3.6%. Anaheim rose $14.49 per visit day above peer offices in two-way fixed-effects DiD (t&nbsp;=&nbsp;4.28), growing to +$21.99 under trend adjustment. The synthetic control puts the post-period gap at $18.67. No single control office drives the result. At provider level, three dentists show elevated post-2015 payments in baseline DiD—but pretrend diagnostics split them: two show acceleration that predates the March 2015 cutoff, one does not, and it's that divergence in internal validity, not raw effect size, that determines how much weight each signal can carry.</p>

  <div class="cgd-impact-grid">
    <div class="cgd-impact-card">
      <div class="cgd-impact-value">$62.23M</div>
      <div class="cgd-impact-label">Total Denti-Cal payments in office records (Jan 2013-Sep 2016)</div>
    </div>
    <div class="cgd-impact-card">
      <div class="cgd-impact-value hot">+$14.49</div>
      <div class="cgd-impact-label">Anaheim DiD effect per visit day after March 2015</div>
    </div>
    <div class="cgd-impact-card">
      <div class="cgd-impact-value">+$18.67</div>
      <div class="cgd-impact-label">Post-period Anaheim gap vs synthetic control</div>
    </div>
  </div>

  <div class="cgd-mini-timeline">
    <svg viewBox="0 0 700 86" style="width:100%;max-width:700px;display:block;">
      <defs>
        <linearGradient id="cgdTimeGlow" x1="0%" x2="100%" y1="0%" y2="0%">
          <stop offset="0%" stop-color="rgba(168,200,216,0.6)"/>
          <stop offset="56%" stop-color="rgba(224,112,85,0.85)"/>
          <stop offset="100%" stop-color="rgba(125,184,0,0.7)"/>
        </linearGradient>
      </defs>
      <line x1="30" y1="42" x2="670" y2="42" stroke="rgba(255,255,255,0.16)" stroke-width="2" />
      <line x1="30" y1="42" x2="670" y2="42" stroke="url(#cgdTimeGlow)" stroke-width="3" stroke-linecap="round" opacity="0.75"/>
      <circle cx="170" cy="42" r="6" fill="rgba(168,200,216,0.9)"/>
      <circle cx="402" cy="42" r="7" fill="rgba(224,112,85,0.95)"/>
      <circle cx="602" cy="42" r="6" fill="rgba(125,184,0,0.95)"/>
      <line x1="402" y1="22" x2="402" y2="62" stroke="rgba(224,112,85,0.68)" stroke-dasharray="4,3"/>
      <text x="132" y="21">Jan 2013</text>
      <text x="335" y="18">Mar 2015 transition</text>
      <text x="560" y="21">Sep 2016</text>
      <text x="92" y="72">Baseline period</text>
      <text x="430" y="72">Divergence window tested</text>
    </svg>
  </div>
</div>

<p class="cgd-p">This article makes two claims. First, the office-level Anaheim signal is strong and remains strong under harder specifications. Second, the provider-level Diaz signal is important but less clean causally once pre-existing trend differences are modeled.</p>

<h2 class="cgd-h2">Case Context and Research Question</h2>

<p class="cgd-p">Children's Dental Group (CDG) operates pediatric dental clinics across California, serving low-income populations. <a href="https://www.moriarty.com/childrensdentalgroup/">Litigation alleged</a> infection-control failures at Anaheim (73 children hospitalized, hundreds exposed) and unnecessary high-reimbursement procedures chain-wide. Court-appointed co-lead counsel represented dozens of families in consolidated suits.</p>

<div class="cgd-callout red">
  <strong>Scope note:</strong> This article does not adjudicate those legal claims. It examines a narrower question using state billing records only: whether payment-intensity patterns changed after the March 2015 ownership transition.
</div>

<p class="cgd-p">In March 2015, Sam Gruenbaum acquired CDG's clinic chain. The question here is narrower: do state payment records show a change?</p>

<p class="cgd-p">Data source: Data is sourced from a California Public Records Act request. It contains state-reported payment totals by office-month (ten clinics, eight with full pre/post coverage) and by dentist-week (25 providers). No internal dashboards, patient-level extracts, or private benchmarks. Only shareable, verifiable state records.</p>

---

<h2 class="cgd-h2">Office-Level Results: Where the Divergence Starts</h2>

<p class="cgd-p">The office-level records span 45 months (January 2013–September 2016): ten clinics, $62.23 million in Denti-Cal payments. Two clinics (Baldwin Park, Whittier) appear only post-2015 and cannot support comparison. The eight with full-period coverage average <strong>$144 per visit day</strong>.</p>

<p class="cgd-p">Pre-2015 average: $146.45. Post-2015: $141.13, a 3.6% system-wide decline. One office moved opposite.</p>

<div class="cgd-vis-card">
  <div class="cgd-vis-label">REQUEST 1 & 2 · DENTI-CAL OFFICE RECORDS</div>
  <div class="cgd-vis-title">Payment per Visit Day: Pre vs. Post March 2015</div>
  <div class="cgd-vis-sub">Dollars per patient visit day · office-level totals · March 2015 cutoff</div>
  <div style="position:relative;width:100%;height:340px;">
    <canvas id="cgdOfficePPDChart"></canvas>
  </div>
  <p class="cgd-vis-note">Most offices show flat or declining payment intensity after the transition. Anaheim is the exception, rising 6% while the system average fell 3.6%. †Baldwin Park and Whittier appear only in post-2015 records and have no pre-period baseline.</p>
</div>

<p class="cgd-p">Anaheim rose from $144.53 to $153.25 (+6%). Every other clinic stayed flat or fell. San Jose dropped most (−12%), Santa Ana −4.6%, South Gate flat. The divergence is measurable and moves against the system. It does not prove wrongdoing—office-level records omit procedure detail, case mix, volume shifts, and staffing changes can all produce the same signal.</p>

---

<h2 class="cgd-h2">The Causal Test: Did Anaheim Diverge or Just Float?</h2>

<p class="cgd-p">To test whether Anaheim's trajectory changed after March 2015—controlling for system-wide trends—the tool is difference-in-differences: measure Anaheim's relative change against the other seven offices, then net out system-wide movement.</p>

<p class="cgd-p">Effect: <strong>+$14.49 per visit day</strong> (SE $3.39, t = 4.28, 95% CI: $7.85–$21.12). Standardized effect (relative to pre-period SD): 0.75. After netting system-wide trends, Anaheim rose $14.50 more than peer clinics.</p>

<p class="cgd-p">Two robustness checks: pretrend slope is flat (−$0.21/month, t = −0.93), supporting parallel-trends. Trend-adjusted DiD is larger: +$21.99 (t = 4.02, CI: $11.26–$32.71). The office-level result strengthens under stricter specification.</p>

<div class="cgd-vis-card">
  <div class="cgd-vis-label">SYNTHETIC CONTROL · ANAHEIM VS. CONSTRUCTED BENCHMARK</div>
  <div class="cgd-vis-title">Anaheim Payment Intensity vs. Synthetic Counterpart</div>
  <div class="cgd-vis-sub">Dollars per visit day · monthly · synthetic control weighted from 7 control offices</div>
  <div class="cgd-vis-legend">
    <span><i style="background:#7db800;"></i> Anaheim (actual)</span>
    <span><i style="background:#a8c8d8;"></i> Synthetic control</span>
  </div>
  <div style="position:relative;width:100%;height:320px;">
    <canvas id="cgdSynthChart"></canvas>
  </div>
  <p class="cgd-vis-note">Pre-treatment RMSE = $9.02. The synthetic series tracks Anaheim closely before March 2015. Post-treatment mean gap = +$18.67. The vertical line marks the Gruenbaum transition in March 2015.</p>
</div>

<p class="cgd-p">Synthetic control confirms the pattern. Pre-2015, a weighted combination of seven offices tracks Anaheim with RMSE $9.02 (Carson 32.5%, Eagle Rock 18.4%, Sunnyvale 16%). Post-2015, gap opens. Post-period mean gap: <strong>+$18.67 per visit day</strong>, largest mid-2015 through late 2016.</p>

<div class="cgd-vis-card">
  <div class="cgd-vis-label">SENSITIVITY CHECK · LEAVE-ONE-OUT</div>
  <div class="cgd-vis-title">DiD Estimate Holds Across All Control-Office Subsets</div>
  <div class="cgd-vis-sub">95% confidence intervals · each bar drops one control office</div>
  <div style="position:relative;width:100%;height:280px;">
    <canvas id="cgdOfficeLooChart"></canvas>
  </div>
  <p class="cgd-vis-note">LOO range: $12.16 to $15.94. All estimates exclude zero. The San Jose LOO produces the smallest effect because that office has the sharpest post-2015 decline, so removing it strengthens Anaheim's relative position.</p>
</div>

<p class="cgd-p">Estimate stable across leave-one-out: $12.16 (San Jose dropped) to $15.94 (Eagle Rock dropped). All intervals exclude zero. No single office drives the result.</p>

<p class="cgd-p">The placebo check is less decisive, though still informative: Anaheim ranks first among the eight offices, and the permutation p-value is 0.25. With only eight offices, that's the best possible ranking, but the sample is too small to achieve conventional significance thresholds through permutation alone. The LOO stability and the synthetic control's pre-period fit are the stronger tests. Both hold.</p>

---

<h2 class="cgd-h2">Twenty-Five Dentists, $24 Million, Not Evenly Distributed</h2>

<p class="cgd-p">The weekly provider records offer a second angle on the same system. Request 6 covers 25 individual dentists, identified by NPI number in the original data and matched to names here using a separate NPI lookup table. NPI numbers are public identifiers registered in the <a href="https://npiregistry.cms.hhs.gov/">national NPI registry</a> maintained by CMS. The records track weekly Denti-Cal payments from early 2013 through September 2016. Total payments in this extract are $24.09 million, distributed unevenly.</p>

<div class="cgd-vis-card">
  <div class="cgd-vis-label">REQUEST 6 · WEEKLY PROVIDER PAYMENTS</div>
  <div class="cgd-vis-title">Total Denti-Cal Payments by Dentist, Full Panel</div>
  <div class="cgd-vis-sub">All weeks in panel · Jan 2013 – Sep 2016 · top 15 providers shown</div>
  <div style="position:relative;width:100%;height:360px;">
    <canvas id="cgdProviderTotalsChart"></canvas>
  </div>
  <p class="cgd-vis-note">Lisa Vo Nguyen leads at $2.40M total. The top five providers together account for 44.9% of the $24.09M panel. The bottom half of the provider list accounts for less than 20%.</p>
</div>

<p class="cgd-p">The top five providers, Lisa Vo Nguyen, Irina Mihaela Tarnavsky, Trinh Thuy Pham, Helen Hoi-Yen Ching, and Pamela Abraham, account for 44.9 percent of total panel payments. That concentration is not unusual by itself because dental billing often clusters among high-volume practitioners. The key question is whether the distribution <em>changed</em> after March 2015.</p>

<div class="cgd-vis-card">
  <div class="cgd-vis-label">REQUEST 6 · PRE vs. POST COMPARISONS</div>
  <div class="cgd-vis-title">Weekly Payment Mean: Before vs. After March 2015</div>
  <div class="cgd-vis-sub">Average weekly Denti-Cal payments · providers with observations in both periods</div>
  <div class="cgd-vis-legend">
    <span><i style="background:#a8c8d8;"></i> Pre-March 2015</span>
    <span><i style="background:#7db800;"></i> Post-March 2015</span>
  </div>
  <div style="position:relative;width:100%;height:380px;">
    <canvas id="cgdPrePostChart"></canvas>
  </div>
  <p class="cgd-vis-note">David Michael Diaz shows the largest post/pre ratio (1.45×) among providers present on both sides of the cutoff. Irina Mihaela Tarnavsky is the second-largest mover (1.35×). Lisa Vo Nguyen and others stayed roughly flat.</p>
</div>

<p class="cgd-p">Among providers with records on both sides of the March 2015 cutoff, the variation is striking. David Michael Diaz moved from a weekly mean of $12,039 to $17,509, a 45 percent increase. Irina Mihaela Tarnavsky rose 35 percent. Trinh Thuy Pham rose 14 percent. Lisa Vo Nguyen, the panel's highest earner by total, barely moved. Allison Lynnae Olex fell 12 percent. Caroline Hu fell 37 percent and left the active panel well before the end of the study period.</p>

<p class="cgd-p">This is not uniform movement across providers. Post-March 2015 gains concentrated in a subset of dentists while others declined or exited. That concentration is consistent with workload or billing intensity being redistributed within the network.</p>

---

<h2 class="cgd-h2">Three Provider Signals: Testing Diaz, Tarnavsky, and Pham</h2>

<p class="cgd-p">Three dentists stand out in the pre/post comparison. David Diaz shows the largest raw increase (45%), but two others moved sharply too: Irina Tarnavsky (35%) and Trinh Thuy Pham (14%). The standard causal test is difference-in-differences: use nine other providers as controls, absorb week-to-week system variation, and measure whether each dentist's trajectory changed relative to peers after March 2015.</p>

<p class="cgd-p">On the ten providers with sufficient pre- and post-period data, the baseline DiD estimates are: <strong>Diaz +$4,757/week</strong> (t = 6.27), <strong>Tarnavsky +$3,811/week</strong> (t = 7.80), <strong>Pham +$1,208/week</strong> (t = 2.73). All three rank positive in placebo rotation. But pretrend diagnostics matter: they reveal whether the increase actually began after the policy date or earlier.</p>

<p class="cgd-p"><strong>Diaz</strong> has a pre-existing differential slope of +$177/week/week (t = 2.15) and a positive falsification cutoff at March 2014 (+$733, t = 2.68). When trend-adjusted, his estimate shrinks to +$1,284 with a confidence interval that crosses zero. Large raw effect, but pre-period acceleration undermines the post-March signal.</p>

<p class="cgd-p"><strong>Tarnavsky</strong> shows a smaller pretrend (+$26/week/week, t = 2.76) and a positive falsification cutoff (+$1,462, t = 2.64). When trend-adjusted, her effect turns negative at −$653 (CI includes zero). Substantial raw effect, but also signs of earlier movement.</p>

<p class="cgd-p"><strong>Pham</strong> shows a flat pretrend (−$12/week/week, t = −1.49)—no significant acceleration before March 2015. His falsification cutoff is negative (−$1,141, t = −2.31), consistent with no shift at the placebo date. When trend-adjusted, his effect grows: +$3,521 (t = 4.63, 95% CI: $1,599–$5,443, excludes zero). The smallest raw effect but the cleanest causal structure.</p>

<div class="cgd-vis-card">
  <div class="cgd-vis-label">PROVIDER PANEL · MONTHLY TRENDS</div>
  <div class="cgd-vis-title">Monthly Average Weekly Payments by Dentist</div>
  <div class="cgd-vis-sub">Monthly average of weekly Denti-Cal payments · eligible providers in DiD panel · Jan 2013 – Sep 2016</div>
  <div class="cgd-vis-legend">
    <span><i style="background:#e07055;"></i> David Michael Diaz</span>
    <span><i style="background:#7db800;"></i> Irina Tarnavsky</span>
    <span><i style="background:#a8c8d8;"></i> Lisa Vo Nguyen</span>
    <span><i style="background:#f5c542;"></i> Trinh Thuy Pham</span>
    <span><i style="background:#8a8c84;"></i> Allison Olex</span>
  </div>
  <div style="position:relative;width:100%;height:360px;">
    <canvas id="cgdMultilineChart"></canvas>
  </div>
  <p class="cgd-vis-note">Diaz and Tarnavsky show sharp upward acceleration mid-2015 onward. Pham's rise is gentler but sustained. Lisa Vo Nguyen and Allison Olex track flat or downward trajectories. The monthly view is essential: Pham, despite a lower raw effect, shows no pre-March acceleration.</p>
</div>

<p class="cgd-p">Diaz enters in late 2013 at $6–$12K/week, reaching $19–$23K by late 2015–2016 (peaks $21.7K and $20.2K in July–Aug 2016). Tarnavsky follows a similar trajectory from a lower base, rising from $11–$13K to $14–$19K post-2015. Pham starts at $11–$13K and rises more gradually to $13–$14K. The key difference: Diaz and Tarnavsky show acceleration beginning in early/mid-2015, while Pham's acceleration begins closer to the March cutoff. Lisa Vo Nguyen, despite $2.4M in total payments, shows no post-2015 step change. Allison Olex trends downward. This timing matters for causal inference.</p>

---

<h2 class="cgd-h2">Robustness: Ranking and Causal Quality</h2>

<p class="cgd-p">Baseline size is not the measure of causal quality. The relevant question is internal validity: does the estimate hold when pre-period trends are accounted for? Placebo rotation ranks all three among the top four providers, but their pretrend profiles diverge sharply.</p>

<div class="cgd-vis-card">
  <div class="cgd-vis-label">PLACEBO ROTATION · PROVIDER PANEL</div>
  <div class="cgd-vis-title">DiD Estimate When Each Provider Is Designated "Treated"</div>
  <div class="cgd-vis-sub">Weekly payment treatment effect · March 2015 cutoff · 10 eligible providers</div>
  <div style="position:relative;width:100%;height:320px;">
    <canvas id="cgdPlaceboBarChart"></canvas>
  </div>
  <p class="cgd-vis-note">Diaz ranks #1 ($4,757/week), Tarnavsky #2 ($3,811), Pham #4 ($1,208). Permutation p = 0.10 one-sided for Diaz. The bottom half of providers show negative effects. Ranking by baseline effect is different from ranking by causal robustness.</p>
</div>

<p class="cgd-p">In baseline DiD ranking: Diaz first ($4,757), Tarnavsky second ($3,811), Pham fourth ($1,208). Permutation p = 0.10. But placebo rank is separate from pretrend quality. Diaz and Tarnavsky both show significant pre-period acceleration. Pham does not. Leave-one-out checks confirm baseline Diaz and Tarnavsky estimates are stable across control subset removals; Pham's smaller magnitude is stable too.</p>

<div class="cgd-vis-card">
  <div class="cgd-vis-label">PROVIDER LEV EL · THREE-PROVIDER CAUSAL COMPARISON</div>
  <div class="cgd-vis-title">Baseline DiD, Pretrend, Falsification, and Trend-Adjusted Estimates</div>
  <div class="cgd-vis-sub">DiD model with 10 eligible providers as controls · March 2015 cutoff</div>
  <div class="cgd-table-wrap">
    <table class="cgd-table">
      <thead>
        <tr>
          <th>Provider</th>
          <th>Baseline DiD</th>
          <th>Pretrend ($/wk/wk)</th>
          <th>Falsification (Mar 2014)</th>
          <th>Trend-Adjusted DiD</th>
          <th>Summary</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><strong>David Diaz</strong></td>
          <td class="hi"><span class="cgd-num">+$4,757 (t=6.27)</span></td>
          <td class="hi"><span class="cgd-num">+$177 (t=2.15)</span></td>
          <td class="hi"><span class="cgd-num">+$733 (t=2.68)</span></td>
          <td><span class="cgd-num">+$1,284 (CI includes 0)</span></td>
          <td>Large baseline; pre-trend undermines</td>
        </tr>
        <tr>
          <td><strong>Irina Tarnavsky</strong></td>
          <td class="hi"><span class="cgd-num">+$3,811 (t=7.80)</span></td>
          <td class="hi"><span class="cgd-num">+$26 (t=2.76)</span></td>
          <td class="hi"><span class="cgd-num">+$1,462 (t=2.64)</span></td>
          <td><span class="cgd-num">−$653 (CI includes 0)</span></td>
          <td>Strong baseline; early acceleration evident</td>
        </tr>
        <tr>
          <td><strong>Trinh Pham</strong></td>
          <td><span class="cgd-num">+$1,208 (t=2.73)</span></td>
          <td><span class="cgd-num">−$12 (t=−1.49)</span></td>
          <td><span class="cgd-num">−$1,141 (t=−2.31)</span></td>
          <td class="hi"><span class="cgd-num">+$3,521 (t=4.63)</span></td>
          <td>Modest baseline; cleanest causal structure</td>
        </tr>
      </tbody>
    </table>
  </div>
  <p class="cgd-vis-note">Pham alone shows a flat pretrend and negative falsification cutoff, consistent with no shift before March 2015. When trend-adjusted, his effect strengthens and excludes zero. Diaz and Tarnavsky both show pre-period acceleration that weakens their causal interpretation when explicitly modeled.</p>
</div>

---

<div class="cgd-vis-card">
  <div class="cgd-vis-label">ROBUSTNESS SUMMARY · STRICTER DIAGNOSTICS</div>
  <div class="cgd-vis-title">How the Main Effects Hold Up Under Harder Specifications</div>
  <div class="cgd-vis-sub">Anaheim office panel vs. Diaz provider panel</div>
  <div class="cgd-table-wrap">
    <table class="cgd-table">
      <thead>
        <tr>
          <th>Check</th>
          <th>Anaheim (Office Panel)</th>
          <th>Diaz (Provider Panel)</th>
          <th>Read</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Baseline TWFE DiD</td>
          <td class="hi"><span class="cgd-num">+$14.49 (t = 4.28)</span></td>
          <td class="hi"><span class="cgd-num">+$4,757 (t = 6.27)</span></td>
          <td>Both positive and statistically strong</td>
        </tr>
        <tr>
          <td>Clustered SE sensitivity</td>
          <td class="hi"><span class="cgd-num">SE $3.23, t = 4.49</span></td>
          <td class="hi"><span class="cgd-num">SE $917, t = 5.19</span></td>
          <td>Inference remains strong under clustering</td>
        </tr>
        <tr>
          <td>Pretrend differential slope</td>
          <td class="hi"><span class="cgd-num">-$0.21/month (t = -0.93)</span></td>
          <td><span class="cgd-num">+$177/week/week (t = 2.15)</span></td>
          <td>Office supports parallel trends; provider does not</td>
        </tr>
        <tr>
          <td>Falsification date (Mar 2014)</td>
          <td><span class="cgd-num">-$4.41 (t = -1.67)</span></td>
          <td><span class="cgd-num">+$733 (t = 2.68)</span></td>
          <td>Provider shows early acceleration before policy date</td>
        </tr>
        <tr>
          <td>Trend-adjusted DiD</td>
          <td class="hi"><span class="cgd-num">+$21.99 (t = 4.02)</span></td>
          <td><span class="cgd-num">+$1,284&nbsp;(SE&nbsp;$1,220;&nbsp;CI includes 0)</span></td>
          <td>Office result survives; provider effect attenuates</td>
        </tr>
      </tbody>
    </table>
  </div>
  <p class="cgd-vis-note">Bottom line: the office-level Anaheim result remains robust across all diagnostics. At provider level, Pham's causal signal is the cleanest: flat pretrend, negative falsification, and a trend-adjusted effect that strengthens and excludes zero. Diaz and Tarnavsky show larger baseline effects but pre-existing acceleration that complicates causal interpretation.</p>
</div>

---

<h2 class="cgd-h2">What the Records Show and What They Don't</h2>

<p class="cgd-p">State records log payments, not procedures, necessity, or patient harm. They show one clear signal: Anaheim's payment intensity rose after March 2015 while peers declined or flat-lined. That divergence holds across synthetic control, two-way fixed-effects DiD, clustered-SE sensitivity, null pretrend tests, and LOO checks. At provider level, Diaz remains the strongest outlier in baseline models and ranks first in placebo rotation, but pretrend diagnostics suggest part of that increase predates March 2015.</p>

<div class="cgd-callout">
  <strong>Summary of main estimates:</strong> Anaheim DiD +$14.49/visit-day (t = 4.28), trend-adjusted +$21.99 (t = 4.02), synthetic post-gap +$18.67. Provider level: Diaz baseline +$4,757 but trend-adjusted +$1,284 (CI includes zero); Tarnavsky baseline +$3,811 but trend-adjusted −$653 (CI includes zero); Pham baseline +$1,208 and trend-adjusted +$3,521 (t = 4.63, excludes zero).
</div>

<p class="cgd-p">Analytical hierarchy: office-level evidence carries strongest causal weight. At provider level, Pham's signal outperforms on internal diagnostics. His effect strengthens under stricter specification, while Diaz and Tarnavsky weaken.</p>

<p class="cgd-p">Discovery turned on procedure-level records, dashboards, patient-level data, and documents. This article uses only state billing records and standard causal methods. Even so, the Anaheim divergence is visible and persistent.</p>

---

<div class="cgd-vis-card">
  <div class="cgd-vis-label">DATA APPENDIX · ALL PROVIDER WEEKLY TOTALS</div>
  <div class="cgd-vis-title">Complete Provider Summary Table</div>
  <div class="cgd-vis-sub">Ranked by total Denti-Cal payments · Jan 2013 – Sep 2016</div>
  <div class="cgd-table-wrap">
    <table class="cgd-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Dentist</th>
          <th>Total Payments</th>
          <th>Avg / Week</th>
          <th>Pre Mean</th>
          <th>Post Mean</th>
          <th>Post/Pre</th>
        </tr>
      </thead>
      <tbody id="cgdProviderTableBody"></tbody>
    </table>
  </div>
  <p class="cgd-vis-note">Post/Pre ratio uses March 2015 as cutoff. Providers with records only on one side show "not available" for the ratio. Providers who left before March 2015 have no post-period data.</p>
</div>

<div class="cgd-footnotes">
  <p><strong>Data source:</strong> California Public Records Act request "Request 1 and 2" (office-month payments and visit days, 10 offices observed, Jan 2013–Sep 2016, 8 with full pre/post coverage) and "Request 6" (weekly NPI-level payments, 25 providers, Jan 2013–Sep 2016). NPI-to-name mapping via NPI Numbers provided by the state.</p>
  <p><strong>Payment per visit day (PPD):</strong> Total Denti-Cal payments divided by patient visit days for the same office-month. Visit days measure the count of days on which at least one patient was seen. It is not a headcount.</p>
  <p><strong>Difference-in-differences:</strong> Two-way fixed-effects OLS with office (or NPI) and calendar-period fixed effects, HC1 heteroskedasticity-robust standard errors. Treatment cutoff is March 2015 (the Gruenbaum transition). Second specification uses January 2016. Cluster-robust standard errors are reported as a sensitivity check (clustered by office or provider).</p>
  <p><strong>Synthetic control:</strong> Non-negative least squares weighting of control offices to minimize pre-period RMSE on the Anaheim PPD series. Pre-RMSE = $9.02. Weights by office: Carson 32.5%, Eagle Rock 18.4%, Sunnyvale 16.0%, Norwalk 14.9%, South Gate 13.5%, Santa Ana 4.7%, San Jose 0%.</p>
  <p><strong>Eligibility for provider DiD panel:</strong> Providers with at least 8 observed pre-treatment weeks and 6 observed post-treatment weeks relative to the March 2015 cutoff. 10 of 25 providers in the panel meet this threshold.</p>
  <p><strong>Placebo rotation:</strong> The DiD model is re-estimated for each of the 10 eligible providers as the designated treated unit. The permutation p-value is the fraction of providers whose |beta| meets or exceeds the Diaz estimate. Two-sided = 0.10, one-sided positive-tail = 0.10.</p>
  <p><strong>Pretrend and falsification diagnostics:</strong> Additional tests include (1) differential pretrend slopes estimated on pre-period data only and (2) a placebo policy date at March 2014. Office-level diagnostics are broadly supportive of a post-2015 divergence. Provider-level diagnostics indicate pre-existing acceleration for Diaz, which attenuates the trend-adjusted treatment estimate.</p>
  <p><strong>Analysis code:</strong> All statistical models, synthetic control, placebo rotations, and chart data are produced by <a href="https://github.com/johntribbia/bouldergearlab/blob/main/scripts/cgd_stat_analysis.py">cgd_stat_analysis.py</a>. No other scripts contribute to the numbers in this article.</p>
  <p><strong>No causal claims about procedures or patient outcomes</strong> are made or implied. Payment intensity is a billing-record measure that does not distinguish procedure type, medical necessity, or clinical outcome.</p>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

const STD_OPTS = {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    x: {
      grid: { color: 'rgba(255,255,255,0.04)' },
      ticks: { font: { family: 'Space Mono, monospace', size: 11 } }
    },
    y: {
      grid: { color: 'rgba(255,255,255,0.04)' },
      ticks: { font: { family: 'Space Mono, monospace', size: 11 } }
    }
  },
  plugins: {
    legend: {
      labels: {
        font: { family: 'Space Mono, monospace', size: 11 },
        color: 'rgba(255,255,255,0.45)',
        boxWidth: 14, padding: 18
      }
    },
    tooltip: {
      backgroundColor: 'rgba(10,13,20,0.96)',
      titleFont: { family: 'Space Mono, monospace', size: 11 },
      bodyFont: { family: 'Space Mono, monospace', size: 11 }
    }
  }
};

// ── 1. Office PPD Pre/Post ────────────────────────────────────────────────────
new Chart(document.getElementById('cgdOfficePPDChart'), {
  type: 'bar',
  data: {
    labels: ['San Jose','South Gate','Santa Ana','Anaheim','Norwalk','Carson','Eagle Rock','Sunnyvale','Baldwin Park†','Whittier†'],
    datasets: [
      {
        label: 'Pre-Mar 2015',
        data: [166.14, 136.23, 157.39, 144.53, 148.46, 140.96, 127.31, 124.11, null, null],
        backgroundColor: 'rgba(168,200,216,0.7)',
        borderRadius: 3
      },
      {
        label: 'Post-Mar 2015',
        data: [146.45, 136.56, 150.13, 153.25, 143.22, 138.22, 130.21, 111.99, 152.53, 136.93],
        backgroundColor: ['rgba(125,184,0,0.55)','rgba(125,184,0,0.55)','rgba(125,184,0,0.55)',
                          'rgba(224,112,85,0.80)','rgba(125,184,0,0.55)','rgba(125,184,0,0.55)',
                          'rgba(125,184,0,0.55)','rgba(125,184,0,0.55)',
                          'rgba(168,200,216,0.45)','rgba(168,200,216,0.45)'],
        borderRadius: 3
      }
    ]
  },
  options: {
    ...STD_OPTS,
    plugins: { ...STD_OPTS.plugins, annotation: undefined },
    scales: {
      ...STD_OPTS.scales,
      y: { ...STD_OPTS.scales.y, title: { display: true, text: '$ per visit day', color: 'rgba(255,255,255,0.3)', font: { family: 'Space Mono, monospace', size: 11 } } }
    }
  }
});

// ── 2. Synthetic Control ──────────────────────────────────────────────────────
const synthLabels = ['2013-01','2013-02','2013-03','2013-04','2013-05','2013-06','2013-07','2013-08','2013-09','2013-10','2013-11','2013-12','2014-01','2014-02','2014-03','2014-04','2014-05','2014-06','2014-07','2014-08','2014-09','2014-10','2014-11','2014-12','2015-01','2015-02','2015-03','2015-04','2015-05','2015-06','2015-07','2015-08','2015-09','2015-10','2015-11','2015-12','2016-01','2016-02','2016-03','2016-04','2016-05','2016-06','2016-07','2016-08','2016-09'];
const anaheimActual = [168.6,159.1,159.0,159.3,172.9,169.4,156.6,154.2,158.4,160.1,137.9,136.5,133.2,131.7,139.3,138.5,144.2,132.1,121.1,128.1,130.2,134.7,134.2,136.5,122.1,136.1,133.7,137.9,144.0,149.0,161.6,152.5,172.5,172.1,161.9,169.9,163.1,168.8,155.9,152.4,159.7,150.8,142.2,141.1,110.2];
const synthActual   = [152.1,158.9,155.9,157.6,156.6,153.6,155.5,144.9,148.2,144.3,128.5,123.1,126.7,134.1,134.5,136.6,135.4,131.0,120.7,122.7,131.5,130.7,127.3,124.6,119.4,122.0,120.5,126.3,131.4,126.3,140.0,133.0,142.0,134.3,137.2,132.2,133.6,133.1,135.9,146.1,141.9,137.8,127.0,131.6,134.5];
const mar2015Idx = synthLabels.indexOf('2015-03');

new Chart(document.getElementById('cgdSynthChart'), {
  type: 'line',
  data: {
    labels: synthLabels,
    datasets: [
      {
        label: 'Anaheim (actual)',
        data: anaheimActual,
        borderColor: '#7db800',
        backgroundColor: 'transparent',
        borderWidth: 2,
        pointRadius: 0
      },
      {
        label: 'Synthetic control',
        data: synthActual,
        borderColor: '#a8c8d8',
        backgroundColor: 'transparent',
        borderWidth: 1.5,
        borderDash: [5,3],
        pointRadius: 0
      }
    ]
  },
  options: {
    ...STD_OPTS,
    scales: {
      x: {
        ...STD_OPTS.scales.x,
        ticks: {
          ...STD_OPTS.scales.x.ticks,
          maxTicksLimit: 12,
          callback: function(val, idx) { return synthLabels[idx].endsWith('-01') ? synthLabels[idx].substring(0,4) : ''; }
        }
      },
      y: { ...STD_OPTS.scales.y, title: { display: true, text: '$ per visit day', color: 'rgba(255,255,255,0.3)', font: { family: 'Space Mono, monospace', size: 11 } } }
    },
    plugins: {
      ...STD_OPTS.plugins,
      annotation: {
        annotations: {
          line1: {
            type: 'line', xMin: mar2015Idx, xMax: mar2015Idx,
            borderColor: 'rgba(255,255,255,0.2)', borderWidth: 1, borderDash: [3,3],
            label: { content: 'Mar 2015', enabled: true, color: 'rgba(255,255,255,0.35)', font: { size: 10, family: 'Space Mono, monospace' } }
          }
        }
      }
    }
  }
});

// ── 3. Office LOO ─────────────────────────────────────────────────────────────
const offLoo = [
  { dropped: 'Eagle Rock', beta: 15.94, low: 9.08, high: 22.80 },
  { dropped: 'South Gate', beta: 15.69, low: 9.02, high: 22.37 },
  { dropped: 'Carson',     beta: 14.98, low: 8.21, high: 21.74 },
  { dropped: 'Norwalk',    beta: 14.71, low: 8.28, high: 21.14 },
  { dropped: 'Santa Ana',  beta: 14.59, low: 7.44, high: 21.73 },
  { dropped: 'Sunnyvale',  beta: 13.37, low: 6.78, high: 19.96 },
  { dropped: 'San Jose',   beta: 12.16, low: 5.93, high: 18.38 }
];
new Chart(document.getElementById('cgdOfficeLooChart'), {
  type: 'bar',
  data: {
    labels: offLoo.map(r => 'Drop ' + r.dropped),
    datasets: [
      {
        label: 'DiD Estimate',
        data: offLoo.map(r => r.beta),
        backgroundColor: 'rgba(125,184,0,0.65)',
        borderRadius: 3
      },
      {
        label: '95% CI lower',
        data: offLoo.map(r => r.low),
        backgroundColor: 'rgba(125,184,0,0.2)',
        borderRadius: 3
      },
      {
        label: '95% CI upper',
        data: offLoo.map(r => r.high),
        backgroundColor: 'rgba(125,184,0,0.2)',
        borderRadius: 3
      }
    ]
  },
  options: {
    ...STD_OPTS,
    scales: {
      ...STD_OPTS.scales,
      y: { ...STD_OPTS.scales.y, title: { display: true, text: '$ per visit day', color: 'rgba(255,255,255,0.3)', font: { family: 'Space Mono, monospace', size: 11 } } }
    }
  }
});

// ── 4. Provider Totals ────────────────────────────────────────────────────────
const provTotals = [
  { name: 'Lisa Vo Nguyen', total: 2400732 },
  { name: 'Irina M. Tarnavsky', total: 2369734 },
  { name: 'Trinh Thuy Pham', total: 2312188 },
  { name: 'Helen Hoi-Yen Ching', total: 2024371 },
  { name: 'Pamela Abraham', total: 1713793 },
  { name: 'Allison Lynnae Olex', total: 1605012 },
  { name: 'David Michael Diaz', total: 1590074 },
  { name: 'Rana Mary Rakow', total: 1471505 },
  { name: 'Caroline Hu', total: 1332211 },
  { name: 'James Kidong Cho', total: 1171284 },
  { name: 'Raheleh Pourtemour', total: 1158475 },
  { name: 'Yazan Mazan Kasey', total: 918626 },
  { name: 'Hisako Seignemartin', total: 867711 },
  { name: 'Maria Helena Lima', total: 674770 },
  { name: 'Elaine Bonnie Lam', total: 597972 }
];
new Chart(document.getElementById('cgdProviderTotalsChart'), {
  type: 'bar',
  data: {
    labels: provTotals.map(r => r.name),
    datasets: [{
      label: 'Total Denti-Cal Payments',
      data: provTotals.map(r => r.total),
      backgroundColor: provTotals.map(r => r.name === 'David Michael Diaz' ? 'rgba(224,112,85,0.8)' : 'rgba(125,184,0,0.55)'),
      borderRadius: 3
    }]
  },
  options: {
    ...STD_OPTS,
    indexAxis: 'y',
    scales: {
      x: { ...STD_OPTS.scales.x, ticks: { ...STD_OPTS.scales.x.ticks, callback: v => '$' + (v/1e6).toFixed(1) + 'M' } },
      y: { ...STD_OPTS.scales.y, ticks: { font: { family: 'Space Mono, monospace', size: 10 } } }
    }
  }
});

// ── 5. Provider Pre/Post ──────────────────────────────────────────────────────
const provPP = [
  { name: 'Lisa Vo Nguyen',        pre: 13285, post: 12909 },
  { name: 'Irina M. Tarnavsky',    pre: 11005, post: 14813 },
  { name: 'Trinh Thuy Pham',       pre: 11561, post: 13131 },
  { name: 'Helen Hoi-Yen Ching',   pre: 13107, post: 12996 },
  { name: 'Pamela Abraham',        pre:  9811, post:  9767 },
  { name: 'Allison Lynnae Olex',   pre:  8827, post:  7815 },
  { name: 'David Michael Diaz',    pre: 12039, post: 17509 },
  { name: 'Rana Mary Rakow',       pre:  7442, post:  8274 },
  { name: 'Caroline Hu',           pre: 13306, post:  8407 },
  { name: 'Yazan Mazan Kasey',     pre:  9766, post: 13034 }
];
new Chart(document.getElementById('cgdPrePostChart'), {
  type: 'bar',
  data: {
    labels: provPP.map(r => r.name),
    datasets: [
      { label: 'Pre mean ($/wk)', data: provPP.map(r => r.pre), backgroundColor: 'rgba(168,200,216,0.7)', borderRadius: 3 },
      { label: 'Post mean ($/wk)', data: provPP.map(r => r.post),
        backgroundColor: provPP.map(r => r.name === 'David Michael Diaz' ? 'rgba(224,112,85,0.85)' : 'rgba(125,184,0,0.65)'),
        borderRadius: 3 }
    ]
  },
  options: {
    ...STD_OPTS,
    indexAxis: 'y',
    scales: {
      x: { ...STD_OPTS.scales.x, ticks: { ...STD_OPTS.scales.x.ticks, callback: v => '$' + (v/1000).toFixed(0) + 'k' } },
      y: { ...STD_OPTS.scales.y, ticks: { font: { family: 'Space Mono, monospace', size: 10 } } }
    }
  }
});

// ── 6. Multi-line monthly trend ───────────────────────────────────────────────
const mlMonths = ['2013-01','2013-02','2013-03','2013-04','2013-05','2013-06','2013-07','2013-08','2013-09','2013-10','2013-11','2013-12','2014-01','2014-02','2014-03','2014-04','2014-05','2014-06','2014-07','2014-08','2014-09','2014-10','2014-11','2014-12','2015-01','2015-02','2015-03','2015-04','2015-05','2015-06','2015-07','2015-08','2015-09','2015-10','2015-11','2015-12','2016-01','2016-02','2016-03','2016-04','2016-05','2016-06','2016-07','2016-08','2016-09'];
const mlDiaz    = [null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,6036,11969,12613,8713,14043,13714,16398,15060,13700,14703,16684,17861,16331,15274,16822,13951,17654,21698,20185,23133,21149,19365,19744,16235,14657];
const mlTarn    = [12037,8104,9742,15019,10686,10127,10372,11925,8266,8602,10915,9122,10300,13244,11812,11094,12251,8897,13026,12506,10558,12032,9991,10424,12633,11406,8848,12904,10438,12793,14057,13929,12683,15746,15582,12391,15806,14152,15860,17359,18128,18483,19044,19093,10644];
const mlLisa    = [13930,15480,15525,15676,15462,16255,16917,14960,15149,12216,13641,12107,8226,108,null,12632,12937,13715,12470,13313,12721,11928,11141,11097,10112,11430,12209,9842,11046,13015,12634,13992,11176,12406,12822,13425,12088,13610,13368,15000,14596,13107,14275,14246,11808];
const mlTrinh   = [11017,12093,13861,11732,14090,13772,15462,11437,9220,13097,9658,10321,12509,11473,12549,10279,9824,10146,10121,11526,11769,9514,9931,9637,11470,12347,16446,13454,10684,12137,12851,15790,14382,15196,12191,12277,14885,15441,15641,13225,14402,14945,10156,7931,5178];
const mlOlex    = [9011,9755,11118,11182,12006,10561,9571,11852,9530,10429,7467,10824,7458,7645,8697,7582,9294,9203,9131,6652,4600,6816,6756,7273,6385,6761,6428,9444,7157,6746,6159,7556,7450,10127,5008,6184,5987,7768,10282,9530,9555,8045,9031,9078,5706];
const mar2015ML = mlMonths.indexOf('2015-03');

new Chart(document.getElementById('cgdMultilineChart'), {
  type: 'line',
  data: {
    labels: mlMonths,
    datasets: [
      { label: 'David Michael Diaz', data: mlDiaz, borderColor: '#e07055', backgroundColor: 'transparent', borderWidth: 2.5, pointRadius: 0, spanGaps: false },
      { label: 'Irina Tarnavsky', data: mlTarn, borderColor: '#7db800', backgroundColor: 'transparent', borderWidth: 1.5, pointRadius: 0 },
      { label: 'Lisa Vo Nguyen', data: mlLisa, borderColor: '#a8c8d8', backgroundColor: 'transparent', borderWidth: 1.5, pointRadius: 0, spanGaps: false },
      { label: 'Trinh Thuy Pham', data: mlTrinh, borderColor: '#f5c542', backgroundColor: 'transparent', borderWidth: 1.5, pointRadius: 0 },
      { label: 'Allison Olex', data: mlOlex, borderColor: '#8a8c84', backgroundColor: 'transparent', borderWidth: 1, pointRadius: 0, borderDash: [3,3] }
    ]
  },
  options: {
    ...STD_OPTS,
    scales: {
      x: {
        ...STD_OPTS.scales.x,
        ticks: { ...STD_OPTS.scales.x.ticks, maxTicksLimit: 10,
          callback: function(val, idx) { return mlMonths[idx] && mlMonths[idx].endsWith('-01') ? mlMonths[idx].substring(0,4) : ''; }
        }
      },
      y: { ...STD_OPTS.scales.y, ticks: { ...STD_OPTS.scales.y.ticks, callback: v => '$' + (v/1000).toFixed(0) + 'k' } }
    }
  }
});

// ── 7. Provider Placebo Bar ───────────────────────────────────────────────────
const placeboBetas = [
  { dentist: 'David Diaz',       beta: 4757 },
  { dentist: 'Irina Tarnavsky',  beta: 3811 },
  { dentist: 'Yazan Kasey',      beta: 2646 },
  { dentist: 'Trinh Thuy Pham',  beta: 1208 },
  { dentist: 'Rana Rakow',       beta:  389 },
  { dentist: 'Pamela Abraham',   beta: -716 },
  { dentist: 'Helen Ching',      beta: -921 },
  { dentist: 'Lisa Vo Nguyen',   beta: -1042 },
  { dentist: 'Allison Olex',     beta: -1735 },
  { dentist: 'Caroline Hu',      beta: -6086 }
];
new Chart(document.getElementById('cgdPlaceboBarChart'), {
  type: 'bar',
  data: {
    labels: placeboBetas.map(r => r.dentist),
    datasets: [{
      label: 'Placebo DiD beta ($/wk)',
      data: placeboBetas.map(r => r.beta),
      backgroundColor: placeboBetas.map(r => r.dentist === 'David Diaz' ? 'rgba(224,112,85,0.85)' : (r.beta > 0 ? 'rgba(125,184,0,0.45)' : 'rgba(138,140,132,0.45)')),
      borderRadius: 3
    }]
  },
  options: {
    ...STD_OPTS,
    scales: {
      ...STD_OPTS.scales,
      y: { ...STD_OPTS.scales.y, ticks: { ...STD_OPTS.scales.y.ticks, callback: v => '$' + (v/1000).toFixed(0) + 'k' } }
    }
  }
});

// ── 8. Provider LOO ───────────────────────────────────────────────────────────
const provLoo = [
  { dropped: 'Tarnavsky',  beta: 5139, low: 3618, high: 6660 },
  { dropped: 'Trinh Pham', beta: 4993, low: 3471, high: 6516 },
  { dropped: 'Kasey',      beta: 4937, low: 3430, high: 6445 },
  { dropped: 'Lisa Nguyen',beta: 4878, low: 3376, high: 6380 },
  { dropped: 'Rana Rakow', beta: 4835, low: 3298, high: 6372 },
  { dropped: 'Olex',       beta: 4792, low: 3277, high: 6307 },
  { dropped: 'Abraham',    beta: 4689, low: 3211, high: 6167 },
  { dropped: 'Helen Ching',beta: 4493, low: 3024, high: 5962 },
  { dropped: 'Caroline Hu',beta: 4032, low: 2573, high: 5491 }
];
new Chart(document.getElementById('cgdProviderLooChart'), {
  type: 'bar',
  data: {
    labels: provLoo.map(r => 'Drop ' + r.dropped),
    datasets: [
      { label: 'DiD Estimate', data: provLoo.map(r => r.beta), backgroundColor: 'rgba(224,112,85,0.7)', borderRadius: 3 },
      { label: 'CI Low',       data: provLoo.map(r => r.low),  backgroundColor: 'rgba(224,112,85,0.25)', borderRadius: 3 },
      { label: 'CI High',      data: provLoo.map(r => r.high), backgroundColor: 'rgba(224,112,85,0.25)', borderRadius: 3 }
    ]
  },
  options: {
    ...STD_OPTS,
    scales: {
      ...STD_OPTS.scales,
      y: { ...STD_OPTS.scales.y, ticks: { ...STD_OPTS.scales.y.ticks, callback: v => '$' + (v/1000).toFixed(0) + 'k' } }
    }
  }
});

// ── Provider Data Table ───────────────────────────────────────────────────────
const tableData = [
  { dentist: 'Lisa Vo Nguyen',          total: 2400732, avg: 13119, pre: 13285, post: 12909, ratio: 0.972 },
  { dentist: 'Irina Mihaela Tarnavsky', total: 2369734, avg: 12222, pre: 11005, post: 14813, ratio: 1.346 },
  { dentist: 'Trinh Thuy Pham',         total: 2312188, avg: 12012, pre: 11561, post: 13131, ratio: 1.136 },
  { dentist: 'Helen Hoi-Yen Ching',     total: 2024371, avg: 10695, pre: 13107, post: 12996, ratio: 0.992 },
  { dentist: 'Pamela Abraham',          total: 1713793, avg:  9042, pre:  9811, post:  9767, ratio: 0.996 },
  { dentist: 'Allison Lynnae Olex',     total: 1605012, avg:  8279, pre:  8827, post:  7815, ratio: 0.885 },
  { dentist: 'David Michael Diaz',      total: 1590074, avg: 16225, pre: 12039, post: 17509, ratio: 1.454 },
  { dentist: 'Rana Mary Rakow',         total: 1471505, avg:  7781, pre:  7442, post:  8274, ratio: 1.112 },
  { dentist: 'Caroline Hu',             total: 1332211, avg:  9172, pre: 13306, post:  8407, ratio: 0.632 },
  { dentist: 'James Kidong Cho',        total: 1171284, avg: 15016, pre: 15016, post:   null, ratio: null },
  { dentist: 'Raheleh Pourtemour',      total: 1158475, avg: 12067, pre: 12067, post:   null, ratio: null },
  { dentist: 'Yazan Mazan Kasey',       total:  918626, avg: 11483, pre:  9766, post: 13034, ratio: 1.335 },
  { dentist: 'Hisako Seignemartin',     total:  867711, avg: 11569, pre: 11569, post:   null, ratio: null },
  { dentist: 'Maria Helena Lima',       total:  674770, avg: 11246, pre: 11246, post:   null, ratio: null },
  { dentist: 'Elaine Bonnie Lam',       total:  597972, avg: 14237, pre:   null, post: 14237, ratio: null }
];

const fmt = (n, prefix='$') => n != null ? prefix + n.toLocaleString('en-US', {maximumFractionDigits: 0}) : 'N/A';
const fmtR = r => r != null ? r.toFixed(2) + '×' : 'N/A';
const ratioClass = r => r == null ? '' : r >= 1.3 ? ' class="hi"' : r < 0.9 ? ' class="lo"' : '';

const tbody = document.getElementById('cgdProviderTableBody');
tableData.forEach((r, i) => {
  tbody.insertAdjacentHTML('beforeend', `<tr>
    <td>${i+1}</td>
    <td>${r.dentist}</td>
    <td>${fmt(r.total)}</td>
    <td>${fmt(r.avg)}</td>
    <td>${r.pre != null ? fmt(r.pre) : 'N/A'}</td>
    <td>${r.post != null ? fmt(r.post) : 'N/A'}</td>
    <td${ratioClass(r.ratio)}>${fmtR(r.ratio)}</td>
  </tr>`);
});
</script>
