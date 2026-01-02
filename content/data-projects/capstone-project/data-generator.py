"""
AI Model Quality Impact Analysis - Synthetic Dataset Generator
================================================================
Generates 2.5M+ records across three interconnected tables for capstone project.

Author: Boulder Gear Lab
Version: 1.0
Python: 3.8+
Dependencies: pandas, numpy
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Tuple, List
import warnings
warnings.filterwarnings('ignore')

# Set random seed for reproducibility
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

print("=" * 70)
print("AI Model Quality Impact Analysis - Dataset Generator")
print("=" * 70)
print(f"Random Seed: {RANDOM_SEED} (for reproducibility)")
print()


def generate_evaluation_data(n_v10: int = 15000, 
                             n_v11: int = 18000, 
                             n_v12: int = 17000) -> pd.DataFrame:
    """
    Generate offline model evaluation data with correlated metrics.
    
    Parameters:
    -----------
    n_v10, n_v11, n_v12 : int
        Number of evaluations per model version
    
    Returns:
    --------
    pd.DataFrame with evaluation records
    """
    print("Generating Offline Model Evaluation Data...")
    
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
    
    # Verify correlation
    correlation = df['human_rating'].corr(df['synthetic_metric'])
    print(f"  ✓ Generated {len(df):,} evaluation records")
    print(f"  ✓ Correlation ρ(human_rating, synthetic_metric) = {correlation:.3f}")
    print(f"  ✓ Model versions: {df['model_version'].unique().tolist()}")
    print()
    
    return df


def generate_user_demographics(n_users: int = 100000) -> pd.DataFrame:
    """
    Generate user demographic and subscription data.
    
    Parameters:
    -----------
    n_users : int
        Number of users to generate
    
    Returns:
    --------
    pd.DataFrame with user records
    """
    print("Generating User Demographics & Subscription Data...")
    
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
    
    # Calculate statistics
    overall_conv = df['is_subscriber'].mean() * 100
    treatment_conv = df[df['is_treatment_group']]['is_subscriber'].mean() * 100
    control_conv = df[~df['is_treatment_group']]['is_subscriber'].mean() * 100
    enterprise_pct = (df['user_type'] == 'Enterprise').mean() * 100
    
    print(f"  ✓ Generated {len(df):,} user records")
    print(f"  ✓ Overall conversion rate: {overall_conv:.2f}%")
    print(f"  ✓ Treatment group conversion: {treatment_conv:.2f}%")
    print(f"  ✓ Control group conversion: {control_conv:.2f}%")
    print(f"  ✓ Enterprise users: {enterprise_pct:.1f}%")
    print()
    
    return df


def generate_engagement_data(users_df: pd.DataFrame) -> pd.DataFrame:
    """
    Generate time-series engagement data for all users.
    
    Parameters:
    -----------
    users_df : pd.DataFrame
        User demographics dataframe
    
    Returns:
    --------
    pd.DataFrame with engagement session records
    """
    print("Generating User Engagement Time-Series Data...")
    print("  (This may take 1-2 minutes for 2M+ records...)")
    
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
    
    # Calculate statistics
    missing_sentiment = df['user_sentiment_score'].isna().mean() * 100
    avg_prompts = df['total_prompts'].mean()
    engagement_quality_corr = df['total_prompts'].corr(
        df['model_version_used'].map({'v1.0': 3.2, 'v1.1': 3.7, 'v1.2': 4.1})
    )
    
    print(f"  ✓ Generated {len(df):,} engagement session records")
    print(f"  ✓ Missing sentiment scores: {missing_sentiment:.1f}%")
    print(f"  ✓ Average prompts per session: {avg_prompts:.2f}")
    print(f"  ✓ Correlation(prompts, model_quality): {engagement_quality_corr:.3f}")
    print()
    
    return df


def verify_data_quality(eval_df: pd.DataFrame, 
                       demo_df: pd.DataFrame, 
                       engage_df: pd.DataFrame) -> None:
    """
    Verify data quality and statistical properties.
    """
    print("=" * 70)
    print("Data Quality Verification")
    print("=" * 70)
    
    # Total records
    total_records = len(eval_df) + len(demo_df) + len(engage_df)
    print(f"Total Records Generated: {total_records:,}")
    print()
    
    # Evaluation data checks
    print("Evaluation Data:")
    corr = eval_df['human_rating'].corr(eval_df['synthetic_metric'])
    print(f"  - Correlation ρ(human, synthetic): {corr:.4f} (target: ~0.82)")
    print(f"  - Model versions: {sorted(eval_df['model_version'].unique())}")
    print(f"  - Categories: {len(eval_df['eval_prompt_category'].unique())}")
    print()
    
    # Demographics checks
    print("Demographics Data:")
    print(f"  - Total users: {len(demo_df):,}")
    print(f"  - Subscribers: {demo_df['is_subscriber'].sum():,} ({demo_df['is_subscriber'].mean()*100:.2f}%)")
    print(f"  - Treatment group: {demo_df['is_treatment_group'].sum():,} ({demo_df['is_treatment_group'].mean()*100:.2f}%)")
    print(f"  - Enterprise users: {(demo_df['user_type']=='Enterprise').sum():,} ({(demo_df['user_type']=='Enterprise').mean()*100:.1f}%)")
    print()
    
    # Engagement checks
    print("Engagement Data:")
    print(f"  - Total sessions: {len(engage_df):,}")
    print(f"  - Unique users: {engage_df['user_id'].nunique():,}")
    print(f"  - Missing sentiment: {engage_df['user_sentiment_score'].isna().sum():,} ({engage_df['user_sentiment_score'].isna().mean()*100:.1f}%)")
    print(f"  - Week range: {engage_df['week'].min()} to {engage_df['week'].max()}")
    
    # Check referential integrity
    users_in_engagement = set(engage_df['user_id'].unique())
    users_in_demo = set(demo_df['user_id'].unique())
    integrity_check = users_in_engagement.issubset(users_in_demo)
    print(f"  - Referential integrity: {'✓ PASS' if integrity_check else '✗ FAIL'}")
    print()
    
    # Statistical properties for causal inference
    print("Causal Inference Properties:")
    treatment_users = demo_df[demo_df['is_treatment_group']]
    control_users = demo_df[~demo_df['is_treatment_group']]
    
    # Check balance
    pre_eng_diff = abs(treatment_users['pre_project_engagement_score'].mean() - 
                      control_users['pre_project_engagement_score'].mean())
    print(f"  - Pre-engagement balance: {pre_eng_diff:.2f} point difference")
    
    # DiD effect
    treatment_engage = engage_df[engage_df['user_id'].isin(treatment_users['user_id'])]
    pre_treatment = treatment_engage[treatment_engage['week'] < 8]['total_prompts'].mean()
    post_treatment = treatment_engage[treatment_engage['week'] >= 8]['total_prompts'].mean()
    did_effect = post_treatment - pre_treatment
    print(f"  - Embedded DiD effect: {did_effect:.2f} prompts/week")
    
    # Conversion effect
    treatment_conv = treatment_users['is_subscriber'].mean()
    control_conv = control_users['is_subscriber'].mean()
    ate_effect = (treatment_conv - control_conv) * 100
    print(f"  - Embedded ATE (conversion): {ate_effect:.2f} percentage points")
    print()


def save_datasets(eval_df: pd.DataFrame, 
                 demo_df: pd.DataFrame, 
                 engage_df: pd.DataFrame,
                 output_dir: str = './') -> None:
    """
    Save datasets to CSV files.
    """
    print("=" * 70)
    print("Saving Datasets to CSV Files...")
    print("=" * 70)
    
    files = [
        (eval_df, 'offline_model_evaluation.csv'),
        (demo_df, 'user_demographics_subscription.csv'),
        (engage_df, 'user_engagement_timeseries.csv')
    ]
    
    for df, filename in files:
        filepath = output_dir + filename
        df.to_csv(filepath, index=False)
        file_size_mb = df.memory_usage(deep=True).sum() / (1024 * 1024)
        print(f"  ✓ Saved: {filename}")
        print(f"    - Records: {len(df):,}")
        print(f"    - Size: ~{file_size_mb:.1f} MB")
        print()


def generate_sample_preview(eval_df: pd.DataFrame, 
                           demo_df: pd.DataFrame, 
                           engage_df: pd.DataFrame) -> None:
    """
    Print sample records from each dataset.
    """
    print("=" * 70)
    print("Sample Data Preview")
    print("=" * 70)
    print()
    
    print("Evaluation Data (first 3 records):")
    print(eval_df.head(3).to_string(index=False))
    print()
    
    print("Demographics Data (first 3 records):")
    print(demo_df.head(3).to_string(index=False))
    print()
    
    print("Engagement Data (first 3 records):")
    print(engage_df.head(3).to_string(index=False))
    print()


def main():
    """
    Main execution function.
    """
    print("Starting dataset generation...")
    print()
    
    # Generate all three datasets
    eval_df = generate_evaluation_data()
    demo_df = generate_user_demographics(n_users=100000)
    engage_df = generate_engagement_data(demo_df)
    
    # Verify data quality
    verify_data_quality(eval_df, demo_df, engage_df)
    
    # Show sample data
    generate_sample_preview(eval_df, demo_df, engage_df)
    
    # Save to CSV
    save_datasets(eval_df, demo_df, engage_df)
    
    print("=" * 70)
    print("Dataset Generation Complete!")
    print("=" * 70)
    print()
    print("Next Steps:")
    print("1. Load the CSV files into your analysis environment")
    print("2. Perform exploratory data analysis")
    print("3. Test parallel trends assumption (weeks 1-7)")
    print("4. Implement DiD regression for engagement analysis")
    print("5. Conduct propensity score matching for conversion analysis")
    print()
    print("Good luck with your capstone project!")


if __name__ == "__main__":
    main()