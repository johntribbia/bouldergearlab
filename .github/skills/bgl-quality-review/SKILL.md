---
name: bgl-quality-review
description: 'Objective quality reviewer for all BGL work — writing, code, data analysis, and visualizations. Use when asked to review, audit, or QA any article, script, chart, or analysis. Applies a structured checklist across four dimensions: writing quality, technical correctness, visual/design consistency, and analytical integrity.'
---

# BGL Quality Review

Run this when asked to review finished or near-finished work before publication, or when asked to audit something that "doesn't feel right."

This skill is deliberately adversarial. Its job is to find problems, not to affirm what's already there.

---

## Dimension 1: Writing Quality

Apply the full writing-voice skill checklist. Look for:

### AI Fingerprints — flag any instance of:
- "It's worth noting…" / "It's important to understand…"
- "Let's explore…" / "Let's dive into…"
- "In today's rapidly evolving…" / "paradigm shift" / "game-changing"
- "Ultimately…" as a paragraph opener
- "Delve", "leverage", "utilize", "robust", "nuanced", "cutting-edge"
- Rhetorical questions used as transitions ("So what does this mean?")
- Sentences that exist only to announce what the next sentence will say
- Stacked hedges: "could potentially be argued to suggest that…"

### Structure Problems:
- Bullet-point prose in the middle of analytical sections (convert to paragraph)
- Over-explanation: the same point stated twice in different words
- Missing evidence: claim made without data or citation to support it
- Generic conclusion that could apply to any article

### Voice Drift:
- Passages that sound like a different author (more formal, more casual, or more generic than surrounding text)
- Metaphors that are labored or don't resolve cleanly
- Sentences that try to do too many things

**Output format:** Quote the offending sentence. State the problem in one line. Suggest a fix or flag for human revision.

---

## Dimension 2: Code Quality

For Python scripts (`scripts/`) and JavaScript in articles.

### Python:
- No hardcoded credentials, API keys, or absolute paths that won't work on another machine
- Input validation at system boundaries (file paths, user input, URLs)
- No SQL string concatenation (use parameterized queries if applicable)
- `os.path` or `pathlib` used for file paths, not string concatenation
- Error messages give actionable information, not just exception type
- No bare `except:` clauses that swallow all errors silently
- Dependencies clearly stated (imports at top, README lists pip packages)

### JavaScript (in article `<script>` blocks):
- Canvas IDs are unique — no two charts on the same page share an ID
- SVG `marker` IDs are prefixed to avoid collisions between articles rendered on the same page
- Chart.js globals (`Chart.defaults.color`, `Chart.defaults.borderColor`) set before any `new Chart()` call
- `new Chart()` calls do not rely on DOM elements that may not exist yet
- No `console.log` left in production code

### General:
- Are there race conditions or order-of-operations issues?
- Does any code fail silently in a way that produces misleading output?

**Output format:** File name and line number (if known). State the issue. Severity: `BLOCKER` (wrong output or security issue), `WARNING` (fragile but functional), `STYLE` (minor).

---

## Dimension 3: Visual / Design Consistency

Check against the bgl-design-system skill.

### CSS / Styling:
- Is the correct article prefix used consistently? No class name collisions with other articles?
- Are all design tokens (`--moss`, `--predawn`, `--f-mono`, etc.) used instead of hardcoded equivalents?
- Font sizes in article CSS — body paragraphs at `1.5rem`, labels/notes at `1.25rem`?
- Are all component colors within the defined palette (moss, ice, rust, stone)?

### Charts:
- Chart.js global defaults set (`color`, `borderColor`)?
- Axis fonts set to Space Mono?
- Tooltip background `rgba(10,13,20,0.96)`?
- Bar charts have `borderWidth: 1.5` and `borderRadius: 3`?
- Y-axis ticks formatted with `%` callback if showing percentages?
- Legend visible (`display: true`) when multiple datasets are present?

### SVG Diagrams:
- All `marker` IDs namespaced with article prefix?
- Font family specified as `'Space Mono',monospace` in `font-family` attribute?
- No hardcoded pixel widths that break on mobile — `width:100%` on the SVG?

### Layout:
- Vis cards have `margin: 36px 0` and `padding: 28px 24px 20px`?
- Callout boxes have the correct left-border color for their variant (moss or rust)?
- Footnotes block present and separated from body by `margin-top: 52px`?

**Output format:** Component name. What's wrong. What the correct value should be.

---

## Dimension 4: Analytical Integrity

For data project articles and any article making quantitative claims.

### Factual Accuracy:
- Are statistics cited to a specific source? Are the numbers in the text consistent with the source?
- Do chart values match the numbers stated in the prose?
- Are percentages, ratios, and Gini coefficients correctly described (direction, magnitude)?
- Are time periods stated correctly (the report period, not the publication date)?

### Statistical Claims:
- Does the article conflate correlation and causation without appropriate hedging?
- Are confidence intervals or uncertainty ranges stated when they exist?
- Does the framing of a finding match what the underlying method can actually support?
- Are cherry-picked statistics used without showing the broader context?

### Logical Consistency:
- Do section conclusions follow from the evidence presented in that section?
- Are comparisons made between things that are actually comparable (same base, same metric)?
- Does the closing argument address the question posed in the opening?

### Citation Completeness:
- Are all factual claims that aren't common knowledge cited?
- Do external links have `target="_blank" rel="noopener"`?
- Are source names stated in text (not just linked) so the article is readable offline?

**Output format:** Claim or section. Issue type: `FACTUAL ERROR`, `UNSUPPORTED CLAIM`, `LOGICAL GAP`, `MISSING CITATION`. Description and suggested fix.

---

## Review Output Structure

When delivering a quality review, use this format:

```
## Quality Review: [Article/File Name]

### BLOCKERS (must fix before publish)
[List issues that are factually wrong, technically broken, or security-relevant]

### WARNINGS (should fix)
[Issues that weaken the work: AI fingerprints, weak analysis, visual inconsistencies]

### MINOR
[Small style, formatting, or preference issues]

### PASSING
[What is working well — brief, specific, not generic praise]
```

If everything passes a dimension, say so explicitly rather than omitting that section. A clean review is meaningful only if the reviewer actually checked.

---

## What This Skill Does Not Do

- It does not rewrite content — it flags and explains
- It does not override the author's voice — it flags passages that have drifted from it
- It does not make judgment calls about subjective editorial decisions (what to include, article angle) — those stay with the author
