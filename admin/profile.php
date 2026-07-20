<?php
/**
 * Online Resume System - Admin Profile Management
 * Edit personal information and professional summary
 *
 * ULTRATHINK #255 - New Year's Eve Build
 */

require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/includes/auth.php';

// Require authentication
requireAuth();

// Get current profile
$profile = getProfile();
$errors = [];
$success = false;

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Verify CSRF token
    if (!isset($_POST['csrf_token']) || !verifyCSRFToken($_POST['csrf_token'])) {
        $errors[] = 'Invalid request. Please try again.';
    } else {
        // Sanitize inputs
        $data = [
            'id' => $profile['id'] ?? 1,
            'full_name' => trim($_POST['full_name'] ?? ''),
            'job_title' => trim($_POST['job_title'] ?? ''),
            'email' => trim($_POST['email'] ?? ''),
            'phone' => trim($_POST['phone'] ?? ''),
            'location' => trim($_POST['location'] ?? ''),
            'linkedin_url' => trim($_POST['linkedin_url'] ?? ''),
            'website_url' => trim($_POST['website_url'] ?? ''),
            'summary' => trim($_POST['summary'] ?? ''),
            'profile_image' => $profile['profile_image'] ?? null,
        ];

        // Validate required fields
        if (empty($data['full_name'])) {
            $errors[] = 'Full name is required.';
        }

        // Handle image upload
        if (isset($_FILES['profile_image']) && $_FILES['profile_image']['error'] === UPLOAD_ERR_OK) {
            $uploadResult = uploadProfileImage($_FILES['profile_image']);
            if (isset($uploadResult['error'])) {
                $errors[] = $uploadResult['error'];
            } else {
                // Delete old image if exists
                if ($profile['profile_image'] && file_exists(UPLOADS_PATH . $profile['profile_image'])) {
                    unlink(UPLOADS_PATH . $profile['profile_image']);
                }
                $data['profile_image'] = $uploadResult['filename'];
            }
        }

        // Update profile if no errors
        if (empty($errors)) {
            if (updateProfile($data)) {
                setFlash('success', 'Profile updated successfully!');
                redirect('profile.php');
            } else {
                $errors[] = 'Failed to update profile. Please try again.';
            }
        }
    }
}

// Refresh profile data after potential update
$profile = getProfile();
$flash = getFlash();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile - <?= e(APP_NAME) ?></title>
    <link rel="stylesheet" href="<?= CSS_URL ?>/base.css">
    <link rel="stylesheet" href="<?= CSS_URL ?>/dashboard.css">
    <style>
        .profile-image-preview {
            width: 120px;
            height: 120px;
            border-radius: var(--rounded-lg);
            object-fit: cover;
            border: 2px solid var(--gray-200);
            background: var(--gray-100);
        }

        .profile-image-placeholder {
            width: 120px;
            height: 120px;
            border-radius: var(--rounded-lg);
            background: var(--gray-100);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray-400);
            border: 2px dashed var(--gray-300);
        }

        .image-upload-wrapper {
            display: flex;
            align-items: center;
            gap: var(--space-4);
        }

        .image-upload-info {
            font-size: var(--text-sm);
            color: var(--gray-500);
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <?php include __DIR__ . '/includes/sidebar.php'; ?>

        <main class="main-content">
            <!-- Top Bar -->
            <header class="topbar">
                <div class="topbar-left">
                    <button class="mobile-menu-btn" onclick="toggleSidebar()">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="3" y1="12" x2="21" y2="12"></line>
                            <line x1="3" y1="6" x2="21" y2="6"></line>
                            <line x1="3" y1="18" x2="21" y2="18"></line>
                        </svg>
                    </button>
                    <h1 class="page-title">Edit Profile</h1>
                </div>
                <div class="topbar-right">
                    <a href="../resume.php" class="topbar-btn" target="_blank">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                        <span>View Resume</span>
                    </a>
                    <a href="logout.php" class="topbar-btn logout-btn">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                            <polyline points="16 17 21 12 16 7"></polyline>
                            <line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                        <span>Logout</span>
                    </a>
                </div>
            </header>

            <!-- Page Content -->
            <div class="page-content">
                <?php if ($flash): ?>
                    <div class="alert alert-<?= e($flash['type']) ?>">
                        <?= e($flash['message']) ?>
                    </div>
                <?php endif; ?>

                <?php if (!empty($errors)): ?>
                    <div class="alert alert-danger">
                        <ul style="margin: 0; padding-left: var(--space-4);">
                            <?php foreach ($errors as $error): ?>
                                <li><?= e($error) ?></li>
                            <?php endforeach; ?>
                        </ul>
                    </div>
                <?php endif; ?>

                <form method="POST" enctype="multipart/form-data" class="form-card">
                    <?= csrfField() ?>

                    <!-- Profile Image Section -->
                    <div class="form-section">
                        <h3 class="form-section-title">Profile Image</h3>
                        <div class="image-upload-wrapper">
                            <?php if ($profile && $profile['profile_image']): ?>
                                <img src="<?= IMAGES_URL ?>/<?= e($profile['profile_image']) ?>" alt="Profile" class="profile-image-preview" id="imagePreview">
                            <?php else: ?>
                                <div class="profile-image-placeholder" id="imagePreview">
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                        <circle cx="12" cy="7" r="4"></circle>
                                    </svg>
                                </div>
                            <?php endif; ?>
                            <div>
                                <input type="file" name="profile_image" id="profile_image" accept="image/*" class="form-input" style="max-width: 300px;" onchange="previewImage(this)">
                                <p class="image-upload-info">JPG, PNG, GIF or WebP. Max 5MB.</p>
                            </div>
                        </div>
                    </div>

                    <!-- Personal Information Section -->
                    <div class="form-section">
                        <h3 class="form-section-title">Personal Information</h3>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="full_name" class="form-label">Full Name *</label>
                                <input type="text" id="full_name" name="full_name" class="form-input" value="<?= e($profile['full_name'] ?? '') ?>" required>
                            </div>
                            <div class="form-group">
                                <label for="job_title" class="form-label">Job Title</label>
                                <input type="text" id="job_title" name="job_title" class="form-input" value="<?= e($profile['job_title'] ?? '') ?>" placeholder="e.g., Full Stack Developer">
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" id="email" name="email" class="form-input" value="<?= e($profile['email'] ?? '') ?>" placeholder="your@email.com">
                            </div>
                            <div class="form-group">
                                <label for="phone" class="form-label">Phone</label>
                                <input type="tel" id="phone" name="phone" class="form-input" value="<?= e($profile['phone'] ?? '') ?>" placeholder="+60 123 456 789">
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="location" class="form-label">Location</label>
                            <input type="text" id="location" name="location" class="form-input" value="<?= e($profile['location'] ?? '') ?>" placeholder="City, Country">
                        </div>
                    </div>

                    <!-- Online Presence Section -->
                    <div class="form-section">
                        <h3 class="form-section-title">Online Presence</h3>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="linkedin_url" class="form-label">LinkedIn URL</label>
                                <input type="url" id="linkedin_url" name="linkedin_url" class="form-input" value="<?= e($profile['linkedin_url'] ?? '') ?>" placeholder="https://linkedin.com/in/yourprofile">
                            </div>
                            <div class="form-group">
                                <label for="website_url" class="form-label">GitHub URL</label>
                                <input type="url" id="website_url" name="website_url" class="form-input" value="<?= e($profile['website_url'] ?? '') ?>" placeholder="https://github.com/yourusername">
                            </div>
                        </div>
                    </div>

                    <!-- Professional Summary Section -->
                    <div class="form-section">
                        <h3 class="form-section-title">Professional Summary</h3>
                        <div class="form-group">
                            <label for="summary" class="form-label">Summary</label>
                            <textarea id="summary" name="summary" class="form-textarea" rows="6" placeholder="Write a brief professional summary..."><?= e($profile['summary'] ?? '') ?></textarea>
                            <p class="form-error" style="color: var(--gray-500); margin-top: var(--space-2);">This will appear at the top of your resume.</p>
                        </div>
                    </div>

                    <!-- Form Actions -->
                    <div class="form-actions">
                        <a href="index.php" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <script>
        // Mobile sidebar toggle
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.querySelector('.sidebar-overlay');
            sidebar.classList.toggle('open');
            overlay.classList.toggle('active');
        }

        // Image preview
        function previewImage(input) {
            const preview = document.getElementById('imagePreview');
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    if (preview.tagName === 'IMG') {
                        preview.src = e.target.result;
                    } else {
                        const img = document.createElement('img');
                        img.src = e.target.result;
                        img.className = 'profile-image-preview';
                        img.id = 'imagePreview';
                        preview.parentNode.replaceChild(img, preview);
                    }
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

    </script>
</body>
</html>
