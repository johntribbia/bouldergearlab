---
name: writing-voice
description: 'Writing style and voice for BGL data project articles. Use when drafting, editing, or revising any article prose — especially data project posts. Enforces a journalistic, evidence-driven voice that must be free of AI fingerprints, AI slop, and AI tell-signs.'
---

# BGL Writing Voice

## The Standard

The target is the writing in [*The Double Burden*](../../content/data-projects/ai-justice/index.md) and [*The Shape of a Good Answer*](../../content/data-projects/arc/index.md). That is the bar. Everything below describes how to stay there.

## The Non-Negotiables

**No AI fingerprints.** Delete on sight:
- "It's worth noting that…"
- "It's important to understand that…"
- "In conclusion…" / "To summarize…"
- "Let's explore…" / "Let's dive into…"
- "In today's rapidly evolving landscape…"
- "This brings us to…" / "With that in mind…"
- "Ultimately…" as a paragraph opener
- "Delve", "leverage", "utilize", "robust", "nuanced", "cutting-edge", "game-changing", "paradigm shift"
- Rhetorical questions used as section transitions ("So what does this mean?")
- Excessive hedging stacked in one sentence ("It could potentially be argued that…")
- Any sentence that exists only to say what the next paragraph will say

**No bullet-point prose.** Bullets are for technical specs and data tables. Argument and narrative live in paragraphs. If you find yourself reaching for a bullet list in the middle of an analytical section, write a paragraph instead.

**No over-explanation.** State the finding, show the logic, move on. Do not restate what was just said in slightly different words. Do not explain what the reader is about to learn before they learn it.

## Sentence and Paragraph Rhythm

Vary sentence length aggressively. Short sentences do the heavy lifting. Long sentences carry the qualifications, the context, the evidence. The rhythm should feel more like journalism than academic writing.

Three to four sentences per paragraph is typical. A lone sentence at the end of a section — or even as its own paragraph — is a tool, not a mistake.

Use colons to introduce elaborations cleanly: no transition word needed, just the elaboration.

Em dashes are for parenthetical force — not commas, not parentheses, when the pause should land hard.

## Tone and Stance

The voice is direct, not detached. The writer has a point of view and defends it with evidence. Opinions are earned by the data and the reasoning, not by assertion.

Do not perform authority. Sentences like "As any practitioner knows…" or "It's clear that…" are empty. If something is clear, the evidence makes it clear without announcement.

Humor is allowed but rare. Irony is allowed but exact. If a line is funny or ironic, it earns that by precision, not by trying.

## Voice Examples from Published Work

**Good (from *The Double Burden*):**
> The convergence is genuinely significant. It suggests the access side of the ledger can improve over time within a shared institutional environment. The infrastructure side has not historically tracked the adoption side.

Short. Direct. Each sentence does only one thing. No connecting tissue that the reader doesn't need.

**Good (from *The Shape of a Good Answer*):**
> Most agent evaluations only check whether the final answer was right. That is like judging effort in a mountain race by finish time alone.

Statement. Then analogy. The analogy appears once and does its work. Not belabored.

**Bad (AI slop pattern):**
> It is important to note that the convergence finding is quite significant. This brings us to an interesting question about the infrastructure side, which, as we've seen, has not historically tracked the adoption side. Let's explore this further.

This is what to avoid: padding, transition clichés, announcing instead of doing.

## Structural Conventions

- Byline: `*Article by John Tribbia*` on its own line immediately below front matter separator
- Section headers: use HTML `<h2 class="[prefix]-h2">` to match article CSS, not Markdown `##` (in HTML-heavy articles)
- In prose-only sections, Markdown `##` is fine
- `---` horizontal rules between major sections (Markdown, not HTML)
- Footnotes/citations go in a `<div class="[prefix]-footnotes">` block at the end, not inline

## What the Older Articles Do Wrong (For Reference)

The `beyond-the-algorithm` and `ai-impacting-bi` posts are earlier work. They use excessive metaphors (the baking / Michelin-star framing), bullet-heavy structure, and phrases like "This is the seismic shift" and "the kitchen is open." That pattern should not appear in new writing. The newer work is the model.
