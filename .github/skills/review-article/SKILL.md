---
name: review-article
description: 'Conventions for BGL gear review articles sourced from RoadTrailRun. Use when creating, editing, or formatting any review post — covers front matter, multi-tester attribution, RoadTrailRun origin line, image naming, stats block, and prose structure.'
---

# BGL Review Article — Conventions

Reviews on BGL are primarily sourced from RoadTrailRun and republished here. They follow a consistent structure that differs from data project articles.

---

## File Structure

```
content/reviews/[product-slug]/
├── index.md
├── image_0.jpg      ← banner / hero
├── image_1.jpg
├── image_2.jpg
...
```

Images are named `image_N.jpg` (or `.png`) starting from `image_0.jpg`. The converter script (`scripts/convert_review.py`) handles this automatically when importing from Google Docs or a DOCX.

---

## Front Matter

```yaml
---
title: "[Brand] [Product] Review"  # Title case, no trailing punctuation
date: YYYY-MM-DD
banner: "image_0.jpg"
tags: ["running", "shoes"]  # See tag options below
categories: ["reviews"]
description: "150–160 character SEO description. Quote one tester's key verdict if possible."
draft: true
---
<!--more-->
```

**Tag options:** `running`, `cycling`, `ebikes`, `shoes`, `accessories`, `nutrition`, `gear`, `trail`, `winter`, `waterproof`

The `description` field: quote a tester or state the primary verdict plainly. Keep it under 160 characters. It shows in search results.

---

## Article Opening — Required Elements in Order

1. **RoadTrailRun origin line** (if originally published there):
```markdown
Original Post from RoadTrailRun
([link](https://www.roadtrailrun.com/YYYY/MM/slug.html))
```

2. **RoadTrailRun CTA button:**
```html
<a href="https://www.roadtrailrun.com"
class="button primary button-wrapper"><span>Read All RoadTrailRun
Reviews Here</span></a>
```

3. **Byline:**
```markdown
*Article by [First Last] and [First Last]*
```
   — For multiple testers, list all names. For solo reviews, just the one name.
   — The byline comes *after* the CTA button, not before.

4. **Product heading with price:**
```markdown
### [Brand Product Name] ($XXX)
```

5. **Banner image:**
```markdown
![image_0.jpg](image_0.jpg)
```

---

## Multi-Tester Attribution Format

BGL reviews often have multiple testers. Each opinion is attributed inline:

```markdown
**Pros**

Feature description: **Tester Name / Tester Name**

Another feature: **All Testers**
```

Or in prose format (longer reviews):

```
John: My impression of the upper was...

Renee: I found the fit to run narrow...
```

Consistent pattern: tester name at the start of their section separated by colon, or attribution in bold at the end of a bullet/line. Never mix the two styles within the same section.

---

## Stats Block

Always include a Stats section with these fields (fill what's known, omit what isn't):

```markdown
### Stats

**Weight:** Men's XX oz / XXX g (US 9) · Women's XX oz / XXX g (US 7)
**Stack Height:** XX mm heel / XX mm forefoot
**Drop:** XX mm
**Price:** $XXX
**Available:** [Month Year] or "Now"
**Purchase:** [Retailer link if affiliate available]
```

---

## Standard Section Order

1. Opening / product heading / banner image
2. Pros
3. Cons
4. Stats
5. First Impressions, Fit and Upper
6. Midsole / Ride (shoes) or equivalent category-specific sections
7. Outsole / Traction (for trail/winter shoes)
8. Comparisons (optional)
9. Who It's For / Conclusions

Not every review needs every section. Match the structure to what testers actually covered.

---

## Image Placement

Images go inline with the prose using standard Markdown:

```markdown
![image_3.jpg](image_3.jpg)
```

No captions required, but if a tester identifies a specific feature in an image, a short italic line below is fine:

```markdown
*Renee's women's colorway showing the Gore-Tex gusset.*
```

Do not use HTML `<figure>` or `<img>` tags — plain Markdown image syntax only.

---

## Affiliate Links

Use the `avantlink` format when linking to REI or other affiliate partners:

```markdown
[Available at REI](https://www.avantlink.com/click.php?tt=cl&merchant_id=...&url=...)
```

Never use bare product URLs when an affiliate link is available.

---

## Prose Conventions Specific to Reviews

- Tester voice is preserved — do not homogenize or "clean up" individual tester language
- Quotes from testers stay in the tester's own words; do not paraphrase
- Present tense for current impressions, past tense for specific test events ("I ran the Flatirons in these twice before...")
- Comparing to previous versions: mention version number explicitly ("Speedgoat 4", not "the previous version")
- Measurements: always state units. "9.7 oz / 275g (US 9)" not just "9.7 oz"

---

## Checklist Before Publishing

- [ ] `draft: false`
- [ ] `description` under 160 characters
- [ ] RoadTrailRun origin line and CTA button present (if applicable)
- [ ] Byline lists all contributing testers
- [ ] Stats block complete with weight, stack, drop, price
- [ ] Images referenced in order (`image_0`, `image_1`, etc.)
- [ ] `<!--more-->` tag present
- [ ] Affiliate links used where available
