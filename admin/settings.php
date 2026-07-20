<?php
/**
 * Online Resume System - Admin Settings
 * Change email and password
 *
 * ULTRATHINK #255 - New Year's Eve Build
 */

require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/includes/auth.php';

requireAuth();

$errors = [];
$success = '';

// Handle email change
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['change_email'])) {
    if (!isset($_POST['csrf_token']) || !verifyCSRFToken($_POST['csrf_token'])) {
        $errors[] = 'Invalid request.';
    } else {
        $newEmail = trim($_POST['new_email'] ?? '');
        $currentPassword = $_POST['current_password_email'] ?? '';

        if (empty($newEmail)) {
            $errors[] = 'New email is required.';
        } elseif (!filter_var($newEmail, FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'Please enter a valid email address.';
        } elseif (empty($currentPassword)) {
            $errors[] = 'Current password is required to change email.';
        } else {
            // Verify current password
            $pdo = getDB();
            $stmt = $pdo->prepare("SELECT password_hash FROM users WHERE id = :id");
            $stmt->execute(['id' => getAuthUserId()]);
            $user = $stmt->fetch();

            if ($user && password_verify($currentPassword, $user['password_hash'])) {
                if (updateUserEmail(getAuthUserId(), $newEmail)) {
                    $_SESSION['user_email'] = $newEmail;
                    setFlash('success', 'Email updated successfully!');
                    redirect('settings.php');
                } else {
                    $errors[] = 'Failed to update email.';
                }
            } else {
                $errors[] = 'Current password is incorrect.';
            }
        }
    }
}

// Handle password change
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['change_password'])) {
    if (!isset($_POST['csrf_token']) || !verifyCSRFToken($_POST['csrf_token'])) {
        $errors[] = 'Invalid request.';
    } else {
        $currentPassword = $_POST['current_password'] ?? '';
        $newPassword = $_POST['new_password'] ?? '';
        $confirmPassword = $_POST['confirm_password'] ?? '';

        if (empty($currentPassword)) {
            $errors[] = 'Current password is required.';
        }
        if (empty($newPassword)) {
            $errors[] = 'New password is required.';
        } elseif (strlen($newPassword) < 6) {
            $errors[] = 'New password must be at least 6 characters.';
        }
        if ($newPassword !== $confirmPassword) {
            $errors[] = 'New passwords do not match.';
        }

        if (empty($errors)) {
            // Verify current password
            $pdo = getDB();
            $stmt = $pdo->prepare("SELECT password_hash FROM users WHERE id = :id");
            $stmt->execute(['id' => getAuthUserId()]);
            $user = $stmt->fetch();

            if ($user && password_verify($currentPassword, $user['password_hash'])) {
                $newHash = password_hash($newPassword, PASSWORD_DEFAULT);
                if (updateUserPassword(getAuthUserId(), $newHash)) {
                    setFlash('success', 'Password updated successfully!');
                    redirect('settings.php');
                } else {
                    $errors[] = 'Failed to update password.';
                }
            } else {
                $errors[] = 'Current password is incorrect.';
            }
        }
    }
}

$flash = getFlash();
$currentEmail = getCurrentUserEmail();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - <?= e(APP_NAME) ?></title>
    <link rel="stylesheet" href="<?= CSS_URL ?>/base.css">
    <link rel="stylesheet" href="<?= CSS_URL ?>/dashboard.css">
</head>
<body>
    <div class="dashboard">
        <?php include __DIR__ . '/includes/sidebar.php'; ?>

        <main class="main-content">
            <header class="topbar">
                <div class="topbar-left">
                    <button class="mobile-menu-btn" onclick="toggleSidebar()">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line>
                        </svg>
                    </button>
                    <h1 class="page-title">Settings</h1>
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
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                        <span>Logout</span>
                    </a>
                </div>
            </header>

            <div class="page-content">
                <?php if ($flash): ?>
                    <div class="alert alert-<?= e($flash['type']) ?>"><?= e($flash['message']) ?></div>
                <?php endif; ?>

                <?php if (!empty($errors)): ?>
                    <div class="alert alert-danger">
                        <?php foreach ($errors as $error): ?><div><?= e($error) ?></div><?php endforeach; ?>
                    </div>
                <?php endif; ?>

                <!-- Change Email -->
                <div class="form-card" style="margin-bottom: var(--space-6);">
                    <h3 class="form-section-title">Change Email</h3>
                    <p style="color: var(--gray-500); margin-bottom: var(--space-4);">Current email: <strong><?= e($currentEmail) ?></strong></p>

                    <form method="POST">
                        <?= csrfField() ?>
                        <input type="hidden" name="change_email" value="1">

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">New Email *</label>
                                <input type="email" name="new_email" class="form-input" placeholder="new@email.com" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Current Password *</label>
                                <input type="password" name="current_password_email" class="form-input" placeholder="Enter current password" required>
                            </div>
                        </div>

                        <div class="form-actions" style="border-top: none; padding-top: 0; justify-content: flex-start;">
                            <button type="submit" class="btn btn-primary">Update Email</button>
                        </div>
                    </form>
                </div>

                <!-- Change Password -->
                <div class="form-card">
                    <h3 class="form-section-title">Change Password</h3>

                    <form method="POST">
                        <?= csrfField() ?>
                        <input type="hidden" name="change_password" value="1">

                        <div class="form-group">
                            <label class="form-label">Current Password *</label>
                            <input type="password" name="current_password" class="form-input" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">New Password *</label>
                                <input type="password" name="new_password" class="form-input" minlength="6" required>
                                <small style="color: var(--gray-500);">Minimum 6 characters</small>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Confirm New Password *</label>
                                <input type="password" name="confirm_password" class="form-input" required>
                            </div>
                        </div>

                        <div class="form-actions" style="border-top: none; padding-top: 0; justify-content: flex-start;">
                            <button type="submit" class="btn btn-primary">Update Password</button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>

    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
            document.querySelector('.sidebar-overlay').classList.toggle('active');
        }
        console.log('%c Powered by Kiyo Software TechLab', 'color: #0047AB; font-size: 14px; font-weight: bold;');
    </script>
</body>
</html>
