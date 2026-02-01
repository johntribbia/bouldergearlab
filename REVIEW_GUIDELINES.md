# Review Content Guidelines

## Overview

This guide provides standards for creating and maintaining product reviews on Boulder Gear Lab. Following these guidelines ensures consistency, quality, and SEO optimization across all reviews.

## Directory Structure

Reviews are organized in `/content/reviews/` with each review in its own directory:

```
content/reviews/
├── product-name-review/
│   ├── index.md
│   ├── image_0.jpg
│   ├── image_1.jpg
│   └── ...
```

**Naming Convention:** Use lowercase with hyphens, descriptive and SEO-friendly
- ✅ Good: `mizuno-wave-rider-29-review`
- ✅ Good: `biolite-range-500-review`
- ❌ Bad: `bridging-the-gap-a-comprehensive` (unclear)
- ❌ Bad: `review-part-101` (cryptic suffix)

## Front Matter Standards

```yaml
---
title: "Product Name Review"  # Include "Review" in title for SEO
date: YYYY-MM-DD              # Publication date
banner: "image_0.jpg"          # Hero image (should exist in directory)
tags: ["category", "type"]     # See tags list below
categories: ["reviews"]        # Always "reviews"
description: "150-160 char SEO description with key details"
draft: false                   # true = unpublished, false = published
---
```

### Recommended Tags

- **Running:** `["running", "shoes"]`, `["running", "accessories"]`, `["running", "nutrition"]`
- **Cycling:** `["cycling", "ebikes"]`, `["cycling", "bikes"]`, `["cycling", "accessories"]`
- **General Gear:** `["gear", "outdoor"]`, `["gear", "winter"]`

## Content Structure

### Required Sections (in order)

1. **<!--more--> tag** - Place immediately after front matter
2. **Attribution** - Author byline and RoadTrailRun link if applicable
3. **Product Name & Price** - H3 heading with pricing
4. **Hero Image** - Primary product photo
5. **Introduction** - Engaging opening paragraph(s)
6. **Pros** - Bulleted list of advantages
7. **Cons** - Bulleted list of limitations
8. **Stats** (if applicable) - Technical specifications
9. **First Impressions** - Initial unboxing/handling thoughts
10. **Design & Construction** - Detailed component analysis
11. **Performance Testing** - Real-world usage results
12. **Fit & Sizing** (for wearables) - Sizing guidance
13. **Durability** - Long-term observations
14. **Who Is This For?** - Target audience
15. **Verdict** - Final recommendation
16. **Photo Gallery** - Additional images

### Optional Sections

- **Most Comparable Products** - Competitive comparisons
- **Testing Notes** - Methodology disclosure
- **Disclosure** - Relationship with manufacturer

## Formatting Standards

### Headings

- Use H2 (`##`) for major sections
- Use H3 (`###`) for subsections and product name
- Never use empty headings (`###` with no text)

### Lists

- Use dashes (`-`) for all lists (not asterisks)
- Use bold for emphasis: `- **Key point:** Explanation`

### Images

- Name images sequentially: `image_0.jpg`, `image_1.jpg`, etc.
- Use descriptive alt text in brackets: `![Product on trail](image_1.jpg)`
- Place images contextually throughout review

### Links

- RoadTrailRun button template:
```html
<a href="https://www.roadtrailrun.com"
class="button primary button-wrapper"><span>Read All RoadTrailRun
Reviews Here</span></a>
```

## SEO Best Practices

### Description Field

- **Length:** 150-160 characters (Google's display limit)
- **Content:** Include product name, key feature, and value proposition
- **Examples:**
  - ✅ "Comprehensive review of the Mizuno Wave Rider 29 with testing insights and performance analysis on road and trail."
  - ✅ "The BioLite Range 500 headlamp tested across 100+ miles. Battery life, beam quality, and comfort evaluation."
  - ❌ "" (empty - bad for SEO)
  - ❌ "A review of shoes" (too vague)

### Title Optimization

- Include product name and "Review" keyword
- Keep under 60 characters for search display
- Natural language, not keyword stuffing

## Quality Checklist

Before publishing, verify:

- [ ] Front matter is complete (no empty description)
- [ ] Tags are accurate and consistent
- [ ] Images are properly linked and loading
- [ ] All headings have text (no empty `###`)
- [ ] Lists use dashes, not asterisks
- [ ] RoadTrailRun attribution present (if applicable)
- [ ] Spelling and grammar checked
- [ ] Links are functional
- [ ] Product specifications accurate
- [ ] Testing methodology disclosed

## Creating a New Review

### Using the Template

```bash
hugo new reviews/product-name-review/index.md --kind review
```

This creates a new review directory with the template pre-filled.

### Manual Creation

1. Create directory: `content/reviews/product-name-review/`
2. Copy template from `/archetypes/review.md`
3. Add images to the directory
4. Fill in front matter
5. Write content following structure above
6. Set `draft: false` when ready

## Tools & Scripts

### Standardize Formatting

```bash
python3 scripts/standardize_reviews.py
```

Automatically:
- Removes empty headings
- Converts list formatting to dashes
- Fixes spacing inconsistencies

### Add SEO Descriptions

```bash
python3 scripts/add_seo_descriptions.py
```

Automatically generates descriptions from first paragraph if missing.

## Common Mistakes to Avoid

1. **Empty descriptions** - Always fill in SEO description
2. **Wrong tags** - Double-check category accuracy (e.g., sunscreen ≠ shoes)
3. **Inconsistent formatting** - Use template and formatting tools
4. **Missing attribution** - Credit RoadTrailRun when applicable
5. **Unclear directory names** - Use descriptive, SEO-friendly names
6. **Duplicate content** - Check for existing reviews before creating
7. **Broken images** - Verify all image files exist
8. **Draft status** - Remember to set `draft: false` to publish

## Multi-Author Reviews

For reviews with multiple contributors:

```markdown
*Article by John Tribbia, Sam Winebaum, and Jana Herzgova*
```

Use bold author names for individual sections:

```markdown
**John:** The upper felt comfortable from the first mile...

**Sam:** I found the fit to be more narrow than expected...
```

## Series Reviews

For multi-part content (e.g., "How To Adopt The Cargo Bike Lifestyle"):

- Name directories clearly: `-part-1`, `-part-2`, etc.
- Link between parts in introduction
- Use consistent front matter across series
- Maintain publication date order

## Questions?

Refer to existing high-quality reviews as examples:
- `brooks-catamount-2-multi-tester-review`
- `mizuno-wave-rider-29-review`
- `la-sportiva-prodigio-review`

For technical issues, check `/scripts/` for automation tools.
