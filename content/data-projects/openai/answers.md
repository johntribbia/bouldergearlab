# ChatGPT A/B Test — Question Answers

---

**1. What was the impact on paid plan signups?**

The treatment lifted paid signup rates by 1.70 percentage points — from 7.96% in control to 9.66% in treatment. The two-proportion z-test returns z = 4.83 (p < 0.001) with a 95% CI of [+1.01, +2.39 pp], so the effect is unambiguous. However, only about 170 of the ~966 treatment signups per 10,000 treated users are incremental — the other ~796 would have converted without the offer and simply collected a free month they didn't need to be persuaded by.

---

**2. What was the impact on paid plan retention?**

The raw cancellation rates — 50.4% treatment vs. 49.9% control — look nearly identical but are not comparable: 65% of treatment signups occurred in July with their 30-day free trial expiring after the July 31 observation close, so their cancellation decisions were never recorded. Restricting to users whose trial fully elapsed within the observation window (signed up on or before July 1, n = 976), the corrected rates are 71.3% for treatment and 69.9% for control — a 1.3 pp gap in the direction of worse retention for treatment, but not statistically significant (z = 0.43, p = 0.67, CI [−4.7, +7.3 pp]). The honest read is that the offer does not meaningfully change whether subscribers stay once they start paying, though the CI is wide enough that a small harm cannot be ruled out.

---

**3. How do we assess the statistical reliability of our conclusions?**

Both primary tests (signup lift, in-window retention) use two-proportion z-tests whose normal approximation is valid at these sample sizes. The signup result is rock-solid — the experiment is essentially over-powered for a 1.7 pp effect at n = 30,000. Retention is the weak point: with n = 334 in-window treatment users, the 95% CI spans 12 percentage points, meaning the data is consistent with both "no effect" and "modest harm."

---

**4. Did the treatment effect differ by day of week, and how do you distinguish signal from noise?**

Yes — Sunday, Monday, and Tuesday show meaningfully higher lift (+2.3 to +3.4 pp) compared to the rest of the week, while Friday shows essentially zero effect (−0.3 pp). With seven simultaneous tests, raw p-values overstate significance, so Benjamini–Hochberg FDR correction was applied: all three early-week days survive FDR at α = 0.05, and Sunday alone survives the stricter Bonferroni threshold (p = 0.0003). The consistent clustering by day type — weekend and early-week sessions, which tend to be more exploratory — gives the pattern a plausible mechanism, but this was not pre-specified, so it belongs in a follow-up experiment, not a deployment decision.

---

**5. Have we run this experiment long enough?**

For measuring signup lift: yes — the assignment period is complete and the statistical result is conclusive. For measuring retention: no. The treatment offers a free first month, so a user assigned in mid-July has their natural cancellation decision point in mid-August, after data collection closed. This right-censors 65.4% of treatment signups (632 of 966) and makes the raw retention comparison invalid. A window of at least four months from the start of assignment — pushing observation through September — would allow every free-month trial to expire and be resolved before the data cut.

---

**6. What do we need to believe about user lifetime to expect to break even?**

Per 100 treated users: 9.7 signups receive a free month at $20 each → **$194 in foregone revenue**. Of those, only 1.7 are incremental; applying the in-window retention rate (28.7% stay), the program generates ~0.49 retained net-new subscribers paying $20/month. Break-even = $194 ÷ ($20 × 0.49) ≈ **19.8 months**. This assumes constant monthly churn (geometric decay), which implies a maximum sustainable monthly churn rate of about 5.1% — above that threshold, the subscriber base decays too fast and the program never recoups its cost regardless of how long it runs.

---

**7. Should we ship this treatment?**

Ship, with the condition that post-trial churn gets measured directly before any scaling decision. The signup lift is real and well-powered, the offer reaches genuinely convertible users, and the in-window retention result shows incremental subscribers are not lower-quality than organic converters. The economics work if monthly churn on retained subscribers stays below ~5%, which is plausible for a productivity tool but needs to be confirmed from internal cohort data — that single number is the difference between a profitable program and one that never breaks even.

---

**8. What target audience would you recommend for a follow-up experiment?**

The strongest targeting signal in this dataset is day of week: users assigned on Sunday, Monday, or Tuesday convert at +2.7 pp versus the overall +1.7 pp, which cuts the program-level break-even from ~20 months to ~13 months and raises the maximum sustainable churn threshold from 5.1% to 7.5%. This requires no product changes — just a scheduling rule — and covers 43% of the eligible audience. A secondary lens worth testing is PST timezone (+2.4 pp, n = 1,871, CI excludes zero), though it should be pre-registered in the follow-up rather than acted on as a production filter from this data alone. Engagement signals not currently in the dataset — session frequency, feature breadth, days since last active — would almost certainly outperform both of these and should be instrumented before the next experiment runs.
