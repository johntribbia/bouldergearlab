"""
arc_validation.py
-----------------
Validates the ARC trajectory classifier (V3) described in
"Stress-Testing the Arc" (bouldergearlab data-projects/arc_validation).

Three tests:
  1. Sanity check  — classify the four article example trajectories
  2. Bulk accuracy — 1,500 synthetic labeled trajectories (300 per pattern)
  3. Noise sweep   — 5,000 trials per pattern per sigma level

Run:
    python scripts/arc_validation.py
"""

import random
import math

# ── V3 Classifier (exact code from article) ───────────────────────────────────

def classify_trajectory(scores):
    n = len(scores)
    s = list(scores)
    t = n // 3
    early_mean = sum(s[:t]) / t
    mid_mean   = sum(s[t:2*t]) / t
    late_mean  = sum(s[2*t:]) / (n - 2*t)
    slope_l    = (s[-1] - s[2*t]) / max(n - 2*t - 1, 1)

    # 1. Recovery first: dip > 0.20, then climbs back > 0.10 above the dip
    dips = [i for i in range(1, n-1) if s[i] < s[i-1] - 0.20]
    if dips and s[-1] > s[dips[0]] + 0.10:
        return 'recovery'

    # 2. Early collapse: early strong, drops and stays low through mid AND late
    if (early_mean - mid_mean) > 0.20 and (early_mean - late_mean) > 0.20:
        return 'early_collapse'

    # 3. Late drift: final segment slopes clearly negative
    if slope_l < -0.12:
        return 'late_drift'

    # 4. Steady degradation: overall decline without a structural break
    if (s[0] - s[-1]) > 0.15:
        return 'steady_degradation'

    return 'healthy'


# ── Article Base Trajectories (from arc/index.md chart data) ──────────────────

ARTICLE_TRAJECTORIES = {
    'early_collapse':     [0.90, 0.91, 0.88, 0.60, 0.55, 0.58, 0.61, 0.62, 0.60, 0.58],
    'late_drift':         [0.60, 0.58, 0.62, 0.78, 0.82, 0.85, 0.88, 0.87, 0.55, 0.45],
    'steady_degradation': [0.85, 0.82, 0.78, 0.74, 0.71, 0.68, 0.65, 0.62, 0.58, 0.57],
    'recovery':           [0.88, 0.90, 0.85, 0.40, 0.38, 0.72, 0.85, 0.87, 0.86, 0.89],
}

PATTERNS = ['early_collapse', 'late_drift', 'steady_degradation', 'recovery', 'healthy']


def clamp(v, lo=0.0, hi=1.0):
    return max(lo, min(hi, v))


# ── Synthetic Trajectory Generators ──────────────────────────────────────────

def gen_early_collapse(n=10, sigma=0.0):
    """High start, collapses at end of first third, stays low."""
    start = random.uniform(0.82, 0.94)
    drop  = random.uniform(0.22, 0.38)
    low   = start - drop
    collapse_step = random.randint(max(1, n // 3 - 1), n // 3 + 1)
    s = []
    for i in range(n):
        base = (start + random.uniform(-0.03, 0.03)) if i < collapse_step \
               else (low + random.uniform(-0.04, 0.06))
        s.append(clamp(base + random.gauss(0, sigma)))
    return s


def gen_late_drift(n=10, sigma=0.0):
    """Rises or holds, then drops sharply in the final 2–3 steps."""
    peak  = random.uniform(0.78, 0.92)
    start = random.uniform(0.55, 0.70)
    drop  = random.uniform(0.30, 0.48)
    drift_start = n - random.randint(2, 3)
    s = []
    for i in range(n):
        if i < drift_start:
            base = start + (peak - start) * (i / max(drift_start - 1, 1))
        else:
            steps_in = i - drift_start
            base = peak - drop * ((steps_in + 1) / (n - drift_start))
        s.append(clamp(base + random.gauss(0, sigma)))
    return s


def gen_steady_degradation(n=10, sigma=0.0):
    """Gradual monotone-ish decline, total drop > 0.15."""
    start      = random.uniform(0.78, 0.92)
    total_drop = random.uniform(0.18, 0.38)
    s = []
    for i in range(n):
        base = start - total_drop * (i / (n - 1))
        s.append(clamp(base + random.gauss(0, sigma)))
    return s


def gen_recovery(n=10, sigma=0.0):
    """Single large dip (>0.38), then recovers above pre-dip level."""
    start    = random.uniform(0.80, 0.92)
    dip_step = random.randint(2, n // 2)
    drop     = random.uniform(0.40, 0.56)
    dip_val  = start - drop
    s = []
    for i in range(n):
        if i < dip_step:
            base = start + random.uniform(-0.04, 0.04)
        elif i == dip_step:
            base = dip_val
        else:
            frac = (i - dip_step) / (n - 1 - dip_step)
            base = dip_val + (start - dip_val) * frac
        s.append(clamp(base + random.gauss(0, sigma)))
    return s


def gen_healthy(n=10, sigma=0.0):
    """Stable or gently improving trajectory — no large drops or declines."""
    center = random.uniform(0.68, 0.84)
    trend  = random.uniform(-0.04, 0.08)
    s = []
    for i in range(n):
        base = center + trend * (i / (n - 1))
        s.append(clamp(base + random.gauss(0, sigma)))
    return s


GENERATORS = {
    'early_collapse':     gen_early_collapse,
    'late_drift':         gen_late_drift,
    'steady_degradation': gen_steady_degradation,
    'recovery':           gen_recovery,
    'healthy':            gen_healthy,
}


# ── Metrics ───────────────────────────────────────────────────────────────────

def f1_score(true_labels, pred_labels, label):
    tp = sum(1 for t, p in zip(true_labels, pred_labels) if t == label and p == label)
    fp = sum(1 for t, p in zip(true_labels, pred_labels) if t != label and p == label)
    fn = sum(1 for t, p in zip(true_labels, pred_labels) if t == label and p != label)
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    recall    = tp / (tp + fn) if (tp + fn) > 0 else 0.0
    if precision + recall == 0:
        return 0.0
    return 2 * precision * recall / (precision + recall)


def evaluate(true_labels, pred_labels):
    accuracy  = sum(t == p for t, p in zip(true_labels, pred_labels)) / len(true_labels)
    per_f1    = {label: f1_score(true_labels, pred_labels, label) for label in PATTERNS}
    macro_f1  = sum(per_f1.values()) / len(PATTERNS)
    return accuracy, macro_f1, per_f1


# ── Test 1: Article trajectories sanity check ─────────────────────────────────

def test_article_trajectories():
    print("=" * 62)
    print("TEST 1 — Article Trajectory Sanity Check")
    print("=" * 62)
    model_labels = [
        ('A', 'early_collapse'),
        ('B', 'late_drift'),
        ('C', 'steady_degradation'),
        ('D', 'recovery'),
    ]
    all_pass = True
    for model, label in model_labels:
        traj   = ARTICLE_TRAJECTORIES[label]
        result = classify_trajectory(traj)
        ok     = result == label
        status = "PASS ✓" if ok else f"FAIL ✗  (got: {result})"
        print(f"  Model {model}  ({label:<22})  {status}")
        if not ok:
            all_pass = False
    print()
    return all_pass


# ── Test 2: Bulk accuracy (1,500 trajectories) ───────────────────────────────

def test_bulk(n_per_pattern=300, sigma=0.03, n_steps=10, seed=42):
    print("=" * 62)
    print(f"TEST 2 — Bulk Accuracy")
    print(f"  N = {n_per_pattern * len(PATTERNS)}  |  "
          f"{n_per_pattern} per pattern  |  σ = {sigma}  |  n_steps = {n_steps}")
    print("=" * 62)
    random.seed(seed)
    true_labels, pred_labels = [], []
    for label in PATTERNS:
        gen_fn = GENERATORS[label]
        for _ in range(n_per_pattern):
            traj = gen_fn(n=n_steps, sigma=sigma)
            true_labels.append(label)
            pred_labels.append(classify_trajectory(traj))

    accuracy, macro_f1, per_f1 = evaluate(true_labels, pred_labels)
    print(f"  Overall accuracy : {accuracy:.1%}")
    print(f"  Macro F1         : {macro_f1:.2f}")
    print()
    print(f"  {'Pattern':<24}  {'F1':>6}  {'Article target':>14}")

    # V3 F1 values from the arc_validation article table
    article_f1 = {
        'early_collapse':     0.68,
        'late_drift':         0.70,
        'steady_degradation': 0.75,
        'recovery':           0.98,
        'healthy':            0.84,
    }
    print(f"  {'-' * 46}")
    for label in PATTERNS:
        target = article_f1.get(label, '-')
        delta  = per_f1[label] - target if isinstance(target, float) else 0
        flag   = "  ← large gap" if abs(delta) > 0.10 else ""
        print(f"  {label:<24}  {per_f1[label]:>6.2f}  {target:>14.2f}{flag}")
    print()


# ── Test 3: Noise Sweep ───────────────────────────────────────────────────────

def test_noise_sweep(trials_per_cell=5000, n_steps=10, seed=99):
    print("=" * 62)
    print(f"TEST 3 — Noise Sweep  ({trials_per_cell:,} trials per cell)")
    print("=" * 62)

    sigmas        = [0.02, 0.05, 0.08, 0.11, 0.15]
    sweep_patterns = ['early_collapse', 'late_drift', 'steady_degradation', 'recovery']

    # Article-reported accuracy values from <arc_validation> Chart.js data
    article_expected = {
        'early_collapse':     [1.00, 0.94, 0.76, 0.61, 0.46],
        'late_drift':         [0.99, 0.84, 0.72, 0.63, 0.57],
        'steady_degradation': [1.00, 0.95, 0.76, 0.58, 0.44],
        'recovery':           [1.00, 1.00, 0.97, 0.94, 0.90],
    }

    col_w = 16
    header = f"  {'σ':<7}" + "".join(f"{p[:13]:>{col_w}}" for p in sweep_patterns)

    rng     = random.Random(seed)
    results = {p: [] for p in sweep_patterns}

    print("  Actual accuracy:")
    print(header)
    print("  " + "-" * (7 + col_w * len(sweep_patterns)))

    for sigma in sigmas:
        row = f"  {sigma:<7.2f}"
        for pattern in sweep_patterns:
            base    = ARTICLE_TRAJECTORIES[pattern]
            correct = sum(
                1 for _ in range(trials_per_cell)
                if classify_trajectory([clamp(v + rng.gauss(0, sigma)) for v in base]) == pattern
            )
            acc = correct / trials_per_cell
            results[pattern].append(acc)
            row += f"{acc:>{col_w}.1%}"
        print(row)

    print()
    print("  Article expected:")
    print(header)
    print("  " + "-" * (7 + col_w * len(sweep_patterns)))
    for i, sigma in enumerate(sigmas):
        row = f"  {sigma:<7.2f}"
        for pattern in sweep_patterns:
            row += f"{article_expected[pattern][i]:>{col_w}.1%}"
        print(row)

    print()
    print("  Delta (actual − expected):")
    print(header)
    print("  " + "-" * (7 + col_w * len(sweep_patterns)))
    max_delta = 0.0
    for i, sigma in enumerate(sigmas):
        row = f"  {sigma:<7.2f}"
        for pattern in sweep_patterns:
            delta = results[pattern][i] - article_expected[pattern][i]
            max_delta = max(max_delta, abs(delta))
            flag = " !" if abs(delta) > 0.08 else "  "
            row += f"{delta:>+{col_w - 2}.1%}{flag}"
        print(row)

    print()
    if max_delta > 0.08:
        print("  ⚠  Max delta exceeds 8 pp — article numbers may need updating.")
    else:
        print("  Max delta within 8 pp — results consistent with article.")
    print()


# ── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("ARC Classifier Validation")
    print()

    sanity_ok = test_article_trajectories()
    test_bulk()
    test_noise_sweep()

    if sanity_ok:
        print("Article sanity check: ALL 4 TRAJECTORIES CLASSIFIED CORRECTLY")
    else:
        print("Article sanity check: FAILURES — V3 classifier logic may have drifted")
    print()
