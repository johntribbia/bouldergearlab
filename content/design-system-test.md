---
title: "Design System Test Page"
date: 2025-02-01
draft: true
---

<style>
/* Additional test page styles */
.component-demo {
    margin: 40px 0;
    padding: 30px;
    background: white;
    border-radius: 16px;
    border: 2px solid #eee;
}

.component-label {
    font-size: 14px;
    color: var(--rock-gray);
    text-transform: uppercase;
    letter-spacing: 2px;
    margin-bottom: 20px;
    font-weight: 700;
}
</style>

<section class="section">
    <div class="container">
        <h2>Design System Components</h2>
        <p class="section-subtitle">Testing all available UI components from resume.html</p>

        <!-- Stats Demo -->
        <div class="component-demo">
            <div class="component-label">Stats Counter</div>
            <div class="stats-row">
                <div class="stat-item">
                    <span class="stat-number" data-target="45">0</span>
                    <span class="stat-label">Total Reviews</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number" data-target="100">0</span>
                    <span class="stat-label">Tested Products</span>
                </div>
            </div>
        </div>

        <!-- Peak Cards Demo -->
        <div class="component-demo">
            <div class="component-label">Peak Cards (3-Column Grid)</div>
            <div class="peaks-grid">
                <div class="peak-card fade-in-up">
                    <div class="peak-title">Trail Running</div>
                    <div class="peak-desc">Comprehensive reviews of trail running shoes, gear, and accessories tested in the Colorado Rockies.</div>
                </div>
                <div class="peak-card fade-in-up">
                    <div class="peak-title">Road Running</div>
                    <div class="peak-desc">In-depth analysis of road running shoes for different paces, distances, and running styles.</div>
                </div>
                <div class="peak-card fade-in-up">
                    <div class="peak-title">Gear Testing</div>
                    <div class="peak-desc">Honest reviews of outdoor gear including hydration systems, apparel, and nutrition products.</div>
                </div>
            </div>
        </div>

        <!-- Skills Demo -->
        <div class="component-demo">
            <div class="component-label">Skills Categories</div>
            <div class="skills-container">
                <div class="skill-category fade-in-up">
                    <h3>Testing Focus</h3>
                    <div class="skill-tags">
                        <span class="skill-tag" data-tooltip="100+ pairs tested">Running Shoes</span>
                        <span class="skill-tag" data-tooltip="Trail & Road">Performance Testing</span>
                        <span class="skill-tag">Durability Analysis</span>
                        <span class="skill-tag">Fit Assessment</span>
                    </div>
                </div>
                <div class="skill-category fade-in-up">
                    <h3>Terrain Experience</h3>
                    <div class="skill-tags">
                        <span class="skill-tag">Mountain Trails</span>
                        <span class="skill-tag">Technical Terrain</span>
                        <span class="skill-tag">Road Running</span>
                        <span class="skill-tag">Ultra Distance</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Award Badges Demo -->
        <div class="component-demo">
            <div class="component-label">Award Badges</div>
            <div class="awards-grid">
                <div class="award-badge fade-in-up">
                    <div class="award-title">Best Trail Shoe 2024</div>
                    <div class="award-desc">Awarded to the top-performing trail running shoe tested this year</div>
                </div>
                <div class="award-badge fade-in-up">
                    <div class="award-title">Most Versatile</div>
                    <div class="award-desc">For shoes that excel across multiple terrain types and conditions</div>
                </div>
                <div class="award-badge fade-in-up">
                    <div class="award-title">Best Value</div>
                    <div class="award-desc">Outstanding performance at an accessible price point</div>
                </div>
            </div>
        </div>

        <!-- Publication Cards Demo -->
        <div class="component-demo">
            <div class="component-label">Publication Cards</div>
            <div class="publications-grid">
                <div class="publication-card fade-in-up">
                    <div class="pub-title">Comprehensive Review: Hoka Speedgoat 5 GTX</div>
                    <div class="pub-meta">Boulder Gear Lab • 2024 • John Tribbia</div>
                    <span class="pub-citations">Featured Review</span>
                </div>
                <div class="publication-card fade-in-up">
                    <div class="pub-title">Long-term Test: Brooks Catamount 2</div>
                    <div class="pub-meta">Road Trail Run • 2024 • Multi-tester Review</div>
                    <span class="pub-citations">500+ miles tested</span>
                </div>
            </div>
        </div>

        <!-- CTA Buttons Demo -->
        <div class="component-demo">
            <div class="component-label">Call-to-Action Buttons</div>
            <div style="text-align: center;">
                <a href="#" class="cta-button">Primary Button</a>
                <a href="#" class="cta-button secondary">Secondary Button</a>
            </div>
        </div>

        <!-- Expedition Cards Demo -->
        <div class="component-demo">
            <div class="component-label">Expedition Timeline Cards</div>
            <div class="expedition-section">
                <div class="expedition-card fade-in-up">
                    <div class="exp-header">
                        <div>
                            <div class="exp-route">LA SPORTIVA</div>
                            <div class="exp-summit">Sponsored Athlete</div>
                            <div class="exp-location">Trail Running Division</div>
                        </div>
                        <div class="exp-elevation">2015 – 2018</div>
                    </div>
                    <ul class="achievements-trail">
                        <li>Represented brand at <strong>major ultra marathons</strong> across North America</li>
                        <li>Provided <strong>product feedback</strong> for shoe development</li>
                    </ul>
                </div>
                <div class="expedition-card fade-in-up">
                    <div class="exp-header">
                        <div>
                            <div class="exp-route">PEARL IZUMI</div>
                            <div class="exp-summit">Team Member</div>
                            <div class="exp-location">Elite Mountain Running</div>
                        </div>
                        <div class="exp-elevation">2012 – 2015</div>
                    </div>
                    <ul class="achievements-trail">
                        <li>Competed in <strong>trail and mountain races</strong> internationally</li>
                        <li>Contributed to <strong>technical apparel testing</strong></li>
                    </ul>
                </div>
            </div>
        </div>

    </div>
</section>

<section class="section compact">
    <div class="container">
        <h2>Color Palette</h2>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-top: 30px;">
            <div style="background: var(--mountain-dark); color: white; padding: 40px; border-radius: 12px; text-align: center;">
                <div style="font-weight: 700; margin-bottom: 8px;">Mountain Dark</div>
                <div style="opacity: 0.8; font-size: 14px;">#1a1a2e</div>
            </div>
            <div style="background: var(--trail-red); color: white; padding: 40px; border-radius: 12px; text-align: center;">
                <div style="font-weight: 700; margin-bottom: 8px;">Trail Red (Green)</div>
                <div style="opacity: 0.8; font-size: 14px;">#46a606</div>
            </div>
            <div style="background: var(--alpine-blue); color: white; padding: 40px; border-radius: 12px; text-align: center;">
                <div style="font-weight: 700; margin-bottom: 8px;">Alpine Blue</div>
                <div style="opacity: 0.8; font-size: 14px;">#2c5f8d</div>
            </div>
        </div>
    </div>
</section>

<section class="section compact">
    <div class="container">
        <div class="open-to-opportunities fade-in-up">
            <h3>Featured Callout Component</h3>
            <p>This gradient background component is perfect for highlighting important messages, calls-to-action, or announcements. It uses the alpine-blue to trail-red gradient for maximum visual impact.</p>
        </div>
    </div>
</section>
