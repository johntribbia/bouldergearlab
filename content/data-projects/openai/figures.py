"""figures.py — BGL-style publication figures for the ChatGPT A/B test analysis.

Usage:
    cd /workspaces/bouldergearlab/content/data-projects/openai
    python3 figures.py

Saves six PNG files to figures/. Requires matplotlib, scipy, numpy.
"""

import csv
import math
import os
from collections import defaultdict
from datetime import datetime, timedelta

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.lines import Line2D
from scipy import stats

# ── Paths ──────────────────────────────────────────────────────────────────────
_HERE     = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(_HERE, 'data', 'chatgpt_ab_test.csv')
FIG_DIR   = os.path.join(_HERE, 'figures')
os.makedirs(FIG_DIR, exist_ok=True)

# ── Colour system — dark BGL theme (treeline / alpine surfaces) ───────────────
_BG   = '#0F1A1C'  # treeline — figure outer background
_SURF = '#131F24'  # alpine   — axes surface
_EDGE = '#1C2E35'  # ridge    — spine / border colour

C = {
    'moss':   '#7DB800',  # primary — treatment, positive, significant
    'ice':    '#A8C8D8',  # secondary — control, series 2
    'rust':   '#E07055',  # negative — cancelled, bad outcome
    'stone':  '#8A9EA8',  # neutral reference lines / not-significant
    'steel':  '#5B9EC8',  # alternate line (brightened for dark bg)
    'text':   '#C8DCE4',  # primary labels / axis text  (~78% white)
    'sub':    '#3D5560',  # subtitles / captions  (~24% white)
    'muted':  '#6E8A94',  # annotations / lower-priority text (~43% white)
}
MONO = 'DejaVu Sans'  # unified sans-serif — drop the monospace look

RC = {
    'figure.facecolor':  _BG,
    'axes.facecolor':    _SURF,
    'axes.edgecolor':    _EDGE,
    'axes.spines.top':   False,
    'axes.spines.right': False,
    'axes.grid':         True,
    'grid.color':        '#182830',
    'grid.linewidth':    0.7,
    'axes.labelcolor':   C['muted'],
    'axes.labelsize':    10,
    'xtick.color':       C['sub'],
    'ytick.color':       C['sub'],
    'xtick.labelsize':   9,
    'ytick.labelsize':   9,
    'font.family':       'sans-serif',
    'font.size':         10,
    'figure.dpi':        150,
    'savefig.dpi':       150,
    'savefig.facecolor': _BG,
    'text.color':        C['text'],
    'legend.fontsize':   9,
}

# ── Helpers ────────────────────────────────────────────────────────────────────
CUTOFF  = datetime(2023, 7, 1)
OBS_END = datetime(2023, 7, 31)


def parse(s):
    return datetime.strptime(s, '%Y-%m-%d') if s else None


def load():
    rows  = list(csv.DictReader(open(DATA_PATH)))
    treat = [r for r in rows if r['treatment'] == '1']
    ctrl  = [r for r in rows if r['treatment'] == '0']
    return rows, treat, ctrl


def add_header(fig, bold, sub, top=0.97):
    """Add a bold title + muted subtitle to the top of the figure using
    figure-level text. The title sits at `top` (figure fraction) and the
    subtitle 0.035 below it. Caller should set subplot_adjust top margin
    to leave room (typically rect=[0,0,1,top-0.07]).
    """
    fig.text(0.0, top, bold,
             ha='left', va='top',
             fontsize=13, fontweight='bold', color=C['text'])
    fig.text(0.0, top - 0.055, sub,
             ha='left', va='top',
             fontsize=8.5, color=C['sub'], fontfamily=MONO)


def savefig(fig, name):
    p = os.path.join(FIG_DIR, name)
    fig.savefig(p, bbox_inches='tight', facecolor=_BG, dpi=150)
    plt.close(fig)
    print(f'  \u2713  {name}')


# ── Figure 00 — Signup Rate by Arm ────────────────────────────────────────────
def fig00(treat, ctrl):
    n_t, n_c = len(treat), len(ctrl)
    s_t = sum(1 for r in treat if r['paid_signup_date'])
    s_c = sum(1 for r in ctrl  if r['paid_signup_date'])
    p_t, p_c = s_t / n_t, s_c / n_c
    se_t = math.sqrt(p_t * (1 - p_t) / n_t)
    se_c = math.sqrt(p_c * (1 - p_c) / n_c)
    lift = p_t - p_c
    se_d = math.sqrt(se_t**2 + se_c**2)
    z    = lift / se_d

    fig, ax = plt.subplots(figsize=(6, 5.2))
    fig.subplots_adjust(top=0.78, bottom=0.14, left=0.13, right=0.95)

    x = [0, 1]
    ax.bar(x, [p_t * 100, p_c * 100],
           color=[C['moss'], C['ice']], width=0.52,
           edgecolor='none', zorder=3)
    ax.errorbar(x, [p_t * 100, p_c * 100],
                yerr=[1.96 * se_t * 100, 1.96 * se_c * 100],
                fmt='none', color=C['stone'], capsize=5,
                linewidth=1.3, capthick=1.3, zorder=4)

    # Value labels inside bars
    for xi, p in [(0, p_t), (1, p_c)]:
        ax.text(xi, p * 100 * 0.45, f'{p * 100:.2f}%',
                ha='center', va='center',
                fontsize=12, fontweight='bold', color='white')

    # Lift annotation — placed as a horizontal bracket between bars
    y_top = max(p_t, p_c) * 100 + 1.96 * max(se_t, se_c) * 100 + 0.6
    ax.annotate('', xy=(1, y_top + 0.5), xytext=(0, y_top + 0.5),
                arrowprops=dict(arrowstyle='-', color=C['stone'], lw=1))
    ax.text(0.5, y_top + 0.7,
            f'+{lift*100:.2f} pp   z = {z:.2f}   p < 0.001',
            ha='center', va='bottom',
            fontsize=9, color=C['muted'], fontfamily=MONO)

    ax.set_xticks(x)
    ax.set_xticklabels(['Treatment\n(n = 10,000)', 'Control\n(n = 20,000)'],
                       fontsize=10)
    ax.set_ylabel('Paid signup rate (%)')
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f'{v:.0f}%'))
    ax.set_ylim(0, y_top + 2.8)
    ax.xaxis.grid(False)

    add_header(fig,
               'Signup Rate by Arm',
               'Two-proportion z-test  ·  30,000 users  ·  June–July 2023  ·  95% CI shown')
    savefig(fig, '00_signup_rate.png')


# ── Figure 01 — Retention: Raw vs In-Window ───────────────────────────────────
def fig01(treat, ctrl):
    st_all = [r for r in treat if r['paid_signup_date']]
    sc_all = [r for r in ctrl  if r['paid_signup_date']]
    pt_raw = sum(1 for r in st_all if r['paid_plan_canceled'] == '1') / len(st_all)
    pc_raw = sum(1 for r in sc_all if r['paid_plan_canceled'] == '1') / len(sc_all)

    t_in = [r for r in treat if r['paid_signup_date'] and
            parse(r['paid_signup_date']) <= CUTOFF]
    c_in = [r for r in ctrl  if r['paid_signup_date'] and
            parse(r['paid_signup_date']) <= CUTOFF]
    pt_in = sum(1 for r in t_in if r['paid_plan_canceled'] == '1') / len(t_in)
    pc_in = sum(1 for r in c_in if r['paid_plan_canceled'] == '1') / len(c_in)

    def _panel(ax, pt, pc, n_t, n_c, title, stats_line):
        x = [0, 1]
        ax.bar(x, [pt * 100, pc * 100],
               color=C['rust'], width=0.52, label='Canceled',
               edgecolor=_SURF, linewidth=0.8, zorder=3)
        ax.bar(x, [(1 - pt) * 100, (1 - pc) * 100],
               bottom=[pt * 100, pc * 100],
               color=C['moss'], width=0.52, label='Retained',
               edgecolor=_SURF, linewidth=0.8, zorder=3)
        for xi, pcan, pret in [(0, pt, 1 - pt), (1, pc, 1 - pc)]:
            ax.text(xi, pcan * 50, f'{pcan*100:.1f}%',
                    ha='center', va='center', fontsize=10,
                    fontweight='bold', color='white')
            ax.text(xi, pcan * 100 + pret * 50, f'{pret*100:.1f}%',
                    ha='center', va='center', fontsize=10,
                    fontweight='bold', color='white')
        ax.set_xticks(x)
        ax.set_xticklabels([f'Treatment\n(n = {n_t:,})', f'Control\n(n = {n_c:,})'],
                           fontsize=10)
        ax.xaxis.grid(False)
        ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f'{v:.0f}%'))
        ax.set_ylim(0, 100)
        # Panel title as ax.set_title — no annotations
        ax.set_title(title, fontsize=10, fontweight='bold',
                     color=C['text'], loc='left', pad=8)
        # Stats line as x-axis label area
        ax.set_xlabel(stats_line, fontsize=7.5, color=C['muted'],
                      fontfamily=MONO, labelpad=6)

    fig, axes = plt.subplots(1, 2, figsize=(10, 5.5))
    fig.subplots_adjust(top=0.82, bottom=0.22, left=0.09, right=0.86, wspace=0.25)

    _panel(axes[0], pt_raw, pc_raw, len(st_all), len(sc_all),
           '(a)  Raw — all signups',
           f'T = {pt_raw*100:.1f}%   C = {pc_raw*100:.1f}%'
           f'   ·   misleading: 65% of T signups right-censored')
    _panel(axes[1], pt_in, pc_in, len(t_in), len(c_in),
           '(b)  Corrected — in-window only (signed up ≤ July 1)',
           f'T = {pt_in*100:.1f}%   C = {pc_in*100:.1f}%'
           f'   ·   z = 0.43   p = 0.67   CI [−4.7, +7.3 pp]')

    axes[0].set_ylabel('Share of signups (%)')
    handles = [mpatches.Patch(color=C['rust'], label='Canceled'),
               mpatches.Patch(color=C['moss'], label='Retained')]
    # Right-margin legend outside both panels (100% stacked = no interior whitespace)
    fig.legend(handles=handles, loc='center left', ncol=1,
               frameon=False, fontsize=10, bbox_to_anchor=(0.875, 0.52))

    add_header(fig,
               'Cancellation Rate: The Artifact and the Reality',
               'Stacked bar — 100% = signups who had completed their 30-day trial window')
    savefig(fig, '01_retention_comparison.png')


# ── Figure 02 — Right-Censoring Timeline ──────────────────────────────────────
def fig02(treat):
    signed = [r for r in treat if r['paid_signup_date']]
    np.random.seed(42)
    idx    = np.random.choice(len(signed), min(180, len(signed)), replace=False)
    sample = sorted([signed[i] for i in idx], key=lambda r: r['paid_signup_date'])

    obs_start = datetime(2023, 6, 1)
    fig, ax = plt.subplots(figsize=(10, 6))
    fig.subplots_adjust(top=0.82, bottom=0.10, left=0.07, right=0.96)

    for y, r in enumerate(sample):
        su       = parse(r['paid_signup_date'])
        te       = su + timedelta(days=30)
        censored = te > OBS_END
        color    = C['rust'] if censored else C['moss']
        end_disp = min(te, datetime(2023, 8, 10))
        ax.barh(y, (end_disp - su).days, left=(su - obs_start).days,
                height=0.75, color=color, alpha=0.55, linewidth=0)
        if censored:
            ax.plot((te - obs_start).days, y,
                    '>', color=C['rust'], markersize=3.5, alpha=0.75, linewidth=0)

    cut_x = (CUTOFF  - obs_start).days
    end_x = (OBS_END - obs_start).days
    ax.axvline(cut_x, color=C['steel'], linewidth=1.2, linestyle='--', zorder=5)
    ax.axvline(end_x, color=C['text'],  linewidth=1.6, linestyle='-',  zorder=5)

    # Vertical line labels placed inside the plot area via ax.text at data coords
    ax.text(cut_x + 0.8, len(sample) * 0.96, 'July 1\nIn-window cutoff',
            fontsize=7.5, color=C['steel'], va='top', fontfamily=MONO)
    ax.text(end_x + 0.8, len(sample) * 0.96, 'July 31\nObs. end',
            fontsize=7.5, color=C['text'], va='top', fontfamily=MONO)

    tick_dates = [datetime(2023, d[0], d[1]) for d in
                  [(6, 1), (7, 1), (7, 31), (8, 31)]]
    ax.set_xticks([(d - obs_start).days for d in tick_dates])
    ax.set_xticklabels([d.strftime('%b %-d') for d in tick_dates])
    ax.set_xlim(-2, 98)
    ax.set_yticks([])
    ax.set_xlabel('Calendar date', labelpad=6)
    ax.set_ylabel('Treatment signups (180-user sample)', labelpad=8)
    ax.yaxis.grid(False)

    handles = [
        mpatches.Patch(color=C['moss'],  alpha=0.65,
                       label='Observable — trial elapses within July 31'),
        mpatches.Patch(color=C['rust'],  alpha=0.65,
                       label='Right-censored — trial expires after July 31'),
    ]
    ax.legend(handles=handles, frameon=False, fontsize=9, loc='lower right')

    add_header(fig,
               'Free-Month Trials vs. Observation Window',
               '180 sampled treatment signups  ·  each bar = signup date → 30-day trial end')
    savefig(fig, '02_censoring_timeline.png')


# ── Figure 03 — Days-to-Signup Distribution ───────────────────────────────────
def fig03(treat, ctrl):
    def d2s(cohort):
        return [(parse(r['paid_signup_date']) - parse(r['assignment_date'])).days
                for r in cohort
                if r['paid_signup_date'] and parse(r['paid_signup_date']) <= CUTOFF]

    t_d = d2s(treat)
    c_d = d2s(ctrl)
    t_med, c_med = int(np.median(t_d)), int(np.median(c_d))

    fig, ax = plt.subplots(figsize=(8.5, 5.2))
    fig.subplots_adjust(top=0.80, bottom=0.12, left=0.10, right=0.97)

    bins = list(range(0, 32, 1))  # daily bins
    kw   = dict(bins=bins, density=True, edgecolor=_SURF, linewidth=0.5, zorder=3)
    ax.hist(c_d, color=C['ice'],  alpha=0.70, label=f'Control  (n = {len(c_d):,})',  **kw)
    ax.hist(t_d, color=C['moss'], alpha=0.45, label=f'Treatment  (n = {len(t_d):,})', **kw)

    # Median lines — label them in the legend, not as floating text
    ax.axvline(t_med, color=C['moss'],  linewidth=1.5, linestyle='--', alpha=0.9, zorder=4,
               label=f'Treatment median = {t_med}d')
    ax.axvline(c_med, color=C['steel'], linewidth=1.5, linestyle='--', alpha=0.9, zorder=4,
               label=f'Control median = {c_med}d')

    ax.set_xlabel('Days from assignment to paid signup')
    ax.set_ylabel('Density')
    ax.set_xticks(range(0, 32, 7))
    ax.legend(frameon=False, fontsize=9.5, loc='upper right')

    add_header(fig,
               'Days-to-Signup Distribution',
               'In-window cohort only (signed up ≤ July 1)  ·  daily bins  ·'
               '  identical medians validate in-window comparison')
    savefig(fig, '03_days_to_signup.png')


# ── Figure 04 — DOW Lift ──────────────────────────────────────────────────────
def fig04(treat, ctrl):
    days_order = ['Sunday', 'Monday', 'Tuesday', 'Wednesday',
                  'Thursday', 'Friday', 'Saturday']
    t_d = defaultdict(list)
    c_d = defaultdict(list)
    for r in treat:
        t_d[parse(r['assignment_date']).strftime('%A')].append(
            1 if r['paid_signup_date'] else 0)
    for r in ctrl:
        c_d[parse(r['assignment_date']).strftime('%A')].append(
            1 if r['paid_signup_date'] else 0)

    lifts, errs, pvals = [], [], []
    for day in days_order:
        ta, ca = t_d[day], c_d[day]
        p_t = sum(ta) / len(ta)
        p_c = sum(ca) / len(ca)
        se  = math.sqrt(p_t * (1 - p_t) / len(ta) + p_c * (1 - p_c) / len(ca))
        z   = (p_t - p_c) / se
        pvals.append(2 * (1 - stats.norm.cdf(abs(z))))
        lifts.append((p_t - p_c) * 100)
        errs.append(1.96 * se * 100)

    # BH FDR correction
    m      = len(days_order)
    ranked = sorted(range(m), key=lambda i: pvals[i])
    sig    = [False] * m
    for rank, idx in enumerate(ranked):
        if pvals[idx] < (rank + 1) / m * 0.05:
            sig[idx] = True

    fig, ax = plt.subplots(figsize=(8.5, 5.5))
    fig.subplots_adjust(top=0.80, bottom=0.12, left=0.13, right=0.80)

    y_pos = list(range(m))
    for i, (day, lift, err, s) in enumerate(zip(days_order, lifts, errs, sig)):
        color = C['moss'] if s else C['stone']
        ax.errorbar(lift, i, xerr=err,
                    fmt='o', color=color, markersize=7,
                    capsize=4, linewidth=1.5, capthick=1.5,
                    zorder=4 if s else 3)
        # Right-align labels outside the right plot edge via axes fraction
        label = f'{lift:+.1f} pp' + ('  ✓' if s else '')
        ax.text(lift + err + 0.25, i, label,
                va='center', fontsize=8.5, color=color, fontfamily=MONO)

    ax.axvline(0, color=C['text'], linewidth=0.8, alpha=0.25, zorder=2)
    ax.set_yticks(y_pos)
    ax.set_yticklabels(days_order, fontsize=10)
    ax.invert_yaxis()
    ax.set_xlabel('Signup lift vs. control (percentage points)')
    ax.xaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f'{v:+.0f} pp'))
    ax.yaxis.grid(False)
    ax.set_xlim(-5, 11)

    handles = [
        Line2D([0], [0], marker='o', color='none', markerfacecolor=C['moss'],
               markersize=7, label='Significant (Benjamini–Hochberg FDR, α = 0.05)'),
        Line2D([0], [0], marker='o', color='none', markerfacecolor=C['stone'],
               markersize=7, label='Not significant'),
    ]
    ax.legend(handles=handles, frameon=False, fontsize=9.5, loc='lower right',
              bbox_to_anchor=(0.98, 0.04))

    add_header(fig,
               'Signup Lift by Day of Week',
               'Exploratory subgroup  ·  95% CI  ·  Benjamini–Hochberg FDR (7 comparisons)'
               '  ·  strict Bonferroni retains Sunday only (p = 0.0003)')
    savefig(fig, '04_dow_lift.png')


# ── Figure 05 — Break-Even Sensitivity ───────────────────────────────────────
def fig05(treat, ctrl):
    sr_t = sum(1 for r in treat if r['paid_signup_date']) / len(treat)
    sr_c = sum(1 for r in ctrl  if r['paid_signup_date']) / len(ctrl)
    lift_all = sr_t - sr_c
    price    = 20.0

    # In-window retention (the measured fraction that don't cancel post-trial)
    t_in = [r for r in treat if r['paid_signup_date'] and
            parse(r['paid_signup_date']) <= CUTOFF]
    ret_t = 1 - sum(1 for r in t_in if r['paid_plan_canceled'] == '1') / len(t_in)

    smt      = {'Sunday', 'Monday', 'Tuesday'}
    t_s      = [r for r in treat if parse(r['assignment_date']).strftime('%A') in smt]
    c_s      = [r for r in ctrl  if parse(r['assignment_date']).strftime('%A') in smt]
    sr_t_smt = sum(1 for r in t_s if r['paid_signup_date']) / len(t_s)
    sr_c_smt = sum(1 for r in c_s if r['paid_signup_date']) / len(c_s)
    lift_smt = sr_t_smt - sr_c_smt

    def be_months(sr, lift, m_arr):
        cost      = sr * 100 * price
        monthly_r = lift * 100 * ret_t * price
        m_thresh  = monthly_r / cost
        threshold = cost * m_arr / monthly_r
        T = np.where(
            threshold < 1,
            np.log(np.maximum(1 - threshold, 1e-12)) / np.log(np.maximum(1 - m_arr, 1e-12)),
            np.nan,
        )
        return np.clip(T, 0, 60), m_thresh

    m_vals = np.linspace(0.005, 0.10, 600)
    be_all, m_thresh_all = be_months(sr_t,     lift_all, m_vals)
    be_smt, m_thresh_smt = be_months(sr_t_smt, lift_smt, m_vals)
    churn_pct = m_vals * 100

    fig, ax = plt.subplots(figsize=(8.5, 5.5))
    fig.subplots_adjust(top=0.80, bottom=0.12, left=0.11, right=0.97)

    t_all_pct = m_thresh_all * 100
    t_smt_pct = m_thresh_smt * 100
    ax.axvspan(0,         t_all_pct, alpha=0.14, color=C['moss'],  zorder=1)
    ax.axvspan(t_all_pct, t_smt_pct, alpha=0.09, color=C['stone'], zorder=1)
    ax.axvspan(t_smt_pct, 11,        alpha=0.12, color=C['rust'],  zorder=1)

    ax.plot(churn_pct, be_all, color=C['moss'],  linewidth=2.2, zorder=3,
            label=f'All days  (lift = +{lift_all*100:.1f} pp · threshold ≈ {t_all_pct:.1f}%)')
    ax.plot(churn_pct, be_smt, color=C['steel'], linewidth=2.2, linestyle='--', zorder=3,
            label=f'Sun / Mon / Tue  (lift = +{lift_smt*100:.1f} pp · threshold ≈ {t_smt_pct:.1f}%)')

    for xc, color in [(t_all_pct, C['moss']), (t_smt_pct, C['steel'])]:
        ax.axvline(xc, color=color, linewidth=1.0, linestyle=':', zorder=2, alpha=0.8)

    # Region labels — positioned at y=55 so they stay inside the axes ylim (0–60)
    for xc, lb in [
        (t_all_pct / 2,               'Ship'),
        ((t_all_pct + t_smt_pct) / 2, 'Target\nonly'),
        ((t_smt_pct + 10) / 2,        'Iterate'),
    ]:
        ax.text(xc, 55, lb, ha='center', fontsize=8.5,
                color=C['muted'], fontfamily=MONO, va='top')

    # LTV reference line — label on the right to avoid collision with curves
    ax.axhline(20, color=C['muted'], linewidth=0.8, linestyle='--', alpha=0.7, zorder=2)
    ax.text(9.7, 21.5, 'LTV = 20 mo',
            fontsize=7.5, color=C['muted'], fontfamily=MONO, va='bottom', ha='right')

    ax.set_xlim(0.5, 10)
    ax.set_ylim(0, 60)
    ax.set_xlabel('Monthly churn rate of paying subscribers (%)')
    ax.set_ylabel('Months to program break-even')
    ax.xaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f'{v:.0f}%'))
    ax.legend(frameon=False, fontsize=9.5, loc='lower right', bbox_to_anchor=(0.98, 0.04))

    add_header(fig,
               'ROI Break-Even vs. Monthly Churn Rate',
               'Program-level  ·  constant hazard / geometric decay  ·'
               '  curves approach ∞ at the threshold churn rate')
    savefig(fig, '05_breakeven_sensitivity.png')


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    plt.rcParams.update(RC)
    print('\nLoading data...')
    rows, treat, ctrl = load()
    print(f'  {len(rows):,} rows  ({len(treat):,} treatment  /  {len(ctrl):,} control)\n')
    print('Generating figures...')
    fig00(treat, ctrl)
    fig01(treat, ctrl)
    fig02(treat)
    fig03(treat, ctrl)
    fig04(treat, ctrl)
    fig05(treat, ctrl)
    print(f'\nDone. Output \u2192 {FIG_DIR}')


if __name__ == '__main__':
    main()
