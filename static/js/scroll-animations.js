/**
 * Boulder Gear Lab - Scroll Reveal & Score Animations
 * Modern Intersection Observer-based animations
 */

(function() {
    'use strict';

    // Configuration
    const config = {
        threshold: 0.15,      // Trigger when 15% visible
        rootMargin: '0px 0px -50px 0px',
        animateOnce: true     // Only animate once
    };

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    function init() {
        // Check for reduced motion preference
        if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
            revealAllElements();
            return;
        }

        setupScrollReveal();
        setupScoreAnimations();
        setupStatsCounter();
        autoTagScrollElements();
    }

    /**
     * Auto-tag common elements for scroll reveal
     */
    function autoTagScrollElements() {
        // Tag review cards
        document.querySelectorAll('.review-card, .peak-card').forEach(el => {
            if (!el.classList.contains('scroll-reveal')) {
                el.classList.add('scroll-reveal');
            }
        });

        // Tag section headers
        document.querySelectorAll('.section-header, .section-title').forEach(el => {
            if (!el.classList.contains('scroll-reveal')) {
                el.classList.add('scroll-reveal');
            }
        });

        // Tag stats
        document.querySelectorAll('.bgl-stat-number').forEach(el => {
            if (!el.classList.contains('scroll-reveal')) {
                el.classList.add('scroll-reveal');
            }
        });

        // Tag feature boxes
        document.querySelectorAll('.feature-box, .box').forEach(el => {
            if (!el.classList.contains('scroll-reveal')) {
                el.classList.add('scroll-reveal');
            }
        });

        // Re-run setup for newly tagged elements
        setupScrollReveal();
    }

    /**
     * Setup Intersection Observer for scroll reveals
     */
    function setupScrollReveal() {
        const revealElements = document.querySelectorAll('.scroll-reveal:not(.revealed)');
        
        if (!revealElements.length) return;

        const observer = new IntersectionObserver((entries, obs) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                    
                    if (config.animateOnce) {
                        obs.unobserve(entry.target);
                    }
                }
            });
        }, {
            threshold: config.threshold,
            rootMargin: config.rootMargin
        });

        revealElements.forEach(el => observer.observe(el));
    }

    /**
     * Setup score circle and bar animations
     */
    function setupScoreAnimations() {
        // Score circles
        const scoreCircles = document.querySelectorAll('.review-score-circle');
        
        if (scoreCircles.length) {
            const circleObserver = new IntersectionObserver((entries, obs) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('animated');
                        animateScoreNumber(entry.target);
                        obs.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.5 });

            scoreCircles.forEach(el => circleObserver.observe(el));
        }

        // Score bars
        const scoreBars = document.querySelectorAll('.score-bar-fill');
        
        if (scoreBars.length) {
            const barObserver = new IntersectionObserver((entries, obs) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('animated');
                        obs.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.3 });

            scoreBars.forEach(el => barObserver.observe(el));
        }

        // Pros/Cons lists
        const prosConsList = document.querySelectorAll('.pros-list, .cons-list');
        
        if (prosConsList.length) {
            const listObserver = new IntersectionObserver((entries, obs) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('revealed');
                        obs.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.2 });

            prosConsList.forEach(el => listObserver.observe(el));
        }
    }

    /**
     * Animate score number counting up
     */
    function animateScoreNumber(circleEl) {
        const scoreEl = circleEl.querySelector('.score-number');
        if (!scoreEl) return;

        const targetScore = parseInt(circleEl.style.getPropertyValue('--score')) || 0;
        const duration = 1500; // ms
        const startTime = performance.now();

        function updateNumber(currentTime) {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            
            // Ease out cubic
            const easedProgress = 1 - Math.pow(1 - progress, 3);
            const currentValue = Math.round(easedProgress * targetScore);
            
            scoreEl.textContent = currentValue;

            if (progress < 1) {
                requestAnimationFrame(updateNumber);
            }
        }

        requestAnimationFrame(updateNumber);
    }

    /**
     * Setup animated stats counter
     */
    function setupStatsCounter() {
        const stats = document.querySelectorAll('.bgl-stat-number');
        
        if (!stats.length) return;

        const statsObserver = new IntersectionObserver((entries, obs) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                    animateStatNumber(entry.target);
                    obs.unobserve(entry.target);
                }
            });
        }, { threshold: 0.5 });

        stats.forEach(el => statsObserver.observe(el));
    }

    /**
     * Animate stat numbers counting up
     */
    function animateStatNumber(el) {
        const text = el.textContent.trim();
        const match = text.match(/^([\d,]+)(\+?)(.*)$/);
        
        if (!match) return;
        
        const targetNum = parseInt(match[1].replace(/,/g, ''));
        const suffix = (match[2] || '') + (match[3] || '');
        const duration = 2000;
        const startTime = performance.now();

        function updateStat(currentTime) {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            
            // Ease out expo
            const easedProgress = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress);
            const currentValue = Math.round(easedProgress * targetNum);
            
            el.textContent = currentValue.toLocaleString() + suffix;

            if (progress < 1) {
                requestAnimationFrame(updateStat);
            }
        }

        requestAnimationFrame(updateStat);
    }

    /**
     * Fallback: reveal all elements immediately
     */
    function revealAllElements() {
        document.querySelectorAll('.scroll-reveal').forEach(el => {
            el.classList.add('revealed');
        });
        document.querySelectorAll('.review-score-circle').forEach(el => {
            el.classList.add('animated');
        });
        document.querySelectorAll('.score-bar-fill').forEach(el => {
            el.classList.add('animated');
        });
        document.querySelectorAll('.pros-list, .cons-list').forEach(el => {
            el.classList.add('revealed');
        });
    }

})();
