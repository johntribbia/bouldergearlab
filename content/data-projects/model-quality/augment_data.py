"""
Augment user_engagement_timeseries.csv with:
  1. Prompt category counts (prompts_coding, prompts_creative_writing, etc.)
  2. active_days_observed (distinct days with ≥1 session, 1-7)
     - Includes a KNOWN causal effect of within-version quality (Q_it_c)
       on active_days so the downstream estimator can be validated as a
       calibration recovery exercise.

Category distribution is derived from user role + model version quality patterns,
consistent with how the original data-generator.py created user demographics.
Uses the same RANDOM_SEED=42 for reproducibility.

The augmented CSV replaces the original with new columns appended.
"""

import pandas as pd
import numpy as np

RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

print("=" * 70)
print("Augmenting user_engagement_timeseries.csv")
print("=" * 70)

# Load data
print("Loading datasets...")
engage_df = pd.read_csv("user_engagement_timeseries.csv")
demo_df   = pd.read_csv("user_demographics_subscription.csv")
eval_df   = pd.read_csv("offline_model_evaluation.csv")

print(f"  Engagement rows:  {len(engage_df):,}")
print(f"  Users:            {demo_df.shape[0]:,}")
print(f"  Evaluations:      {eval_df.shape[0]:,}")

# ----------------------------------------------------------------
# 1. Prompt category columns
# ----------------------------------------------------------------
# The eval data uses these 5 categories:
categories = sorted(eval_df['eval_prompt_category'].unique())
print(f"\nCategories from eval data: {categories}")

# Map user roles to category preferences (Dirichlet concentration vectors).
# Software Engineers -> Coding heavy; Writers -> Creative Writing; etc.
# These are alpha vectors for a Dirichlet draw.
role_category_priors = {
    #                    Coding  Creative  General QA  Math/Logic  Scientific
    'Software Engineer': [6.0,    1.0,       2.0,        3.0,        1.5],
    'Data Scientist':    [4.0,    0.5,       2.0,        4.5,        3.0],
    'Student':           [2.5,    2.0,       3.0,        3.0,        2.5],
    'Researcher':        [2.0,    1.0,       2.0,        2.5,        5.0],
    'Writer':            [0.5,    6.0,       2.5,        0.5,        0.5],
    'Business Analyst':  [2.0,    1.0,       4.0,        2.0,        1.5],
    'Other':             [2.0,    2.0,       3.0,        2.0,        2.0],
}

# Join role info
engage_df = engage_df.merge(
    demo_df[['user_id', 'industry_role', 'pre_project_engagement_score']],
    on='user_id', how='left'
)

# For each user, draw a stable category preference from Dirichlet seeded by user_id
print("\nGenerating per-user category preferences from role-based Dirichlet priors...")

unique_users = engage_df['user_id'].unique()
user_role_map = dict(zip(demo_df['user_id'], demo_df['industry_role']))

user_prefs = {}
for uid in unique_users:
    # Seed per user for stability
    uid_seed = int(uid.replace('USR_', '')) + RANDOM_SEED
    rng = np.random.RandomState(uid_seed)
    
    role = user_role_map.get(uid, 'Other')
    alpha = role_category_priors.get(role, role_category_priors['Other'])
    
    # Draw from Dirichlet
    prefs = rng.dirichlet(alpha)
    user_prefs[uid] = prefs

print(f"  Generated preferences for {len(user_prefs):,} users")

# Now distribute total_prompts across categories for each row
print("Distributing prompts across categories...")

cat_columns = [f"prompts_{c.lower().replace(' ', '_').replace('/', '_')}" for c in categories]
print(f"  Category columns: {cat_columns}")

# Vectorized approach: build user preference matrix
user_ids_ordered = engage_df['user_id'].values
pref_matrix = np.array([user_prefs[uid] for uid in user_ids_ordered])

# For each row, sample from multinomial(total_prompts, prefs)
# But multinomial row-by-row is slow for 1.5M rows. Use a fast approach:
total_prompts = engage_df['total_prompts'].values

# Add small per-session noise to preferences (so same user has slight week-to-week variation)
session_noise = np.random.dirichlet(np.ones(len(categories)) * 50, size=len(engage_df))
noisy_prefs = 0.85 * pref_matrix + 0.15 * session_noise  # 85% stable, 15% noise
noisy_prefs = noisy_prefs / noisy_prefs.sum(axis=1, keepdims=True)

# Multinomial draw per row
print("  Running multinomial draws (this may take a moment)...")
cat_counts = np.zeros((len(engage_df), len(categories)), dtype=int)
for i in range(len(engage_df)):
    cat_counts[i] = np.random.multinomial(total_prompts[i], noisy_prefs[i])

for j, col in enumerate(cat_columns):
    engage_df[col] = cat_counts[:, j]

# Validate: category counts should sum to total_prompts
row_sums = cat_counts.sum(axis=1)
assert np.all(row_sums == total_prompts), "Category counts don't sum to total_prompts!"
print(f"  ✓ Validated: all rows sum correctly")

# ----------------------------------------------------------------
# 1b. Compute Q_it_c for causal mechanism injection
# ----------------------------------------------------------------
# Build quality lookup: mean human_rating by category × version
# This mirrors the R script's Step 1.
TRUE_BETA = 1.0  # Known causal effect on log-odds scale

print(f"\n{'='*70}")
print(f"Computing Q_it_c for causal injection (TRUE_BETA = {TRUE_BETA})")
print(f"{'='*70}")

quality_lookup = eval_df.groupby(
    ['eval_prompt_category', 'model_version']
)['human_rating'].mean()

# Quality matrix: rows=categories (alphabetical), columns=versions
versions_ordered = ['v1.0', 'v1.1', 'v1.2']
q_matrix = np.array([
    [quality_lookup[(cat, v)] for v in versions_ordered]
    for cat in categories
])
print(f"  Quality matrix (categories × versions):")
for j, cat in enumerate(categories):
    print(f"    {cat:>20s}: {q_matrix[j]}")

# Build TRUE user preference matrix (from Dirichlet draws, not noisy counts)
pref_matrix_true = np.array([user_prefs[uid] for uid in engage_df['user_id'].values])

# Map version strings to column indices
version_to_idx = {v: i for i, v in enumerate(versions_ordered)}
version_idx = engage_df['model_version_used'].map(version_to_idx).values

# Compute Q_it = Σ w_ic × q_cv for each row (vectorized)
Q_it = np.zeros(len(engage_df))
for j in range(len(categories)):
    q_by_version = q_matrix[j, version_idx]
    Q_it += pref_matrix_true[:, j] * q_by_version

# Center within version to isolate within-version variation
Q_it_c = np.zeros_like(Q_it)
for v in versions_ordered:
    mask = engage_df['model_version_used'].values == v
    v_mean = Q_it[mask].mean()
    Q_it_c[mask] = Q_it[mask] - v_mean
    print(f"  {v}: Q_it mean={v_mean:.4f}, Q_it_c sd={Q_it_c[mask].std():.4f}")

print(f"  Overall Q_it_c: mean={Q_it_c.mean():.6f}, sd={Q_it_c.std():.4f}")
print(f"  TRUE_BETA = {TRUE_BETA}")
print(f"  Expected effect per 1-SD: {TRUE_BETA * Q_it_c.std():.4f} log-odds")

# ----------------------------------------------------------------
# 2. active_days_observed
# ----------------------------------------------------------------
# Simulate distinct active days in 0-7 range based on session patterns.
# Use a model: more sessions + longer duration -> more active days, with noise.
# This creates a proper count variable, NOT a rescaled continuous one.

print("\nGenerating active_days_observed...")

# Base probability of being active on any given day of the week
# depends on engagement level (pre_project_engagement_score) and session intensity
pre_eng = engage_df['pre_project_engagement_score'].fillna(30).values
session_dur = engage_df['session_duration_min'].values
n_prompts = total_prompts

# Logistic model for daily activity probability
# Higher engagement and more prompts -> higher probability of being active each day
log_odds_base = -1.5 + 0.02 * pre_eng + 0.03 * n_prompts

# Model quality effect: better models -> slightly more active days
model_quality_map = {'v1.0': 0.0, 'v1.1': 0.15, 'v1.2': 0.30}
quality_bonus = engage_df['model_version_used'].map(model_quality_map).values
log_odds_base += quality_bonus

# *** CAUSAL MECHANISM: within-version quality -> active days ***
# This is the known effect the downstream estimator should recover.
log_odds_base += TRUE_BETA * Q_it_c
print(f"  Injected TRUE_BETA * Q_it_c into active_days log-odds")
print(f"  Log-odds contribution: mean={TRUE_BETA * Q_it_c.mean():.6f}, "
      f"sd={TRUE_BETA * Q_it_c.std():.4f}")

# Convert to probability
p_active = 1 / (1 + np.exp(-log_odds_base))
p_active = np.clip(p_active, 0.05, 0.95)  # avoid degenerate cases

# For each row, simulate 7 Bernoulli trials (one per day of week)
active_days = np.random.binomial(7, p_active)
# Ensure at least 1 active day (user had at least one session that week)
active_days = np.maximum(active_days, 1)

engage_df['active_days_observed'] = active_days

print(f"  active_days_observed: mean={active_days.mean():.2f}, "
      f"min={active_days.min()}, max={active_days.max()}")
print(f"  Distribution: {dict(zip(*np.unique(active_days, return_counts=True)))}")

# ----------------------------------------------------------------
# 3. Clean up and save
# ----------------------------------------------------------------
# Drop the helper columns we joined
engage_df = engage_df.drop(columns=['industry_role', 'pre_project_engagement_score'])

# Reorder so new columns are at the end
original_cols = [
    'session_id', 'user_id', 'week', 'total_prompts',
    'avg_response_time_sec', 'user_sentiment_score',
    'deployment_week', 'model_version_used',
    'prompt_length_avg', 'session_duration_min'
]
new_cols = cat_columns + ['active_days_observed']
engage_df = engage_df[original_cols + new_cols]

print(f"\nFinal columns: {list(engage_df.columns)}")
print(f"Final shape: {engage_df.shape}")

# Sanity checks
print("\nSanity checks:")
print(f"  Category sum == total_prompts: {(engage_df[cat_columns].sum(axis=1) == engage_df['total_prompts']).all()}")
print(f"  active_days_observed in [1,7]: {(engage_df['active_days_observed'] >= 1).all() and (engage_df['active_days_observed'] <= 7).all()}")
print(f"  No NaN in new columns: {engage_df[new_cols].isna().sum().sum() == 0}")

# Show category distribution by role (spot check)
merged_check = engage_df.merge(
    pd.read_csv("user_demographics_subscription.csv")[['user_id', 'industry_role']],
    on='user_id', how='left'
)
print("\nMean category proportions by role (should reflect role priors):")
for role in ['Software Engineer', 'Writer', 'Data Scientist', 'Researcher']:
    subset = merged_check[merged_check['industry_role'] == role]
    proportions = subset[cat_columns].sum() / subset['total_prompts'].sum()
    top_cat = proportions.idxmax()
    print(f"  {role:>25s}: top = {top_cat} ({proportions[top_cat]:.1%})")

# Save
print("\nSaving augmented CSV...")
engage_df.to_csv("user_engagement_timeseries.csv", index=False)
print(f"  ✓ Saved user_engagement_timeseries.csv ({len(engage_df):,} rows)")
print("\nDone.")
