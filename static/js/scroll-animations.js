/**
 * Boulder Gear Lab – Alpine Dark Reveal System
 * Unified IntersectionObserver for .reveal → .vis, .scroll-reveal → .revealed,
 * stat counters, score circles, and stagger delays.
 */

(function () {
    'use strict';

    /* ── config ───────────────────────────────── */
    const CFG = {
        threshold : 0.12,
        rootMargin: '0px 0px -60px 0px',
        once      : true,          // observe only once
        staggerMs : 120            // delay between siblings
    };

    /* ── bootstrap ────────────────────────────── */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }

    function boot() {
        if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
            showAll();
            return;
        }
        autoTag();
        initReveals();
        initScoreCircles();
        initScoreBars();
        initProsCons();
        initStatCounters();
    }

    /* ── auto-tag common elements ─────────────── */
    function autoTag() {
        var sel = [
            '.review-card',
            '.peak-card',
            '.section-header',
            '.section-title',
            '.bgl-stat-number',
            '.feature-box',
            '.box',
            '.box-simple'
        ];
        sel.forEach(function (s) {
            document.querySelectorAll(s).forEach(function (el) {
                if (!el.classList.contains('reveal') && !el.classList.contains('scroll-reveal')) {
                    el.classList.add('reveal');
                }
            });
        });
    }

    /* ── reveal observer (.reveal → .vis, .scroll-reveal → .revealed) ── */
    function initReveals() {
        var targets = document.querySelectorAll('.reveal:not(.vis), .scroll-reveal:not(.revealed)');
        if (!targets.length) return;

        /* assign stagger delays inside grid parents */
        assignStagger('.peaks-grid');
        assignStagger('.premium-grid');

        var io = new IntersectionObserver(function (entries, obs) {
            entries.forEach(function (e) {
                if (!e.isIntersecting) return;
                var t = e.target;
                t.classList.add(t.classList.contains('scroll-reveal') ? 'revealed' : 'vis');
                if (CFG.once) obs.unobserve(t);
            });
        }, { threshold: CFG.threshold, rootMargin: CFG.rootMargin });

        targets.forEach(function (el) { io.observe(el); });
    }

    function assignStagger(parentSel) {
        document.querySelectorAll(parentSel).forEach(function (grid) {
            var kids = grid.querySelectorAll('.reveal, .scroll-reveal');
            kids.forEach(function (el, i) {
                el.style.transitionDelay = (i * CFG.staggerMs) + 'ms';
            });
        });
    }

    /* ── score circles ────────────────────────── */
    function initScoreCircles() {
        observe('.review-score-circle', 0.5, function (el) {
            el.classList.add('animated');
            animateNumber(el.querySelector('.score-number'),
                parseInt(el.style.getPropertyValue('--score')) || 0, 1500);
        });
    }

    /* ── score bars ───────────────────────────── */
    function initScoreBars() {
        observe('.score-bar-fill', 0.3, function (el) {
            el.classList.add('animated');
        });
    }

    /* ── pros / cons ──────────────────────────── */
    function initProsCons() {
        observe('.pros-list, .cons-list', 0.2, function (el) {
            el.classList.add('revealed');
        });
    }

    /* ── stat counters ────────────────────────── */
    function initStatCounters() {
        observe('.bgl-stat-number', 0.5, function (el) {
            el.classList.add('revealed');
            var text  = el.textContent.trim();
            var m     = text.match(/^([\d,]+)(\+?)(.*)$/);
            if (!m) return;
            var target = parseInt(m[1].replace(/,/g, ''));
            var suffix = (m[2] || '') + (m[3] || '');
            animateCount(el, target, suffix, 2000);
        });
    }

    /* ── helpers ───────────────────────────────── */
    function observe(selector, thresh, cb) {
        var els = document.querySelectorAll(selector);
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

    function animateNumber(el, target, duration) {
        if (!el) return;
        var t0 = performance.now();
        (function tick(now) {
            var p = Math.min((now - t0) / duration, 1);
            var ease = 1 - Math.pow(1 - p, 3);
            el.textContent = Math.round(ease * target);
            if (p < 1) requestAnimationFrame(tick);
        })(t0);
    }

    function animateCount(el, target, suffix, duration) {
        var t0 = performance.now();
        (function tick(now) {
            var p = Math.min((now - t0) / duration, 1);
            var ease = p === 1 ? 1 : 1 - Math.pow(2, -10 * p);
            el.textContent = Math.round(ease * target).toLocaleString() + suffix;
            if (p < 1) requestAnimationFrame(tick);
        })(t0);
    }

    /* ── reduced-motion fallback ──────────────── */
    function showAll() {
        document.querySelectorAll('.reveal').forEach(function (e) { e.classList.add('vis'); });
        document.querySelectorAll('.scroll-reveal').forEach(function (e) { e.classList.add('revealed'); });
        document.querySelectorAll('.review-score-circle, .score-bar-fill').forEach(function (e) { e.classList.add('animated'); });
        document.querySelectorAll('.pros-list, .cons-list').forEach(function (e) { e.classList.add('revealed'); });
    }

})();
