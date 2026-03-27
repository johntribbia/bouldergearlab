---
name: bgl-design-system
description: 'Design system, CSS tokens, component patterns, and Chart.js defaults for Boulder Gear Lab data project articles. Use when building or editing HTML visualization cards, callout boxes, data tables, SVG diagrams, or Chart.js charts in any BGL content file.'
---

# BGL Design System — Data Project Articles

## Design Tokens (CSS Variables)

Defined in `static/css/alpine-dark.css`. Always use these; never hardcode equivalents.

| Token | Value | Use |
|---|---|---|
| `--predawn` | `#0a0d14` | Page background |
| `--treeline` | `#0f1a1c` | Deep surface |
| `--alpine` | `#111820` | Mid surface |
| `--ridge` | `#1a2030` | Raised surface / table headers |
| `--moss` | `#7db800` | Primary accent, borders, labels |
| `--moss-glow` | `rgba(125,184,0,0.25)` | Glows |
| `--moss-dim` | `rgba(125,184,0,0.6)` | Dimmed accent |
| `--ice` | `#a8c8d8` | Secondary data color |
| `--stone` | `#8a8c84` | Muted text |
| `--f-display` | `'Outfit', sans-serif` | Headings, vis titles |
| `--f-mono` | `'Space Mono', monospace` | Labels, captions, table cells, notes |

## Typography Scale (in article CSS)

| Class role | `font-size` | `color` |
|---|---|---|
| Body paragraph | `1.5rem` | `rgba(255,255,255,0.65)` |
| Strong/bold in body | — | `rgba(255,255,255,0.88)` |
| Section heading | `1.65rem` | `rgba(255,255,255,0.9)` |
| Vis label (mono, uppercase) | `1.25rem` | `var(--moss)` |
| Vis title | `1.5rem` | `rgba(255,255,255,0.88)` |
| Vis sub / caption | `1.25rem` | `rgba(255,255,255,0.35)` |
| Vis note / footnote | `1.25rem` | `rgba(255,255,255,0.3)` |
| Table header | `1.25rem` | `rgba(255,255,255,0.7)` |
| Table cell | `1.25rem` | `rgba(255,255,255,0.5)` |
| Table cell first-child | — | `rgba(255,255,255,0.82)`, `font-weight: 700` |

## CSS Naming Convention

Every article gets a two-to-three letter prefix to namespace its classes and avoid collisions. Examples: `aj-` (ai-justice), `arc-` (arc article).

Apply prefix to: `vis-card`, `vis-label`, `vis-title`, `vis-sub`, `vis-legend`, `vis-note`, `h2`, `p`, `callout`, `table-wrap`, `table`, `table-caption`, `footnotes`, `lede`, `hr`.

## Component Patterns

### Visualization Card

```html
<div class="[prefix]-vis-card">
  <div class="[prefix]-vis-label">SOURCE · CONTEXT</div>
  <div class="[prefix]-vis-title">Chart title here</div>
  <div class="[prefix]-vis-sub">Subtitle or axis description · units</div>
  <div class="[prefix]-vis-legend">
    <span><i style="background:#7db800;"></i> Label A</span>
    <span><i style="background:#a8c8d8;"></i> Label B</span>
  </div>
  <div style="position: relative; width: 100%; height: 300px;">
    <canvas id="chartId"></canvas>
  </div>
  <p class="[prefix]-vis-note">Source note and interpretation.</p>
</div>
```

CSS for the card:
```css
.[prefix]-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
```

Legend `i` swatch: `display:inline-block; width:26px; height:3px; border-radius:2px; flex-shrink:0`

### Callout / Highlight Box

```html
<div class="[prefix]-callout">
  <strong>Label:</strong> Body text.
</div>
```

Variants: default (moss accent), `.red` (rust accent `#e07055`).

CSS:
```css
.[prefix]-callout {
  margin: 2.2rem 0; padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic; font-size: 1.5rem;
  color: rgba(255,255,255,0.55); line-height: 1.8;
}
.[prefix]-callout.red { border-color: #e07055; background: rgba(224,112,85,0.05); }
.[prefix]-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }
```

### Lede Block (intro citation/context note)

```html
<div class="[prefix]-lede">
  Short framing sentence about data source or context window.
</div>
```

CSS:
```css
.[prefix]-lede {
  font-family: var(--f-mono); font-size: 1.25rem;
  color: rgba(255,255,255,0.4);
  border-left: 2px solid var(--moss);
  padding: 0.8rem 1.2rem;
  background: rgba(125,184,0,0.06);
  line-height: 1.65; margin-bottom: 2.5rem;
  letter-spacing: 0.03em;
}
```

### Data Table

```html
<div class="[prefix]-table-wrap">
  <div class="[prefix]-table-caption">Table N · Description</div>
  <table class="[prefix]-table">
    <thead><tr><th>Col</th></tr></thead>
    <tbody><tr><td>Value</td></tr></tbody>
  </table>
</div>
```

### Section Heading

```html
<h2 class="[prefix]-h2">Section Title</h2>
```

CSS:
```css
.[prefix]-h2 {
  font-family: var(--f-display); font-size: 1.65rem; font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem; padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}
```

### Footnotes Block

```html
<div class="[prefix]-footnotes">
  Source citations, methodology notes.
</div>
```

CSS: `margin-top: 52px; border-top: 1px solid rgba(255,255,255,0.08); padding-top: 26px; font-family: var(--f-mono); font-size: 1.25rem; color: rgba(255,255,255,0.3); line-height: 1.65;`

## Chart.js Defaults

Always set these globals before any `new Chart()` call:

```js
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';
```

### Standard Chart Options Block

```js
options: {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    x: {
      grid: { color: 'rgba(255,255,255,0.04)' },
      ticks: { font: { family: 'Space Mono, monospace', size: 12 } }
    },
    y: {
      grid: { color: 'rgba(255,255,255,0.04)' },
      ticks: { font: { family: 'Space Mono, monospace', size: 11 } }
    }
  },
  plugins: {
    legend: {
      labels: {
        font: { family: 'Space Mono, monospace', size: 11 },
        color: 'rgba(255,255,255,0.45)',
        boxWidth: 14, padding: 18
      }
    },
    tooltip: {
      backgroundColor: 'rgba(10,13,20,0.96)',
      titleFont: { family: 'Space Mono, monospace', size: 11 },
      bodyFont: { family: 'Space Mono, monospace', size: 11 }
    }
  }
}
```

### Color Palette for Charts

| Role | Hex | RGBA fill (0.65 opacity) |
|---|---|---|
| Primary / Aug baseline | `#7db800` (moss) | `rgba(125,184,0,0.65)` |
| Secondary / comparison | `#a8c8d8` (ice) | `rgba(168,200,216,0.65)` |
| Warning / cost / burden | `#e07055` (rust) | `rgba(224,112,85,0.65)` |
| Muted / background series | `#8a8c84` (stone) | `rgba(138,140,132,0.5)` |

Bar charts: `borderWidth: 1.5`, `borderRadius: 3`

### CDN

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
```

## SVG Diagrams

Use inline SVG for flow/structural diagrams. Consistent conventions:
- `viewBox="0 0 700 200"` (adjust height as needed), `style="width:100%;max-width:700px;display:block;margin:12px 0;"`
- Box fill: `rgba(255,255,255,0.035)`, stroke: `rgba(255,255,255,0.12)`, `rx="4"`
- Colored boxes follow their palette color at 5–7% fill opacity, 28% stroke opacity
- Text: `font-family="'Space Mono',monospace"`, label text at 9–11px, annotation text at 7.5–8.5px
- Arrows: named `<marker>` elements with `id="[prefix]-arr-[color]"`, fill at 60–65% opacity
- Dashed lines for "output/benefit" flows: `stroke-dasharray="5,3"`
- Solid lines for "resource/cost" flows

## Front Matter Conventions

```yaml
---
title: "Title Here"
date: YYYY-MM-DD
tags: ['data project']
categories: ['data project']
description: "One sentence, declarative, no clickbait. States the finding or stakes."
draft: false
banner: "[prefix]-banner.svg"
---
<!--more-->
```

The `description` field is used in meta/SEO. It should read as a complete sentence that tells someone exactly what the article establishes — not a teaser, not a question.
