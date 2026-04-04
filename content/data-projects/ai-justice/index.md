---
title: "The Double Burden: How is AI Repeating the Oldest Story in Environmental Justice?"
date: 2026-03-27
tags: ['data project']
categories: ['data project']
description: "Global AI usage is becoming more concentrated, not less. The top twenty countries account for 48% of all per-capita AI usage, and the physical cost of that infrastructure falls on communities that rarely benefit from it."
draft: false
banner: "aj-banner.svg"
---
<!--more-->

<style>
/* ── AI Justice Article — BGL Dark Theme ── */

.aj-lede {
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

.aj-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.aj-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }

.aj-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.aj-hr {
  border: none;
  border-top: 1px solid rgba(255,255,255,0.08);
  margin: 3rem 0;
}

/* ── Visualization cards ── */
.aj-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.aj-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.aj-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.aj-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.aj-vis-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 22px;
  margin-bottom: 14px;
  font-size: 1.25rem;
  color: rgba(255,255,255,0.55);
  font-family: var(--f-mono);
}
.aj-vis-legend span { display: flex; align-items: center; gap: 8px; }
.aj-vis-legend i { display: inline-block; width: 26px; height: 3px; border-radius: 2px; flex-shrink: 0; }
.aj-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}

/* ── Callout / highlight box ── */
.aj-callout {
  margin: 2.2rem 0;
  padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic;
  font-size: 1.5rem;
  color: rgba(255,255,255,0.55);
  line-height: 1.8;
}
.aj-callout.red   { border-color: #e07055; background: rgba(224,112,85,0.05); }
.aj-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

/* ── Data table ── */
.aj-table-wrap {
  overflow-x: auto;
  margin: 26px 0;
  border-radius: 4px;
  border: 1px solid rgba(255,255,255,0.07);
}
.aj-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.aj-table thead tr { background: rgba(255,255,255,0.06); }
.aj-table thead th {
  padding: 12px 16px;
  text-align: left;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.7);
}
.aj-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.aj-table tbody td {
  padding: 11px 16px;
  border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono);
  color: rgba(255,255,255,0.5);
  font-size: 1.25rem;
  line-height: 1.6;
}
.aj-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }
.aj-table-caption {
  font-family: var(--f-mono);
  font-size: 1.1rem;
  color: rgba(255,255,255,0.28);
  letter-spacing: 0.06em;
  text-transform: uppercase;
  margin-bottom: 0.5rem;
}

/* ── Footer note ── */
.aj-footnotes {
  margin-top: 52px;
  border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  line-height: 1.65;
}
</style>

<div class="aj-lede">
  Analysis based on the Anthropic Economic Index (March 2026) and Environmental Justice literature.
</div>

*Article by John Tribbia*

The **Anthropic Economic Index** for March 2026 contains a number that deserves more attention than it has received: 49% of jobs have now seen at least a quarter of their tasks performed using Claude. Breadth is not the same as equity, and the same report documents a pattern that should concern anyone familiar with how industrial booms distribute their costs.

Within the United States, AI usage is converging. States that started behind are catching up. At the country level, the Gini coefficient (a measure where 0 is perfect equality and 1 is total concentration) moved the other direction. The top 20 countries went from 45% to 48% of global per-capita AI usage between November 2025 and February 2026. Raw percentages understate what is happening: the gap is widening in direction, not just in magnitude, and the report documents a learning curve finding that makes it self-reinforcing.

Meanwhile, the physical infrastructure of AI is moving out of saturated tech hubs and into communities that rarely appear in the charts measuring who benefits. Data centers follow cheap land, cheap power, and limited regulatory capacity. Scholars in environmental justice research have a name for communities that absorb disproportionate industrial burden so that others can access cheap energy or cheap goods. They call them **sacrifice zones**.

---

<h2 class="aj-h2">Two Curves, Two Directions</h2>

<p class="aj-p">The Gini coefficient for AI usage across US states has been falling since August 2025. The top five states went from 30% of domestic per-capita usage to 24%. Within a shared infrastructure, labor market, and regulatory environment, the technology is spreading. The Gini coefficient for countries moved the other way. The top 20 countries' share of global per-capita usage went from 45% to 48%.</p>

<div class="aj-vis-card">
  <div class="aj-vis-label">Anthropic Economic Index · Aug 2025 to Feb 2026</div>
  <div class="aj-vis-title">Same period. Converging within the US. Diverging across countries.</div>
  <div class="aj-vis-sub">Share of per-capita usage held by top geography · US states (top 5) and countries (top 20)</div>
  <div class="aj-vis-legend">
    <span><i style="background:#7db800;"></i> Aug 2025</span>
    <span><i style="background:#a8c8d8;"></i> Feb 2026</span>
  </div>
  <div style="position: relative; width: 100%; height: 300px;">
    <canvas id="concentrationChart"></canvas>
  </div>
  <p class="aj-vis-note">Source: Anthropic Economic Index, March 2026. Within the US, the adoption gap shrank. Globally, it grew. Both trends continued from the previous report, but the US convergence is decelerating. The report now projects 5 to 9 years to reach roughly equal per-capita usage across states, up from the 2 to 5 year estimate in the previous report.</p>
</div>

<p class="aj-p">This is not mainly a bandwidth or language problem. Using AI at work requires an employer who has built it into workflows, a job structured around knowledge work, and enough time on the platform to develop fluency. That last part matters more than the report's headline findings suggest.</p>

<p class="aj-p">The March 2026 report documents that users who have been on Claude for six months or more have a 10% higher success rate in their conversations, independent of country, task type, or other factors. They also do more work-related tasks and fewer personal ones. The most plausible explanation is learning-by-doing: experienced users have developed habits that make them better at the tool. The implication is that the three-point global concentration shift understates the real dynamic. The advantage of early adoption compounds. Those already ahead get more benefit from the same capability improvement than those just arriving.</p>

---

<h2 class="aj-h2">Sacrifice Zones</h2>

<p class="aj-p">Valerie Kuletz used the term sacrifice zone in 1998 to describe communities downwind of nuclear test ranges in the American West: places whose land, water, and health were treated as expendable in service of national priorities. Robert Bullard applied similar logic to industrial facility siting in <em>Dumping in Dixie</em> (1990), documenting that hazardous waste sites, petrochemical plants, and incinerators were not randomly distributed across the American South. They followed race and income. Facilities went where political resistance was lowest, and political resistance was lowest in communities with less money, less legal infrastructure, and less connection to the people making zoning decisions.</p>

<p class="aj-p">Northern Virginia and Phoenix have the legal staff, environmental consultants, and political relationships to make data center siting uncomfortable. County commissioners in rural Mississippi and rural Wyoming get a familiar pitch instead: jobs, tax base, economic development. It rarely leads with how much the facility will draw from the local water table, or what happens to residential electricity rates when demand spikes.</p>

<p class="aj-p">A 100-megawatt data center uses as much electricity as roughly 100,000 homes. When local grid infrastructure cannot absorb that demand, upgrade costs get spread to residential ratepayers rather than to the hyperscaler that created them.</p>

<div class="aj-vis-card">
  <div class="aj-vis-label">Conceptual · Resource Flow</div>
  <div class="aj-vis-title">What enters the host community vs. what leaves it</div>
  <div class="aj-vis-sub">The sacrifice zone structure in three nodes</div>
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 200" style="width:100%;max-width:700px;display:block;margin:12px 0;">
    <defs>
      <marker id="sfz-arr-red" markerWidth="7" markerHeight="7" refX="6" refY="3.5" orient="auto">
        <path d="M0,0 L7,3.5 L0,7 Z" fill="rgba(224,112,85,0.65)"/>
      </marker>
      <marker id="sfz-arr-ice" markerWidth="7" markerHeight="7" refX="6" refY="3.5" orient="auto">
        <path d="M0,0 L7,3.5 L0,7 Z" fill="rgba(168,200,216,0.6)"/>
      </marker>
      <marker id="sfz-arr-pale" markerWidth="7" markerHeight="7" refX="6" refY="3.5" orient="auto">
        <path d="M0,0 L7,3.5 L0,7 Z" fill="rgba(224,112,85,0.4)"/>
      </marker>
    </defs>
    <!-- HOST COMMUNITY box -->
    <rect x="12" y="28" width="148" height="120" rx="4" fill="rgba(224,112,85,0.07)" stroke="rgba(224,112,85,0.28)" stroke-width="1"/>
    <text x="86" y="50" text-anchor="middle" font-family="'Space Mono',monospace" font-size="9.5" fill="rgba(255,255,255,0.65)" font-weight="700" letter-spacing="0.08em">HOST COMMUNITY</text>
    <text x="86" y="70" text-anchor="middle" font-family="'Space Mono',monospace" font-size="8.5" fill="rgba(224,112,85,0.75)">grid electricity</text>
    <text x="86" y="86" text-anchor="middle" font-family="'Space Mono',monospace" font-size="8.5" fill="rgba(224,112,85,0.75)">fresh water</text>
    <text x="86" y="102" text-anchor="middle" font-family="'Space Mono',monospace" font-size="8.5" fill="rgba(224,112,85,0.75)">land</text>
    <line x1="30" y1="114" x2="142" y2="114" stroke="rgba(255,255,255,0.06)" stroke-width="0.8"/>
    <text x="86" y="128" text-anchor="middle" font-family="'Space Mono',monospace" font-size="7.5" fill="rgba(255,255,255,0.22)">costs remain here</text>
    <text x="86" y="141" text-anchor="middle" font-family="'Space Mono',monospace" font-size="7.5" fill="rgba(255,255,255,0.22)">after facility is built</text>
    <!-- DATA CENTER box -->
    <rect x="276" y="56" width="148" height="72" rx="4" fill="rgba(255,255,255,0.035)" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
    <text x="350" y="90" text-anchor="middle" font-family="'Space Mono',monospace" font-size="11" fill="rgba(255,255,255,0.78)" font-weight="700" letter-spacing="0.07em">DATA CENTER</text>
    <text x="350" y="108" text-anchor="middle" font-family="'Space Mono',monospace" font-size="8" fill="rgba(255,255,255,0.28)">100MW+ facility</text>
    <!-- GLOBAL AI USERS box -->
    <rect x="540" y="28" width="148" height="120" rx="4" fill="rgba(168,200,216,0.05)" stroke="rgba(168,200,216,0.22)" stroke-width="1"/>
    <text x="614" y="50" text-anchor="middle" font-family="'Space Mono',monospace" font-size="9.5" fill="rgba(255,255,255,0.65)" font-weight="700" letter-spacing="0.06em">GLOBAL AI USERS</text>
    <text x="614" y="70" text-anchor="middle" font-family="'Space Mono',monospace" font-size="8.5" fill="rgba(168,200,216,0.65)">top 20 countries</text>
    <text x="614" y="86" text-anchor="middle" font-family="'Space Mono',monospace" font-size="8.5" fill="rgba(168,200,216,0.65)">48% of global usage</text>
    <line x1="558" y1="100" x2="678" y2="100" stroke="rgba(255,255,255,0.06)" stroke-width="0.8"/>
    <text x="614" y="115" text-anchor="middle" font-family="'Space Mono',monospace" font-size="7.5" fill="rgba(255,255,255,0.22)">benefits concentrated</text>
    <text x="614" y="128" text-anchor="middle" font-family="'Space Mono',monospace" font-size="7.5" fill="rgba(255,255,255,0.22)">in distant markets</text>
    <!-- Resource arrows: left → center -->
    <line x1="162" y1="70" x2="270" y2="82" stroke="rgba(224,112,85,0.55)" stroke-width="1.5" marker-end="url(#sfz-arr-red)"/>
    <line x1="162" y1="86" x2="270" y2="92" stroke="rgba(224,112,85,0.55)" stroke-width="1.5" marker-end="url(#sfz-arr-red)"/>
    <line x1="162" y1="102" x2="270" y2="102" stroke="rgba(224,112,85,0.55)" stroke-width="1.5" marker-end="url(#sfz-arr-red)"/>
    <!-- AI services arrow: center → right (dashed) -->
    <line x1="426" y1="90" x2="534" y2="80" stroke="rgba(168,200,216,0.5)" stroke-width="1.8" stroke-dasharray="5,3" marker-end="url(#sfz-arr-ice)"/>
    <text x="480" y="72" text-anchor="middle" font-family="'Space Mono',monospace" font-size="7.5" fill="rgba(168,200,216,0.38)">AI services</text>
    <!-- Cost feedback arc: center → left (below) -->
    <path d="M 276 132 C 238 152 195 155 162 140" stroke="rgba(224,112,85,0.35)" stroke-width="1.2" stroke-dasharray="4,4" fill="none" marker-end="url(#sfz-arr-pale)"/>
    <text x="218" y="166" text-anchor="middle" font-family="'Space Mono',monospace" font-size="7.5" fill="rgba(224,112,85,0.3)">rate increases · water depletion</text>
  </svg>
  <p class="aj-vis-note">Resources flow from the host community into the facility. AI services flow outward to a concentrated global user base. The infrastructure costs — grid strain, water table drawdown, rate increases — stay local.</p>
</div>

---

<h2 class="aj-h2">The Physical Cost</h2>

<p class="aj-p">A 100MW hyperscale facility running near capacity draws roughly 876,000 megawatt-hours of electricity per year. Reported water use at large U.S. data centers has already reached the mid-hundreds of millions of gallons annually: Google used 355.1 million gallons in The Dalles in 2021, and Microsoft's facility near Des Moines used nearly 360 million gallons in 2022. Hyperscale campuses commonly span a few hundred acres, often on agricultural or previously undeveloped land. In water-stressed counties, that demand can collide with irrigation and other local water needs. During GPT-4's development, Microsoft's Iowa operations used water at a rate that worked out to roughly an Olympic swimming pool every couple of days.</p>

<div class="aj-table-wrap">
  <div class="aj-table-caption">Table 1 · Estimated Annual Impact per 100MW Facility</div>
  <table class="aj-table">
    <thead>
      <tr><th>Resource</th><th>Annual Consumption</th><th>Community Equivalent</th></tr>
    </thead>
    <tbody>
      <tr><td>Electricity</td><td>~876,000 MWh</td><td>Power for ~75,000 households</td></tr>
      <tr><td>Fresh Water</td><td>355M+ gallons</td><td>Hundreds of millions of gallons for cooling</td></tr>
      <tr><td>Land Use</td><td>200 – 500 acres</td><td>Often converted from farmland or open land</td></tr>
    </tbody>
  </table>
</div>

---

<h2 class="aj-h2">Procedural Justice</h2>

<p class="aj-p">Bullard's framework for environmental justice distinguishes between distributive questions (who bears costs, who gets benefits) and procedural ones (who gets a seat at the table when decisions are made). Most public attention to data center siting focuses on distributive outcomes after a facility is announced. By then, the procedural question has been answered.</p>

<p class="aj-p">Rural planning boards typically do not have hydrology staff or environmental impact modeling capacity. When a developer representing a hyperscaler walks in with a 200-page feasibility study, the asymmetry is not between competing arguments but between technical capacity and its absence.</p>

<p class="aj-p">The March 2026 report distinguishes between augmentation, where AI makes a worker more productive, and automation, where AI takes over what the worker does. Augmentation rose slightly in Claude.ai traffic. Automation patterns in the API grew: sales workflows, market monitoring, customer service. These are administrative and service roles distributed throughout the economy, not concentrated in global tech hubs, and they exist in the same communities absorbing data center infrastructure.</p>

<p class="aj-p">Augmentation is not a stable position. The same report documents coding tasks migrating from Claude.ai, where a human collaborates, into API workflows, where the human is further removed. That migration happened over three months. Goldman Sachs estimated in 2023 that 300 million jobs globally were exposed to AI-driven automation. The IMF put the share of jobs at high risk at 40% for advanced economies. The knowledge workers currently being augmented are not exempt from that trajectory. They are further back on it. Augmentation is often how displacement starts: the tool handles the routine portions of a job, the job title persists, and then one day the remaining portions are not enough to justify the role.</p>

<div class="aj-callout red">
  <strong>The overlap:</strong> Communities hosting this infrastructure are among those most exposed to the automation of the administrative and service work that employs them locally. They are being asked to give up water and grid capacity for facilities that may eventually displace the jobs their residents hold.
</div>

---

<h2 class="aj-h2">The Aggregate Pattern</h2>

<p class="aj-p">The AI industry is, structurally, an infrastructure-intensive industry. Infrastructure-intensive industries have a track record in the American context that Bullard documented three decades ago: physical burden migrates toward communities with less capacity to set terms. The migration is not typically the result of deliberate malice. It results from developers following rational incentives (cheap land, limited organized resistance, local officials looking for tax revenue) and from communities lacking the legal and technical staff to slow the intake down long enough to change the terms.</p>

<p class="aj-p">The convergence finding within the US is genuinely significant. It suggests the access side of the ledger can improve over time within a shared institutional environment. The infrastructure side has not historically tracked the adoption side. The regions that absorbed coal infrastructure did not proportionally absorb coal wealth. The communities that absorbed petrochemical infrastructure absorbed the contamination at rates disconnected from their share of the economic benefit. The pattern is consistent enough that the burden of proof runs the other way: what is different this time that would produce a different result.</p>

<p class="aj-p">Bullard's core finding in 1990 was not that environmental injustice was intentional. Most individual siting decisions were made by people following incentives, and the pattern came out of the aggregate. The same structure appears in data center siting decisions being made now, across dozens of communities, each evaluated separately, each following the same incentive gradient. What the March 2026 report begins to make legible is that the communities absorbing this infrastructure and the communities benefiting most from what the infrastructure produces are not, predominantly, the same places.</p>

<div class="aj-footnotes">
  Analysis based on the <a href="https://www.anthropic.com/research/economic-index-march-2026-report" target="_blank" rel="noopener">Anthropic Economic Index, March 2026</a>. The 100MW scale reference comes from the International Energy Agency's <em>Energy and AI</em> analysis; the annual electricity figure is the implied load at continuous operation. Water-use figures draw on disclosed reporting for Google's The Dalles data center and Microsoft's Iowa operations, along with Brookings reporting on high-end daily water demand at large data centers. Land-use estimates draw on TechTarget reporting on hyperscale campus size and market reporting on large data center land transactions. Water-stress and irrigation conflicts draw on the Lincoln Institute of Land Policy and local reporting from Arizona, Oregon, and Aragon, Spain. The AI training water-use comparison draws on Associated Press reporting about Microsoft's Iowa facilities during GPT-4 development and the water-footprint research led by Shaolei Ren at UC Riverside. Environmental justice framework draws on Robert Bullard, <em>Dumping in Dixie</em> (1990); Valerie Kuletz, <em>The Tainted Desert</em> (1998). Automation exposure estimates from Goldman Sachs Global Investment Research, "The Potentially Large Effects of Artificial Intelligence on Economic Growth" (2023); IMF, <em>World Economic Outlook</em> (April 2024).
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

/* ── CHART: US convergence vs. country divergence (both from reported figures) ── */
new Chart(document.getElementById('concentrationChart'), {
  type: 'bar',
  data: {
    labels: ['Top 5 US states', 'Top 20 countries'],
    datasets: [
      {
        label: 'Aug 2025',
        data: [30, 45],
        backgroundColor: 'rgba(125,184,0,0.65)',
        borderColor: '#7db800',
        borderWidth: 1.5,
        borderRadius: 3
      },
      {
        label: 'Feb 2026',
        data: [24, 48],
        backgroundColor: 'rgba(168,200,216,0.65)',
        borderColor: '#a8c8d8',
        borderWidth: 1.5,
        borderRadius: 3
      }
    ]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: {
        grid: { color: 'rgba(255,255,255,0.04)' },
        ticks: { font: { family: 'Space Mono, monospace', size: 12 } }
      },
      y: {
        max: 60,
        grid: { color: 'rgba(255,255,255,0.04)' },
        ticks: {
          font: { family: 'Space Mono, monospace', size: 11 },
          callback: val => val + '%'
        }
      }
    },
    plugins: {
      legend: {
        display: true,
        labels: {
          font: { family: 'Space Mono, monospace', size: 11 },
          color: 'rgba(255,255,255,0.45)',
          boxWidth: 14,
          padding: 18
        }
      },
      tooltip: {
        backgroundColor: 'rgba(10,13,20,0.96)',
        titleFont: { family: 'Space Mono, monospace', size: 11 },
        bodyFont: { family: 'Space Mono, monospace', size: 11 },
        callbacks: {
          label: ctx => ' ' + ctx.dataset.label + ': ' + ctx.parsed.y + '% of per-capita usage'
        }
      }
    }
  }
});
</script>