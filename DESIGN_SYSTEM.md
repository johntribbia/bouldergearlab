# Boulder Gear Lab Design System Components

## Quick Reference Guide

### Color Palette

```css
--mountain-dark: #1a1a2e    /* Dark backgrounds, footer */
--trail-red: #46a606         /* Primary accent (GREEN) */
--summit-white: #F5F5F7      /* Light backgrounds */
--rock-gray: #86868B         /* Secondary text */
--alpine-blue: #2c5f8d       /* Secondary accent */
--forest-green: #2d5016      /* Tertiary accent */
```

### Typography

**Display Font:** Archivo (headings, bold elements)
**Body Font:** Plus Jakarta Sans (paragraphs, content)
**Fallback:** Roboto

**Usage:**
```css
h1, h2, h3 { font-family: var(--font-display); }
body, p { font-family: var(--font-body); }
```

### Components Library

#### 1. Reading Progress Bar
```html
<div class="reading-progress"></div>
```
Automatically tracked by JavaScript. Already added to all pages.

#### 2. Hero Section
```html
<section class="hero-section">
    <canvas id="mountainCanvas"></canvas>
    <div class="hero-content">
        <span class="hero-tagline">TAGLINE</span>
        <h1 class="hero-title">Title</h1>
        <p class="hero-subtitle">Subtitle text</p>
        <a href="#" class="cta-button">Primary CTA</a>
        <a href="#" class="cta-button secondary">Secondary CTA</a>
    </div>
</section>
```

#### 3. Stats Row
```html
<div class="stats-row">
    <div class="stat-item">
        <span class="stat-number" data-target="100">0</span>
        <span class="stat-label">LABEL</span>
    </div>
    <div class="stat-item">
        <span class="stat-number" data-target="50">0</span>
        <span class="stat-label">ANOTHER LABEL</span>
    </div>
</div>
```
Numbers animate from 0 to target when scrolled into view.

#### 4. Content Section
```html
<section class="section">
    <div class="container">
        <h2>Section Title</h2>
        <p class="section-subtitle">Optional subtitle</p>
        <!-- Content here -->
    </div>
</section>
```
Use `class="section compact"` for less padding.

#### 5. Skills Grid
```html
<div class="skills-container">
    <div class="skill-category fade-in-up">
        <h3>Category Name</h3>
        <div class="skill-tags">
            <span class="skill-tag" data-tooltip="Expertise level">Skill</span>
            <span class="skill-tag">Skill 2</span>
        </div>
    </div>
</div>
```

#### 6. Peak Cards (3-column grid)
```html
<div class="peaks-grid">
    <div class="peak-card fade-in-up">
        <div class="peak-title">Title</div>
        <div class="peak-desc">Description text...</div>
    </div>
    <!-- Add 2 more for 3-column layout -->
</div>
```

#### 7. Expedition Cards (Timeline)
```html
<div class="expedition-section">
    <div class="expedition-card fade-in-up">
        <div class="exp-header">
            <div>
                <div class="exp-route">COMPANY NAME</div>
                <div class="exp-summit">Job Title</div>
                <div class="exp-location">Location</div>
            </div>
            <div class="exp-elevation">2020 – 2025</div>
        </div>
        <ul class="achievements-trail">
            <li><strong>Bold text</strong> regular text</li>
            <li>Another achievement</li>
        </ul>
    </div>
    <!-- Add more cards -->
</div>
```
Automatically creates timeline with waypoint markers.

#### 8. Award Badges
```html
<div class="awards-grid">
    <div class="award-badge fade-in-up">
        <div class="award-title">Award Name</div>
        <div class="award-desc">Description with optional <a href="#">link</a></div>
    </div>
</div>
```

#### 9. Publication Cards
```html
<div class="publications-grid">
    <div class="publication-card fade-in-up">
        <div class="pub-title">Publication Title</div>
        <div class="pub-meta">Journal • Year • Authors</div>
        <span class="pub-citations">100+ citations</span>
    </div>
</div>
```

#### 10. CTA Buttons
```html
<a href="#" class="cta-button">Primary Button</a>
<a href="#" class="cta-button secondary">Secondary Button</a>
```

#### 11. Contact Buttons
```html
<a href="mailto:email@example.com" class="contact-button">Email</a>
```

#### 12. Team Size Badge
```html
<span class="team-size">👥 Team Size: 5-8</span>
```

### Animation Classes

#### Fade In on Scroll
```html
<div class="fade-in-up">
    Content fades in when scrolled into view
</div>
```

#### Staggered Delays
Cards automatically have staggered animation delays based on nth-child:
- 1st: 0.05s
- 2nd: 0.1s
- 3rd: 0.15s
- etc.

### Utility Classes

#### Spacing
```css
.section          /* padding: 80px 0 0 */
.section.compact  /* padding: 40px 0 0 */
```

#### Container
```css
.container  /* max-width: 1100px, centered */
```

### Interactive Features

#### Custom Cursor
Automatically applied on desktop. Disable with:
```css
body { cursor: auto !important; }
```

#### Smooth Scroll
Works automatically for anchor links:
```html
<a href="#section-id">Jump to section</a>
```

#### Hover Effects
All cards have built-in hover effects:
- `translateY(-5px)` lift
- Box shadow
- Border color change

### Accessibility Features

#### ARIA Labels
```html
<canvas aria-hidden="true" role="img" aria-label="Decorative background"></canvas>
<div role="progressbar" aria-label="Reading progress"></div>
```

#### Focus States
All interactive elements have 3px outline on focus:
```css
:focus {
    outline: 3px solid var(--trail-red);
    outline-offset: 2px;
}
```

#### External Links
```html
<a href="#" target="_blank" rel="noopener noreferrer">Link</a>
```

### Responsive Breakpoints

```css
@media (max-width: 768px) {
    /* Mobile styles */
    .skills-container { grid-template-columns: 1fr; }
    .expedition-section { grid-template-columns: 1fr; }
    .stats-row { grid-template-columns: 1fr; }
}
```

### Best Practices

#### DO:
✅ Use CSS variables for colors
✅ Add `fade-in-up` class for animations
✅ Include ARIA labels
✅ Use semantic HTML
✅ Test on mobile

#### DON'T:
❌ Hardcode colors (#46a606 → use var(--trail-red))
❌ Skip accessibility attributes
❌ Nest cards too deeply
❌ Override animation timing without testing
❌ Use custom cursor on mobile

### Example Page Structure

```html
<!DOCTYPE html>
<html>
<head>
    {{ partial "headers.html" . }}
</head>
<body>
    {{ partial "top.html" . }}
    {{ partial "nav.html" . }}
    
    <section class="section">
        <div class="container">
            <h2>Page Title</h2>
            <p class="section-subtitle">Subtitle</p>
            
            <div class="peaks-grid">
                <div class="peak-card fade-in-up">
                    <div class="peak-title">Card 1</div>
                    <div class="peak-desc">Description</div>
                </div>
            </div>
        </div>
    </section>
    
    {{ partial "footer.html" . }}
    {{ partial "scripts.html" . }}
</body>
</html>
```

### Quick Start Checklist

- [ ] Include headers.html partial (fonts + CSS)
- [ ] Include top.html partial (reading progress)
- [ ] Include scripts.html partial (animations)
- [ ] Wrap content in `.container`
- [ ] Add `fade-in-up` to animated elements
- [ ] Use semantic HTML (section, article, nav)
- [ ] Test on mobile and desktop
- [ ] Verify accessibility (keyboard nav, screen reader)

### Component Playground

To test components, create a new page:
```bash
hugo new test-components.md
```

Then add component HTML in the markdown file's content.

---

**Need Help?** See [THEME_IMPLEMENTATION.md](THEME_IMPLEMENTATION.md) for detailed documentation.
