// Boulder Gear Lab Theme Animations
// Based on resume.html animation system

(function() {
    'use strict';

    // Initialize canvas if present
    const canvas = document.getElementById('mountainCanvas');
    if (canvas) {
        const ctx = canvas.getContext('2d');

        function resize() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }
        window.addEventListener('resize', resize);
        resize();

        // Mountain peaks
        class Mountain {
            constructor() {
                this.peaks = [
                    { x: 0.2, height: 0.5 },
                    { x: 0.35, height: 0.7 },
                    { x: 0.5, height: 0.35 },
                    { x: 0.65, height: 0.6 },
                    { x: 0.8, height: 0.45 }
                ];
            }

            draw() {
                ctx.beginPath();
                ctx.moveTo(0, canvas.height);

                // First point with smooth entry
                if (this.peaks.length > 0) {
                    const firstPeak = this.peaks[0];
                    const x = canvas.width * firstPeak.x;
                    const y = canvas.height - (canvas.height * firstPeak.height);
                    ctx.quadraticCurveTo(x * 0.5, y, x, y);
                }

                // Smooth curves between peaks
                for (let i = 1; i < this.peaks.length; i++) {
                    const peak = this.peaks[i];
                    const prevPeak = this.peaks[i - 1];

                    const x = canvas.width * peak.x;
                    const y = canvas.height - (canvas.height * peak.height);
                    const prevX = canvas.width * prevPeak.x;
                    const prevY = canvas.height - (canvas.height * prevPeak.height);

                    // Calculate control points for smoother curves
                    const midX = (prevX + x) / 2;
                    const tension = 0.3;

                    const cp1X = prevX + (midX - prevX) * (1 - tension);
                    const cp1Y = prevY;
                    const cp2X = x - (x - midX) * (1 - tension);
                    const cp2Y = y;

                    ctx.bezierCurveTo(cp1X, cp1Y, cp2X, cp2Y, x, y);
                }

                // Smooth exit
                const lastPeak = this.peaks[this.peaks.length - 1];
                const lastX = canvas.width * lastPeak.x;
                const lastY = canvas.height - (canvas.height * lastPeak.height);
                ctx.quadraticCurveTo(lastX + (canvas.width - lastX) * 0.5, lastY, canvas.width, canvas.height);

                ctx.closePath();

                const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
                gradient.addColorStop(0, 'rgba(224, 30, 55, 0.15)');
                gradient.addColorStop(1, 'rgba(44, 95, 141, 0.05)');
                ctx.fillStyle = gradient;
                ctx.fill();

                ctx.strokeStyle = 'rgba(224, 30, 55, 0.3)';
                ctx.lineWidth = 2;
                ctx.stroke();
            }
        }

        // Floating data points
        const particles = [];
        const words = [
            'LLM Development & Evaluation', 'Model Quality Metrics', 'Text Summarization', 
            'Sentiment Analysis', 'Automated Classification', 'SQL', 'Python', 'R', 
            'ETL Pipelines', 'Data Visualization', 'Statistical Modeling', 'Forecasting', 
            'Multi-Touch Attribution', 'Predictive Analytics', 'A/B Testing', 'Causal Inference', 
            'Technical Strategy', 'Team Building', 'Cross-functional Collaboration', 
            'Stakeholder Management', 'Mentorship', 'Quality Standards'
        ];

        for (let i = 0; i < 25; i++) {
            particles.push({
                x: Math.random() * canvas.width,
                y: Math.random() * canvas.height,
                text: words[Math.floor(Math.random() * words.length)],
                speed: 0.15 + Math.random() * 0.4,
                opacity: 0.02 + Math.random() * 0.08,
                drift: Math.random() * 2 - 1
            });
        }

        const mountain = new Mountain();

        // Remove loading state once canvas is ready
        setTimeout(() => {
            canvas.classList.remove('loading');
        }, 100);

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            mountain.draw();

            particles.forEach(p => {
                ctx.fillStyle = `rgba(255, 255, 255, ${p.opacity})`;
                ctx.font = '900 14px Manrope';
                ctx.fillText(p.text, p.x, p.y);

                p.y -= p.speed;
                p.x += p.drift * 0.1;

                if (p.y < -20) {
                    p.y = canvas.height + 20;
                    p.x = Math.random() * canvas.width;
                }

                if (p.x < -50 || p.x > canvas.width + 50) {
                    p.x = Math.random() * canvas.width;
                }
            });

            requestAnimationFrame(animate);
        }

        animate();

        // Parallax scrolling
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const heroContent = document.querySelector('.hero-content');
            const canvasElement = document.querySelector('#mountainCanvas');
            
            if (scrolled < window.innerHeight && heroContent && canvasElement) {
                heroContent.style.transform = `translateY(${scrolled * 0.5}px)`;
                canvasElement.style.transform = `translateY(${scrolled * 0.3}px)`;
            }
        });
    }

    // Smooth scroll
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });

    // Stats Counter Animation
    function animateCounter(element) {
        const target = parseInt(element.dataset.target);
        const duration = 2000;
        const start = 0;
        const increment = target / (duration / 16);
        let current = 0;
        
        const timer = setInterval(() => {
            current += increment;
            if (current >= target) {
                element.textContent = target.toLocaleString();
                clearInterval(timer);
            } else {
                element.textContent = Math.floor(current).toLocaleString();
            }
        }, 16);
    }

    // Trigger stats counter on scroll into view
    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.querySelectorAll('.stat-number').forEach(animateCounter);
                statsObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    const statsRow = document.querySelector('.stats-row');
    if (statsRow) {
        statsObserver.observe(statsRow);
    }

    // Scroll-triggered animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, observerOptions);

    // Observe all elements with fade-in-up class
    document.querySelectorAll('.fade-in-up').forEach(el => {
        observer.observe(el);
    });

    // Reading Progress Bar
    const readingProgress = document.querySelector('.reading-progress');
    if (readingProgress) {
        window.addEventListener('scroll', () => {
            const scrolled = window.scrollY;
            const height = document.documentElement.scrollHeight - window.innerHeight;
            const progress = (scrolled / height) * 100;
            readingProgress.style.width = progress + '%';
        });
    }
})();
