# Capstone Project: Quantifying the Business Impact of AI Model Quality Investments

## Project Overview

**Level**: Masters-level Applied Mathematics  
**Duration**: 12 weeks  
**Team Size**: 3-5 students  
**Industry Partner**: Anthropic (AI Research Company)  
**Dataset Size**: 2.5M+ synthetic records

## Executive Summary

This capstone project challenges graduate students to answer a critical business question facing AI companies: **Does investing in rigorous offline model evaluations translate to measurable improvements in user engagement and revenue?**

Students will work with realistic synthetic data spanning 6 months of user interactions, model evaluation scores, and subscription conversions to establish causal relationships between model quality improvements and key business metrics.

## Business Context

AI companies face a fundamental trade-off: comprehensive model testing requires significant resources (human evaluators, compute time, expert hours), but the ROI on these investments remains unclear. This project simulates a scenario where:

- Three model versions (v1.0, v1.1, v1.2) were deployed sequentially
- Each version underwent extensive offline evaluation (human ratings + synthetic benchmarks)
- 100,000 users interacted with these models over 26 weeks
- The company needs to determine: **Should we continue investing in expensive evaluation processes?**

## Core Research Questions

### 1. Causality: Model Quality → User Engagement
*Does a demonstrably higher quality model (as measured by offline evaluations) causally increase user engagement?*

**Key Metrics**:
- Sessions per week
- Prompts per session  
- User sentiment scores
- Session duration

**Challenge**: Seasonal trends, marketing campaigns, and user heterogeneity confound the relationship.

### 2. Monetization: Model Quality → Subscription Conversion
*Does sustained exposure to higher quality models increase the probability of converting from free to paid subscriber?*

**Key Metrics**:
- Conversion rate (free → paid)
- Time to conversion
- Subscription retention

**Challenge**: Self-selection bias (early adopters differ from later users) and baseline engagement differences.

### 3. Enterprise Data Limitations
*Can we infer model quality impacts for enterprise users when prompt classification data is unavailable due to Terms of Service restrictions?*

**Key Innovation**: Develop proxy variables (prompt length, session duration) to extend causal analysis to enterprise segment.

## Dataset Description

### Three Interconnected Tables

#### A. Offline Model Evaluation Data (~50,000 records)
Contains quality assessments from human evaluators and synthetic benchmarks for three model versions deployed at weeks 1, 8, and 16.

**Key Variables**:
- `model_version`: v1.0, v1.1, v1.2
- `human_rating`: 1-5 scale ratings from expert evaluators
- `synthetic_metric`: 0-100 automated benchmark scores
- `eval_prompt_category`: Coding, Creative Writing, Math/Logic, etc.
- `cost_of_evaluation`: USD spent per evaluation

**Statistical Property**: Correlation ρ(human_rating, synthetic_metric) ≈ 0.82 (strong but imperfect)

#### B. User Engagement Time-Series (~2,000,000 records)
Weekly session logs tracking how users interacted with different model versions.

**Key Variables**:
- `user_id`: Links to demographics table
- `week`: 1-26 (6-month observation period)
- `total_prompts`: Count of AI interactions
- `user_sentiment_score`: -1 to 1 (derived from feedback)
- `model_version_used`: Which model the user was exposed to
- `prompt_length_avg`: Proxy variable for enterprise analysis

**Realistic Challenges**:
- 15% missing sentiment scores (logging failures)
- Seasonal spike: +20% engagement in weeks 20-26
- Correlation with quality is mild (ρ ≈ 0.25), indicating confounding

#### C. User Demographics & Subscription Data (100,000 records)
Static user characteristics and subscription outcomes measured at week 26.

**Key Variables**:
- `is_subscriber`: Boolean outcome variable
- `user_type`: Consumer (70%) vs Enterprise (30%)
- `pre_project_engagement_score`: Baseline engagement before week 1
- `is_treatment_group`: Exposed primarily to v1.1+ models
- `signup_date`: Controls for cohort effects

**Ground Truth Effects** (embedded in synthetic data):
- Overall conversion rate: 8%
- High pre-engagement (>70): 18% conversion
- Treatment effect: +4 percentage points (10% vs 6%)

## Download Datasets

All datasets have been generated and are ready for analysis. Download the CSV files below:

### Dataset Files

| File | Records | Size | Description |
|------|---------|------|-------------|
| [offline_model_evaluation.csv](offline_model_evaluation.csv) | 50,000 | 15.6 MB | Model evaluation scores from human raters and automated benchmarks |
| [user_demographics_subscription.csv](user_demographics_subscription.csv) | 100,000 | 42.3 MB | User characteristics and subscription outcomes |
| [user_engagement_timeseries.csv](user_engagement_timeseries.csv) | 1,500,980 | 360.7 MB | Weekly engagement metrics and session data |

**Total Dataset Size**: 2.5M+ records, ~418 MB

### Dataset Summary Statistics

**Offline Model Evaluation Data**:
- Model versions: v1.0 (15,000 evals), v1.1 (18,000 evals), v1.2 (17,000 evals)
- Human-synthetic correlation: ρ ≈ 0.517
- Evaluation categories: Coding, Creative Writing, Math/Logic, General QA, Scientific

**User Demographics**:
- Total users: 100,000
- Subscribers: 8,922 (8.92% conversion rate)
- Treatment group: 84,182 (84.18%)
- Enterprise users: 30,165 (30.2%)

**User Engagement**:
- Total sessions: 1,500,980
- Week range: 1-26 (6 months)
- Missing sentiment scores: 225,789 (15.0%)
- Average prompts per session: 10.34
- Correlation(prompts, model_quality): 0.345

## Technical Methodology

### Causal Inference Techniques Required

#### 1. Difference-in-Differences (DiD)
Students must implement a DiD regression with user and week fixed effects to estimate the causal effect of model deployment on engagement.

**Model Specification**:
```
Engagement_it = β₀ + β₁·Treatment_i + β₂·Post_t + β₃·(Treatment_i × Post_t) + γ·X_it + δ_i + τ_t + ε_it
```

Where β₃ is the DiD estimator (causal effect of interest).

**Key Assumption to Test**: Parallel trends in pre-treatment period (weeks 1-7)

#### 2. Propensity Score Matching (PSM)
For the conversion analysis, students must:
1. Estimate propensity scores (probability of treatment)
2. Match treatment and control users on observables
3. Calculate Average Treatment Effect (ATE) with confidence intervals
4. Conduct sensitivity analysis (Rosenbaum bounds)

#### 3. Proxy Variable Development
Since enterprise users lack prompt classification data, students must:
- Validate proxy variables (prompt_length_avg, session_duration) in consumer segment
- Apply validated proxies to enterprise segment
- Compare effect sizes across segments

### Data Quality Challenges (Learning Opportunities)

1. **Missing Data**: 15% of sentiment scores are NULL → Require multiple imputation
2. **Confounding**: Seasonal trends and marketing campaigns → Need time fixed effects
3. **Selection Bias**: Treatment assignment not random → Use PSM or IPW
4. **Outliers**: Some users have extreme engagement (bots?) → Winsorization or robust regression
5. **Enterprise Constraints**: 30% of data lacks prompt categories → Proxy variable innovation

## Learning Objectives

By completing this project, students will:

1. **Master Causal Inference**: Apply DiD, PSM, and instrumental variables to observational data
2. **Handle Real-World Data Issues**: Missing values, outliers, confounding, measurement error
3. **Communicate Technical Findings**: Translate statistical results into business recommendations
4. **Work with Large Datasets**: Process and analyze 2.5M+ records efficiently
5. **Develop Domain Expertise**: Understand AI product metrics and evaluation practices
6. **Practice Reproducible Research**: Document methodology, assumptions, and sensitivity analyses

## Deliverables

### 1. Technical Report (20-25 pages)
- Hypothesis formulation with mathematical notation
- Causal inference model specifications
- Statistical test results with visualizations
- Sensitivity analyses and robustness checks
- Business recommendations with confidence intervals

### 2. Code Repository
- Data cleaning and preprocessing scripts
- Causal inference implementations (DiD, PSM)
- Visualization notebooks
- Reproducibility documentation

### 3. Executive Presentation (15 minutes)
- Business problem framing
- Key findings (effect sizes, significance)
- Confidence in causal claims
- Investment recommendations
- Limitations and future research

### 4. Data Quality Audit
- Missing data patterns
- Outlier detection and handling
- Balance tests (treatment vs control)
- Validation of causal assumptions

## Tools & Prerequisites

**Required Skills**:
- Regression analysis and hypothesis testing
- Causal inference fundamentals (confounding, selection bias)
- Python or R programming
- Data visualization

**Recommended Packages**:
- Python: `pandas`, `numpy`, `statsmodels`, `scikit-learn`, `matplotlib`, `seaborn`
- R: `tidyverse`, `MatchIt`, `lme4`, `CausalImpact`

**Computational Resources**:
- Standard laptop sufficient (dataset fits in memory)
- Optional: Cloud computing for parallelized matching algorithms

## Timeline

### Weeks 1-2: Data Exploration & Hypothesis Formation
- Generate synthetic datasets
- Exploratory data analysis (distributions, correlations, trends)
- Formulate null and alternative hypotheses
- Identify potential confounders

### Weeks 3-5: Causal Analysis - Engagement
- Implement DiD regression with fixed effects
- Test parallel trends assumption
- Run robustness checks (alternative specifications, placebo tests)
- Visualize treatment effects over time

### Weeks 6-8: Causal Analysis - Conversion
- Estimate propensity scores
- Perform matching (nearest neighbor, kernel)
- Calculate ATE with bootstrapped confidence intervals
- Conduct sensitivity analysis

### Weeks 9-10: Enterprise Analysis & Extensions
- Validate proxy variables
- Compare consumer vs enterprise effects
- Test for effect heterogeneity (by country, role, baseline engagement)

### Weeks 11-12: Final Report & Presentation
- Synthesize findings
- Develop business recommendations
- Prepare visualizations and slides
- Practice presentation

## Expected Findings (For Instructors)

The synthetic data embeds the following ground truth effects:

1. **Engagement Effect**: DiD estimate ≈ +2.5 prompts/week (p < 0.01)
2. **Conversion Effect**: ATE ≈ +4 percentage points (p < 0.05)
3. **ROI Calculation**: Based on evaluation costs and subscriber lifetime value
4. **Effect Heterogeneity**: Larger effects for users with high baseline engagement

Students should conclude that model quality investments **do** have measurable positive effects, but the magnitude is moderate and requires careful causal analysis to detect.

## Real-World Applications

This project mirrors actual business analytics challenges at:
- **AI Companies**: Anthropic, OpenAI, Google DeepMind
- **Product Analytics Teams**: Meta, Netflix, Spotify
- **E-commerce**: A/B testing and personalization impact
- **Healthcare**: Treatment effect estimation from observational data

Skills developed are directly applicable to roles in:
- Applied Science / Research Science
- Data Science (Causal Inference focus)
- Product Analytics
- Business Intelligence
- Econometrics / Policy Analysis

## Resources & Support

**Dataset Access**: [Download synthetic datasets](#) (CSV format, 2.5M+ records)

**Starter Code**: Python notebook with data loading and basic EDA

**Office Hours**: Weekly sessions for methodology questions

**Reading List**:
- Angrist & Pischke: "Mostly Harmless Econometrics"
- Pearl, Glymour & Jewell: "Causal Inference in Statistics"
- Imbens & Rubin: "Causal Inference for Statistics, Social, and Biomedical Sciences"

## Contact

**Project Sponsor**: Boulder Gear Lab  
**Website**: [www.bouldergearlab.com/data-projects](https://www.bouldergearlab.com/data-projects/)  
**Questions**: Contact your faculty advisor or teaching assistant

---

## Why This Project Matters

As AI systems become more sophisticated and expensive to develop, companies must make data-driven decisions about where to invest limited resources. This project teaches students to:

1. **Think causally** in complex business environments
2. **Handle imperfect data** with rigor and transparency
3. **Translate statistics** into actionable business insights
4. **Build credible evidence** despite observational data constraints

These skills are increasingly valuable as more companies move beyond simple A/B testing toward sophisticated causal inference for strategic decision-making.

**Ready to start?** Download the datasets and begin your analysis. Remember: in the real world, you won't know the ground truth—your job is to build the most credible causal argument possible given the data constraints. Good luck!