#!/usr/bin/env python3
"""
CGD payment-pattern analysis — CDG_Dental_Data_v1.xlsx only.

All data originates from California public records obtained via the
Public Records Act. No private dashboard exports, plaintiff procedure
extracts, or private benchmark files are used.

Outputs JSON consumed by content/data-projects/cgd/index.md.
"""

from __future__ import annotations

import json
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.optimize import nnls
import statsmodels.formula.api as smf


ROOT      = Path(__file__).resolve().parents[1]
FILES_DIR = ROOT / "content" / "data-projects" / "cgd" / "files"
STATE_FILE = FILES_DIR / "drive-download-20260503T130801Z-3-001" / "CDG_Dental_Data_v1.xlsx"
NPI_FILE   = FILES_DIR / "drive-download-20260503T130801Z-3-001" / "npi_numbers.xlsx"

CUT_MAR2015 = pd.Timestamp("2015-03-01")
CUT_JAN2016 = pd.Timestamp("2016-01-01")

FOCAL_DENTISTS = [
    "David Michael Diaz",
    "Irina Mihaela Tarnavsky",
    "Trinh Thuy Pham",
]



def _load_npi() -> pd.DataFrame:
    npi = pd.read_excel(NPI_FILE)[["NPI", "Dentist"]].copy()
    npi["NPI"] = pd.to_numeric(npi["NPI"], errors="coerce")
    npi = npi.dropna(subset=["NPI"])
    npi["NPI"] = npi["NPI"].astype(int)
    return npi


def _load_office_panel() -> pd.DataFrame:
    frame = pd.read_excel(STATE_FILE, sheet_name="Request 1 and 2")
    frame = frame.rename(columns={
        frame.columns[0]: "office",
        frame.columns[1]: "year",
        frame.columns[2]: "month_num",
        frame.columns[4]: "payments",
        frame.columns[5]: "visit_days",
    })
    for col in ["year", "month_num", "payments", "visit_days"]:
        frame[col] = pd.to_numeric(frame[col], errors="coerce")
    frame = frame.dropna(subset=["year", "month_num", "payments", "visit_days"]).copy()
    frame["office"] = frame["office"].astype(str).str.strip().str.replace("NorWalk", "Norwalk")
    frame["date"] = pd.to_datetime(
        dict(year=frame["year"].astype(int), month=frame["month_num"].astype(int), day=1)
    )
    frame["ppd"] = frame["payments"] / frame["visit_days"]
    return frame


def _load_weekly_panel() -> pd.DataFrame:
    frame = pd.read_excel(STATE_FILE, sheet_name="Request 6")
    frame = frame.rename(columns={
        frame.columns[0]: "npi",
        frame.columns[1]: "week_ending",
        frame.columns[2]: "payments",
    })
    frame["npi"]      = pd.to_numeric(frame["npi"], errors="coerce")
    frame["payments"] = pd.to_numeric(frame["payments"], errors="coerce")
    frame["week_ending"] = pd.to_datetime(frame["week_ending"])
    frame = frame.dropna(subset=["npi", "payments"])
    frame["npi"] = frame["npi"].astype(int)
    npi = _load_npi()
    frame = frame.merge(npi[["NPI", "Dentist"]], left_on="npi", right_on="NPI", how="left")
    return frame



def load_office_summary() -> dict:
    """Per-office totals, PPD pre/post, and system-wide totals."""
    o = _load_office_panel()

    rows = []
    for nm, g in o.groupby("office"):
        pre  = g[g["date"] < CUT_MAR2015]
        post = g[g["date"] >= CUT_MAR2015]
        rows.append({
            "office": nm,
            "total_payments": round(float(g["payments"].sum()), 2),
            "total_days": int(g["visit_days"].sum()),
            "ppd_overall": round(float(g["payments"].sum() / g["visit_days"].sum()), 2),
            "ppd_pre":  round(float(pre["payments"].sum()  / pre["visit_days"].sum()),  2) if len(pre)  else None,
            "ppd_post": round(float(post["payments"].sum() / post["visit_days"].sum()), 2) if len(post) else None,
            "pre_months":  int(len(pre)),
            "post_months": int(len(post)),
        })
    df = pd.DataFrame(rows)
    df["ratio_post_pre"] = (df["ppd_post"] / df["ppd_pre"]).round(3)
    df["delta_ppd"]      = (df["ppd_post"] - df["ppd_pre"]).round(2)

    overall_pre  = o[o["date"] < CUT_MAR2015]
    overall_post = o[o["date"] >= CUT_MAR2015]

    return {
        "overall": {
            "total_payments": round(float(o["payments"].sum()), 2),
            "total_days": int(o["visit_days"].sum()),
            "ppd_overall": round(float(o["payments"].sum() / o["visit_days"].sum()), 2),
            "pre_ppd":  round(float(overall_pre["payments"].sum()  / overall_pre["visit_days"].sum()),  2),
            "post_ppd": round(float(overall_post["payments"].sum() / overall_post["visit_days"].sum()), 2),
            "ratio_post_pre": round(
                float(overall_post["payments"].sum() / overall_post["visit_days"].sum()) /
                float(overall_pre["payments"].sum()  / overall_pre["visit_days"].sum()), 3
            ),
        },
        "offices": df.sort_values("total_payments", ascending=False).round(3).to_dict(orient="records"),
    }


def load_provider_summary() -> dict:
    """Per-dentist totals, pre/post split, and concentration stats."""
    w = _load_weekly_panel()

    rows = []
    for (npi_id, name), g in w.groupby(["npi", "Dentist"]):
        pre  = g[g["week_ending"] < CUT_MAR2015]["payments"]
        post = g[g["week_ending"] >= CUT_MAR2015]["payments"]
        rows.append({
            "npi":           int(npi_id),
            "dentist":       str(name),
            "total_payments": round(float(g["payments"].sum()), 2),
            "total_weeks":   int(len(g)),
            "active_weeks":  int((g["payments"] > 0).sum()),
            "avg_weekly":    round(float(g["payments"].mean()), 2),
            "pre_mean":      round(float(pre.mean()), 2) if len(pre) else None,
            "post_mean":     round(float(post.mean()), 2) if len(post) else None,
            "pre_weeks":     int(len(pre)),
            "post_weeks":    int(len(post)),
        })
    df = pd.DataFrame(rows).sort_values("total_payments", ascending=False).reset_index(drop=True)
    df["payment_rank"] = df.index + 1
    df["post_pre_ratio"] = (df["post_mean"] / df["pre_mean"]).round(3)

    total = float(df["total_payments"].sum())
    top5  = float(df["total_payments"].head(5).sum())

    return {
        "total_panel_payments": round(total, 2),
        "total_npi_count": int(df["npi"].nunique()),
        "total_weeks": int(w["week_ending"].nunique()),
        "top5_share": round(top5 / total, 4),
        "providers": df.round(3).to_dict(orient="records"),
        "focal_dentists": FOCAL_DENTISTS,
    }


def load_office_causal_battery() -> dict:
    """Two-way FE DiD, synthetic control, placebo, LOO, and monthly series for Anaheim."""
    o = _load_office_panel()
    valid = [
        nm for nm, g in o.groupby("office")
        if (g["date"] < CUT_MAR2015).any() and (g["date"] >= CUT_MAR2015).any() and len(g) >= 20
    ]
    panel = o[o["office"].isin(valid)].copy()
    panel["treat"]    = (panel["office"] == "Anaheim").astype(int)
    panel["post_mar"] = (panel["date"] >= CUT_MAR2015).astype(int)
    panel["post_jan"] = (panel["date"] >= CUT_JAN2016).astype(int)
    panel["month_str"] = panel["date"].dt.strftime("%Y-%m")
    pre_sd = float(panel.loc[panel["date"] < CUT_MAR2015, "ppd"].std(ddof=0))

    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        m_mar = smf.ols("ppd ~ treat*post_mar + C(office) + C(month_str)", data=panel).fit(cov_type="HC1")
        m_jan = smf.ols("ppd ~ treat*post_jan + C(office) + C(month_str)", data=panel).fit(cov_type="HC1")
        m_mar_cluster = smf.ols("ppd ~ treat*post_mar + C(office) + C(month_str)", data=panel).fit(
            cov_type="cluster", cov_kwds={"groups": panel["office"]}
        )

    b_mar, s_mar = float(m_mar.params["treat:post_mar"]), float(m_mar.bse["treat:post_mar"])
    b_jan, s_jan = float(m_jan.params["treat:post_jan"]), float(m_jan.bse["treat:post_jan"])
    s_mar_cluster = float(m_mar_cluster.bse["treat:post_mar"])

    # Monthly pivot
    pivot = panel.pivot_table(index="date", columns="office", values="ppd", aggfunc="mean").sort_index()
    controls = [c for c in pivot.columns if c != "Anaheim"]
    pivot["ctrl_mean"] = pivot[controls].mean(axis=1)
    pivot["gap"] = pivot["Anaheim"] - pivot["ctrl_mean"]

    # Synthetic control
    pre_idx = pivot.index < CUT_MAR2015
    x, y = pivot.loc[pre_idx, controls].values, pivot.loc[pre_idx, "Anaheim"].values
    weights, _ = nnls(x, y)
    if weights.sum() > 0:
        weights /= weights.sum()
    pivot["synth"] = pivot[controls].values.dot(weights)
    pre_rmse = float(np.sqrt(np.mean((y - x.dot(weights)) ** 2)))
    post_gap = float(pivot.loc[pivot.index >= CUT_MAR2015, "Anaheim"].mean()
                     - pivot.loc[pivot.index >= CUT_MAR2015, "synth"].mean())

    # Placebo
    placebo = []
    for off in valid:
        tmp = panel.copy()
        tmp["treat_pl"] = (tmp["office"] == off).astype(int)
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            m = smf.ols("ppd ~ treat_pl*post_mar + C(office) + C(month_str)", data=tmp).fit(cov_type="HC1")
        placebo.append({"office": off, "beta": round(float(m.params["treat_pl:post_mar"]), 2)})
    placebo = sorted(placebo, key=lambda r: -r["beta"])
    anaheim_rank = next(i + 1 for i, r in enumerate(placebo) if r["office"] == "Anaheim")
    perm_p = round(sum(1 for r in placebo if abs(r["beta"]) >= abs(b_mar)) / len(placebo), 3)
    one_sided_pos = round((anaheim_rank) / len(placebo), 3)

    # falsification: shift cutoff one year earlier
    false_cut = pd.Timestamp("2014-03-01")
    fpanel = panel[panel["date"] < CUT_MAR2015].copy()
    fpanel["post_false"] = (fpanel["date"] >= false_cut).astype(int)
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        m_false = smf.ols("ppd ~ treat*post_false + C(office) + C(month_str)", data=fpanel).fit(cov_type="HC1")
    b_false = float(m_false.params["treat:post_false"])
    s_false = float(m_false.bse["treat:post_false"])

    # pretrend check and trend-adjusted DiD
    panel["tidx"] = ((panel["date"] - panel["date"].min()).dt.days / 30.44)
    pre_only = panel[panel["date"] < CUT_MAR2015].copy()
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        m_pretrend = smf.ols("ppd ~ treat*tidx + C(office)", data=pre_only).fit(cov_type="HC1")
        m_trend_adj = smf.ols(
            "ppd ~ treat*post_mar + treat:tidx + C(office) + C(month_str)", data=panel
        ).fit(cov_type="HC1")

    b_pretrend = float(m_pretrend.params["treat:tidx"])
    s_pretrend = float(m_pretrend.bse["treat:tidx"])
    b_trend = float(m_trend_adj.params["treat:post_mar"])
    s_trend = float(m_trend_adj.bse["treat:post_mar"])

    # LOO
    loo = []
    for off in controls:
        sub = panel[panel["office"] != off].copy()
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            m = smf.ols("ppd ~ treat*post_mar + C(office) + C(month_str)", data=sub).fit(cov_type="HC1")
        b, s = float(m.params["treat:post_mar"]), float(m.bse["treat:post_mar"])
        loo.append({
            "dropped": off,
            "beta": round(b, 2),
            "ci_low": round(b - 1.96 * s, 2),
            "ci_high": round(b + 1.96 * s, 2),
        })
    loo = sorted(loo, key=lambda r: -r["beta"])

    return {
        "valid_offices": valid,
        "did_mar2015": {
            "beta": round(b_mar, 2), "se": round(s_mar, 2),
            "se_cluster_office": round(s_mar_cluster, 2),
            "t_cluster_office": round(b_mar / s_mar_cluster, 2),
            "t": round(b_mar / s_mar, 2),
            "ci_low": round(b_mar - 1.96 * s_mar, 2),
            "ci_high": round(b_mar + 1.96 * s_mar, 2),
            "std_effect": round(b_mar / pre_sd, 3),
        },
        "did_jan2016": {
            "beta": round(b_jan, 2), "se": round(s_jan, 2),
            "t": round(b_jan / s_jan, 2),
            "ci_low": round(b_jan - 1.96 * s_jan, 2),
            "ci_high": round(b_jan + 1.96 * s_jan, 2),
            "std_effect": round(b_jan / pre_sd, 3),
        },
        "synthetic_control": {
            "pre_rmse": round(pre_rmse, 2),
            "post_mean_gap": round(post_gap, 2),
            "weights": {off: round(float(w), 3) for off, w in zip(controls, weights)},
        },
        "placebo": {
            "anaheim_rank": anaheim_rank,
            "total_offices": len(valid),
            "permutation_p_two_sided": perm_p,
            "permutation_p_one_sided_positive": one_sided_pos,
            "betas": placebo,
        },
        "falsification_2014_03": {
            "beta": round(b_false, 2),
            "se": round(s_false, 2),
            "t": round(b_false / s_false, 2),
            "ci_low": round(b_false - 1.96 * s_false, 2),
            "ci_high": round(b_false + 1.96 * s_false, 2),
        },
        "pretrend_differential_slope": {
            "beta_per_month": round(b_pretrend, 3),
            "se": round(s_pretrend, 3),
            "t": round(b_pretrend / s_pretrend, 2),
            "ci_low": round(b_pretrend - 1.96 * s_pretrend, 3),
            "ci_high": round(b_pretrend + 1.96 * s_pretrend, 3),
        },
        "trend_adjusted_did_mar2015": {
            "beta": round(b_trend, 2),
            "se": round(s_trend, 2),
            "t": round(b_trend / s_trend, 2),
            "ci_low": round(b_trend - 1.96 * s_trend, 2),
            "ci_high": round(b_trend + 1.96 * s_trend, 2),
        },
        "leave_one_out": loo,
        "series": {
            "gap": [
                {"month": d.strftime("%Y-%m"), "value": round(float(v), 2)}
                for d, v in zip(pivot.index, pivot["gap"])
            ],
            "anaheim_vs_synth": [
                {"month": d.strftime("%Y-%m"), "anaheim": round(float(a), 2), "synth": round(float(s), 2)}
                for d, a, s in zip(pivot.index, pivot["Anaheim"], pivot["synth"])
            ],
            "all_offices": {
                off: [
                    {"month": d.strftime("%Y-%m"), "ppd": round(float(v), 2) if not pd.isna(v) else None}
                    for d, v in zip(pivot.index, pivot[off])
                ]
                for off in pivot.columns if off not in ("ctrl_mean", "gap", "synth")
            },
        },
    }


def load_provider_causal_battery(focal_dentist: str) -> dict:
    """DiD, placebo rotation, LOO, and monthly series for one focal provider."""
    w = _load_weekly_panel()

    el_mar = [
        int(n) for n, g in w.groupby("npi")
        if (g["week_ending"] < CUT_MAR2015).sum() >= 8 and (g["week_ending"] >= CUT_MAR2015).sum() >= 6
    ]
    el_jan = [
        int(n) for n, g in w.groupby("npi")
        if (g["week_ending"] < CUT_JAN2016).sum() >= 8 and (g["week_ending"] >= CUT_JAN2016).sum() >= 6
    ]

    def _did(npi_list, post_col, cut):
        p = w[w["npi"].isin(npi_list)].copy()
        p["npi_str"] = p["npi"].astype(str)
        p["treat"]   = (p["Dentist"] == focal_dentist).astype(int)
        p[post_col]  = (p["week_ending"] >= cut).astype(int)
        p["week_str"] = p["week_ending"].dt.strftime("%Y-%W")
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            m = smf.ols(f"payments ~ treat*{post_col} + C(npi_str) + C(week_str)", data=p).fit(cov_type="HC1")
            m_cluster = smf.ols(f"payments ~ treat*{post_col} + C(npi_str) + C(week_str)", data=p).fit(
                cov_type="cluster", cov_kwds={"groups": p["npi_str"]}
            )
        return (
            float(m.params[f"treat:{post_col}"]),
            float(m.bse[f"treat:{post_col}"]),
            float(m_cluster.bse[f"treat:{post_col}"]),
            p,
        )

    b_mar, s_mar, s_mar_cluster, panel_mar = _did(el_mar, "post_mar", CUT_MAR2015)
    b_jan, s_jan, s_jan_cluster, panel_jan = _did(el_jan, "post_jan", CUT_JAN2016)

    # placebo: rotate treated label across eligible providers
    placebo = []
    for nm, g in panel_mar.groupby("Dentist"):
        tmp = panel_mar.copy()
        tmp["treat_pl"] = (tmp["Dentist"] == nm).astype(int)
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            m = smf.ols("payments ~ treat_pl*post_mar + C(npi_str) + C(week_str)", data=tmp).fit(cov_type="HC1")
        placebo.append({"dentist": nm, "beta": round(float(m.params["treat_pl:post_mar"]), 0)})
    placebo = sorted(placebo, key=lambda r: -r["beta"])
    focal_pl_rank = next((i + 1 for i, r in enumerate(placebo) if focal_dentist in r["dentist"]), None)
    perm_p = round(sum(1 for r in placebo if abs(r["beta"]) >= abs(b_mar)) / len(placebo), 3) if len(placebo) > 0 else 1.0
    one_sided_pos = round((focal_pl_rank / len(placebo)), 3) if focal_pl_rank and len(placebo) > 0 else 1.0

    # falsification: shift cutoff one year earlier
    false_cut = pd.Timestamp("2014-03-01")
    fpanel = panel_mar[panel_mar["week_ending"] < CUT_MAR2015].copy()
    fpanel["post_false"] = (fpanel["week_ending"] >= false_cut).astype(int)
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        m_false = smf.ols("payments ~ treat*post_false + C(npi_str) + C(week_str)", data=fpanel).fit(cov_type="HC1")
    b_false = float(m_false.params["treat:post_false"])
    s_false = float(m_false.bse["treat:post_false"])

    # pretrend check and trend-adjusted DiD
    panel_mar["tidx"] = ((panel_mar["week_ending"] - panel_mar["week_ending"].min()).dt.days / 7.0)
    pre_only = panel_mar[panel_mar["week_ending"] < CUT_MAR2015].copy()
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        m_pretrend = smf.ols("payments ~ treat*tidx + C(npi_str)", data=pre_only).fit(cov_type="HC1")
        m_trend_adj = smf.ols(
            "payments ~ treat*post_mar + treat:tidx + C(npi_str) + C(week_str)", data=panel_mar
        ).fit(cov_type="HC1")

    b_pretrend = float(m_pretrend.params["treat:tidx"])
    s_pretrend = float(m_pretrend.bse["treat:tidx"])
    b_trend = float(m_trend_adj.params["treat:post_mar"])
    s_trend = float(m_trend_adj.bse["treat:post_mar"])

    # LOO
    focal_npi_vals = panel_mar[panel_mar["Dentist"] == focal_dentist]["npi"].unique()
    focal_npi = int(focal_npi_vals[0]) if len(focal_npi_vals) > 0 else None
    ctrl_npis = [n for n in el_mar if focal_npi is None or n != focal_npi]
    loo = []
    for drop_npi in ctrl_npis:
        sub = panel_mar[panel_mar["npi"] != drop_npi].copy()
        nm  = str(panel_mar[panel_mar["npi"] == drop_npi]["Dentist"].values[0])
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            m = smf.ols("payments ~ treat*post_mar + C(npi_str) + C(week_str)", data=sub).fit(cov_type="HC1")
        b, s = float(m.params["treat:post_mar"]), float(m.bse["treat:post_mar"])
        loo.append({
            "dropped_dentist": nm,
            "beta": round(b, 0),
            "ci_low": round(b - 1.96 * s, 0),
            "ci_high": round(b + 1.96 * s, 0),
        })
    loo = sorted(loo, key=lambda r: -r["beta"])

    # Monthly series per named provider
    panel_mar["month"] = panel_mar["week_ending"].dt.to_period("M").dt.to_timestamp()
    monthly = panel_mar.groupby(["month", "Dentist"])["payments"].mean().unstack().round(0)
    monthly_series = {
        col: [
            {"month": idx.strftime("%Y-%m"), "value": None if pd.isna(v) else int(v)}
            for idx, v in monthly[col].items()
        ]
        for col in monthly.columns
    }

    # Pre/post summary for focal dentist
    focal_pre  = float(w[(w["Dentist"] == focal_dentist) & (w["week_ending"] < CUT_MAR2015)]["payments"].mean())
    focal_post = float(w[(w["Dentist"] == focal_dentist) & (w["week_ending"] >= CUT_MAR2015)]["payments"].mean())

    return {
        "focal_dentist": focal_dentist,
        "eligible_providers_mar2015": [
            str(w[w["npi"] == n]["Dentist"].values[0]) for n in el_mar
        ],
        "did_mar2015": {
            "beta": round(b_mar, 0), "se": round(s_mar, 0),
            "se_cluster_provider": round(s_mar_cluster, 0),
            "t_cluster_provider": round(b_mar / s_mar_cluster, 2) if s_mar_cluster > 0 else 0,
            "t": round(b_mar / s_mar, 2),
            "ci_low": round(b_mar - 1.96 * s_mar, 0),
            "ci_high": round(b_mar + 1.96 * s_mar, 0),
            "n_rows": int(panel_mar.shape[0]),
            "n_providers": int(panel_mar["npi"].nunique()),
        },
        "did_jan2016": {
            "beta": round(b_jan, 0), "se": round(s_jan, 0),
            "se_cluster_provider": round(s_jan_cluster, 0),
            "t_cluster_provider": round(b_jan / s_jan_cluster, 2) if s_jan_cluster > 0 else 0,
            "t": round(b_jan / s_jan, 2),
            "ci_low": round(b_jan - 1.96 * s_jan, 0),
            "ci_high": round(b_jan + 1.96 * s_jan, 0),
            "n_rows": int(panel_jan.shape[0]),
            "n_providers": int(panel_jan["npi"].nunique()),
        },
        "placebo_rotation": {
            "focal_rank": focal_pl_rank,
            "total_providers": len(placebo),
            "permutation_p_two_sided": perm_p,
            "permutation_p_one_sided_positive": one_sided_pos,
            "betas": placebo,
        },
        "falsification_2014_03": {
            "beta": round(b_false, 0),
            "se": round(s_false, 0),
            "t": round(b_false / s_false, 2),
            "ci_low": round(b_false - 1.96 * s_false, 0),
            "ci_high": round(b_false + 1.96 * s_false, 0),
        },
        "pretrend_differential_slope": {
            "beta_per_week": round(b_pretrend, 3),
            "se": round(s_pretrend, 3),
            "t": round(b_pretrend / s_pretrend, 2),
            "ci_low": round(b_pretrend - 1.96 * s_pretrend, 3),
            "ci_high": round(b_pretrend + 1.96 * s_pretrend, 3),
        },
        "trend_adjusted_did_mar2015": {
            "beta": round(b_trend, 0),
            "se": round(s_trend, 0),
            "t": round(b_trend / s_trend, 2),
            "ci_low": round(b_trend - 1.96 * s_trend, 0),
            "ci_high": round(b_trend + 1.96 * s_trend, 0),
        },
        "leave_one_out": loo,
        "focal_pre_mean": round(focal_pre, 0),
        "focal_post_mean": round(focal_post, 0),
        "focal_post_pre_ratio": round(focal_post / focal_pre, 3),
        "monthly_series_by_dentist": monthly_series,
    }


def main() -> None:
    payload = {
        "source_file": "CDG_Dental_Data_v1.xlsx",
        "provenance": "California Public Records Act — shareable state records only",
        "office_summary":   load_office_summary(),
        "provider_summary": load_provider_summary(),
        "office_causal":    load_office_causal_battery(),
        "provider_causal":  {
            dentist: load_provider_causal_battery(dentist)
            for dentist in FOCAL_DENTISTS
        },
    }
    print(json.dumps(payload, indent=2, default=str))


if __name__ == "__main__":
    main()
