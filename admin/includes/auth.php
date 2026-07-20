<?php
/**
 * Online Resume System - Authentication Middleware
 * Protects admin pages from unauthorized access
 *
 * ULTRATHINK #255 - New Year's Eve Build
 */

// Start session if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/**
 * Check if user is authenticated
 * Redirects to login page if not logged in
 */
function requireAuth() {
    if (!isset($_SESSION['user_id']) || !isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
        // Store the requested URL for redirect after login
        $_SESSION['redirect_url'] = $_SERVER['REQUEST_URI'];

        // Redirect to landing page (has login popup)
        header('Location: ../index.php');
        exit;
    }

    // Check session timeout (30 minutes of inactivity)
    $timeout = 30 * 60; // 30 minutes in seconds
    if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity'] > $timeout)) {
        // Session expired, destroy and redirect
        session_unset();
        session_destroy();

        // Start new session for flash message
        session_start();
        $_SESSION['flash'] = [
            'type' => 'warning',
            'message' => 'Your session has expired. Please log in again.'
        ];

        header('Location: ../index.php');
        exit;
    }

    // Update last activity time
    $_SESSION['last_activity'] = time();
}

/**
 * Check if user is already logged in
 * For use on login page to redirect authenticated users
 */
function redirectIfAuthenticated() {
    if (isset($_SESSION['user_id']) && isset($_SESSION['logged_in']) && $_SESSION['logged_in'] === true) {
        header('Location: index.php');
        exit;
    }
}

/**
 * Log in a user
 */
function loginUser($userId, $email) {
    // Regenerate session ID to prevent session fixation
    session_regenerate_id(true);

    $_SESSION['user_id'] = $userId;
    $_SESSION['user_email'] = $email;
    $_SESSION['logged_in'] = true;
    $_SESSION['last_activity'] = time();
    $_SESSION['login_time'] = time();
}

/**
 * Log out a user
 */
function logoutUser() {
    // Unset all session variables
    $_SESSION = [];

    // Destroy the session cookie
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(
            session_name(),
            '',
            time() - 42000,
            $params['path'],
            $params['domain'],
            $params['secure'],
            $params['httponly']
        );
    }

    // Destroy the session
    session_destroy();
}

/**
 * Get current user's email
 */
function getCurrentUserEmail() {
    return $_SESSION['user_email'] ?? null;
}

/**
 * Get current user's ID
 */
function getAuthUserId() {
    return $_SESSION['user_id'] ?? null;
}

/**
 * Check if request is AJAX
 */
function isAjaxRequest() {
    return !empty($_SERVER['HTTP_X_REQUESTED_WITH']) &&
           strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest';
}

/**
 * Return JSON response for AJAX requests
 */
function jsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}
