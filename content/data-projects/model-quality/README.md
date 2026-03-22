# Replication Package — Model Quality and User Engagement

Code for *"Measuring the Effect of Language Model Quality on User Engagement: A Within-Version Causal Analysis"*.

---

## Requirements

**Python** (3.9+)
```
pandas
numpy
```

**R** (4.2+)
```
dplyr, tidyr, readr
mgcv
ggplot2, patchwork, scales
```

Install R packages once:
```r
install.packages(c("dplyr", "tidyr", "readr", "mgcv",
                   "ggplot2", "patchwork", "scales", "data.table"))
```

---

## Scripts

| File | Purpose |
|---|---|
| `data-generator.py` | Generate the three base CSV tables |
| `augment_data.py` | Add category columns and causal outcomes to the engagement data |
| `model_quality_analysis.R` | Full 15-step analysis pipeline (Steps 1–15) |
| `gap_analyses.R` | Gap analyses: frozen-weights sensitivity, falsification, K-L correction, benchmarks |

Run them in the order above. All scripts read and write to the same directory.

---

## Execution

From the directory containing the scripts and CSVs:

```bash
# Generate base data (~2–3 minutes)
python data-generator.py

# Add category counts and causal outcomes
python augment_data.py

# Full analysis — requires ~4 GB RAM for 2000-user sample
Rscript model_quality_analysis.R

# Gap analyses — runs on 500-user sample, fits in ~1.3 GB RAM
Rscript gap_analyses.R
```

Figures are saved to `figures/`.

---

## Data

Three synthetic CSV files are produced by the generation step:

- **`offline_model_evaluation.csv`** — 50K evaluation records with human ratings (1–5) and synthetic metric scores per model version × prompt category.
- **`user_demographics_subscription.csv`** — 100K users with role, country, subscription status, and treatment group assignment.
- **`user_engagement_timeseries.csv`** — Weekly session records for each user across a 26-week window. After augmentation, includes prompt category counts (`prompts_coding`, etc.) and three causal outcome columns: `active_days_observed`, `churn_risk_observed`, `session_duration_aug`.

The engagement CSV is overwritten in-place by `augment_data.py`.

---

## Design

The identifying variation comes from within-version differences in effective model quality. Users whose prompt mix leans toward categories rated higher within a given model version receive a higher quality score (Q\_it\_c) than users on the same version with a different mix. This is not confounded by the version-level quality jump because Q\_it\_c is centered within version.

Known causal effects injected into the data generating process (log-odds scale):

| Outcome | TRUE_BETA | Variable |
|---|---|---|
| Active days | 1.0 | `active_days_observed` |
| Churn risk | −0.6 | `churn_risk_observed` |
| Session duration | 0.4 | `session_duration_aug` |

Both `model_quality_analysis.R` (Step 12) and `gap_analyses.R` (Steps 12a, 12b) report recovery rates against these ground-truth values.

---

## Memory note

The full analysis script (`model_quality_analysis.R`) uses a 2000-user stratified sample and requires approximately 4 GB of free RAM for the GAMM fitting steps. If memory is constrained, `gap_analyses.R` reproduces all five gap analyses on a 500-user sample and completes under 1.5 GB.

---

## Seed

`RANDOM_SEED = 42` in all scripts. Change it and re-run to confirm results are not seed-dependent.
