/**
 * Online Resume System - Main JavaScript
 * Common utilities and interactions
 *
 * ULTRATHINK #255 - New Year's Eve Build
 */

// Easter egg in console
console.log(`%c
┌─────────────────────────────────────────┐
│   ██╗  ██╗██╗██╗   ██╗ ██████╗         │
│   ██║ ██╔╝██║╚██╗ ██╔╝██╔═══██╗        │
│   █████╔╝ ██║ ╚████╔╝ ██║   ██║        │
│   ██╔═██╗ ██║  ╚██╔╝  ██║   ██║        │
│   ██║  ██╗██║   ██║   ╚██████╔╝        │
│   ╚═╝  ╚═╝╚═╝   ╚═╝    ╚═════╝         │
├─────────────────────────────────────────┤
│   Created by Kiyoraka Ken              │
│   Kiyo Software Tech Lab               │
│   https://github.com/Kiyoraka          │
└─────────────────────────────────────────┘
`, 'color: #FFFFFF; font-family: monospace;');

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        const href = this.getAttribute('href');
        if (href === '#') return;

        const target = document.querySelector(href);
        if (target) {
            e.preventDefault();
            const navHeight = document.querySelector('.navbar')?.offsetHeight || 0;
            const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - navHeight - 20;

            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// Navbar scroll effect
const navbar = document.querySelector('.navbar');
if (navbar) {
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;

        if (currentScroll > 100) {
            navbar.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1)';
        } else {
            navbar.style.boxShadow = '0 1px 3px rgba(0, 0, 0, 0.1)';
        }

        lastScroll = currentScroll;
    });
}

// Form validation helper
function validateForm(form) {
    const inputs = form.querySelectorAll('[required]');
    let isValid = true;

    inputs.forEach(input => {
        if (!input.value.trim()) {
            isValid = false;
            input.classList.add('error');
        } else {
            input.classList.remove('error');
        }
    });

    return isValid;
}

// Alert auto-dismiss (only visible alerts, not modal errors)
document.querySelectorAll('.alert:not([style*="display: none"])').forEach(alert => {
    if (alert.offsetParent !== null) { // Check if visible
        setTimeout(() => {
            alert.style.transition = 'opacity 0.5s ease';
            alert.style.opacity = '0';
            setTimeout(() => alert.remove(), 500);
        }, 5000);
    }
});

// Confirm delete
document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', function(e) {
        if (!confirm(this.dataset.confirm || 'Are you sure?')) {
            e.preventDefault();
        }
    });
});
