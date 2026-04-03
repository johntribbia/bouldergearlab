---
title: "The Double Burden: How AI Infrastructure Repeats an Old Pattern"
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

*Analysis based on the Anthropic Economic Index (March 2026) and Environmental Justice literature.*

*Article by John Tribbia*

---

The **Anthropic Economic Index** for March 2026 includes a finding that hasn't gotten much traction in the coverage of it: 49% of jobs have now seen at least a quarter of their tasks performed using Claude. Breadth is not the same as equity. The same report documents a pattern familiar from every major industrial boom before it: costs and benefits don't settle in the same places.

---

## Two Curves, Two Directions

Within the United States, AI usage is converging. States that started behind are catching up. The top five states went from 30% of domestic per-capita usage to 24% between August 2025 and February 2026. At the country level, the Gini coefficient moved the other direction. The top 20 countries went from 45% to 48% of global per-capita AI usage over the same period.

Same period. Converging within the US. Diverging across countries.

This is not mainly a bandwidth or language problem. Using AI at work requires an employer who has built it into workflows, a job structured around knowledge work, and enough time on the platform to develop fluency. That last part matters more than the headline convergence numbers suggest.

The March 2026 report documents that users who have been on Claude for six months or more have a 10% higher conversation success rate, independent of country, task type, or other factors. They also do more work-related tasks and fewer personal ones. The most plausible explanation is learning-by-doing: experienced users have developed habits that make them better at the tool. The three-point global concentration shift understates the real dynamic. The advantage of early adoption compounds. Those already ahead get more from each capability improvement than those just arriving.

The US convergence finding is also decelerating. The report now projects 5 to 9 years to reach roughly equal per-capita usage across states, up from the 2 to 5 year estimate in the previous report.

---

## Sacrifice Zones

Valerie Kuletz used the term sacrifice zone in 1998 to describe communities downwind of nuclear test ranges in the American West: places whose land, water, and health were treated as expendable in service of national priorities. Robert Bullard applied similar logic to industrial facility siting in *Dumping in Dixie* (1990), documenting that hazardous waste sites, petrochemical plants, and incinerators were not randomly distributed across the American South. They followed race and income. Facilities went where political resistance was lowest, and political resistance was lowest in communities with less money, less legal infrastructure, and less connection to the people making zoning decisions.

Northern Virginia and Phoenix have the legal staff, environmental consultants, and political relationships to make data center siting uncomfortable. County commissioners in rural Mississippi and rural Wyoming get a familiar pitch: jobs, tax base, economic development. The pitch rarely leads with how much the facility will draw from the local water table, or what happens to residential electricity rates when demand spikes.

A 100-megawatt data center uses as much electricity as roughly 100,000 homes. When local grid infrastructure cannot absorb that demand, upgrade costs get spread to residential ratepayers rather than to the hyperscaler that created them.

---

## The Physical Cost

A 100MW hyperscale facility running near capacity draws roughly 876,000 megawatt-hours of electricity per year. Reported water use at large U.S. data centers has already reached the mid-hundreds of millions of gallons annually: Google used 355.1 million gallons in The Dalles in 2021, and Microsoft's facility near Des Moines used nearly 360 million gallons in 2022. Hyperscale campuses commonly span a few hundred acres, often on agricultural or previously undeveloped land. In water-stressed counties, that demand collides with irrigation and other local water needs.

**Table 1: Estimated Annual Impact per 100MW Facility**

| Resource | Annual Consumption | Community Equivalent |
|---|---|---|
| Electricity | ~876,000 MWh | Power for ~75,000 households |
| Fresh Water | 355M+ gallons | Scale of reported use at Google The Dalles, Microsoft Iowa |
| Land Use | 200-500 acres | Often converted from farmland or open land |

Electricity, water, and land flow into the facility from the host community. AI services flow outward to a user base concentrated somewhere else. The costs — grid strain, water table drawdown, rate increases — stay local.

---

## Procedural Justice

Bullard's framework distinguishes between distributive questions (who bears costs, who gets benefits) and procedural ones (who gets a seat at the table when decisions are made). Most public attention to data center siting focuses on distributive outcomes after a facility is announced. By then, the procedural question has been answered.

Rural planning boards typically do not have hydrology staff or environmental impact modeling capacity. When a developer representing a hyperscaler walks in with a 200-page feasibility study, the asymmetry is not between competing arguments but between technical capacity and its absence. The most consequential decisions have already been made before the first public meeting.

Bullard's 1990 findings were the result of decisions made years earlier, in rooms affected communities never entered. The siting decisions happening now, across dozens of communities evaluated separately, have the same structure.

---

## The Automation Overlap

The March 2026 report distinguishes between augmentation, where AI makes a worker more productive, and automation, where AI takes over what the worker does. Augmentation rose slightly in Claude.ai traffic. Automation patterns in the API grew: business sales & outreach, and automated trading & market operations. These are administrative and service roles distributed throughout the economy, not concentrated in global tech hubs.

Goldman Sachs estimated in 2023 that 300 million jobs globally were exposed to AI-driven automation. The IMF put the share of jobs at high risk at 40% for advanced economies.

The overlap argument writes itself. The communities absorbing data center infrastructure tend to be the same ones most exposed to automation in the jobs that employ them locally. The same logic that sent data centers to rural Wyoming sent petrochemical plants to the rural South. Communities with less political resistance tend to have fewer of the knowledge work jobs that get augmented and more of the service and administrative jobs that get automated.

The problem is the evidence for that overlap does not yet exist at the local level. The March 2026 report does not break down automation exposure by geography. Data center siting records are fragmented across county filings. The structural argument is sound. The data to confirm it locally has not been assembled.

The case on siting and procedural grounds stands without the overlap claim. Reaching for it before it can be demonstrated weakens the parts that hold.

---

## The Aggregate Pattern

AI is an infrastructure-intensive industry. Infrastructure-intensive industries have a track record in the American context that Bullard documented three decades ago: physical burden migrates toward communities with less capacity to set terms. The migration is not typically the result of deliberate malice. It results from developers following rational incentives — cheap land, limited organized resistance, local officials looking for tax revenue — and from communities lacking the legal and technical staff to slow the intake down long enough to change the terms.

The convergence finding within the US is genuinely significant. It suggests the access side of the ledger can improve over time within a shared institutional environment. The infrastructure side has not historically tracked the adoption side. The regions that absorbed coal infrastructure did not proportionally absorb coal wealth. The communities that absorbed petrochemical infrastructure absorbed the contamination at rates disconnected from their share of the economic benefit. The pattern is consistent enough that the burden of proof runs the other way: what is different this time that would produce a different result.

Bullard's core finding in 1990 was not that environmental injustice was intentional. Most individual siting decisions were made by people following incentives, and the pattern emerged from the aggregate. The same structure appears in data center siting decisions being made now, across dozens of communities, each evaluated separately, each following the same incentive gradient. What the March 2026 report makes visible is that the communities absorbing this infrastructure and the communities benefiting most from it are not, in the main, the same places.

---

*Analysis based on the [Anthropic Economic Index, March 2026](https://www.anthropic.com/research/economic-index-march-2026-report). The 100MW scale reference comes from the International Energy Agency's Energy and AI analysis; the annual electricity figure is the implied load at continuous operation. Water-use figures draw on disclosed reporting for Google's The Dalles data center and Microsoft's Iowa operations, along with Brookings reporting on high-end daily water demand at large data centers. Land-use estimates draw on TechTarget reporting on hyperscale campus size and market reporting on large data center land transactions. Water-stress and irrigation conflicts draw on the Lincoln Institute of Land Policy and local reporting from Arizona, Oregon, and Aragon, Spain. Environmental justice framework draws on Robert Bullard, Dumping in Dixie (1990); Valerie Kuletz, The Tainted Desert (1998). Automation exposure estimates from Goldman Sachs Global Investment Research, "The Potentially Large Effects of Artificial Intelligence on Economic Growth" (2023); IMF, World Economic Outlook (April 2024).*

*Generative AI was used as an editor after the writing and analysis were complete. The author reviewed all suggested changes.*