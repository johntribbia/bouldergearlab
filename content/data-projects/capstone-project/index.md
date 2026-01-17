---
title: "Capstone Project: Quantifying the Business Impact of AI Model Quality Investments"
date: 2026-01-01
banner: "capstone-banner.jpg"
tags: ['data project']
categories: ['data project']
description: ""
draft: false
---

## Project Overview

**Dataset Size**: 2.5M+ synthetic records

## Executive Summary

This capstone project challenges students to answer a critical business question facing AI companies: **Does investing in rigorous offline model evaluations translate to measurable improvements in user engagement and revenue?**

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

#### B. User Engagement Time-Series (~2,000,000 records)
Weekly session logs tracking how users interacted with different model versions.

**Key Variables**:
- `user_id`: Links to demographics table
- `week`: 1-26 (6-month observation period)
- `total_prompts`: Count of AI interactions
- `user_sentiment_score`: -1 to 1 (derived from feedback)
- `model_version_used`: Which model the user was exposed to
- `prompt_length_avg`: Proxy variable for enterprise analysis

#### C. User Demographics & Subscription Data (100,000 records)
Static user characteristics and subscription outcomes measured at week 26.

**Key Variables**:
- `is_subscriber`: Boolean outcome variable
- `user_type`: Consumer (70%) vs Enterprise (30%)
- `pre_project_engagement_score`: Baseline engagement before week 1
- `is_treatment_group`: Exposed primarily to v1.1+ models
- `signup_date`: Controls for cohort effects

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

---

## Why This Project Matters

As AI systems become more sophisticated and expensive to develop, companies must make data-driven decisions about where to invest limited resources. This project teaches students to:

1. **Think causally** in complex business environments
2. **Handle imperfect data** with rigor and transparency
3. **Translate statistics** into actionable business insights
4. **Build credible evidence** despite observational data constraints

These skills are increasingly valuable as more companies move beyond simple A/B testing toward sophisticated causal inference for strategic decision-making.

**Ready to start?** Download the datasets and begin your analysis. Remember: in the real world, you won't know the ground truth — your job is to build the most credible causal argument possible given the data constraints. Good luck!