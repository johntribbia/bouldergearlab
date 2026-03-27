/**
 * Boulder Gear Lab – Unified Interactions
 * ─────────────────────────────────────────
 * Merged from: scroll-animations.js, premium-interactions.js, theme-animations.js
 * Vanilla JS · IIFE · Respects prefers-reduced-motion · No console.log
 */
(function () {
    'use strict';

    /* ══════════════════════════════════════════════════
       CONFIGURATION
       ══════════════════════════════════════════════════ */
    var CFG = {
        revealThreshold:    0.12,
        revealMargin:       '0px 0px -60px 0px',
        staggerMs:          120,
        navScrollThreshold: 100,
        wordsPerMinute:     200
    };

    var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    /* ══════════════════════════════════════════════════
       BOOTSTRAP
       ══════════════════════════════════════════════════ */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    function init() {
        if (reducedMotion) {
            showAllImmediately();
        } else {
            initAutoTag();
            initScrollReveal();
            initStaggerDelays();
            initScoreCircles();
            initScoreBars();
            initProsCons();
            initStatCounters();
            initParallaxHero();
            initMountainCanvas();
        }

        /* These features are functional, not decorative — always run */
        initNavbarScroll();
        initReadingProgress();
        initSmoothScroll();
        initLightbox();
        initTableOfContents();
        initShareButtons();
        initCopyLink();
        initLazyLoadFallback();
        initKeyboardNav();
        initPrintOptimization();
        initReadTime();
    }

    /* ══════════════════════════════════════════════════
       REDUCED-MOTION FALLBACK
       Show everything instantly, no animation.
       ══════════════════════════════════════════════════ */
    function showAllImmediately() {
        document.querySelectorAll('.reveal').forEach(function (el) { el.classList.add('vis'); });
        document.querySelectorAll('.scroll-reveal').forEach(function (el) { el.classList.add('revealed'); });
        document.querySelectorAll('.fade-in-up, .reveal-left, .reveal-right, .reveal-scale, .stagger-children')
            .forEach(function (el) { el.classList.add('visible'); });
        document.querySelectorAll('.review-score-circle, .score-bar-fill')
            .forEach(function (el) { el.classList.add('animated'); });
        document.querySelectorAll('.pros-list, .cons-list')
            .forEach(function (el) { el.classList.add('revealed'); });
        document.querySelectorAll('.score-circle').forEach(function (circle) {
            var score = parseFloat(circle.dataset.score) || 0;
            circle.style.setProperty('--score', (score / 10) * 100);
        });
    }

    /* ══════════════════════════════════════════════════
       1. AUTO-TAG COMMON ELEMENTS FOR REVEAL
       Adds .reveal to well-known component selectors
       so they participate in scroll-reveal without
       manual markup.
       ══════════════════════════════════════════════════ */
    function initAutoTag() {
        var selectors = [
            '.review-card', '.peak-card', '.section-header',
            '.section-title', '.bgl-stat-number', '.feature-box',
            '.box', '.box-simple'
        ];
        selectors.forEach(function (sel) {
            document.querySelectorAll(sel).forEach(function (el) {
                if (!el.classList.contains('reveal') && !el.classList.contains('scroll-reveal')) {
                    el.classList.add('reveal');
                }
            });
        });
    }

    /* ══════════════════════════════════════════════════
       2. SCROLL REVEAL (IntersectionObserver)
       Supports three class patterns:
         .reveal        → .vis
         .scroll-reveal → .revealed
         .fade-in-up / .reveal-left / .reveal-right /
         .reveal-scale / .stagger-children → .visible
       ══════════════════════════════════════════════════ */
    function initScrollReveal() {
        var targets = document.querySelectorAll(
            '.reveal:not(.vis), .scroll-reveal:not(.revealed), ' +
            '.fade-in-up:not(.visible), .reveal-left:not(.visible), ' +
            '.reveal-right:not(.visible), .reveal-scale:not(.visible), ' +
            '.stagger-children:not(.visible)'
        );
        if (!targets.length) return;

        var io = new IntersectionObserver(function (entries, obs) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                var el = entry.target;
                if (el.classList.contains('scroll-reveal')) {
                    el.classList.add('revealed');
                } else if (el.classList.contains('reveal')) {
                    el.classList.add('vis');
                } else {
                    el.classList.add('visible');
                }
                obs.unobserve(el);
            });
        }, { threshold: CFG.revealThreshold, rootMargin: CFG.revealMargin });

        targets.forEach(function (el) { io.observe(el); });
    }

    /* ══════════════════════════════════════════════════
       3. STAGGER DELAYS IN GRID PARENTS
       Children of grid containers get incremental
       transition-delay for a cascade effect.
       ══════════════════════════════════════════════════ */
    function initStaggerDelays() {
        ['.peaks-grid', '.premium-grid'].forEach(function (parentSel) {
            document.querySelectorAll(parentSel).forEach(function (grid) {
                var kids = grid.querySelectorAll('.reveal, .scroll-reveal');
                kids.forEach(function (el, i) {
                    el.style.transitionDelay = (i * CFG.staggerMs) + 'ms';
                });
            });
        });
    }

    /* ══════════════════════════════════════════════════
       4. NAVBAR SCROLL BEHAVIOR
       Adds .scrolled class when page is scrolled past
       threshold — drives CSS transitions on the navbar.
       ══════════════════════════════════════════════════ */
    function initNavbarScroll() {
        var navbar = document.getElementById('navbar');
        if (!navbar) return;

        window.addEventListener('scroll', function () {
            if (window.scrollY > CFG.navScrollThreshold) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        }, { passive: true });
    }

    /* ══════════════════════════════════════════════════
       5. READING PROGRESS BAR
       Width of .reading-progress tracks scroll depth.
       ══════════════════════════════════════════════════ */
    function initReadingProgress() {
        var bar = document.querySelector('.reading-progress');
        if (!bar) return;

        window.addEventListener('scroll', function () {
            var docHeight = document.documentElement.scrollHeight - window.innerHeight;
            if (docHeight <= 0) return;
            bar.style.width = Math.min((window.scrollY / docHeight) * 100, 100) + '%';
        }, { passive: true });
    }

    /* ══════════════════════════════════════════════════
       6. SMOOTH SCROLL FOR ANCHOR LINKS
       Falls back to instant scroll when reduced motion
       is preferred.
       ══════════════════════════════════════════════════ */
    function initSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
            anchor.addEventListener('click', function (e) {
                var href = this.getAttribute('href');
                if (href === '#') return;
                var target = document.querySelector(href);
                if (target) {
                    e.preventDefault();
                    target.scrollIntoView({
                        behavior: reducedMotion ? 'auto' : 'smooth',
                        block: 'start'
                    });
                }
            });
        });
    }

    /* ══════════════════════════════════════════════════
       7. SCORE CIRCLE ANIMATION
       Two variants:
         .review-score-circle — reads --score CSS var,
           animates .score-number text.
         .score-circle — reads data-score attribute,
           animates --score CSS var for conic-gradient.
       ══════════════════════════════════════════════════ */
    function initScoreCircles() {
        /* review template circles */
        observeOnce('.review-score-circle', 0.5, function (el) {
            el.classList.add('animated');
            var scoreNum = el.querySelector('.score-number');
            var score = parseInt(el.style.getPropertyValue('--score')) || 0;
            animateNumber(scoreNum, score, 1500);
        });

        /* generic data-score circles */
        observeOnce('.score-circle', 0.5, function (el) {
            var score = parseFloat(el.dataset.score) || 0;
            var pct = (score / 10) * 100;
            var current = 0;
            var increment = pct / 60;
            (function step() {
                current += increment;
                if (current >= pct) {
                    el.style.setProperty('--score', pct);
                } else {
                    el.style.setProperty('--score', current);
                    requestAnimationFrame(step);
                }
            })();
        });
    }

    /* ══════════════════════════════════════════════════
       8. SCORE BAR ANIMATION
       .score-bar-fill receives .animated on scroll-in.
       ══════════════════════════════════════════════════ */
    function initScoreBars() {
        observeOnce('.score-bar-fill', 0.3, function (el) {
            el.classList.add('animated');
        });
    }

    /* ══════════════════════════════════════════════════
       9. PROS / CONS REVEAL
       ══════════════════════════════════════════════════ */
    function initProsCons() {
        observeOnce('.pros-list, .cons-list', 0.2, function (el) {
            el.classList.add('revealed');
        });
    }

    /* ══════════════════════════════════════════════════
       10. STAT COUNTER ANIMATION
       Two selector strategies:
         .bgl-stat-number — parses text like "1,200+ miles"
         .stat-number[data-target] — reads data attribute
       Both use rAF with exponential ease-out.
       ══════════════════════════════════════════════════ */
    function initStatCounters() {
        /* text-parsing counters (review pages) */
        observeOnce('.bgl-stat-number:not([data-target])', 0.5, function (el) {
            el.classList.add('revealed');
            var text = el.textContent.trim();
            var m = text.match(/^([\d,]+)(\+?)(.*)$/);
            if (!m) return;
            var target = parseInt(m[1].replace(/,/g, ''));
            var suffix = (m[2] || '') + (m[3] || '');
            animateCount(el, target, suffix, 2000);
        });

        /* data-attribute counters (resume / about pages) */
        observeOnce('.stat-number[data-target]', 0.5, function (el) {
            var target = parseInt(el.dataset.target);
            if (isNaN(target)) return;
            var suffix = el.dataset.suffix || '';
            animateCount(el, target, suffix, 2000);
        });
    }

    /* ══════════════════════════════════════════════════
       11. IMAGE LIGHTBOX
       Creates an overlay for article images.
       Supports close on click / Esc, and
       left / right arrow keys for image navigation.
       ══════════════════════════════════════════════════ */
    function initLightbox() {
        var postContent = document.getElementById('post-content');
        if (!postContent) return;

        var images = Array.from(postContent.querySelectorAll('img'));
        if (!images.length) return;

        /* build overlay */
        var overlay = document.createElement('div');
        overlay.className = 'lightbox-overlay';
        overlay.innerHTML =
            '<button class="lightbox-close" aria-label="Close lightbox">&times;</button>' +
            '<img src="" alt="Enlarged image">';
        document.body.appendChild(overlay);

        var lightboxImg = overlay.querySelector('img');
        var closeBtn = overlay.querySelector('.lightbox-close');
        var currentIndex = -1;

        /* click handler on article images */
        images.forEach(function (img, idx) {
            img.style.cursor = 'zoom-in';
            img.addEventListener('click', function () { openLightbox(idx); });
        });

        function openLightbox(idx) {
            currentIndex = idx;
            lightboxImg.src = images[idx].src;
            lightboxImg.alt = images[idx].alt;
            overlay.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeLightbox() {
            overlay.classList.remove('active');
            document.body.style.overflow = '';
            currentIndex = -1;
        }

        function showNext() {
            if (currentIndex < 0) return;
            currentIndex = (currentIndex + 1) % images.length;
            lightboxImg.src = images[currentIndex].src;
            lightboxImg.alt = images[currentIndex].alt;
        }

        function showPrev() {
            if (currentIndex < 0) return;
            currentIndex = (currentIndex - 1 + images.length) % images.length;
            lightboxImg.src = images[currentIndex].src;
            lightboxImg.alt = images[currentIndex].alt;
        }

        closeBtn.addEventListener('click', closeLightbox);
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) closeLightbox();
        });

        document.addEventListener('keydown', function (e) {
            if (!overlay.classList.contains('active')) return;
            if (e.key === 'Escape')     closeLightbox();
            if (e.key === 'ArrowRight') showNext();
            if (e.key === 'ArrowLeft')  showPrev();
        });
    }

    /* ══════════════════════════════════════════════════
       12. TABLE OF CONTENTS + ACTIVE HIGHLIGHTING
       Generates a sidebar TOC from h2/h3 headings and
       highlights the current section on scroll.
       ══════════════════════════════════════════════════ */
    function initTableOfContents() {
        var postContent = document.getElementById('post-content');
        if (!postContent) return;
        if (document.querySelector('.toc-sidebar')) return;

        var headings = postContent.querySelectorAll('h2, h3');
        if (headings.length < 3) return;

        var tocContainer = document.querySelector('.toc-container');
        var targetEl = tocContainer || document.querySelector('.col-md-3');
        if (!targetEl) return;

        var toc = document.createElement('div');
        toc.className = 'toc-sidebar';
        toc.innerHTML = '<h4>Contents</h4><ul></ul>';
        var tocList = toc.querySelector('ul');

        headings.forEach(function (heading, i) {
            if (!heading.id) heading.id = 'section-' + i;

            var li = document.createElement('li');
            var a = document.createElement('a');
            a.href = '#' + heading.id;
            a.textContent = heading.textContent.replace(/^▲\s*/, '');
            if (heading.tagName === 'H3') {
                a.style.paddingLeft = '20px';
                a.style.fontSize = '13px';
            }
            li.appendChild(a);
            tocList.appendChild(li);
        });

        if (tocContainer) {
            tocContainer.appendChild(toc);
        } else {
            targetEl.insertBefore(toc, targetEl.firstChild);
        }

        /* highlight active section */
        var tocLinks = toc.querySelectorAll('a');
        var highlightIO = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                tocLinks.forEach(function (link) { link.classList.remove('active'); });
                var active = toc.querySelector('a[href="#' + entry.target.id + '"]');
                if (active) active.classList.add('active');
            });
        }, { threshold: 0, rootMargin: '-20% 0px -70% 0px' });

        headings.forEach(function (h) { highlightIO.observe(h); });
    }

    /* ══════════════════════════════════════════════════
       13. SHARE BUTTONS (Social + Copy Link)
       Injects SVG icons and opens share windows.
       ══════════════════════════════════════════════════ */
    var SHARE_ICONS = {
        twitter:  '<svg viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>',
        facebook: '<svg viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>',
        linkedin: '<svg viewBox="0 0 24 24"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>',
        copy:     '<svg viewBox="0 0 24 24"><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/></svg>'
    };

    function initShareButtons() {
        /* inject SVG icons into share buttons missing them */
        document.querySelectorAll('.share-btn').forEach(function (btn) {
            if (!btn.querySelector('svg')) {
                var platform = btn.dataset.share || btn.classList[1];
                if (SHARE_ICONS[platform]) btn.innerHTML = SHARE_ICONS[platform];
            }
        });

        /* social share click handlers */
        document.querySelectorAll('.share-btn[data-share]').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                var platform = btn.dataset.share;
                var url   = encodeURIComponent(window.location.href);
                var title = encodeURIComponent(document.title);
                var shareUrl = '';

                switch (platform) {
                    case 'twitter':
                        shareUrl = 'https://twitter.com/intent/tweet?url=' + url + '&text=' + title;
                        break;
                    case 'facebook':
                        shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=' + url;
                        break;
                    case 'linkedin':
                        shareUrl = 'https://www.linkedin.com/shareArticle?mini=true&url=' + url + '&title=' + title;
                        break;
                }

                if (shareUrl) window.open(shareUrl, '_blank', 'width=600,height=400');
            });
        });
    }

    function initCopyLink() {
        document.querySelectorAll('.share-btn.copy').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                navigator.clipboard.writeText(window.location.href).then(function () {
                    var original = btn.textContent;
                    btn.textContent = 'Copied!';
                    btn.style.background = 'var(--trail-red)';
                    btn.style.color = 'white';
                    setTimeout(function () {
                        btn.textContent = original;
                        btn.style.background = '';
                        btn.style.color = '';
                    }, 2000);
                });
            });
        });
    }

    /* ══════════════════════════════════════════════════
       14. PARALLAX HERO
       .bgl-hero-image translates + scales on scroll.
       ══════════════════════════════════════════════════ */
    function initParallaxHero() {
        if (reducedMotion) return;
        var heroImage = document.querySelector('.bgl-hero-image');
        if (!heroImage) return;

        window.addEventListener('scroll', function () {
            var scrolled = window.scrollY;
            if (scrolled < window.innerHeight) {
                heroImage.style.transform =
                    'translateY(' + (scrolled * 0.3) + 'px) scale(' + (1 + scrolled * 0.0003) + ')';
            }
        }, { passive: true });
    }

    /* ══════════════════════════════════════════════════
       15. LAZY LOADING FALLBACK
       For browsers without native loading="lazy".
       ══════════════════════════════════════════════════ */
    function initLazyLoadFallback() {
        if ('loading' in HTMLImageElement.prototype) {
            document.querySelectorAll('img[loading="lazy"]').forEach(function (img) {
                img.src = img.dataset.src || img.src;
            });
        } else {
            var lazyImages = document.querySelectorAll('img[loading="lazy"]');
            var io = new IntersectionObserver(function (entries) {
                entries.forEach(function (entry) {
                    if (entry.isIntersecting) {
                        var img = entry.target;
                        img.src = img.dataset.src || img.src;
                        io.unobserve(img);
                    }
                });
            });
            lazyImages.forEach(function (img) { io.observe(img); });
        }
    }

    /* ══════════════════════════════════════════════════
       16. KEYBOARD NAVIGATION
       J / K — vim-style page scrolling.
       Left / Right arrows handled in lightbox (§11).
       ══════════════════════════════════════════════════ */
    function initKeyboardNav() {
        document.addEventListener('keydown', function (e) {
            if (document.activeElement.tagName !== 'BODY') return;
            var behavior = reducedMotion ? 'auto' : 'smooth';
            if (e.key === 'j') window.scrollBy({ top: 100, behavior: behavior });
            if (e.key === 'k') window.scrollBy({ top: -100, behavior: behavior });
        });
    }

    /* ══════════════════════════════════════════════════
       17. PRINT OPTIMIZATION
       Forces eager loading on all images before print.
       ══════════════════════════════════════════════════ */
    function initPrintOptimization() {
        if (!window.matchMedia) return;
        window.matchMedia('print').addEventListener('change', function (e) {
            if (e.matches) {
                document.querySelectorAll('img').forEach(function (img) {
                    img.loading = 'eager';
                });
            }
        });
    }

    /* ══════════════════════════════════════════════════
       18. ESTIMATED READ TIME
       Word-count based, injected into .reading-time
       or .article-meta containers.
       ══════════════════════════════════════════════════ */
    function initReadTime() {
        var postContent = document.getElementById('post-content');
        if (!postContent) return;

        var wordCount = postContent.textContent.trim().split(/\s+/).length;
        var readTime  = Math.ceil(wordCount / CFG.wordsPerMinute);

        var el = document.querySelector('.reading-time, .read-time, [data-content-id="post-content"]');
        if (el) el.textContent = readTime + ' min read';

        var meta = document.querySelector('.article-meta, .card-meta');
        if (meta && !meta.querySelector('.reading-time')) {
            var span = document.createElement('span');
            span.className = 'read-time';
            span.textContent = readTime + ' min read';
            meta.appendChild(span);
        }
    }

    /* ══════════════════════════════════════════════════
       19. MOUNTAIN CANVAS (Resume Page)
       Animated mountain silhouette with floating
       data-skill particles. Only activates when
       #mountainCanvas is present.
       ══════════════════════════════════════════════════ */
    function initMountainCanvas() {
        var canvas = document.getElementById('mountainCanvas');
        if (!canvas) return;

        var ctx = canvas.getContext('2d');

        function resize() {
            canvas.width  = window.innerWidth;
            canvas.height = window.innerHeight;
        }
        window.addEventListener('resize', resize);
        resize();

        /* mountain peaks */
        var peaks = [
            { x: 0.2,  height: 0.5  },
            { x: 0.35, height: 0.7  },
            { x: 0.5,  height: 0.35 },
            { x: 0.65, height: 0.6  },
            { x: 0.8,  height: 0.45 }
        ];

        function drawMountain() {
            ctx.beginPath();
            ctx.moveTo(0, canvas.height);

            if (peaks.length > 0) {
                var fp = peaks[0];
                var fx = canvas.width * fp.x;
                var fy = canvas.height - canvas.height * fp.height;
                ctx.quadraticCurveTo(fx * 0.5, fy, fx, fy);
            }

            for (var i = 1; i < peaks.length; i++) {
                var pk   = peaks[i];
                var prev = peaks[i - 1];
                var x  = canvas.width  * pk.x;
                var y  = canvas.height - canvas.height * pk.height;
                var px = canvas.width  * prev.x;
                var py = canvas.height - canvas.height * prev.height;
                var mx = (px + x) / 2;
                var t  = 0.3;
                ctx.bezierCurveTo(
                    px + (mx - px) * (1 - t), py,
                    x  - (x  - mx) * (1 - t), y,
                    x, y
                );
            }

            var lp = peaks[peaks.length - 1];
            var lx = canvas.width  * lp.x;
            var ly = canvas.height - canvas.height * lp.height;
            ctx.quadraticCurveTo(lx + (canvas.width - lx) * 0.5, ly, canvas.width, canvas.height);
            ctx.closePath();

            var grad = ctx.createLinearGradient(0, 0, 0, canvas.height);
            grad.addColorStop(0, 'rgba(224, 30, 55, 0.15)');
            grad.addColorStop(1, 'rgba(44, 95, 141, 0.05)');
            ctx.fillStyle = grad;
            ctx.fill();

            ctx.strokeStyle = 'rgba(224, 30, 55, 0.3)';
            ctx.lineWidth = 2;
            ctx.stroke();
        }

        /* floating data-skill particles */
        var words = [
            'LLM Development & Evaluation', 'Model Quality Metrics', 'Text Summarization',
            'Sentiment Analysis', 'Automated Classification', 'SQL', 'Python', 'R',
            'ETL Pipelines', 'Data Visualization', 'Statistical Modeling', 'Forecasting',
            'Multi-Touch Attribution', 'Predictive Analytics', 'A/B Testing', 'Causal Inference',
            'Technical Strategy', 'Team Building', 'Cross-functional Collaboration',
            'Stakeholder Management', 'Mentorship', 'Quality Standards'
        ];

        var particles = [];
        for (var p = 0; p < 25; p++) {
            particles.push({
                x:       Math.random() * canvas.width,
                y:       Math.random() * canvas.height,
                text:    words[Math.floor(Math.random() * words.length)],
                speed:   0.15 + Math.random() * 0.4,
                opacity: 0.02 + Math.random() * 0.08,
                drift:   Math.random() * 2 - 1
            });
        }

        setTimeout(function () { canvas.classList.remove('loading'); }, 100);

        /* render loop */
        (function loop() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            drawMountain();

            particles.forEach(function (pt) {
                ctx.fillStyle = 'rgba(255, 255, 255, ' + pt.opacity + ')';
                ctx.font = '900 14px Manrope';
                ctx.fillText(pt.text, pt.x, pt.y);

                pt.y -= pt.speed;
                pt.x += pt.drift * 0.1;

                if (pt.y < -20) {
                    pt.y = canvas.height + 20;
                    pt.x = Math.random() * canvas.width;
                }
                if (pt.x < -50 || pt.x > canvas.width + 50) {
                    pt.x = Math.random() * canvas.width;
                }
            });

            requestAnimationFrame(loop);
        })();

        /* canvas parallax on scroll */
        window.addEventListener('scroll', function () {
            var scrolled     = window.pageYOffset;
            var heroContent  = document.querySelector('.hero-content');
            if (scrolled < window.innerHeight && heroContent) {
                heroContent.style.transform = 'translateY(' + (scrolled * 0.5) + 'px)';
                canvas.style.transform      = 'translateY(' + (scrolled * 0.3) + 'px)';
            }
        }, { passive: true });
    }

    /* ══════════════════════════════════════════════════
       SHARED HELPERS
       ══════════════════════════════════════════════════ */

    /**
     * observeOnce – fire a callback the first time any
     * element matching `selectorOrEl` scrolls into view.
     * Accepts a CSS selector string OR a single Element.
     */
    function observeOnce(selectorOrEl, thresh, cb) {
        var els;
        if (typeof selectorOrEl === 'string') {
            els = document.querySelectorAll(selectorOrEl);
        } else {
            els = [selectorOrEl];
        }
        if (!els.length) return;

        var io = new IntersectionObserver(function (entries, obs) {
            entries.forEach(function (e) {
                if (!e.isIntersecting) return;
                cb(e.target);
                obs.unobserve(e.target);
            });
        }, { threshold: thresh });

        els.forEach(function (el) { io.observe(el); });
    }

    /** Animate a number inside an element (cubic ease-out). */
    function animateNumber(el, target, duration) {
        if (!el) return;
        var t0 = performance.now();
        (function tick(now) {
            var p    = Math.min((now - t0) / duration, 1);
            var ease = 1 - Math.pow(1 - p, 3);
            el.textContent = Math.round(ease * target);
            if (p < 1) requestAnimationFrame(tick);
        })(t0);
    }

    /** Animate a count with optional suffix (exponential ease-out). */
    function animateCount(el, target, suffix, duration) {
        var t0 = performance.now();
        (function tick(now) {
            var p    = Math.min((now - t0) / duration, 1);
            var ease = p === 1 ? 1 : 1 - Math.pow(2, -10 * p);
            el.textContent = Math.round(ease * target).toLocaleString() + suffix;
            if (p < 1) requestAnimationFrame(tick);
        })(t0);
    }

})();
