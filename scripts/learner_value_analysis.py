"""Synthetic staggered-rollout study: retention vs. learning for two learner-facing features.

200 school/community clusters x 200 learners, 20 weeks. Program 0 ships a daily-streak
feature; program 1 ships a guided-tutoring mode. Each program rolls out in four waves of 25
clusters (weeks 5, 9, 13, and a not-yet-reached group). Wave order is NOT random: clusters
with higher baseline engagement go first. Effects are estimated with difference-in-differences
against not-yet-treated clusters (Callaway-Sant'Anna style, base period = the week before
exposure), and compared to a naive pre/post and a naive treated-vs-untreated read.
Because the data-generating process is known, the true effects are computed from the
counterfactual paths in the same simulation.
"""
import json
import pathlib

import numpy as np
import pandas as pd
from scipy.special import expit

OUT = pathlib.Path(__file__).resolve().parent.parent / "content/data-projects/learner-value/data"
OUT.mkdir(parents=True, exist_ok=True)

T, C_PER, M = 20, 100, 200
C = 2 * C_PER
N = C * M
SEGS = ["13-15", "16-17", "18+"]
PROGS = ["streaks", "guided"]
WAVES = [5, 9, 13, 21]  # 21 = not reached within the window
WIN = (6, 8)            # "durable" event-time window, weeks after exposure
ADOPT = np.array([[0.70, 0.65, 0.30], [0.45, 0.45, 0.60]])
BOOST = np.array([[0.90, 0.80, 0.20], [0.25, 0.15, 0.40]])  # logit lift on P(active day), adopters
LEARN_G = np.array([1.0, 0.7, 1.1])   # guided: lift in learning per active day
TASK_G = np.array([0.15, 0.10, 0.15])  # guided: lift in task completion rate
RAMP = np.array([3, 4])
EXTRA_DAY_LEARNING = 0.25   # streak-driven extra days teach a quarter as much as a normal day
EXTRA_DAY_TASK = 0.20       # and complete a task 20% of the time


def simulate(seed, viol=0.0):
    rng = np.random.default_rng(seed)
    prog_c = np.repeat([0, 1], C_PER)
    u = rng.normal(0, 0.4, C)
    cohort = np.empty(C, int)
    for p in (0, 1):
        idx = np.where(prog_c == p)[0]
        order = idx[np.argsort(-(u[idx] + rng.normal(0, 0.3, len(idx))))]
        for k, g in enumerate(WAVES):
            cohort[order[k * 25:(k + 1) * 25]] = g
    cl = np.repeat(np.arange(C), M)
    seg = rng.choice(3, size=N, p=[0.3, 0.3, 0.4])
    prog = prog_c[cl]
    adopt = rng.random(N) < ADOPT[prog, seg]
    weeks = np.arange(1, T + 1)

    season = np.zeros((3, T))
    for s in (0, 1):
        season[s, [8, 9]] += 0.45
        season[s, [17, 18]] += 0.55
        season[s, [14, 15]] -= 0.8
    season[2, [8, 9]] += 0.1
    season[2, [14, 15]] -= 0.15
    zmap = {5: 1.0, 9: 0.33, 13: -0.33, 21: -1.0}
    zc = np.array([zmap[g] for g in cohort])

    eta = (-0.7 + u[cl][:, None] + rng.normal(0, 0.8, N)[:, None] + season[seg]
           - 0.02 * weeks[None, :] + viol * zc[cl][:, None] * weeks[None, :])
    e = weeks[None, :] - cohort[cl][:, None]
    tr = e >= 0
    ramp = np.clip((e + 1) / RAMP[prog][:, None], 0, 1) * tr
    ad = adopt[:, None] * ramp
    p0 = expit(eta)
    p1 = expit(eta + BOOST[prog, seg][:, None] * ad)
    U = rng.random((N, T, 7))
    d0 = (U < p0[..., None]).sum(2)
    d1 = (U < p1[..., None]).sum(2)
    r = p0 / p1

    is_s = (prog == 0)[:, None]
    lmult = np.where(is_s, 1.0, 1 + LEARN_G[seg][:, None] * ad)
    f = np.where(is_s, r + EXTRA_DAY_LEARNING * (1 - r), 1.0)
    init = rng.normal(0, 1, N)
    skill1 = init[:, None] + np.cumsum(0.012 * d1 * f * lmult, 1)
    skill0 = init[:, None] + np.cumsum(0.012 * d0, 1)

    q0 = 0.5
    q1 = np.where(is_s, q0 * r + EXTRA_DAY_TASK * (1 - r), q0 + TASK_G[seg][:, None] * ad)
    tasks = rng.binomial(d1, q1)

    show = rng.random((N, T)) < 0.5  # checkpoint shown at random, regardless of activity
    qscore = skill1 + rng.normal(0, 0.4, (N, T))

    key = cl * 3 + seg
    K = C * 3

    def agg(x):
        return np.stack([np.bincount(key, weights=x[:, t].astype(float), minlength=K) for t in range(T)], 1).reshape(C, 3, T)

    n = np.bincount(key, minlength=K).reshape(C, 3)[..., None]
    act, days, tsum, qn = agg(d1 > 0), agg(d1), agg(tasks), agg(show)
    qsum = agg(np.where(show, qscore, 0))
    with np.errstate(invalid="ignore", divide="ignore"):
        Y = {
            "active": act / n,
            "days": days / n,
            "task": np.where(days > 0, tsum / days, np.nan),
            "learning": np.where(qn > 0, qsum / qn, np.nan),
        }

    W = tr & (e >= WIN[0]) & (e <= WIN[1])
    truth, adoption = {}, {}
    for p in (0, 1):
        for s in range(3):
            m = W & (prog == p)[:, None] & (seg == s)[:, None]
            truth[(p, s)] = {
                "active": float((d1[m] > 0).mean() - (d0[m] > 0).mean()),
                "days": float(d1[m].mean() - d0[m].mean()),
                "task": float((d1[m] * q1[m]).sum() / d1[m].sum() - q0),
                "learning": float((skill1[m] - skill0[m]).mean()),
            }
            adoption[(p, s)] = float(adopt[(prog == p) & (seg == s) & (cohort[cl] < 21)].mean())

    raw = {}
    for g in (5, 21):
        m = (prog == 0) & (cohort[cl] == g)
        raw[g] = [float((d1[m][:, t] > 0).mean()) for t in range(T)]
    return dict(Y=Y, cohort=cohort, prog_c=prog_c, n=n[..., 0], truth=truth, adoption=adoption, raw=raw, u=u)


def att_by_event(Y, cohort, es):
    out = {}
    for e in es:
        num = den = 0.0
        for g in (5, 9, 13):
            t = g + e
            if t < 1 or t > T:
                continue
            tm = cohort == g
            ctrl = (cohort > max(t, g - 1)) & (cohort != g)
            if not tm.any() or not ctrl.any():
                continue
            dif = Y[:, t - 1] - Y[:, g - 2]
            a, b = np.nanmean(dif[tm]), np.nanmean(dif[ctrl])
            if np.isnan(a) or np.isnan(b):
                continue
            num += tm.sum() * (a - b)
            den += tm.sum()
        out[e] = num / den if den else np.nan
    return out


def window(out, lo, hi):
    v = [out[e] for e in range(lo, hi + 1) if not np.isnan(out[e])]
    return float(np.mean(v))


def naive(Y, cohort):
    pp = cs = wts = 0.0
    for g in (5, 9, 13):
        tm = cohort == g
        post = [t for t in range(g + WIN[0], g + WIN[1] + 1) if t <= T]
        pre = list(range(g - 4, g))
        pp += tm.sum() * (np.nanmean(Y[tm][:, [t - 1 for t in post]]) - np.nanmean(Y[tm][:, [t - 1 for t in pre]]))
        cs += tm.sum() * np.mean([np.nanmean(Y[tm][:, t - 1]) - np.nanmean(Y[cohort > t][:, t - 1]) for t in post])
        wts += tm.sum()
    return pp / wts, cs / wts


ES = list(range(-4, 11))
OUTS = ["active", "days", "task", "learning"]


def analyze(sim, B=200, seed=7, boot=True):
    rng = np.random.default_rng(seed)
    res = {}
    for p in (0, 1):
        pidx = np.where(sim["prog_c"] == p)[0]
        for s in range(3):
            for o in OUTS:
                Y = sim["Y"][o][pidx, s]
                co = sim["cohort"][pidx]
                est = att_by_event(Y, co, ES)
                pp, cs = naive(Y, co)
                entry = {"did": window(est, *WIN), "pre_trend": window(est, -4, -2),
                         "event": {str(e): est[e] for e in ES}, "naive_prepost": pp,
                         "naive_cross": cs, "truth": sim["truth"][(p, s)][o]}
                if boot:
                    bs, be = [], []
                    for _ in range(B):
                        ix = rng.choice(len(pidx), len(pidx))
                        ee = att_by_event(Y[ix], co[ix], ES)
                        bs.append(window(ee, *WIN))
                        be.append([ee[e] for e in ES])
                    entry["ci"] = float(1.96 * np.nanstd(bs))
                    entry["event_ci"] = [float(1.96 * np.nanstd(np.array(be)[:, i])) for i in range(len(ES))]
                res[f"{PROGS[p]}|{SEGS[s]}|{o}"] = entry
    return res


def clean(o):
    if isinstance(o, dict):
        return {str(k): clean(v) for k, v in o.items()}
    if isinstance(o, (list, tuple)):
        return [clean(v) for v in o]
    if isinstance(o, (np.floating, np.integer)):
        return float(o)
    return o


if __name__ == "__main__":
    sim = simulate(42)
    res = {"main": analyze(sim)}
    res["adoption"] = {f"{PROGS[p]}|{SEGS[s]}": sim["adoption"][(p, s)] for p in (0, 1) for s in range(3)}
    res["raw_active"] = {"wave5": sim["raw"][5], "notyet": sim["raw"][21]}
    u, co, pc = sim["u"], sim["cohort"], sim["prog_c"]
    res["selection"] = {str(g): float(u[(co == g) & (pc == 0)].mean()) for g in WAVES}

    # sensitivity: early-wave clusters trend faster by 0.01 logit/week per unit of earliness
    resv = analyze(simulate(42, viol=0.01), boot=False)
    res["sensitivity"] = {k: {"did": v["did"], "truth": v["truth"]} for k, v in resv.items() if k.endswith("|active")}

    (OUT / "results.json").write_text(json.dumps(clean(res), indent=1))

    rows = [(c, PROGS[pc[c]], SEGS[s], t + 1, int(co[c]), int(sim["n"][c, s]),
             sim["Y"]["active"][c, s, t], sim["Y"]["days"][c, s, t],
             sim["Y"]["task"][c, s, t], sim["Y"]["learning"][c, s, t])
            for c in range(C) for s in range(3) for t in range(T)]
    pd.DataFrame(rows, columns=["cluster", "program", "segment", "week", "wave_start", "learners",
                                "active_rate", "active_days", "tasks_per_day", "mean_quiz"]).to_csv(
        OUT / "cluster_week_panel.csv", index=False, float_format="%.5f")

    for k, v in res["main"].items():
        print(f"{k:28s} did={v['did']:+.3f}±{v['ci']:.3f} truth={v['truth']:+.3f} "
              f"prepost={v['naive_prepost']:+.3f} cross={v['naive_cross']:+.3f} pretrend={v['pre_trend']:+.3f}")
    print("adoption", res["adoption"])
    print("selection", res["selection"])
    for k, v in res["sensitivity"].items():
        print("sens", k, f"{v['did']:+.3f} truth {v['truth']:+.3f}")
