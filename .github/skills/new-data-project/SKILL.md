---
name: new-data-project
description: 'Scaffold a new BGL data project article from scratch. Use when starting a new data project post — covers file structure, CSS prefix, style block, front matter, component wiring, and article structure. Do not use for review articles.'
---

# New Data Project Article — Scaffold

## Step 1: Create the Directory and File

```
content/data-projects/[slug]/index.md
```

Slug: lowercase, hyphen-separated, descriptive. No dates in the slug.

If the article has a banner SVG or images, they go in the same directory alongside `index.md`.

---

## Step 2: Choose a CSS Prefix

Pick a 2–3 character prefix that is unique to this article and won't collide with existing ones.

| Article | Prefix |
|---|---|
| ai-justice | `aj-` |
| arc / bloom-arc | `arc-` |
| model-quality | `mq-` |

Pick something short that abbreviates the article topic.

---

## Step 3: Front Matter

```yaml
---
title: "Title Here"
date: YYYY-MM-DD
tags: ['data project']
categories: ['data project']
description: "One declarative sentence stating the finding or stakes. No teaser questions. No clickbait."
draft: true
banner: "[prefix]-banner.svg"
---
<!--more-->
```

- `draft: true` until ready to publish
- `description` is used in meta/SEO — should read as a complete sentence giving the conclusion, not a hook
- If the article has a companion technical post (like model-quality / model-quality-overview), add `build: list: never` to the technical variant

---

## Step 4: Style Block

Open with a `<style>` block that scopes all classes under the chosen prefix. Copy this skeleton and fill in:

```html
<style>
/* ── [Article Name] — BGL Dark Theme ── */

.[prefix]-lede {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  color: rgba(255,255,255,0.4);
  border-left: 2px solid var(--moss);
  padding: 0.8rem 1.2rem;
  background: rgba(125,184,0,0.06);
  line-height: 1.65;
  margin-bottom: 2.5rem;
  letter-spacing: 0.03em;
}

.[prefix]-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.[prefix]-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }

.[prefix]-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

/* ── Visualization cards ── */
.[prefix]-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.[prefix]-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.[prefix]-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.[prefix]-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.[prefix]-vis-legend {
  display: flex; flex-wrap: wrap; gap: 8px 22px;
  margin-bottom: 14px;
  font-size: 1.25rem; color: rgba(255,255,255,0.55); font-family: var(--f-mono);
}
.[prefix]-vis-legend span { display: flex; align-items: center; gap: 8px; }
.[prefix]-vis-legend i { display: inline-block; width: 26px; height: 3px; border-radius: 2px; flex-shrink: 0; }
.[prefix]-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}

/* ── Callout ── */
.[prefix]-callout {
  margin: 2.2rem 0; padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic; font-size: 1.5rem;
  color: rgba(255,255,255,0.55); line-height: 1.8;
}
.[prefix]-callout.red { border-color: #e07055; background: rgba(224,112,85,0.05); }
.[prefix]-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

/* ── Data table ── */
.[prefix]-table-wrap {
  overflow-x: auto; margin: 26px 0;
  border-radius: 4px; border: 1px solid rgba(255,255,255,0.07);
}
.[prefix]-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.[prefix]-table thead tr { background: rgba(255,255,255,0.06); }
.[prefix]-table thead th {
  padding: 12px 16px; text-align: left;
  font-family: var(--f-mono); font-size: 1.25rem; font-weight: 600;
  letter-spacing: 0.08em; text-transform: uppercase; color: rgba(255,255,255,0.7);
}
.[prefix]-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.[prefix]-table tbody td {
  padding: 11px 16px; border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono); color: rgba(255,255,255,0.5); font-size: 1.25rem; line-height: 1.6;
}
.[prefix]-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }
.[prefix]-table-caption {
  font-family: var(--f-mono); font-size: 1.1rem;
  color: rgba(255,255,255,0.28); letter-spacing: 0.06em;
  text-transform: uppercase; margin-bottom: 0.5rem;
}

/* ── Footnotes ── */
.[prefix]-footnotes {
  margin-top: 52px; border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px; font-family: var(--f-mono);
  font-size: 1.25rem; color: rgba(255,255,255,0.3); line-height: 1.65;
}
</style>
```

Only include the component classes you will actually use. Delete the ones you won't.

---

## Step 5: Article Opening

Immediately after `</style>`:

```html
<div class="[prefix]-lede">
  One sentence stating the data source or analytic context.
</div>

*Article by John Tribbia*

[Opening paragraph — no heading. Start with the finding or the tension. Not background.]
```

The lede is a citation/context note, not a headline. Keep it to one sentence.

---

## Step 6: Article Structure

Typical section order for data project articles:

1. **Opening** (no heading) — the tension, the question, the finding up front
2. **[Section heading]** — first major analytical section
3. Vis card or table if data supports it
4. **[Section heading]** — second analytical section
5. Callout (if there's a key takeaway that needs visual separation)
6. **[Section heading]** — third analytical section / implications
7. Footnotes block

Use `---` (Markdown horizontal rule) between major sections. Use `<h2 class="[prefix]-h2">` for all section headings.

---

## Step 7: Chart.js Setup (if using charts)

At the bottom of the file, before `</body>` or at end of content:

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
Chart.defaults.color = 'rgba(255,255,255,0.35)';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';

new Chart(document.getElementById('chartId'), {
  // ... see bgl-design-system skill for full options template
});
</script>
```

Canvas elements go inside `.[prefix]-vis-card` divs wrapped in `<div style="position: relative; width: 100%; height: 300px;">`.

---

## Step 8: Footnotes

End every data project article with a footnotes block:

```html
<div class="[prefix]-footnotes">
  Source citations. Methodology notes. Data links.
</div>
```

---

## Checklist Before Publishing

- [ ] `draft: false` in front matter
- [ ] Description is a complete declarative sentence (not a question, not a hook)
- [ ] CSS prefix is unique — no collision with other articles
- [ ] All `canvas` IDs are unique across the page
- [ ] SVG `marker` IDs are prefixed (e.g., `[prefix]-arr-red`) to avoid collisions
- [ ] Chart.js globals set before any `new Chart()` call
- [ ] Footnotes block present with primary sources cited
- [ ] `*Article by John Tribbia*` byline present
- [ ] `<!--more-->` tag present after front matter
