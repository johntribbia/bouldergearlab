"""
Synthetic dataset generator for the model quality -> user engagement study.

Creates three CSV files: offline model evaluations, user demographics and
subscription status, and a weekly engagement time-series (~1.5M session rows).
Run this before augment_data.py.

Author: Boulder Gear Lab
Python: 3.9+
Dependencies: pandas, numpy
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta

RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

print(f"data-generator.py  |  seed={RANDOM_SEED}")
print()


def generate_evaluation_data(n_v10=15000, n_v11=18000, n_v12=17000):
    """Offline evaluation records with correlated human and synthetic metrics."""
    print("--- Evaluation data ---")
    
    model_configs = [
        {'version': 'v1.0', 'deploy_week': 1, 'avg_rating': 3.2, 'avg_synthetic': 65, 'count': n_v10},
        {'version': 'v1.1', 'deploy_week': 8, 'avg_rating': 3.7, 'avg_synthetic': 75, 'count': n_v11},
        {'version': 'v1.2', 'deploy_week': 16, 'avg_rating': 4.1, 'avg_synthetic': 85, 'count': n_v12}
    ]
    
    categories = ['Coding', 'Creative Writing', 'Math/Logic', 'General QA', 'Scientific']
    
    all_records = []
    eval_id = 1
    
    for config in model_configs:
        for _ in range(config['count']):
            # Generate correlated human rating and synthetic metric (ρ ≈ 0.82)
            base_quality = np.random.uniform(0, 1)
            correlation_strength = 0.82
            independent_noise = np.sqrt(1 - correlation_strength**2)
            
            # Human rating (1-5 scale)
            human_noise = np.random.normal(0, 0.7)
            human_rating = config['avg_rating'] + base_quality * 1.5 + human_noise
            human_rating = int(np.clip(np.round(human_rating), 1, 5))
            
            # Synthetic metric (0-100 scale) - correlated with human rating
            synthetic_noise = np.random.normal(0, 8) * independent_noise
            synthetic_metric = config['avg_synthetic'] + base_quality * 25 + synthetic_noise
            synthetic_metric = np.clip(synthetic_metric, 0, 100)
            
            # Cost increases with rating quality
            cost = 10 + np.random.uniform(0, 15) + (human_rating - 1) * 2
            
            # Random evaluation date within 6-month period
            days_offset = np.random.randint(0, 180)
            eval_date = datetime(2024, 1, 1) + timedelta(days=days_offset)
            
            all_records.append({
                'evaluation_id': f'EVAL_{eval_id:06d}',
                'model_version': config['version'],
                'eval_prompt_category': np.random.choice(categories),
                'human_rating': human_rating,
                'synthetic_metric': round(synthetic_metric, 2),
                'cost_of_evaluation': round(cost, 2),
                'evaluation_date': eval_date.strftime('%Y-%m-%d'),
                'deployment_week': config['deploy_week']
            })
            eval_id += 1
    
    df = pd.DataFrame(all_records)
    
    correlation = df['human_rating'].corr(df['synthetic_metric'])
    print(f"  {len(df):,} records  |  ρ(human, synthetic) = {correlation:.3f}")
    print()
    
    return df


def generate_user_demographics(n_users=100000):
    """User demographics, subscription status, and treatment assignment."""
    print("--- User demographics ---")
    
    countries = ['US', 'UK', 'Canada', 'Germany', 'France', 'India', 'Other']
    country_weights = [0.35, 0.15, 0.10, 0.10, 0.08, 0.12, 0.10]
    
    roles = ['Software Engineer', 'Data Scientist', 'Student', 'Researcher', 
             'Writer', 'Business Analyst', 'Other']
    role_weights = [0.25, 0.20, 0.15, 0.12, 0.10, 0.10, 0.08]
    
    user_types = ['Consumer', 'Enterprise']
    
    records = []
    
    for i in range(1, n_users + 1):
        # Pre-project engagement score (baseline)
        pre_engagement = np.random.beta(2, 3) * 100  # Skewed toward lower values
        
        # User type
        user_type = np.random.choice(user_types, p=[0.7, 0.3])
        
        # Signup date influences treatment assignment
        signup_day = np.random.randint(0, 180)
        signup_date = datetime(2024, 6, 15) + timedelta(days=signup_day)
        
        # Treatment group: users who signed up after week 8 (day 56) 
        # or were randomly assigned to new model
        is_treatment = (signup_day > 56) or (np.random.random() < 0.5)
        
        # Conversion probability depends on pre-engagement and treatment
        if pre_engagement > 70:
            base_conv_prob = 0.18
        elif pre_engagement > 40:
            base_conv_prob = 0.08
        else:
            base_conv_prob = 0.03
        
        # Treatment effect: +50% relative increase in conversion
        if is_treatment:
            conv_prob = base_conv_prob * 1.5
        else:
            conv_prob = base_conv_prob
        
        is_subscriber = np.random.random() < conv_prob
        
        # Total weeks active (between 4-26 weeks)
        total_weeks = np.random.randint(4, 27)
        
        records.append({
            'user_id': f'USR_{i:06d}',
            'is_subscriber': is_subscriber,
            'signup_date': signup_date.strftime('%Y-%m-%d'),
            'user_country': np.random.choice(countries, p=country_weights),
            'industry_role': np.random.choice(roles, p=role_weights),
            'user_type': user_type,
            'pre_project_engagement_score': round(pre_engagement, 2),
            'is_treatment_group': is_treatment,
            'total_weeks_active': total_weeks
        })
    
    df = pd.DataFrame(records)

    overall_conv   = df['is_subscriber'].mean() * 100
    treatment_conv = df[df['is_treatment_group']]['is_subscriber'].mean() * 100
    control_conv   = df[~df['is_treatment_group']]['is_subscriber'].mean() * 100
    enterprise_pct = (df['user_type'] == 'Enterprise').mean() * 100

    print(f"  {len(df):,} users  |  conversion {overall_conv:.1f}%  "
          f"(treatment {treatment_conv:.1f}% / control {control_conv:.1f}%)")
    print()

    return df


def generate_engagement_data(users_df):
    """Weekly session records for all users across a 26-week window."""
    print("--- Engagement time-series (this takes ~2 minutes) ---")
    
    model_schedule = [
        {'version': 'v1.0', 'start_week': 1, 'end_week': 7, 'quality': 3.2},
        {'version': 'v1.1', 'start_week': 8, 'end_week': 15, 'quality': 3.7},
        {'version': 'v1.2', 'start_week': 16, 'end_week': 26, 'quality': 4.1}
    ]
    
    all_sessions = []
    session_id = 1
    
    # Process in batches for memory efficiency
    batch_size = 10000
    n_batches = int(np.ceil(len(users_df) / batch_size))
    
    for batch_idx in range(n_batches):
        start_idx = batch_idx * batch_size
        end_idx = min((batch_idx + 1) * batch_size, len(users_df))
        batch_users = users_df.iloc[start_idx:end_idx]
        
        if (batch_idx + 1) % 5 == 0:
            print(f"    Processing batch {batch_idx + 1}/{n_batches}...")
        
        for _, user in batch_users.iterrows():
            base_engagement = user['pre_project_engagement_score']
            is_treatment = user['is_treatment_group']
            is_enterprise = user['user_type'] == 'Enterprise'
            total_weeks = user['total_weeks_active']
            
            for week in range(1, total_weeks + 1):
                # Determine model version for this week
                model = next((m for m in model_schedule 
                            if m['start_week'] <= week <= m['end_week']), 
                           model_schedule[-1])
                
                # Base prompts influenced by pre-engagement
                base_prompts = 5 + (base_engagement / 10)
                
                # Treatment effect: +2.5 prompts for v1.1+ models (DiD effect)
                if is_treatment and week >= 8:
                    base_prompts += 2.5
                
                # Seasonal trend: +20% engagement in weeks 20-26
                if week >= 20:
                    base_prompts *= 1.2
                
                # Add noise
                total_prompts = int(np.clip(
                    np.round(base_prompts + np.random.normal(0, 2.5)), 
                    1, 300
                ))
                
                # Response time improves with model quality
                base_response_time = 3.0 - (model['quality'] - 3.2) * 0.5
                avg_response_time = np.clip(
                    base_response_time + np.random.normal(0, 0.4),
                    0.5, 10.0
                )
                
                # Sentiment correlates with model quality and engagement
                base_sentiment = 0.3 + (model['quality'] - 3.2) * 0.2 + (base_engagement / 200)
                sentiment = np.clip(
                    base_sentiment + np.random.normal(0, 0.2),
                    -1.0, 1.0
                )
                
                # 15% missing sentiment scores
                has_sentiment = np.random.random() > 0.15
                
                # Prompt length as enterprise proxy
                base_length = 80 + np.random.uniform(0, 60)
                if is_enterprise:
                    base_length += 20  # Enterprise users write longer prompts
                prompt_length = base_length
                
                # Session duration
                session_duration = 10 + total_prompts * 2 + np.random.uniform(0, 15)
                
                all_sessions.append({
                    'session_id': f'SES_{session_id:07d}',
                    'user_id': user['user_id'],
                    'week': week,
                    'total_prompts': total_prompts,
                    'avg_response_time_sec': round(avg_response_time, 2),
                    'user_sentiment_score': round(sentiment, 3) if has_sentiment else None,
                    'deployment_week': model['start_week'],
                    'model_version_used': model['version'],
                    'prompt_length_avg': round(prompt_length, 1),
                    'session_duration_min': round(session_duration, 1)
                })
                
                session_id += 1
    
    df = pd.DataFrame(all_sessions)

    missing_sentiment = df['user_sentiment_score'].isna().mean() * 100
    avg_prompts = df['total_prompts'].mean()

    print(f"  {len(df):,} session records  |  missing sentiment {missing_sentiment:.1f}%  "
          f"|  mean prompts/week {avg_prompts:.1f}")
    print()

    return df


def verify_data_quality(eval_df, demo_df, engage_df):
    """Basic sanity checks across the three tables."""
    print("--- Verification ---")
    total = len(eval_df) + len(demo_df) + len(engage_df)
    print(f"  {total:,} total records  "
          f"({len(eval_df):,} evals / {len(demo_df):,} users / {len(engage_df):,} sessions)")

    corr = eval_df['human_rating'].corr(eval_df['synthetic_metric'])
    print(f"  ρ(human, synthetic) = {corr:.3f}  (target ~0.82)")

    sub_rate   = demo_df['is_subscriber'].mean() * 100
    treat_rate = demo_df['is_treatment_group'].mean() * 100
    print(f"  Subscription rate: {sub_rate:.1f}%  |  treatment share: {treat_rate:.1f}%")

    integ_ok = set(engage_df['user_id'].unique()).issubset(
                   set(demo_df['user_id'].unique()))
    print(f"  Referential integrity: {'pass' if integ_ok else 'FAIL'}")
    print()


def save_datasets(eval_df, demo_df, engage_df, output_dir='./'):
    """Write all three tables to CSV."""
    print("--- Saving files ---")
    
    files = [
        (eval_df, 'offline_model_evaluation.csv'),
        (demo_df, 'user_demographics_subscription.csv'),
        (engage_df, 'user_engagement_timeseries.csv')
    ]
    
    for df, filename in files:
        filepath = output_dir + filename
        df.to_csv(filepath, index=False)
        print(f"  {filename}  ({len(df):,} rows)")



def main():
    eval_df   = generate_evaluation_data()
    demo_df   = generate_user_demographics(n_users=100000)
    engage_df = generate_engagement_data(demo_df)
    verify_data_quality(eval_df, demo_df, engage_df)
    save_datasets(eval_df, demo_df, engage_df)
    print("Done.")


if __name__ == "__main__":
    main()