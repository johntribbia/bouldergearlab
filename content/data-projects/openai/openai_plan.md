# Analysis Plan: ChatGPT Paid Plan A/B Test

> **Private — do not share or push to a public repo.**

---

## Dataset Overview

- **File:** `data/chatgpt_ab_test.csv`
- **Rows:** 30,000 users
- **Design:** Unbalanced — 10,000 treatment, 20,000 control (1:2 ratio)
- **Treatment:** "First month free" offer shown to users who had not converted to a paid plan after 3 months of use
- **Date range:** 2023-06-01 to 2023-07-31 (2 months)
- **Columns:**
  - `user_id` — anonymous identifier
  - `assignment_date` — date user was enrolled in experiment
  - `treatment` — 1 = saw offer; 0 = control
  - `assigned_on_platform` — `web` (~89%) or `ios` (~11%)
  - `time_zone` — EST, CST, MST, PST, HST
  - `paid_signup_date` — date of paid plan signup (empty if never converted)
  - `paid_plan_canceled` — 1 if the paid plan was subsequently canceled

---

## Key Numbers (from initial EDA)

| Metric | Treatment | Control |
|--------|-----------|---------|
| N | 10,000 | 20,000 |
| Paid signup rate | 9.7% (966) | 8.0% (1,592) |
| Signup lift | **+1.7pp** | — |
| Cancellation rate (raw, all signups) | 50.4% | 49.9% |
| Cancellation rate (in-window cohort only) | **71.3%** | **70.1%** |
| Retention rate (in-window cohort only) | ~28.7% | ~30.1% |

**The headline tension:** The raw 50.4% cancellation figure is misleading — 65% of treatment signups occurred in July with their 30-day free trial expiring in August, outside the observation window. Once restricted to fully-observable signups, both arms cancel at ~70-71%, with no meaningful difference.

---

## Q1 — Impact on Paid Plan Signups

**Method:** Two-proportion z-test comparing signup rates. Report: absolute lift (pp), relative lift (%), 95% CI on the difference, p-value.

The experiment used an unbalanced design (1:2 ratio), which is fine — the z-test handles unequal group sizes naturally.

**Expected finding:** Significant positive lift. At n=30,000 the experiment is very well-powered for even a 1pp effect.

**Planned output:** Summary table + bar chart showing signup rates by arm.

---

## Q2 — Impact on Paid Plan Retention

**Data constraint confirmed:** `paid_plan_canceled` is a binary flag only — no cancellation timestamp exists. This is not a missing-values problem; it is a right-censoring problem rooted in the observation window.

**The censoring problem (quantified):**
- Treatment users receive a *free first month*, so their natural cancellation decision point is ~day 30 after signup
- 65% of treatment signups (632 of 966) occurred in July — their day-30 window falls in August, after the observation window closes July 31
- These users literally haven't been asked to pay yet by the time the data was collected
- The control arm shows the **same artifact**: control July signups cancel at 37.3% vs. 70.1% for June signups — identical pattern, confirming this is purely an observation window issue

**In-window cohort breakdown:**

| Cohort | N | Cancel Rate |
|--------|---|-------------|
| Treatment — trial elapsed (signed up ≤ July 1) | 334 | **71.3%** |
| Treatment — trial NOT elapsed (signed up > July 1) | 632 | 39.4% ← censored |
| Control — signed up ≤ July 1 | 642 | **69.9%** |
| Control — signed up > July 1 | 950 | 37.3% ← same censoring |

**Method:** Restrict retention analysis to users in both arms who signed up on or before July 1 — giving any signup at least 30 days within the observation window. Apply the same chi-square / z-test on this matched cohort. The "June signups" framing used in earlier EDA is a close approximation (n=612, 70.1%) but the July 1 cutoff is the precise symmetric definition and should be used in the final analysis.

**Projection:** If out-of-window treatment users eventually cancel at the same rate as in-window (~71%), projected total cancels rise from 487 to ~688 of 966 (~71.2%). This is a reasonable upper-bound estimate to report alongside the in-window result.

**Key nuance (selection bias):** This is still a conditioned analysis (conditional on signup), so selection effects apply. Treatment signups include free-riders who never intended to pay. The in-window data suggest that once the trial expires, ~71% of treatment signups cancel — nearly identical to control. The offer changes *who converts*, not *how long they stay*.

**Validation of in-window comparison:** A concern with restricting to July 1 signups is that it conditions on speed-to-convert, which could bias the comparison if the offer caused treatment users to sign up faster. Checking the actual distributions: T in-window users have a median of 6 days from assignment to signup, C in-window users also median 6 days; day-0 conversion rate is 5.1% in both arms. The in-window cohort is compositionally matched on this dimension — the comparison is not contaminated by fast-converter selection bias.

**Retention direction:** Treatment cancels at 71.3%, control at 69.9% — treatment is directionally *worse* by 1.3pp, not the same. This is not statistically significant (CI [-4.7, +7.3]), but the direction is consistent with the free-rider hypothesis: the offer inducing marginal users who are slightly less likely to stay than organic converters. Report the direction clearly, not just "no difference."

**Planned output:** Two-panel stacked bar — raw (misleading) vs. in-window (corrected). Annotate both the censoring artifact and the directional finding. Include the validation check (speed-to-signup distributions matched) as a footnote or callout.

---

## Q3 — Statistical Reliability (Brief)

**Framework:**

- Both primary tests use large samples; asymptotic normal approximation is valid
- With n=30,000 at baseline, power is not the concern — effect size estimation is
- **Randomization check (verified):** Platform balance: T=88.9% web vs C=88.8% — identical. Timezone balance: largest deviation is EST (+1.2pp) and CST (-1.2pp) — trivially small. DOW balance: all days within ±0.5pp of expected 33.3% ratio. Randomization is clean; there is no covariate imbalance to worry about.
- **Multiple comparisons:** Keep primary tests to two (signup rate, retention rate). Flag DOW subgroup analysis (Q4) explicitly as exploratory
- **Practical vs. statistical significance:** A 1.7pp lift is statistically significant at this sample size. Whether it is economically meaningful depends on the ROI analysis (Q6)

**Assumption audit:**
- **Independence / SUTVA:** Both tests assume each user's outcome is independent of other users' treatment assignments. If treated users shared the free-month offer with friends — or if it was publicly visible — some control users may have delayed signup waiting on the offer, which would deflate control conversion and make estimated lift a *lower bound*. This is untestable here but directionally conservative. Flag it in the article as a known structural limitation.
- **Normal approximation adequacy:** Primary signup test (np=966, n(1-p)=9,034) — passes easily. Q2 in-window retention (T arm): np=238, n(1-p)=96. This passes the np ≥ 10 threshold, but the 2.5:1 asymmetry between cancelers and retainers puts us in the tail of the binomial. A bootstrapped proportion CI for the T arm would be slightly more conservative — worth using in the article for the in-window retention estimate specifically.
- **Conditioned analysis (Q2):** The retention comparison is conditioned on having signed up. This is analytically correct for the question asked, but any selection effects from the offer (e.g., the offer attracting marginal users who are different in unmeasured ways) are in play. The speed-to-signup validation (both arms: median 6 days, 5.1% same-day conversions) mitigates this concern but does not eliminate it.
- **Where bootstrapping adds value:** For Q1 and Q2 primary tests, asymptotic z-tests are valid. The one place bootstrapping is distinctly better is the **break-even months estimate** (Q6) — it is a nonlinear ratio of two uncertain quantities (lift and retention rate) with a right-skewed sampling distribution. A symmetric CI understates worst-case (slow break-even) risk. Use bootstrap for Q6; z-tests are fine for primary hypothesis tests.

**One sentence for the article:** Statistical significance is not the limiting factor here — the experiment is large enough that even small effects are detectable, which means the burden shifts to effect size interpretation and economic reasoning.

---

## Q4 — Day-of-Week Treatment Effect Heterogeneity

**Observable pattern from EDA:**

| Day | Treatment Rate | Control Rate | Lift | 95% CI | Sig? |
|-----|---------------|-------------|------|--------|------|
| Sunday | 10.5% | 7.1% | +3.4pp | [+1.6, +5.3] | ✓ |
| Tuesday | 10.4% | 7.9% | +2.5pp | [+0.5, +4.4] | ✓ |
| Monday | 10.2% | 7.9% | +2.3pp | [+0.4, +4.1] | ✓ |
| Saturday | 9.9% | 8.3% | +1.5pp | [-0.3, +3.3] | — |
| Thursday | 10.1% | 8.8% | +1.3pp | [-0.5, +3.2] | — |
| Wednesday | 8.9% | 7.7% | +1.1pp | [-0.7, +3.0] | — |
| Friday | 7.6% | 7.9% | -0.3pp | [-2.0, +1.4] | — |

Only three days show lifts whose 95% CIs exclude zero: Sunday, Tuesday, and Monday. The other four — including Friday's apparent negative lift — are consistent with noise. The pattern is not "some days work, some don't" uniformly; it's concentrated in early-week and Sunday.

**Method to distinguish signal from noise:**

1. **Interaction test** — fit a logistic regression: `signup ~ treatment + day_of_week + treatment*day_of_week`; test whether the interaction terms are jointly significant (likelihood ratio test or Wald F-test)
2. **Multiple testing correction** — with 7 DOW tests, strict Bonferroni sets α = 0.05/7 = 0.0071. **Only Sunday survives strict Bonferroni** (p=0.0003). Monday (p=0.0144) and Tuesday (p=0.0129) fail Bonferroni but **both survive Benjamini-Hochberg FDR correction** (ranks 3 and 2, BH thresholds 0.0214 and 0.0143 respectively). For exploratory subgroup analysis — which this is — BH FDR is the more appropriate criterion; it controls false discovery rate rather than family-wise error rate and is less punishing when the goal is identifying candidates for targeting, not claiming a family of independently confirmed effects. The Sun/Mon/Tue recommendation stands under BH; under strict Bonferroni, Sunday alone stands.
3. **Conceptual frame** — early-week and weekend users may be browsing more exploratorily; late-week sessions may be more task-focused and less moveable by a price nudge

**Key caveat:** DOW of *assignment* is not necessarily DOW of the user's typical session pattern. It is a proxy, not a behavioral measure.

**Planned output:** Bar or dot chart showing lift by DOW with 95% CIs; interaction term table from logistic regression.

---

## Q5 — Have We Run Long Enough?

**Short answer:** No — not to measure retention. Yes — to measure initial signup lift.

**The precise censoring problem (quantified):**
- Observation window: 2023-06-01 to 2023-07-31
- For a treatment user to have a *fully observable* free-month trial: they must have signed up on or before July 1 (day 30 = July 31)
- Only 334 of 966 treatment signups (34.6%) meet this criterion
- The remaining 632 signups (65.4%) are right-censored — their trial is incomplete
- Censored users show 39.4% cancellation; in-window show 71.3% — a 32pp gap that is entirely an artifact of observation timing

**What would change with a longer window:**
- The treatment cancellation rate would converge upward toward ~71%, matching control
- The 'retention advantage' suggested by the raw 50.4% figure would disappear
- The ROI calculation changes materially (see Q6 update below)
- To observe full trial expiry for all July-assigned users, the window would need to extend to at least September 30

**Additional concerns beyond censoring:**
1. **Temporal instability in weekly lift:** The week-by-week signup lift ranges from +0.2pp (July 20–26) to +3.9pp (July 6–12). With ~1,100 treatment users per week, the per-week SE is about ±1.1pp — so this range is within the noise envelope and does not indicate the offer was losing effectiveness. However, the last week (July 20–26) shows near-zero lift and warrants mention: users assigned in that window have the fewest days remaining before the obs window ends, which partially suppresses observed conversion for both arms. The overall +1.7pp headline averages across a volatile but not systematically trending signal.
2. **Days-to-signup heterogeneity:** 41% of treatment signups in week 0 vs. 46% in control. The offer pulls in slower-converting users; their long-run behavior may differ from the week-0 group.
3. **Seasonal scope:** A 2-month window (June–July) may not capture typical fall usage patterns or competitive dynamics.

**Planned output:** Timeline visualization showing assignment dates, signup dates, and free-month expiry for treatment users — annotated to highlight the 65% that fall outside the window. This is a key analytical exhibit, not just a caveat footnote.

---

## Q6 — ROI Whiteboard Math

**Setup:**

- Treatment cost: a free month to every user who signs up = $20/signup
- Treatment signup rate: 9.7%; incremental (vs. control): +1.7pp
- Total signups in treatment arm (10k users): ~970; of those, ~170 are incremental
- Cost of free months given away: ~970 × $20 = ~$19,400 per 10,000 treated users
- Deadweight cost: ~800 users who would have signed up anyway now get a free month ($16,000 not earned)
- Revenue from retained users: requires assumption on LTV

**Break-even calculation (per 100 treated users) — using corrected ~71% cancellation rate:**

| Component | Calculation | Value |
|-----------|------------|-------|
| Incremental signups | 1.7pp × 100 | ~1.7 users |
| Non-incremental signups (deadweight) | 8.0pp × 100 | ~8.0 users |
| Total signups who get free month | 9.7pp × 100 | ~9.7 users |
| Total cost of free months | 9.7 × $20 | $194 |
| Retained incremental users (29% stay) | 1.7 × 29% | ~0.49 users |
| Revenue per retained month | $20 | $20/mo |
| Months to break even on offer cost | $194 / ($20 × 0.49) | ~19.8 months |

**Note:** Using the raw 50% retention figure gives ~11.4 months to break even; using the corrected in-window ~29% retention gives ~20 months. The corrected number is the right one to use, and it changes the case for shipping materially.

**Key assumption to break even:** A retained user must stay ~20+ months on average. That requires ~5% or lower monthly churn. Note this assumes a constant hazard rate (geometric lifetime distribution). Real subscriber churn is typically front-loaded — higher in months 1–2 after trial end, lower thereafter. If churn is front-loaded, a simple 1/m calculation overstates expected lifetime. The threshold to flag internally is whether the 3-month+ subscriber cohort (past the initial churn spike) has churn at or below 5%. That is the population this offer is feeding.

**Uncertainty on the break-even estimate itself:** Break-even is a ratio of two uncertain inputs (signup lift in the denominator, retention rate also in the denominator), so the sampling distribution is right-skewed — worse cases (longer break-even) are more likely than the symmetric interval implies. A log-normal approximation using the relative standard errors of lift and retention gives an approximate 95% CI of **[13, 31] months** (vs. point estimate ~19.7 months). The strategic thresholds (ship at 5% churn / 20 months, reconsider at 8% / 12 months) remain the same; the range just makes clear the decision is not a knife edge at either boundary. Bootstrap this — don't rely on delta method — when writing the final analysis.

**Alternative framing (incremental only):** Net-new signups only (+1.7pp), 29% retention:
- ~0.49 incremental retained users per 100 treated
- Direct cost of acquiring those 1.7 incremental signups: 1.7 × $20 = $34; their direct break-even = $34 / (0.49 × $20/mo) ≈ 3.5 months
- But that ignores the deadweight drag. Full program cost ($194) divided by incremental retained users (0.49) = ~$394 per retained net-new subscriber — this is the true cost of the program per durable conversion
- Minimum viable lifetime at the user level: ~3.5 months (1 free + 2.5 paid). At the program level: ~20 months.
- The gap between those two numbers is the deadweight problem. Every retained incremental user is in effect subsidizing ~5 free months for users who would have converted anyway.

**The two-level framing matters:** At the *user* level the math looks OK (3 months = break-even). At the *program* level (across all 9.7 treated signups per 100), the deadweight drag pushes break-even to ~20 months because you're paying for 8 non-incremental signups for every 1.7 incremental ones.

**Planned output:** Explicit table of assumptions + break-even formula under both retention assumptions (raw vs. corrected) + sensitivity bar showing break-even months as a function of retention rate.

---

## Q7 — Should We Ship?

**Recommendation sketch (to be developed in article):**

The treatment achieves a statistically significant signup lift (+1.7pp) but shows no improvement in retention. The ~$20 offer appears to successfully attract marginal signups, but approximately half of those convert for the free month only and then leave. The economic case depends entirely on the long-run LTV of the retained half.

**Arguments for shipping:**
- Clean, significant signup lift in a well-powered experiment
- Sun/Mon/Tue targeting reduces required subscriber lifetime to ~13 months, which is plausibly within reach of a typical paid subscriber cohort
- Offer has iteration potential regardless of ship decision

**Arguments against (or for caution):**
- Retention rate is identical to control (~71% cancel once trials expire) — the offer changes *who shows up*, not *who stays*
- The ~71% cancellation rate means only ~29% of signups become genuine long-term subscribers
- Deadweight transfer: 8 out of every 9.7 signups per 100 treated users would have signed up anyway and now get a free month for nothing
- Program-level break-even requires ~20 months of retained user lifetime — this needs to be stress-tested against internal churn data
- Raw 50% cancellation figure in the data is an artifact of the observation window, not a real retention signal

**Conditional recommendation:** Do not ship to the full eligible population without validating that retained subscriber LTV exceeds ~20 months. If internal cohort data supports that, the economics work. If not, narrow the audience first (Q8) before scaling.

---

## Q8 — Target Audience for Follow-Up Experiment

**Based on heterogeneity observed in the data:**

1. **Day of week: Sunday/Tuesday/Monday assignees** — show highest treatment lift (+2.5–3.4pp) vs. Friday (-0.3pp). A weekend-only or early-week targeting window could improve incremental signup rate without proportionally increasing free-rider cost.

2. **Platform: iOS users** — slightly higher lift (+2.0pp vs. +1.7pp for web), smaller subgroup but worth validating. iOS users may be more casual/exploratory, making them more responsive to a promotional nudge.

3. **Timezone: PST users** — PST shows +2.4pp lift with CI [+0.7, +4.0] on n=1,871 treatment users. MST shows a larger point estimate (+3.9pp) but with only n=542 treatment users the CI is [+0.9, +7.0] — too wide to recommend as a targeting criterion on its own.

4. **Behavioral signals not in this dataset (but should be):** Days since last active session, number of sessions in final 30 days before assignment, feature breadth of usage (single-use vs. power user). These would be the most powerful targeting features.

**Primary recommendation:** Sun/Mon/Tue is the primary DOW targeting recommendation. A secondary lens is PST timezone (+2.4pp, CI [+0.7, +4.0], n=1,871 T users — the only timezone with a reasonably sized sample and a CI that excludes zero).

**Retention assumption in Sun/Mon/Tue break-even:** The 13.3-month break-even uses the global 28.7% in-window retention rate. A direct check on Sun/Mon/Tue in-window signups: T cancels 69.9% (n=143), C cancels 71.2% (n=250) — the direction actually favors treatment slightly, but n=143 is too small to conclude anything. The global retention rate is the right assumption to use; the SMT-specific check shows no alarming difference.

---

## Analytical Explorations to Showcase

This article should read as a demonstration of how to think, not just what the answer is. Each of these explorations is a show-your-work moment that belongs in the piece:

1. **The misleading headline number** — The raw 50.4% cancellation rate looks like a decent result. Showing why it's wrong requires understanding how the free-month mechanic interacts with the observation window. Walk through the logic before revealing the corrected number. This is the single most important analytical move in the piece.

2. **The control arm as your own robustness check** — The control arm independently confirms the censoring story: July control signups also cancel at only 37%, while June signups cancel at 70%. This is a self-contained sanity check using data already in hand. It removes any doubt that the pattern is mechanical, not behavioral.

3. **The 1:2 allocation question** — The experiment is unbalanced (10k treatment, 20k control). Worth a brief note on why this is statistically fine, and what it might imply about the design team's priors (perhaps they expected a small effect and wanted a larger control estimate).

4. **The DOW interaction test** — Not just a chart of DOW lifts. Show the full logistic regression with interaction terms and discuss whether the joint interaction test is significant. This distinguishes noise from a potentially actionable signal. Sunday being the strongest day has an intuitive story worth testing.

5. **The two-level break-even framing** — Most ROI analysis stops at the user level ("this user pays back in 3 months"). The program-level calculation (including deadweight cost of giving free months to non-incremental signups) pushes break-even to ~20 months. Showing both framings and explaining why they differ is a strong analytical communication moment.

6. **The right-censoring timeline visualization** — A chart that shows, for each signup, whether the 30-day trial has elapsed within the observation window. This should be a visual exhibit, not just a number. The reader should see the problem, not just read about it.

7. **What we'd need to measure better** — Close the piece with a concrete list of what a follow-up instrumentation plan would look like: cancellation timestamp, session activity logs, usage depth features. Same framing as the rate-limit piece's "three things done before the policy lands."

---

## Article Structure (Blog Post)

The article should follow the same structure as the rate-limit piece:

1. **Opening lede + tension** — the offer lifts signups, but the headline retention number is wrong — and showing why is the whole point
2. **Section: What the data shows on signup** — Q1 with chart
3. **Section: The retention problem, part 1** — the raw 50.4% figure and why it's an artifact
4. **Section: The retention problem, part 2** — in-window cohorts, control arm confirmation, corrected ~71%
5. **Section: Can we trust these numbers?** — Q3 (statistical reliability, power, multiple comparisons)
6. **Section: Have we run long enough?** — Q5 with timeline visualization
7. **Section: Does day of week matter?** — Q4 with chart and interaction test
8. **Section: The ROI math** — Q6 whiteboard calculation, both user-level and program-level
9. **Section: What to do** — Q7 recommendation
10. **Section: Who to target next** — Q8
11. **TL;DR** — 3–4 sentences max

---

## Figures to Produce

| # | Chart | Type | Key Point |
|---|-------|------|-----------|
| 00 | Signup rate by arm (bar) | Two bars with CI | +1.7pp lift at a glance |
| 01a | Retention rate — raw (stacked bar) | Treatment vs. Control, all signups | "50/50" — appears balanced |
| 01b | Retention rate — corrected (stacked bar) | In-window cohorts only | ~71% cancel in both arms; offer changes nothing |
| 02 | Right-censoring timeline | Scatter/swim-lane per signup | Which trials have elapsed; 65% censored highlighted |
| 03 | Days-to-signup distribution (histogram) | T vs. C overlay | Week-0 spike; tail shows offer pulls in slow converters |
| 04 | Signup lift by day of week (dot/bar + CI) | DOW on x-axis | Friday ≈ 0; Sunday highest |
| 05 | ROI break-even sensitivity | Line chart | Months-to-break-even vs. retention rate (raw vs. corrected) |

---

## The "So What?" — Senior Leadership Layer

This section is not part of the 8-question answer. It is the layer that goes on top: what a senior analyst or director does with these results that a junior analyst would not.

---

### What this analysis can and cannot tell you

Be explicit about the limits upfront. The signup lift (+1.7pp, z=4.83, p<0.001) is real and well-powered. The retention comparison is not: with n=334 treatment users in the in-window cohort, the 95% CI on the retention difference is [-4.7pp, +7.3pp]. That interval is wide enough to contain both "the offer slightly helps retention" and "the offer meaningfully hurts it." The honest answer is that we don't know whether the offer changes long-run behavior, and we should say so cleanly rather than hiding behind the corrected point estimate of +1.3pp.

The ship decision cannot be made from this data alone. It depends on a LTV assumption this dataset doesn't contain.

**Three additional limits to state explicitly in the article:**
1. **No cancellation timing:** `paid_plan_canceled` is a binary flag — we know *that* users canceled, not *when*. We cannot distinguish month-1 free-riders (canceled the day the trial ended) from month-6 churn (genuine dissatisfaction). That distinction is material: the 71% cancellation rate in the in-window cohort almost certainly includes both groups, and they have very different implications for whether the offer is a retention problem or just a conversion funnel question.
2. **SUTVA / contamination:** If control users learned of the free-month offer — through treated friends, social sharing, or marketing that was hard to contain — control conversion rates are slightly inflated and estimated lift is a lower bound on the true effect. Untestable here. Directionally conservative.
3. **Break-even depends on a number not in this data:** The ~20-month break-even threshold requires internal cohort data on 3-month+ subscriber churn — specifically the population this offer feeds. Reporting the break-even without flagging that the key input (monthly churn rate) is assumed, not measured, would be analytically incomplete.

---

### The one question that unlocks the decision

Program-level break-even requires retained subscribers to stay ~20 months (~5% monthly churn or lower). That is the single number to validate before deciding. It is not exotic — any internal cohort data on 3-month+ subscribers can answer it.

| Monthly churn assumption | Implied LTV | Break-even met? |
|--------------------------|-------------|-----------------|
| 5% or lower | 20+ months | Yes — ship |
| 5–8% | 12–20 months | Marginal — target only (see below) |
| 8% or higher | <12 months | No — iterate the offer |

A director frames this as a hypothesis, not a blocker: "Pull the cohort data. If churn is under 5%, the economics work and we ship. If it's 5–8%, we ship to the targeted audience only. If it's above 8%, we kill the offer and rethink the design before running another experiment."

---

### The targeted audience improvement

Sun/Mon/Tue targeting is the most defensible narrow-audience recommendation from this data:
- Reaches 43% of eligible users
- Average lift: +2.7pp vs. +1.7pp overall
- Program-level break-even: **13.2 months** (vs. 19.7 months for full population)
- Only three of seven DOW lifts are statistically significant; the Sun/Mon/Tue recommendation rests on actual signal, not the full DOW chart

The framing for a PM: "We don't need to build anything new. A scheduling rule that sends the offer on Sunday, Monday, or Tuesday cuts the break-even requirement by a third."

---

### Stakeholder communication plan

Three audiences, three different conversations:

**PM / product leadership:** "The offer lifts signups but we're flying blind on whether those signups stick. The raw 50% cancellation number is an artifact of the observation window — the corrected number is 71%, which matches control exactly. Before we decide to ship, we need to check one internal number: what is the monthly churn rate of users who have been on a paid plan for 3+ months?"

**Finance:** "The program is break-even-negative at the program level unless average subscriber lifetime exceeds 20 months. At the user level, any single retained subscriber breaks even in ~3.5 months — but paying for free months for the 8 out of 9.7 signups who would have converted without the offer is the drag. Targeting Sun/Mon/Tue users drops the required lifetime to 13 months."

**Engineering / data:** "Before the next experiment, we need three schema changes: (1) cancellation timestamp (not just a flag), (2) daily session activity in the 30 days before assignment, (3) a holdout design that runs for at least 4 months so all free-month trials expire within the observation window. Without those, the next analysis will have the same censoring problem."

---

### What a senior person says that is different

These are the moments in a debrief or doc review where the seniority shows:

1. **"The 50% cancellation rate you'll see in the data is wrong, and here's why in one chart."** — Not buried in a footnote. Front and center.

2. **"We are highly confident the offer lifts signups. We have essentially no ability to tell from this data whether it changes retention, because 65% of signups never had the chance to cancel before the data was cut."** — State what the experiment can and can't answer. Don't oversell the in-window finding.

3. **"The recommendation is conditional, not binary."** — Not "ship" or "don't ship." Ship to Sun/Mon/Tue users if internal churn data shows lifetime ≥13 months; ship to everyone if ≥20 months; rethink the offer if neither.

4. **"The next experiment needs to be designed differently before we run it."** — Longer window, better instrumentation, tighter audience. Saying this in the same breath as the recommendation is what separates a complete analysis from one that just answers the questions asked.

5. **"For every 1 incremental signup, roughly 5 non-incremental users also got a free month."** — The deadweight drag is not a statistical footnote. The ratio is 4.7x (796 non-incremental signups per 170 incremental). That belongs in the executive summary as a concrete number, not a vague reference to deadweight.

---

### Follow-up experiment design

Before running the follow-up, the team needs to agree on three things:

1. **Minimum observation window: 4 months.** Any free-month trial assigned on day 1 of the experiment expires on day 30. The last assignment (end of month 2) expires on day ~60. Ongoing churn behavior needs at least another 60 days of signal. Four months captures this cleanly.

2. **Cancellation timestamp as a required field.** The current flag tells you if someone canceled; it does not tell you when, or whether it was during the free month (free-rider) or 6 months in (genuine churn). That distinction is critical for the next retention analysis.

3. **Pre-assignment behavioral features.** Days active in the prior 30 days, number of distinct features used, conversation depth — these are the features that will allow a targeting model to go beyond DOW and timezone. The current dataset has none of them.

---

## Statistical Tests Summary

| Question | Test | Metric |
|----------|------|--------|
| Q1 — Signup lift | Two-proportion z-test / chi-square | Absolute pp lift, 95% CI, p-value |
| Q2 — Retention | Two-proportion z-test / chi-square (conditioned on signup) | Cancellation rate difference |
| Q4 — DOW interaction | Logistic regression with interaction terms + LRT | Interaction p-value; per-DOW CIs |
| Q8 — Subgroup HTE | Stratified z-tests + interaction terms | Platform, timezone lift |

All subgroup tests to be treated as exploratory (Bonferroni correction or FDR, noted in text).

---

## Open Questions Before Writing

1. ~~**Cancellation timing:**~~ **RESOLVED** — `paid_plan_canceled` is a binary flag with no timestamp. No cancellation date column exists. The correct approach is to restrict retention analysis to in-window cohorts (signed up ≤ July 1) and project the full-window estimate. No synthetic data needed.
2. ~~**Right-censoring cutoff:**~~ **RESOLVED** — Cutoff is July 1 for treatment (signup + 30 days ≤ July 31). 65.4% of treatment signups (632 of 966) are right-censored. Control arm independently confirms the pattern.
3. **Control condition definition:** Assuming pure control (no offer shown). If control users saw a different offer (e.g., a discount instead of free month), the signup rate comparison changes interpretation. Flag as assumption.
4. **LTV data:** Not in this dataset. Break-even calculation requires an external assumption about average subscriber lifetime. The corrected analysis puts break-even at ~20 months — this needs to be validated against internal cohort data before a ship decision.
5. **Platform delivery:** Can iOS users actually see the "first month free" offer in-app? If the offer is web-only but iOS users were still enrolled in treatment, their lower baseline signup rate could confound the iOS subgroup lift. Worth flagging.
