#!/usr/bin/env python3
"""
WildChat prompt era analysis — BERTopic over English first-turn prompts,
with a structural break test at the GPT-4 Turbo launch (Nov 2023).

Data: allenai/WildChat-1M
Run from repo root: python scripts/wildchat_analysis.py

Deps: bertopic sentence-transformers umap-learn hdbscan scikit-learn pandas scipy
"""

from __future__ import annotations

import json
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.stats import chi2_contingency

warnings.filterwarnings("ignore", category=FutureWarning)

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "content" / "data-projects" / "wildchat-prompt-eras" / "data"
SAMPLE_CACHE = ROOT / "scripts" / "wildchat_sample.parquet"
ENRICHED_SAMPLE_CACHE = ROOT / "scripts" / "wildchat_sample_with_topics.parquet"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# GPT-4 Turbo (gpt-4-1106-preview) GA — the structural break visible in the data
GPT4_LAUNCH = pd.Timestamp("2023-11-06", tz="UTC")
SAMPLE_N = 1_000       # per shard, 14 shards -> ~14k total
RANDOM_SEED = 42
MIN_TOPIC_SIZE = 50    # calibrated for ~14k docs
N_TOPICS = 40
EMBED_BATCH_SIZE = 128

# Models tracked for the split chart
TARGET_MODELS = {
    "gpt-3.5-turbo": "GPT-3.5",
    "gpt-4": "GPT-4",
}

# GPT-3.5 vs GPT-4 benchmark differentials (% points, GPT-4 minus GPT-3.5).
# Sources: OpenAI GPT-4 technical report (2023); HumanEval, MMLU, TruthfulQA.
# Hard-coded here so the article can cite exact numbers without re-running.
BENCHMARK_REFS = {
    "Coding (HumanEval)":    {"gpt35": 48.1, "gpt4": 67.0, "delta_pp": 18.9},
    "Reasoning (MMLU)":      {"gpt35": 70.0, "gpt4": 86.4, "delta_pp": 16.4},
    "Factual QA (TruthfulQA)":{"gpt35": 58.7,"gpt4": 71.9, "delta_pp": 13.2},
    "Creative Writing (MT-Bench)":{"gpt35": 7.94,"gpt4": 8.99,"delta_pp": 1.05},
    "Casual Chat (MT-Bench)":{"gpt35": 8.35, "gpt4": 8.39, "delta_pp": 0.04},
}

# Fill after the first run — review print_topic_keywords() output and assign names.
# Leave empty on the initial run.
TOPIC_NAMES: dict[int, str] = {
    # assigned after pass-1 keyword review (May 2026)
     0: "Image Generation (Midjourney)",
     1: "Software Coding & Debugging",
     2: "Professional & Business Writing",
     3: "Casual Conversation",
     4: "General Chat & Instructions",
     5: "Creative Fiction Writing",
     6: "Roleplay & Interactive Fiction",
     7: "Translation & World History",
     8: "Scene & Visual Description",
     9: "Character Comparison / Reaction",
    10: "Social & Lifestyle Scenarios",
    11: "Sports, Games & Entertainment Scripts",
    12: "Social Media & Design Content",
    13: "Teen / Young Adult Scenarios",
    14: "Image Generation (Midjourney) - Alt A",
    15: "Content Writing & Blogging",
    16: "Image Generation (Midjourney) - Alt B",
    17: "Image Generation (Midjourney) - Alt C",
    18: "Academic Research & Health",
    19: "Image Generation (Midjourney) - Alt D",
    20: "Music & Lyrics",
    21: "Jailbreak Attempts",
    22: "General Assistance",
    23: "Fantasy Worldbuilding",
    24: "Food & Nutrition",
    25: "Personal Narrative & Family",
    26: "TV, Games & Entertainment Recs",
    27: "Character & Game Design",
    28: "Art & Visual Media",
    29: "Image Generation (Midjourney) - Alt E",
    30: "Document Formatting & Templates",
    31: "Humor & Comedy Writing",
    32: "Anime & Manga Scenarios",
    33: "Image Generation (Midjourney) - Alt F",
    34: "Digital Art Descriptions",
    35: "Meta: ChatGPT Itself",
    36: "Image Generation (Midjourney) - Alt G",
    37: "Video & YouTube Scripts",
    38: "Social Pleasantries",
    -1: "[Outlier / Unclustered]",
}

PARQUET_DIR = Path("/home/codespace/.cache/huggingface/hub/datasets--allenai--WildChat-1M/snapshots/7d6490e462285cf85d91eabea0f9a954fbddcd1f/data")


def load_wildchat(sample_n: int = SAMPLE_N, seed: int = RANDOM_SEED) -> pd.DataFrame:
    # Loads from the small sample cache if it exists, otherwise reads raw HF parquets.
    # After the first run you can delete the 3+ GB HF cache and this will still work.
    import pyarrow.parquet as pq

    if SAMPLE_CACHE.exists():
        print(f"Loading sample from cache ({SAMPLE_CACHE})…")
        df = pd.read_parquet(SAMPLE_CACHE)
        df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce", utc=True)
        print(f"  → {len(df):,} prompts loaded from cache")
        return df

    shard_files = sorted(PARQUET_DIR.glob("train-*.parquet"))
    if not shard_files:
        raise FileNotFoundError(
            f"No Parquet shards found in {PARQUET_DIR} and no sample cache at {SAMPLE_CACHE}.\n"
            "Re-download or restore the HF cache."
        )

    print(f"Reading {len(shard_files)} Parquet shards (turn=1, English only)…")
    frames: list[pd.DataFrame] = []

    for shard in shard_files:
        table = pq.read_table(
            shard,
            columns=["conversation_hash", "timestamp", "model", "country",
                     "toxic", "language", "turn_count", "turn", "conversation"],
            filters=[("turn", "=", 1), ("language", "=", "English")],
        )
        df_shard = table.to_pandas()
        print(f"  {shard.name}: {len(df_shard):,} English first-turn rows")

        def extract_prompt(turns) -> str | None:
            if turns is None or len(turns) == 0:
                return None
            t = turns[0]
            content = t.get("content") if isinstance(t, dict) else getattr(t, "content", None)
            text = (content or "").strip()
            return text if len(text.split()) >= 4 else None

        df_shard["prompt"] = df_shard["conversation"].apply(extract_prompt)
        df_shard = df_shard.drop(columns=["language", "turn", "conversation"])
        df_shard = df_shard.dropna(subset=["prompt"])

        # Stratified sample per shard for temporal coverage
        if len(df_shard) > sample_n:
            df_shard = df_shard.sample(n=sample_n, random_state=seed)
        frames.append(df_shard)

    df = pd.concat(frames, ignore_index=True)
    df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce", utc=True)
    df = df.dropna(subset=["timestamp", "prompt"])
    df = df.drop_duplicates(subset=["prompt"])
    df = df.rename(columns={"conversation_hash": "conversation_id"})

    # turn_count may or may not be in the parquet schema; fall back gracefully
    if "turn_count" not in df.columns:
        df["turn_count"] = None

    print(f"  → {len(df):,} prompts ready for modeling (stratified by shard)")
    print(f"  → Date range: {df['timestamp'].min().date()} – {df['timestamp'].max().date()}")
    print(f"  → Top models: {df['model'].value_counts().head(4).to_dict()}")
    if df["turn_count"].notna().any():
        print(f"  → turn_count: {df['turn_count'].notna().sum():,} non-null records")

    df.to_parquet(SAMPLE_CACHE, index=False)
    print(f"  → sample saved to {SAMPLE_CACHE} ({SAMPLE_CACHE.stat().st_size // 1024:,} KB)")
    print("     HF cache can be deleted to free disk space")
    return df


def clean_prompts(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    # truncate for embedding efficiency; BERTopic handles noise internally
    df["prompt_clean"] = df["prompt"].str[:512].str.strip()
    df = df[df["prompt_clean"].str.split().str.len() >= 4].copy()
    return df.reset_index(drop=True)



def run_bertopic(
    docs: list[str],
    min_topic_size: int = MIN_TOPIC_SIZE,
    nr_topics: int = N_TOPICS,
    seed: int = RANDOM_SEED,
    batch_size: int = EMBED_BATCH_SIZE,
) -> tuple:
    # all-MiniLM-L6-v2, UMAP(n_components=5, cosine), HDBSCAN(eom)
    from bertopic import BERTopic
    from sentence_transformers import SentenceTransformer
    from umap import UMAP
    from hdbscan import HDBSCAN
    from sklearn.feature_extraction.text import CountVectorizer

    print(f"Embedding {len(docs):,} prompts with all-MiniLM-L6-v2 (batch_size={batch_size})…")
    embedding_model = SentenceTransformer("all-MiniLM-L6-v2")

    umap_model = UMAP(
        n_components=5,
        n_neighbors=15,
        min_dist=0.0,
        metric="cosine",
        random_state=seed,
    )
    hdbscan_model = HDBSCAN(
        min_cluster_size=min_topic_size,
        metric="euclidean",
        cluster_selection_method="eom",
        prediction_data=True,
    )
    vectorizer = CountVectorizer(
        stop_words="english",
        min_df=10,
        ngram_range=(1, 2),
    )

    topic_model = BERTopic(
        embedding_model=embedding_model,
        umap_model=umap_model,
        hdbscan_model=hdbscan_model,
        vectorizer_model=vectorizer,
        nr_topics=nr_topics,
        verbose=True,
        calculate_probabilities=False,
    )

    print("Pre-computing embeddings…")
    embeddings = embedding_model.encode(
        docs,
        batch_size=batch_size,
        show_progress_bar=True,
        convert_to_numpy=True,
    )

    print("Fitting BERTopic on pre-computed embeddings…")
    topics, probs = topic_model.fit_transform(docs, embeddings=embeddings)
    n_topics_found = len(set(topics)) - (1 if -1 in topics else 0)
    print(f"  → {n_topics_found} topics found (excl. outlier cluster -1)")
    return topic_model, topics, probs



def build_taxonomy(
    topic_model,
    topics: list[int],
    total_docs: int,
    topic_names: dict[int, str],
) -> list[dict]:
    info = topic_model.get_topic_info()
    taxonomy = []
    for _, row in info.iterrows():
        tid = int(row["Topic"])
        count = int(row["Count"])
        top_kw = topic_model.get_topic(tid)
        keywords = [kw for kw, _ in top_kw[:8]] if top_kw else []
        taxonomy.append({
            "topic_id":    tid,
            "name":        topic_names.get(tid, f"Topic {tid}" if tid >= 0 else "[Outlier]"),
            "size":        count,
            "share_pct":   round(count / total_docs * 100, 2),
            "top_keywords": keywords,
        })
    taxonomy.sort(key=lambda x: x["size"], reverse=True)
    return taxonomy



def build_timeseries(
    df: pd.DataFrame,
    topics: list[int],
    topic_names: dict[int, str],
    top_n: int = 12,
) -> dict:
    """Monthly topic share for the top_n topics, formatted for Chart.js."""
    df = df.copy()
    df["topic"] = topics
    df["month"] = df["timestamp"].dt.to_period("M").astype(str)

    # exclude outlier -1 from ranking
    topic_counts = df[df["topic"] >= 0].groupby("topic").size()
    top_topics = topic_counts.nlargest(top_n).index.tolist()

    monthly = (
        df[df["topic"].isin(top_topics)]
        .groupby(["month", "topic"])
        .size()
        .unstack(fill_value=0)
    )
    monthly_total = df.groupby("month").size()
    monthly_share = monthly.div(monthly_total, axis=0) * 100

    months = sorted(monthly_share.index.tolist())
    datasets = []
    for tid in top_topics:
        if tid not in monthly_share.columns:
            continue
        series = monthly_share.reindex(months)[tid].fillna(0).round(2).tolist()
        datasets.append({
            "topic_id": int(tid),
            "label":    topic_names.get(tid, f"Topic {tid}"),
            "data":     series,
        })

    datasets.sort(key=lambda d: sum(d["data"]), reverse=True)

    return {"labels": months, "datasets": datasets}



def build_model_breakdown(
    df: pd.DataFrame,
    topics: list[int],
    topic_names: dict[int, str],
    top_n: int = 12,
) -> dict:
    df = df.copy()
    df["topic"] = topics

    topic_counts = df[df["topic"] >= 0].groupby("topic").size()
    top_topics = topic_counts.nlargest(top_n).index.tolist()
    topic_labels = [topic_names.get(t, f"Topic {t}") for t in top_topics]

    result = {"labels": topic_labels, "gpt35_shares": [], "gpt4_shares": []}

    for model_key, result_key in [("gpt-3.5-turbo", "gpt35_shares"), ("gpt-4", "gpt4_shares")]:
        sub = df[df["model"].str.startswith(model_key)]
        total = len(sub)
        shares = []
        for tid in top_topics:
            count = (sub["topic"] == tid).sum()
            shares.append(round(count / total * 100, 2) if total > 0 else 0.0)
        result[result_key] = shares

    return result



def build_transition_test(
    df: pd.DataFrame,
    topics: list[int],
    topic_names: dict[int, str],
    top_n: int = 12,
) -> list[dict]:
    """Chi-square test on topic share before vs after GPT4_LAUNCH, sorted by |delta|."""
    df = df.copy()
    df["topic"] = topics
    df["post_gpt4"] = df["timestamp"] >= GPT4_LAUNCH

    topic_counts = df[df["topic"] >= 0].groupby("topic").size()
    top_topics = topic_counts.nlargest(top_n).index.tolist()

    results = []
    for tid in top_topics:
        before = df[~df["post_gpt4"]]
        after  = df[df["post_gpt4"]]
        n_before_total = len(before)
        n_after_total  = len(after)
        n_before_topic = (before["topic"] == tid).sum()
        n_after_topic  = (after["topic"] == tid).sum()

        share_before = n_before_topic / n_before_total * 100 if n_before_total else 0
        share_after  = n_after_topic  / n_after_total  * 100 if n_after_total  else 0
        delta_pp     = share_after - share_before

        # 2x2: [in-topic, not] x [before, after]
        contingency = np.array([
            [n_before_topic, n_before_total - n_before_topic],
            [n_after_topic,  n_after_total  - n_after_topic],
        ])
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            chi2, p_value, _, _ = chi2_contingency(contingency)

        results.append({
            "topic_id":     int(tid),
            "name":         topic_names.get(tid, f"Topic {tid}"),
            "share_before": round(share_before, 2),
            "share_after":  round(share_after, 2),
            "delta_pp":     round(delta_pp, 2),
            "chi2":         round(float(chi2), 3),
            "p_value":      round(float(p_value), 4),
        })

    results.sort(key=lambda x: abs(x["delta_pp"]), reverse=True)
    return results



def build_toxicity_breakdown(
    df: pd.DataFrame,
    topic_names: dict[int, str],
    top_n: int = 12,
) -> list[dict]:
    if "toxic" not in df.columns or df["toxic"].isna().all():
        print("  [skip] No toxic column in sample data.")
        return []

    topic_counts = df[df["topic"] >= 0].groupby("topic").size()
    top_topics = topic_counts.nlargest(top_n).index.tolist()

    all_topics = top_topics + ([-1] if -1 in df["topic"].values else [])

    results = []
    for tid in all_topics:
        sub = df[df["topic"] == tid]
        n = len(sub)
        if n == 0:
            continue
        n_toxic = sub["toxic"].fillna(False).astype(bool).sum()
        results.append({
            "topic_id":      int(tid),
            "name":          topic_names.get(tid, f"Topic {tid}" if tid >= 0 else "[Outlier]"),
            "n":             n,
            "n_toxic":       int(n_toxic),
            "toxicity_rate": round(n_toxic / n * 100, 2),
        })

    results.sort(key=lambda x: x["toxicity_rate"], reverse=True)
    return results



def build_turn_count_breakdown(
    df: pd.DataFrame,
    topic_names: dict[int, str],
    top_n: int = 12,
) -> list[dict]:
    if "turn_count" not in df.columns or df["turn_count"].isna().all():
        print("  [skip] No turn_count column in sample data.")
        return []

    topic_counts = df[df["topic"] >= 0].groupby("topic").size()
    top_topics = topic_counts.nlargest(top_n).index.tolist()

    results = []
    for tid in top_topics:
        sub = df[(df["topic"] == tid) & df["turn_count"].notna()]
        if len(sub) < 5:
            continue
        tc = sub["turn_count"].astype(float)
        results.append({
            "topic_id": int(tid),
            "name":     topic_names.get(tid, f"Topic {tid}"),
            "n":        len(sub),
            "median":   round(float(tc.median()), 1),
            "mean":     round(float(tc.mean()), 1),
            "p25":      round(float(tc.quantile(0.25)), 1),
            "p75":      round(float(tc.quantile(0.75)), 1),
        })

    results.sort(key=lambda x: x["median"], reverse=True)
    return results



def build_prompt_depth_by_topic(
    df: pd.DataFrame,
    topic_names: dict[int, str],
    top_n: int = 12,
) -> list[dict]:
    df = df.copy()
    # Always use the original prompt for word count — prompt_clean is truncated at 512 chars
    prompt_col = "prompt" if "prompt" in df.columns else "prompt_clean"
    df["_wc"] = df[prompt_col].str.split().str.len()

    topic_counts = df[df["topic"] >= 0].groupby("topic").size()
    top_topics = topic_counts.nlargest(top_n).index.tolist()

    results = []
    for tid in top_topics:
        sub = df[df["topic"] == tid]
        if len(sub) < 5:
            continue
        wc = sub["_wc"].dropna().astype(float)
        results.append({
            "topic_id": int(tid),
            "name":     topic_names.get(tid, f"Topic {tid}"),
            "n":        len(sub),
            "median":   round(float(wc.median()), 1),
            "mean":     round(float(wc.mean()), 1),
            "p25":      round(float(wc.quantile(0.25)), 1),
            "p75":      round(float(wc.quantile(0.75)), 1),
        })

    results.sort(key=lambda x: x["median"], reverse=True)
    return results



def print_topic_keywords(topic_model, top_n: int = 20) -> None:
    """Print keywords per cluster so you can fill in TOPIC_NAMES."""
    info = topic_model.get_topic_info()
    print()
    for _, row in info.iterrows():
        tid = int(row["Topic"])
        if tid == -1:
            continue
        count = int(row["Count"])
        kws = topic_model.get_topic(tid)
        kw_str = ", ".join(w for w, _ in kws[:10])
        print(f"  {tid:3d}  ({count:5,})  {kw_str}")
    print()



def main() -> None:
    df = load_wildchat()
    df = clean_prompts(df)
    docs = df["prompt_clean"].tolist()

    topic_model, topics, _ = run_bertopic(docs)
    df["topic"] = topics

    # pass 1: review this output, fill in TOPIC_NAMES above, then re-run
    print_topic_keywords(topic_model)

    df.to_parquet(ENRICHED_SAMPLE_CACHE, index=False)
    print(f"enriched sample: {ENRICHED_SAMPLE_CACHE}")

    taxonomy = build_taxonomy(topic_model, topics, len(docs), TOPIC_NAMES)
    timeseries = build_timeseries(df, topics, TOPIC_NAMES)
    model_break = build_model_breakdown(df, topics, TOPIC_NAMES)
    transition = build_transition_test(df, topics, TOPIC_NAMES)
    toxicity = build_toxicity_breakdown(df, TOPIC_NAMES)
    turn_counts = build_turn_count_breakdown(df, TOPIC_NAMES)
    prompt_depth = build_prompt_depth_by_topic(df, TOPIC_NAMES)

    outputs = {
        "topic_taxonomy.json": taxonomy,
        "topic_timeseries.json": timeseries,
        "model_breakdown.json": model_break,
        "transition_test.json": transition,
        "benchmark_refs.json": BENCHMARK_REFS,
        "toxicity_by_topic.json": toxicity,
        "turn_counts_by_topic.json": turn_counts,
        "prompt_depth_by_topic.json": prompt_depth,
    }
    for fname, payload in outputs.items():
        path = OUT_DIR / fname
        with path.open("w") as f:
            json.dump(payload, f, indent=2, default=str)
        print(f"wrote {path.relative_to(ROOT)}")

    if not TOPIC_NAMES:
        print("\nPass 1 done — fill in TOPIC_NAMES above and re-run.")
        print(f"Sample cached at {SAMPLE_CACHE} (HF parquets can be deleted)")


if __name__ == "__main__":
    main()
