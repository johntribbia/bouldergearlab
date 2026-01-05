# SEO Optimization Guide for Boulder Gear Lab

## Implemented Optimizations

### 1. **robots.txt** ✅
- Created `/static/robots.txt` to guide search engine crawlers
- Allows all robots by default
- Blocks malicious bots (MJ12bot, AhrefsBot, etc.)
- Specifies sitemap location

### 2. **Schema.org Structured Data** ✅
- Added JSON-LD markup for Product reviews (gear items)
- Added JSON-LD markup for Article/Blog posts
- Added Organization schema with location (Boulder, Colorado)
- Improves rich snippets in search results

### 3. **Canonical Tags** ✅
- Added to every page to prevent duplicate content issues
- Helps consolidate ranking power

### 4. **Advanced Meta Tags** ✅
- Twitter Card optimization with social image previews
- hreflang tags for language alternatives
- Theme color for browser address bar
- Preconnect/DNS prefetch for performance

### 5. **Image SEO** ✅
- Added alt text to banner images (previously empty)
- Schema markup includes image metadata
- Sitemap includes image references

### 6. **Enhanced Sitemap** ✅
- Created custom sitemap.xml with:
  - Priority levels (1.0 for homepage, 0.9 for sections, 0.8 for reviews)
  - Change frequency indicators
  - Image URLs and metadata
  - Last modified dates

---

## Recommended Additional Steps

### Content Improvements

1. **Optimize Descriptions**
   - Many reviews lack meta descriptions in frontmatter
   - Add `description` field to each review's YAML frontmatter
   - Keep descriptions 150-160 characters for optimal display
   - Example:
     ```yaml
     description: "Detailed review of the BioLite Range 500 headlamp. 500 lumens, ultra-lightweight at 2.6 oz, perfect for trail running."
     ```

2. **Internal Linking**
   - Link related reviews together
   - Create topic clusters (running gear, bikes, accessories)
   - Use descriptive anchor text (not "read more" or "click here")

3. **Content Depth**
   - Aim for 2,000+ words on competitive keywords
   - Current reviews are ~1,000 words (good start)
   - Add comparison tables and specs

### Technical Improvements

1. **Page Speed Optimization**
   - Compress images (use WebP format)
   - Minify CSS/JS
   - Enable lazy loading for images
   - Consider adding to hugo.toml:
     ```toml
     [minify]
       minifyOutput = true
     ```

2. **Enable Google Analytics**
   - Uncomment googleAnalytics in hugo.toml with your GA4 ID
   - Track user behavior and search queries

3. **Core Web Vitals**
   - Use Google PageSpeed Insights to check metrics
   - Target: LCP < 2.5s, FID < 100ms, CLS < 0.1

4. **Add Author Pages**
   - Create /about section with author expertise
   - Link reviews to author
   - Add author bio to each review frontmatter

### Content Strategy

1. **Keyword Research**
   - Target long-tail keywords ("best trail running headlamp under $100")
   - Use tools: Google Search Console, Ahrefs, SEMrush
   - Add target keywords to title, description, headings (H1, H2)

2. **FAQ Schema** (for future expansion)
   - Add FAQ sections to reviews
   - Implement FAQ schema markup
   - Improves featured snippets

3. **Regular Updates**
   - Update lastmod date when making content changes
   - Link to newer reviews when creating similar content
   - Consolidate thin pages into comprehensive guides

### Monitoring & Maintenance

1. **Google Search Console**
   - Submit sitemap.xml
   - Monitor indexing status
   - Check search queries and CTR
   - Fix crawl errors promptly

2. **Backlink Strategy**
   - Note existing RoadTrailRun attribution (good for brand mentions)
   - Reach out to similar gear review sites
   - Guest post opportunities
   - Broken link building

3. **Local SEO**
   - You're based in Boulder, CO
   - Add local schema (already in place)
   - Consider "Boulder gear reviews" as local angle

---

## Frontend Content Checklist for Each Review

Use this when creating/updating reviews:

- [ ] Descriptive title (include product name and benefit)
- [ ] Meta description (unique per page, 150-160 chars)
- [ ] Banner image with descriptive filename
- [ ] H1 tag (matches title)
- [ ] Subheadings (H2, H3) using target keywords
- [ ] First 100 words contain primary keyword
- [ ] 2-3 internal links to related reviews
- [ ] Images with descriptive alt text (in markdown: `![alt text](image.jpg)`)
- [ ] Review structured with: Overview → Design → Performance → Pros/Cons → Conclusion
- [ ] Publish date and author clearly indicated

---

## Files Modified

✅ `/static/robots.txt` - New
✅ `/layouts/partials/schema-review.html` - New  
✅ `/layouts/partials/seo-meta.html` - New
✅ `/layouts/partials/headers.html` - Updated with new partials
✅ `/layouts/_default/single.html` - Added alt text to images
✅ `/layouts/sitemap.xml` - Enhanced with priorities and images

---

## Quick Wins (High Impact, Low Effort)

1. **Fill in empty meta descriptions**
   - Review 10 top pages and add descriptions to frontmatter
   - Expected impact: +10-15% CTR improvement

2. **Add image alt text to content**
   - Go through reviews and add descriptive alt text to inline images
   - Expected impact: +5% image search traffic

3. **Set up Google Search Console**
   - Takes 15 minutes
   - Provides invaluable data about how Google sees your site

4. **Enable lazy loading**
   - Add `loading="lazy"` to img tags in templates
   - Improves Core Web Vitals score

---

## Questions or Issues?

Review the Hugo SEO best practices:
- https://gohugo.io/content-management/multilingual/
- https://gohugo.io/templates/sitemap-template/
- https://schema.org/Article
- https://schema.org/Product
