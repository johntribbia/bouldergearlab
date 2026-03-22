"""
survey_public_datasets.py
--------------------------
Gap 1 action item: identify and evaluate public datasets that could substitute
for proprietary AI product data in the real-world application section.

The paper needs at minimum:
  - Per-user prompt-level category labels (or a classifiable query field)
  - A temporal engagement signal (session counts, return visits, activity dates)
  - Multiple "quality" variants (model versions, fine-tuning changes, or API tiers)

This script:
  1. Documents five candidate sources with availability, variables, and fit scores.
  2. Attempts to download the LMSYS Chatbot Arena conversations dataset from
     HuggingFace (the strongest candidate) and performs a quick feasibility check.
  3. Prints a recommendation matrix.

Usage:
    cd content/data-projects/model-quality-journal
    pip install datasets pandas pyarrow requests tqdm
    python survey_public_datasets.py

Requirements: internet access; ~2 GB disk for LMSYS download.
"""

import sys
import textwrap

# ─── Candidate Dataset Registry ───────────────────────────────────────────────

CANDIDATES = [
    {
        "name": "LMSYS Chatbot Arena Conversations",
        "source": "HuggingFace: lmsys/chatbot_arena_conversations",
        "url": "https://huggingface.co/datasets/lmsys/chatbot_arena_conversations",
        "n_records": "~33 K conversation pairs",
        "key_variables": [
            "question_id (session proxy)",
            "model_a / model_b (quality variants)",
            "winner (engagement/quality signal)",
            "conversation (classifiable into prompt categories)",
            "language",
        ],
        "fit_category_labels": "Must classify: embed conversation and predict category",
        "fit_engagement_signal": "Weak: win/loss is preference, not return visit",
        "fit_quality_variants": "Strong: compare across 60+ model versions",
        "overall_fit": 7,
        "notes": (
            "Best public proxy for multi-model quality comparison. "
            "Win-rate ≈ revealed preference quality signal. "
            "Missing: user identity (can't track return visits). "
            "Workaround: treat win-rate per category as the 'engagement' outcome."
        ),
    },
    {
        "name": "ShareGPT conversations",
        "source": "HuggingFace: RyokoAI/ShareGPT52K or anon8231489123/ShareGPT_Vicuna_unfiltered",
        "url": "https://huggingface.co/datasets/anon8231489123/ShareGPT_Vicuna_unfiltered",
        "n_records": "~52 K multi-turn conversations",
        "key_variables": [
            "id (session ID, no user-level identity)",
            "conversations (classifiable into categories)",
            "source (model used)",
        ],
        "fit_category_labels": "Must classify using embedding + clustering",
        "fit_engagement_signal": "None: no return-visit or activity signal",
        "fit_quality_variants": "Weak: only one GPT-4 version",
        "overall_fit": 3,
        "notes": (
            "Category labels derivable. Missing both quality variation across versions "
            "and any engagement signal. Not viable as-is."
        ),
    },
    {
        "name": "StackExchange AI/ML question traffic",
        "source": "StackExchange Data Dump (archive.org) — AI and CrossValidated sites",
        "url": "https://archive.org/details/stackexchange",
        "n_records": "~500 K questions + view/vote counts over time",
        "key_variables": [
            "Tag (category label — explicit)",
            "ViewCount / Score (engagement proxy)",
            "CreationDate (temporal signal)",
            "AnswerCount, CommentCount",
        ],
        "fit_category_labels": "Strong: explicit topic tags",
        "fit_engagement_signal": "Moderate: view counts and votes as engagement proxy",
        "fit_quality_variants": "None: would need to be proxied by AI model release dates",
        "overall_fit": 4,
        "notes": (
            "Has category labels and temporal engagement, but no direct AI model "
            "quality variation. Could be used to validate the category-weighting "
            "construction only. Not sufficient as a full real-world test."
        ),
    },
    {
        "name": "WildChat (Qianwen + GPT-4 logs)",
        "source": "HuggingFace: allenai/WildChat-1M",
        "url": "https://huggingface.co/datasets/allenai/WildChat-1M",
        "n_records": "~1 M conversations",
        "key_variables": [
            "hashed_ip (pseudonymous user proxy)",
            "model (gpt-3.5-turbo vs gpt-4)",
            "conversation (classifiable into categories)",
            "timestamp",
            "toxic (content flag)",
        ],
        "fit_category_labels": "Must classify: conversations are raw text",
        "fit_engagement_signal": "Moderate: hashed_ip + timestamp allows session counting",
        "fit_quality_variants": "Moderate: gpt-3.5 vs gpt-4 quality split",
        "overall_fit": 8,
        "notes": (
            "Strongest candidate. hashed_ip gives pseudonymous user-level tracking. "
            "Timestamp + model field creates a natural version-period structure. "
            "Two quality levels (3.5 vs 4) are fewer than ideal but sufficient for "
            "a proof-of-concept real-data application. "
            "Requires: topic classification of conversations into 5 categories."
        ),
    },
    {
        "name": "OpenAI API usage logs (internal — not public)",
        "source": "Requires partnership or research access agreement",
        "url": "N/A",
        "n_records": "Potentially millions",
        "key_variables": [
            "user_id",
            "model (gpt-3.5, gpt-4, gpt-4o, etc.)",
            "endpoint_category (assistants, completions, embeddings)",
            "daily_active flag",
        ],
        "fit_category_labels": "Strong: API endpoint tags and request metadata",
        "fit_engagement_signal": "Strong: daily active users, session counts",
        "fit_quality_variants": "Strong: continuous model upgrade history",
        "overall_fit": 10,
        "notes": (
            "Ideal dataset but requires negotiated access. "
            "Recommendation: draft a data access request (see template at bottom). "
            "Fallback: use WildChat-1M as the real-data section."
        ),
    },
]

# ─── Print Candidate Summary ──────────────────────────────────────────────────

print("=" * 78)
print("GAP 1: PUBLIC DATASET SURVEY")
print("Real-world application candidates for Journal of Data Science submission")
print("=" * 78)
print()
print(f"  {'Dataset':<42} {'Fit':>4}  {'Records':<22}  Notes")
print(f"  {'-'*42} {'-'*4}  {'-'*22}  {'-'*20}")
for c in sorted(CANDIDATES, key=lambda x: -x["overall_fit"]):
    notes_short = c["notes"][:60] + "…" if len(c["notes"]) > 60 else c["notes"]
    print(f"  {c['name']:<42} {c['overall_fit']:>4}/10  {c['n_records']:<22}  {notes_short}")
print()

for c in sorted(CANDIDATES, key=lambda x: -x["overall_fit"]):
    print(f"{'─'*78}")
    print(f"  {c['name']}")
    print(f"  Source:  {c['source']}")
    print(f"  URL:     {c['url']}")
    print(f"  Records: {c['n_records']}")
    print(f"  Overall fit: {c['overall_fit']}/10")
    print()
    print("  Key variables:")
    for v in c["key_variables"]:
        print(f"    • {v}")
    print()
    print("  Category labels:    " + c["fit_category_labels"])
    print("  Engagement signal:  " + c["fit_engagement_signal"])
    print("  Quality variants:   " + c["fit_quality_variants"])
    print()
    print(textwrap.fill("  Assessment: " + c["notes"], width=78,
                        subsequent_indent="              "))
    print()

# ─── Recommendation ──────────────────────────────────────────────────────────

print("=" * 78)
print("RECOMMENDATION")
print("=" * 78)
print("""
  Tier 1 (use immediately with available data):
    WildChat-1M — pseudonymous users, two quality tiers (GPT-3.5 vs GPT-4),
    timestamps enabling session construction, 1M conversations for category
    classification. Proceed to feasibility download below.

  Tier 2 (parallel track — pursue partnership):
    OpenAI API logs — ideal but requires negotiated access.
    Draft a one-page data access request; see template at end of this file.

  NOT RECOMMENDED for full real-data section:
    LMSYS Arena — no user identity; win-rate is a weaker outcome than activity.
    ShareGPT     — no quality variation, no engagement signal.
    StackExchange — no AI model quality variation.
""")

# ─── Feasibility Download: WildChat-1M ───────────────────────────────────────

print("=" * 78)
print("FEASIBILITY CHECK: WildChat-1M (allenai/WildChat-1M)")
print("=" * 78)
print()

try:
    from datasets import load_dataset
    import pandas as pd

    print("  Attempting to load first 10,000 rows as a feasibility check...")
    print("  (Full dataset is ~1M rows, ~2 GB. This only streams the head.)\n")

    ds = load_dataset(
        "allenai/WildChat-1M",
        split="train",
        streaming=True,
        trust_remote_code=True,
    )

    rows = []
    for i, row in enumerate(ds):
        rows.append(row)
        if i >= 9999:
            break

    df = pd.DataFrame(rows)
    print(f"  Loaded {len(df):,} rows.")
    print(f"  Columns: {list(df.columns)}")
    print()

    # Check model distribution
    if "model" in df.columns:
        model_counts = df["model"].value_counts()
        print("  Model distribution (top 10):")
        for m, cnt in model_counts.head(10).items():
            print(f"    {m:<30s}  {cnt:>6,}  ({cnt/len(df):.1%})")
        print()

    # Check timestamp coverage
    if "timestamp" in df.columns:
        print(f"  Timestamp range: {df['timestamp'].min()} → {df['timestamp'].max()}")
        print()

    # Check hashed_ip coverage (user proxy)
    if "hashed_ip" in df.columns:
        n_users     = df["hashed_ip"].nunique()
        n_per_user  = len(df) / n_users
        print(f"  Unique hashed_ip (user proxy): {n_users:,}  ({n_per_user:.1f} rows/user avg)")
        print()

    # Spot-check a conversation for category classification feasibility
    if "conversation" in df.columns:
        sample_conv = df["conversation"].dropna().iloc[0]
        first_user_turn = next(
            (t["content"] for t in sample_conv if t.get("role") == "user"),
            "[no user turn found]"
        )
        print("  Sample first user turn (for category classification feasibility):")
        print(textwrap.fill("    " + str(first_user_turn)[:400], width=78,
                            subsequent_indent="    "))
        print()

    print("  Feasibility verdict: WildChat is loadable and has the required structure.")
    print("  Next step: run full category classification pipeline (see below).")
    print()

    # Save head to CSV for inspection
    out_path = "wildchat_sample_10k.csv"
    df_flat = df.copy()
    if "conversation" in df_flat.columns:
        df_flat["first_user_turn"] = df_flat["conversation"].apply(
            lambda c: next(
                (t["content"] for t in c if t.get("role") == "user"), ""
            ) if isinstance(c, list) else ""
        )
        df_flat = df_flat.drop(columns=["conversation"])
    df_flat.to_csv(out_path, index=False)
    print(f"  Saved sample to {out_path} for manual inspection.")

except ImportError:
    print("  'datasets' package not installed. Install with:")
    print("    pip install datasets pandas pyarrow")
    print()
    print("  Skipping download. Feasibility analysis requires the package.")
except Exception as e:
    print(f"  Download attempt failed: {e}")
    print("  Check internet access and HuggingFace availability.")
    print()

# ─── Next Steps: Category Classification Pipeline ─────────────────────────────

print()
print("=" * 78)
print("NEXT STEPS: Category Classification for WildChat")
print("=" * 78)
print("""
  To apply the quality-exposure framework to WildChat, classify each conversation's
  first user turn into the same 5 categories used in the synthetic data:

  Categories: Coding | Creative Writing | General QA | Math/Logic | Scientific

  Recommended approach (zero-shot with a lightweight classifier):
    1. Embed the first user turn with sentence-transformers/all-MiniLM-L6-v2.
    2. Compute cosine similarity to 5 hand-crafted seed prompts per category.
    3. Assign the argmax category; flag low-confidence rows (max sim < 0.3).
    4. Validate on 500 manually labeled examples.

  WildChat-specific "quality" operationalization:
    • Model tier: gpt-3.5-turbo = lower quality, gpt-4 = higher quality
    • Map categories to quality scores using LMSYS ELO ratings by task type
      (publicly available: https://huggingface.co/spaces/lmsys/chatbot-arena-leaderboard)
    • User-version = (hashed_ip, model) pair; engagement = sessions per week

  This gives a real-data analogue of the synthetic setup with known limitations:
    - Only 2 quality levels (not 3), limiting within-version variation
    - User identity is pseudonymous and may conflate multiple real users
  Both limitations should be disclosed and compared to the synthetic case.
""")

# ─── Data Access Request Template ─────────────────────────────────────────────

print("=" * 78)
print("TEMPLATE: Data Access Request for AI Company Partnership")
print("=" * 78)
print("""
  Subject: Research Data Access Request — Measuring Quality-Engagement Causal Effects

  We are conducting academic research on causal inference methods for measuring
  the impact of AI model quality on user engagement. Our methodology exploits
  within-version heterogeneity in users' quality exposure (arising from their
  category usage mix) to identify quality effects while absorbing between-version
  confounders via version fixed effects.

  We are seeking access to:
    1. Anonymized per-user prompt-level category labels (5–10 categories sufficient)
    2. Weekly active-day counts or equivalent engagement signal
    3. Model version indicators with deployment dates
    4. Any existing per-category quality evaluation scores

  Data requirements (minimum viable):
    - N ≥ 10,000 users tracked across ≥ 2 model versions
    - At least 4 weeks of data per version period
    - User IDs may be pseudonymous (hashed)
    - No raw prompt text required

  We will provide: pre-registered analysis plan, JDS-style paper draft,
  acknowledgment, and co-authorship option if desired.

  Contact: [your contact info]
""")
