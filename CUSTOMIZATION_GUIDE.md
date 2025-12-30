# Boulder Gear Lab Website - Customization & Maintenance Guide

## Quick Reference

### Key File Locations
| Purpose | File Path |
|---------|-----------|
| Site Configuration | `hugo.toml` |
| About Page Text | `content/about.md` |
| Data Projects Intro | `content/data-projects/_index.md` |
| Homepage Layout | `layouts/index.html` |
| Hero Section HTML | `layouts/partials/bgl-hero.html` |
| Custom CSS | `static/css/bgl-custom.css` |
| Theme CSS | `static/css/custom.css` |

---

## Common Customizations

### 1. Change Hero Section Image

**File:** `layouts/partials/bgl-hero.html` (Line 3)

**Current:**
```html
<img src="/img/carousel/image_1.jpg" alt="Testing gear in action">
```

**Change to:**
```html
<img src="/img/your-image.jpg" alt="Your description">
```

**Good Options:**
- Use a personal photo of you testing gear
- Action shot from a review (running shoes, bike, etc.)
- High-quality outdoor/product photography

---

### 2. Update Hero Headline & Subtitle

**File:** `layouts/partials/bgl-hero.html` (Lines 7-9)

**Current:**
```html
<h1>Honest Gear Reviews</h1>
<p class="bgl-hero-subtitle">Tested on hundreds of miles across Colorado.<br>
   Backed by industry experience and analytical thinking.</p>
```

**Examples:**
```html
<!-- Alternative 1: More focused -->
<h1>Real Gear. Real Testing.</h1>
<p>Honest reviews from someone who actually uses the gear.</p>

<!-- Alternative 2: Action-oriented -->
<h1>Gear Worth Testing</h1>
<p>Reviews that go beyond specs to real-world performance.</p>
```

---

### 3. Customize Color Scheme

**File:** `static/css/bgl-custom.css` (Lines 10-16)

**Current Colors:**
```css
:root {
    --bgl-primary: #2c3e50;      /* Dark blue-gray - headings, main text */
    --bgl-accent: #3498db;       /* Bright blue - links, buttons, accents */
    --bgl-light: #ecf0f1;        /* Off-white - backgrounds, borders */
    --bgl-text: #34495e;         /* Dark gray - body text */
    --bgl-border: #bdc3c7;       /* Light gray - dividers */
}
```

**Popular Alternatives:**

*Professional Green:*
```css
--bgl-primary: #1b4332;
--bgl-accent: #40916c;
--bgl-light: #f0f7f4;
--bgl-text: #2d3e32;
--bgl-border: #d4dcd7;
```

*Warm Outdoor:*
```css
--bgl-primary: #5d4e37;
--bgl-accent: #d4a574;
--bgl-light: #f5ede0;
--bgl-text: #4a3f2e;
--bgl-border: #cdc0a8;
```

*Bold Modern:*
```css
--bgl-primary: #1a1a1a;
--bgl-accent: #ff6b35;
--bgl-light: #f7f3e9;
--bgl-text: #2d2d2d;
--bgl-border: #e0e0e0;
```

---

### 4. Adjust Typography Sizes

**File:** `static/css/bgl-custom.css` (Lines 30-52)

**Make Headlines Larger:**
```css
h1 { font-size: 3rem; }     /* Default 2.5rem */
h2 { font-size: 2.25rem; }  /* Default 2rem */
h3 { font-size: 1.75rem; }  /* Default 1.5rem */
```

**Make Body Text Larger:**
```css
body {
    font-size: 17px;  /* Default 16px */
    line-height: 1.8; /* Default 1.7 */
}
```

**Make Code More Prominent:**
```css
code {
    font-size: 0.95em; /* Default 0.9em */
}
```

---

### 5. Adjust Spacing & Whitespace

**File:** `static/css/bgl-custom.css`

**Increase Spacing Between Posts:**
```css
.box.post {
    padding: 3rem;        /* Default 2.5rem */
    margin-bottom: 3rem;  /* Default 2rem */
}
```

**Increase Spacing Between Sections:**
```css
section {
    margin-bottom: 4rem;  /* Default 3rem */
}
```

**Make Content Narrower (Better Reading):**
```css
.col-md-8 {
    max-width: 700px;  /* Default 750px */
}
```

---

### 6. Update About Page

**File:** `content/about.md`

The About page uses Markdown. Key sections:

**Opening Section (Introduction):**
Lines 3-10 - Edit the headline and opening paragraphs

**From The Industry to The Mountains:**
Lines 14-20 - Edit your background and accomplishments

**The Boulder Gear Lab Philosophy:**
Lines 22-25 - Edit your core approach

**Connect Section:**
Lines 32-35 - Update contact info (email, LinkedIn, Strava)

**Signature Line:**
Line 39 - Update the final tagline

---

### 7. Update Meta Descriptions (SEO)

**File:** `hugo.toml` (Lines 21-23)

```toml
defaultDescription = "Honest gear reviews and outdoor data science from Boulder, Colorado"

defaultKeywords = ["gear reviews", "outdoor equipment", "running shoes", "bikes", "Boulder Colorado"]

about_us = "<p>Boulder Gear Lab combines analytical thinking with outdoor industry expertise...</p>"
```

These appear in:
- Google Search results (defaultDescription)
- Social media previews (both)
- Website footer and homepage (about_us)

---

### 8. Update Navigation Menu

**File:** `hugo.toml` (Lines 126-153)

**Current:**
```toml
[[menu.main]]
    name = "About"
    url = "/about/"
    weight = 1

[[menu.main]]
    name = "Gear Reviews"
    url = "/reviews/"
    weight = 2

[[menu.main]]
    name = "Data Projects"
    url = "/data-projects/"
    weight = 3

[[menu.main]]
    name = "RoadTrailRun"
    url = "/roadtrailrun/"
    weight = 4

[[menu.main]]
    name = "Contact"
    url = "/contact/"
    weight = 5
```

**To Add a New Menu Item:**
```toml
[[menu.main]]
    name = "New Page Title"
    url = "/new-page/"
    weight = 6  # Increment the weight
```

**To Remove an Item:**
Simply delete the entire `[[menu.main]]` block for that item.

**To Reorder:**
Change the `weight` values (lower numbers appear first).

---

## Advanced Customizations

### Custom Hero Styling

**File:** `static/css/bgl-custom.css` (Lines 99-186)

**Change Hero Height:**
```css
.bgl-hero {
    height: 600px;  /* Default 500px */
}

@media (max-width: 768px) {
    .bgl-hero {
        height: 400px;  /* Default 350px */
    }
}
```

**Adjust Overlay Darkness:**
```css
.bgl-hero-overlay {
    background: rgba(0, 0, 0, 0.5);  /* Default 0.4 - increase for darker */
}
```

**Change Button Style:**
```css
.bgl-hero-cta {
    background-color: var(--bgl-accent);  /* Change color */
    padding: 15px 40px;                   /* Change size */
    border-radius: 8px;                   /* Change corners */
}
```

---

### Custom Post Card Styling

**File:** `static/css/bgl-custom.css` (Lines 224-245)

**Make Cards Have Borders:**
```css
.box.post {
    border: 2px solid var(--bgl-accent);  /* Add colored border */
    border-radius: 8px;                    /* Rounded corners */
}
```

**Add Gradient Background:**
```css
.box.post {
    background: linear-gradient(135deg, #f5f5f5 0%, #ffffff 100%);
}
```

---

### Custom Sidebar Styling

**File:** `static/css/bgl-custom.css` (Lines 257-273)

**Add Background Color to Sidebar:**
```css
.sidebar {
    background-color: var(--bgl-light);
    padding: 2rem;
    border-radius: 4px;
}
```

---

## Troubleshooting

### Changes Not Showing

**If CSS changes don't appear:**
1. Hard refresh browser: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)
2. Restart Hugo server: Press `Ctrl+C`, then run `hugo server --buildDrafts` again
3. Check browser console for CSS errors: Press `F12` → Console tab

**If HTML changes don't appear:**
1. Hugo server should auto-rebuild, check terminal for "Built in XXXms"
2. Refresh browser page
3. If still not showing, restart Hugo server

### Styling Conflicts

If your custom CSS isn't applying:
1. Check the CSS file is in `static/css/bgl-custom.css`
2. Verify `layouts/partials/custom_headers.html` exists
3. Check specificity - if needed, add `!important`:
   ```css
   .my-element {
       color: blue !important;
   }
   ```

---

## Performance Tips

### Image Optimization
- Hero image should be optimized (compressed, correct size)
- Recommended size: 1400x700px or larger (for retina displays)
- File size should be under 300KB

### CSS Caching
The `?{{ now.Unix }}` parameter in custom_headers.html ensures browsers get the latest CSS. No action needed.

### Faster Loading
- Keep hero image size under 300KB
- Minimize custom CSS if it grows large
- Use image compression tools: TinyPNG, Squoosh, etc.

---

## Content Management

### Adding New Reviews
1. Create folder: `content/reviews/your-review-title/`
2. Create file: `content/reviews/your-review-title/index.md`
3. Use the archetype as template

### Adding Data Projects
1. Create folder: `content/data-projects/your-project-title/`
2. Create file: `content/data-projects/your-project-title/index.md`
3. Add project description in frontmatter

### Updating About Page
- Edit `content/about.md` directly
- Changes appear instantly (with browser refresh)
- HTML is supported in Markdown using raw HTML tags

---

## Version Control Tips

### Recommended Git Workflow
```bash
# Before making changes
git pull

# Make changes
# ... edit files ...

# Test locally
hugo server --buildDrafts

# Commit changes
git add .
git commit -m "Update: Brief description of changes"

# Push to repository
git push
```

---

## Backups

### Important Files to Backup
- `content/` - All your reviews and projects
- `content/about.md` - About page (easily lost)
- `static/img/` - Your images
- `hugo.toml` - Your configuration
- `layouts/` and `static/css/` - Your customizations

### Quick Backup
```bash
tar -czf bouldergearlab-backup-$(date +%Y%m%d).tar.gz \
  content/ hugo.toml layouts/ static/css/ static/img/
```

---

## Getting Help

### Common Hugo Resources
- [Hugo Documentation](https://gohugo.io/documentation/)
- [Hugo Universal Theme Docs](https://github.com/devcows/hugo-universal-theme)
- Hugo Community Forum

### For This Site
- Check file paths in the "Quick Reference" table above
- Review `IMPLEMENTATION_SUMMARY.md` for what was changed
- Test changes locally before pushing to production

---

## Summary

You now have full control over:
✅ Colors and typography
✅ Spacing and layout
✅ Hero section messaging
✅ Navigation structure
✅ Meta descriptions (SEO)
✅ All custom CSS

Start with small changes and test locally. The most impactful changes are usually:
1. Hero image (biggest visual impact)
2. Colors (brand recognition)
3. Typography sizes (readability)
4. Hero headline (first impression)
