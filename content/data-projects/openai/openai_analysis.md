# OpenAI Take-Home Analysis — ChatGPT Paid Plan A/B Test

> ⚠️ **This project is private! Do not push any code to a public repository.**

---

## Background

We offer ChatGPT based on a smaller model (4o-mini) for free to most users, and we offer a **paid plan at $20/month** which includes the best and newest models, access to beta features, and more. However, most users stick to the free plan.

The attached dataset contains the results of an A/B test in which we gave users who had **not yet signed up for a paid plan after three months of use** a **"first month free"** offer to improve signup rates.

---

## Questions to Address

1. What was the impact on **paid plan signups**?
2. What was the impact on **paid plan retention**?
3. How do we assess the **statistical reliability** of our conclusions? *(please be brief)*
4. Your PM has a theory about how users differ by assignment day of week — did you see a **difference in treatment effect by day of week**, and how can you determine whether the difference is noise or signal?
5. Have we run this experiment **long enough** to get representative results? Would you expect anything to change if we ran it longer?
6. Let's think about the **ROI of the treatment**. What do we need to believe about user lifetime in order to expect to break even? Please do "whiteboard math" at a high level — note major assumptions and make calculations explicit. *(ignore compute cost)*
7. **Should we ship this treatment?** Assume we can iterate and improve on it whether we ship it or not — make a recommendation based on the current treatment and current target audience.
8. We'd like to run a **larger follow-up experiment** with the same treatment, but targeting a subset of this experiment's eligible audience. Based on what we learned, what would be a **good target audience**?

---

## Deliverables

- Analysis formatted for a **broad product audience** (engineers, PMs, etc.)
- Sufficient technical detail for a **data scientist** to understand the approach
- Preferred format: slides, doc, or notebook — **include code** (e.g. zipped notebook) alongside the writeup

---

## Other Notes

- The A/B test and all data in this exercise are **simulated** — please treat and describe them as if real
- Please **do not share** the question, data, or answers with anyone else
- For the purpose of this exercise, assume the objective is to **maximize profits from ChatGPT users**