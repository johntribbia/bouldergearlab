# Theme Styling Implementation Guide

## Overview
This document describes how the advanced UX/UI features from resume.html have been applied across the entire bouldergearlab site.

## Changes Made

### 1. CSS Extraction
**File:** `/static/css/theme-styles.css`
- Extracted 850+ lines of CSS from resume.html
- Includes:
  - Color system with CSS variables (--trail-red, --alpine-blue, etc.)
  - Reading progress bar styling
  - Hero section and mountain canvas styles
  - Card components (expedition, peak, award, publication)
  - Responsive design for mobile
  - Accessibility features (focus states, ARIA support)
  - Animation delays and transitions

### 2. JavaScript Extraction
**File:** `/static/js/theme-animations.js`
- Extracted animation system from resume.html
- Features:
  - Mountain landscape canvas animation
  - Floating particle system with skill words
  - Reading progress bar tracking
  - Smooth scroll behavior
  - Stats counter animation
  - Intersection Observer for fade-in animations
  - Parallax scrolling effects

### 3. Template Updates

#### Headers Partial
**File:** `/layouts/partials/headers.html`
- Added Google Fonts (Archivo & Plus Jakarta Sans)
- Linked theme-styles.css before custom.css
- Maintained existing theme structure

#### Scripts Partial
**File:** `/layouts/partials/scripts.html`
- Added theme-animations.js after existing scripts
- Ensures animations load on all pages

#### Top Partial
**File:** `/layouts/partials/top.html`
- Added reading progress bar at top of page
- Includes ARIA labels for accessibility
- Visible on all pages

### 4. Custom Stylesheet
**File:** `/static/css/custom.css`
- Bridges theme styles with existing hugo-universal-theme
- Applies color variables to existing components
- Adds hover effects and transitions to cards
- Improves focus states for accessibility
- Smooth animations for content loading

## CSS Variables Reference

```css
:root {
    --mountain-dark: #1a1a2e;    /* Dark backgrounds */
    --trail-red: #46a606;         /* Primary accent (green) */
    --summit-white: #F5F5F7;      /* Light backgrounds */
    --rock-gray: #86868B;         /* Secondary text */
    --alpine-blue: #2c5f8d;       /* Secondary accent */
    --forest-green: #2d5016;      /* Tertiary accent */
    --font-display: 'Archivo', sans-serif;      /* Headings */
    --font-body: 'Plus Jakarta Sans', sans-serif; /* Body text */
}
```

## Key Features Implemented

### 1. Reading Progress Bar
- Fixed at top of page (z-index: 9999)
- Gradient from trail-red to alpine-blue
- Updates dynamically as user scrolls
- Works on all page types

### 2. Custom Cursor
- SVG-based custom cursor on desktop
- Green circle with stroke
- Changes to pointer on interactive elements
- Disabled on mobile for better UX

### 3. Fade-in Animations
- IntersectionObserver-based
- Elements with `.fade-in-up` class animate on scroll
- Threshold: 0.1 with -100px bottom margin
- Smooth 0.6s ease transition

### 4. Card Components
- Expedition cards (timeline with waypoint markers)
- Peak cards (3-column grid)
- Award badges (flexible grid)
- Publication cards (vertical list)
- All cards have hover effects and transitions

### 5. Accessibility
- ARIA labels on navigation elements
- Focus states with 3px outlines
- rel="noopener noreferrer" on external links
- Semantic HTML structure
- Keyboard navigation support

## How to Use

### Adding Fade-in Animation
Add the `fade-in-up` class to any element:
```html
<div class="fade-in-up">
    This content will fade in when scrolled into view
</div>
```

### Using Color Variables
Reference variables in your CSS:
```css
.my-element {
    color: var(--trail-red);
    background: var(--summit-white);
    border-color: var(--alpine-blue);
}
```

### Creating a Hero Section
Use the existing classes from theme-styles.css:
```html
<section class="hero-section">
    <canvas id="mountainCanvas"></canvas>
    <div class="hero-content">
        <h1 class="hero-title">Your Title</h1>
        <p class="hero-subtitle">Your subtitle</p>
    </div>
</section>
```

### Stats Counter
Add data-target attribute to trigger counter animation:
```html
<div class="stats-row">
    <div class="stat-item">
        <span class="stat-number" data-target="100">0</span>
        <span class="stat-label">Label</span>
    </div>
</div>
```

## Page-Specific Implementations

### Homepage (index.html)
- Already includes all partials
- Reading progress bar active
- Custom fonts loaded
- Animations enabled

### Review Pages (single.html)
- Reading progress bar tracks article progress
- Fade-in animations for content sections
- Custom cursor throughout
- Smooth scroll to anchors

### Resume Page (resume.html)
- Full hero section with mountain canvas
- All animation features
- Complete design system showcase
- Standalone page (doesn't use theme structure)

## Testing Checklist

- [ ] Reading progress bar appears and tracks scroll
- [ ] Custom cursor visible on desktop
- [ ] Fade-in animations trigger on scroll
- [ ] Cards have hover effects
- [ ] Focus states visible on keyboard navigation
- [ ] All fonts load correctly (Archivo, Plus Jakarta Sans)
- [ ] Color variables apply throughout
- [ ] Mobile view disables custom cursor
- [ ] Smooth scroll works on anchor links
- [ ] No console errors in browser

## Browser Compatibility

- **Chrome/Edge:** Full support
- **Firefox:** Full support
- **Safari:** Full support (backdrop-filter may need -webkit prefix)
- **Mobile browsers:** Custom cursor disabled, all other features work

## Performance Considerations

- CSS file: ~850 lines (minify for production)
- JavaScript file: ~200 lines (minimal impact)
- Canvas animation: 60fps on modern devices
- IntersectionObserver: Efficient, no scroll listeners
- Fonts: Loaded from Google Fonts CDN

## Customization

### Changing Colors
Edit CSS variables in `/static/css/theme-styles.css`:
```css
:root {
    --trail-red: #YOUR_COLOR;  /* Change primary color */
}
```

### Disabling Features
Comment out script includes in `/layouts/partials/scripts.html`:
```html
<!-- Theme animations - extracted from resume.html -->
<!-- <script src="{{ "js/theme-animations.js" | relURL }}"></script> -->
```

### Adjusting Animation Speed
Edit transition durations in theme-styles.css:
```css
.fade-in-up {
    transition: opacity 0.6s ease, transform 0.6s ease;  /* Adjust timing */
}
```

## Troubleshooting

### Reading progress bar not showing
- Check that `reading-progress` div is in top.html
- Verify theme-animations.js is loaded
- Check z-index isn't being overridden

### Animations not triggering
- Verify IntersectionObserver support in browser
- Check that elements have `fade-in-up` class
- Ensure theme-animations.js loaded after DOM

### Custom cursor not working
- Check SVG data URI encoding
- Verify cursor property in theme-styles.css
- Note: Won't work on mobile (by design)

### Fonts not loading
- Verify Google Fonts link in headers.html
- Check network tab for 404 errors
- Ensure font-family fallbacks exist

## Maintenance

### When updating Hugo
- Test that partials still load correctly
- Verify IntersectionObserver still works
- Check for deprecated features

### When adding new pages
- Include standard layout with partials
- Add `fade-in-up` class where appropriate
- Test reading progress bar

### When modifying styles
- Keep custom changes in custom.css
- Don't edit theme-styles.css directly
- Use CSS variables for consistency

## Future Enhancements

Potential additions:
- Dark mode toggle
- More canvas animation options
- Additional card component styles
- Prefers-reduced-motion support
- Service worker for offline support
- Image lazy loading integration

## Support

For questions or issues:
1. Check browser console for errors
2. Verify all files loaded correctly
3. Review this documentation
4. Check Hugo build logs
5. Test in incognito mode (no extensions)

## Version History

- **v1.0** (Current): Initial implementation
  - Extracted CSS and JS from resume.html
  - Created global theme files
  - Updated all partials
  - Added comprehensive styling

---

**Last Updated:** 2025
**Maintained By:** John Tribbia
**Site:** bouldergearlab.com
