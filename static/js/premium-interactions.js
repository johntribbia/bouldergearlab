/* ============================================
   BOULDER GEAR LAB - PREMIUM INTERACTIONS
   Enhanced UX/UI JavaScript
   ============================================ */

document.addEventListener('DOMContentLoaded', function() {
    
    // ========================================
    // 1. SCROLL REVEAL ANIMATIONS
    // ========================================
    const revealElements = document.querySelectorAll('.reveal, .reveal-left, .reveal-right, .reveal-scale, .fade-in-up, .stagger-children, .peak-card');
    
    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    });
    
    revealElements.forEach(el => revealObserver.observe(el));
    
    // ========================================
    // 2. NAVBAR SCROLL EFFECT
    // ========================================
    const navbar = document.getElementById('navbar');
    let lastScrollY = 0;
    
    if (navbar) {
        window.addEventListener('scroll', () => {
            const currentScrollY = window.scrollY;
            
            if (currentScrollY > 100) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
            
            lastScrollY = currentScrollY;
        });
    }
    
    // ========================================
    // 3. READING PROGRESS BAR
    // ========================================
    const progressBar = document.querySelector('.reading-progress');
    
    if (progressBar) {
        window.addEventListener('scroll', () => {
            const docHeight = document.documentElement.scrollHeight - window.innerHeight;
            const scrolled = (window.scrollY / docHeight) * 100;
            progressBar.style.width = Math.min(scrolled, 100) + '%';
        });
    }
    
    // ========================================
    // 4. IMAGE LIGHTBOX
    // ========================================
    const postContent = document.getElementById('post-content');
    
    if (postContent) {
        // Create lightbox overlay
        const lightboxOverlay = document.createElement('div');
        lightboxOverlay.className = 'lightbox-overlay';
        lightboxOverlay.innerHTML = `
            <button class="lightbox-close" aria-label="Close lightbox">×</button>
            <img src="" alt="Enlarged image">
        `;
        document.body.appendChild(lightboxOverlay);
        
        const lightboxImg = lightboxOverlay.querySelector('img');
        const lightboxClose = lightboxOverlay.querySelector('.lightbox-close');
        
        // Add click handlers to article images
        const articleImages = postContent.querySelectorAll('img');
        articleImages.forEach(img => {
            img.style.cursor = 'zoom-in';
            img.addEventListener('click', () => {
                lightboxImg.src = img.src;
                lightboxImg.alt = img.alt;
                lightboxOverlay.classList.add('active');
                document.body.style.overflow = 'hidden';
            });
        });
        
        // Close lightbox handlers
        function closeLightbox() {
            lightboxOverlay.classList.remove('active');
            document.body.style.overflow = '';
        }
        
        lightboxClose.addEventListener('click', closeLightbox);
        lightboxOverlay.addEventListener('click', (e) => {
            if (e.target === lightboxOverlay) closeLightbox();
        });
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') closeLightbox();
        });
    }
    
    // ========================================
    // 5. TABLE OF CONTENTS GENERATOR
    // ========================================
    const tocContainer = document.querySelector('.toc-container');
    const existingToc = document.querySelector('.toc-sidebar');
    
    if (postContent && !existingToc) {
        const headings = postContent.querySelectorAll('h2, h3');
        
        if (headings.length > 2) {
            // Generate TOC - prefer .toc-container, fallback to .col-md-3
            const targetElement = tocContainer || document.querySelector('.col-md-3');
            
            if (targetElement) {
                const toc = document.createElement('div');
                toc.className = 'toc-sidebar';
                toc.innerHTML = '<h4>Contents</h4><ul></ul>';
                const tocList = toc.querySelector('ul');
                
                headings.forEach((heading, index) => {
                    // Add ID to heading if not present
                    if (!heading.id) {
                        heading.id = 'section-' + index;
                    }
                    
                    const li = document.createElement('li');
                    const a = document.createElement('a');
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
                    targetElement.insertBefore(toc, targetElement.firstChild);
                }
                
                // Highlight current section
                const tocLinks = toc.querySelectorAll('a');
                
                const highlightObserver = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            tocLinks.forEach(link => link.classList.remove('active'));
                            const activeLink = toc.querySelector(`a[href="#${entry.target.id}"]`);
                            if (activeLink) activeLink.classList.add('active');
                        }
                    });
                }, {
                    threshold: 0,
                    rootMargin: '-20% 0px -70% 0px'
                });
                
                headings.forEach(h => highlightObserver.observe(h));
            }
        }
    }
    
    // ========================================
    // 6. SMOOTH SCROLL FOR ANCHOR LINKS
    // ========================================
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // ========================================
    // 7. ANIMATED COUNTERS (for stats)
    // ========================================
    function animateCounter(element) {
        const target = parseInt(element.dataset.target) || parseInt(element.textContent);
        const duration = 2000;
        const increment = target / (duration / 16);
        let current = 0;
        
        const timer = setInterval(() => {
            current += increment;
            if (current >= target) {
                element.textContent = target.toLocaleString();
                if (element.dataset.suffix) {
                    element.textContent += element.dataset.suffix;
                }
                clearInterval(timer);
            } else {
                element.textContent = Math.floor(current).toLocaleString();
            }
        }, 16);
    }
    
    const statNumbers = document.querySelectorAll('.stat-number[data-target]');
    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateCounter(entry.target);
                statsObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });
    
    statNumbers.forEach(stat => statsObserver.observe(stat));
    
    // ========================================
    // 8. COPY LINK BUTTON
    // ========================================
    const copyButtons = document.querySelectorAll('.share-btn.copy');
    
    copyButtons.forEach(btn => {
        btn.addEventListener('click', async (e) => {
            e.preventDefault();
            try {
                await navigator.clipboard.writeText(window.location.href);
                const originalText = btn.textContent;
                btn.textContent = 'Copied!';
                btn.style.background = 'var(--trail-red)';
                btn.style.color = 'white';
                setTimeout(() => {
                    btn.textContent = originalText;
                    btn.style.background = '';
                    btn.style.color = '';
                }, 2000);
            } catch (err) {
                console.error('Failed to copy:', err);
            }
        });
    });
    
    // ========================================
    // 9. PARALLAX HERO EFFECT
    // ========================================
    const hero = document.querySelector('.bgl-hero');
    const heroImage = document.querySelector('.bgl-hero-image');
    
    if (hero && heroImage) {
        window.addEventListener('scroll', () => {
            const scrolled = window.scrollY;
            if (scrolled < window.innerHeight) {
                heroImage.style.transform = `translateY(${scrolled * 0.3}px) scale(${1 + scrolled * 0.0003})`;
            }
        });
    }
    
    // ========================================
    // 10. LAZY LOADING IMAGES
    // ========================================
    if ('loading' in HTMLImageElement.prototype) {
        // Browser supports native lazy loading
        document.querySelectorAll('img[loading="lazy"]').forEach(img => {
            img.src = img.dataset.src || img.src;
        });
    } else {
        // Fallback for older browsers
        const lazyImages = document.querySelectorAll('img[loading="lazy"]');
        const lazyObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src || img.src;
                    lazyObserver.unobserve(img);
                }
            });
        });
        lazyImages.forEach(img => lazyObserver.observe(img));
    }
    
    // ========================================
    // 11. KEYBOARD NAVIGATION ENHANCEMENTS
    // ========================================
    document.addEventListener('keydown', (e) => {
        // J/K for scrolling through articles (vim-style)
        if (document.activeElement.tagName === 'BODY') {
            if (e.key === 'j') {
                window.scrollBy({ top: 100, behavior: 'smooth' });
            } else if (e.key === 'k') {
                window.scrollBy({ top: -100, behavior: 'smooth' });
            }
        }
    });
    
    // ========================================
    // 12. PRINT OPTIMIZATION
    // ========================================
    if (window.matchMedia) {
        window.matchMedia('print').addEventListener('change', (e) => {
            if (e.matches) {
                // Before print
                document.querySelectorAll('img').forEach(img => {
                    img.loading = 'eager';
                });
            }
        });
    }
    
    // ========================================
    // 13. SHARE BUTTONS
    // ========================================
    
    // SVG icons for share buttons
    const shareIcons = {
        twitter: '<svg viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>',
        facebook: '<svg viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>',
        linkedin: '<svg viewBox="0 0 24 24"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>',
        copy: '<svg viewBox="0 0 24 24"><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/></svg>'
    };
    
    // Add icons to share buttons if they don't have them
    const shareButtons = document.querySelectorAll('.share-btn');
    shareButtons.forEach(btn => {
        // Check if button already has an SVG
        if (!btn.querySelector('svg')) {
            const platform = btn.dataset.share || btn.classList[1];
            if (shareIcons[platform]) {
                btn.innerHTML = shareIcons[platform];
            }
        }
    });
    
    // Handle share button clicks
    document.querySelectorAll('.share-btn[data-share]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const platform = btn.dataset.share;
            const url = encodeURIComponent(window.location.href);
            const title = encodeURIComponent(document.title);
            
            let shareUrl = '';
            
            switch(platform) {
                case 'twitter':
                    shareUrl = `https://twitter.com/intent/tweet?url=${url}&text=${title}`;
                    break;
                case 'facebook':
                    shareUrl = `https://www.facebook.com/sharer/sharer.php?u=${url}`;
                    break;
                case 'linkedin':
                    shareUrl = `https://www.linkedin.com/shareArticle?mini=true&url=${url}&title=${title}`;
                    break;
            }
            
            if (shareUrl) {
                window.open(shareUrl, '_blank', 'width=600,height=400');
            }
        });
    });
    
    // ========================================
    // 14. ESTIMATED READ TIME
    // ========================================
    if (postContent) {
        const text = postContent.textContent;
        const wordCount = text.trim().split(/\s+/).length;
        const readTime = Math.ceil(wordCount / 200); // Average 200 words per minute
        
        // Find reading time element - support multiple selectors
        const readTimeElement = document.querySelector('.reading-time, .read-time, [data-content-id="post-content"]');
        if (readTimeElement) {
            readTimeElement.textContent = `${readTime} min read`;
        }
        
        // Add read time to meta if element exists
        const metaInfo = document.querySelector('.article-meta, .card-meta');
        if (metaInfo && !metaInfo.querySelector('.reading-time')) {
            const readTimeSpan = document.createElement('span');
            readTimeSpan.className = 'read-time';
            readTimeSpan.textContent = `${readTime} min read`;
            metaInfo.appendChild(readTimeSpan);
        }
    }
    
    // ========================================
    // 15. SCORE CIRCLE ANIMATION
    // ========================================
    const scoreCircles = document.querySelectorAll('.score-circle');
    
    scoreCircles.forEach(circle => {
        const score = parseFloat(circle.dataset.score) || 0;
        const percentage = (score / 10) * 100;
        
        const scoreObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    let currentScore = 0;
                    const increment = percentage / 60; // 60 frames for 1 second
                    
                    const animate = () => {
                        currentScore += increment;
                        if (currentScore >= percentage) {
                            currentScore = percentage;
                            circle.style.setProperty('--score', percentage);
                        } else {
                            circle.style.setProperty('--score', currentScore);
                            requestAnimationFrame(animate);
                        }
                    };
                    
                    animate();
                    scoreObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.5 });
        
        scoreObserver.observe(circle);
    });
    
    console.log('🏔️ Boulder Gear Lab Premium UX loaded');
});
