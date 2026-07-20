/**
 * Online Resume System - Dashboard JavaScript
 * Admin panel interactions
 *
 * ULTRATHINK #255 - New Year's Eve Build
 */

// Mobile sidebar toggle
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.querySelector('.sidebar-overlay');

    if (sidebar) {
        sidebar.classList.toggle('open');
    }
    if (overlay) {
        overlay.classList.toggle('active');
    }
}

// Close sidebar when clicking overlay
document.addEventListener('DOMContentLoaded', function() {
    const overlay = document.querySelector('.sidebar-overlay');
    if (overlay) {
        overlay.addEventListener('click', toggleSidebar);
    }

    // Close sidebar on escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            const sidebar = document.getElementById('sidebar');
            if (sidebar && sidebar.classList.contains('open')) {
                toggleSidebar();
            }
        }
    });

    // Close sidebar when clicking outside on mobile
    document.addEventListener('click', function(e) {
        const sidebar = document.getElementById('sidebar');
        const menuBtn = document.querySelector('.mobile-menu-btn');

        if (window.innerWidth <= 1024) {
            if (sidebar && menuBtn) {
                if (!sidebar.contains(e.target) && !menuBtn.contains(e.target) && sidebar.classList.contains('open')) {
                    toggleSidebar();
                }
            }
        }
    });
});

// Form submission with loading state
document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', function(e) {
        const submitBtn = form.querySelector('button[type="submit"]');
        if (submitBtn && !submitBtn.disabled) {
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="loading">Processing...</span>';
        }
    });
});

// Easter egg
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
