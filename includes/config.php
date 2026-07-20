<?php
/**
 * Online Resume System - Configuration File
 * Database connection and application constants
 *
 * ULTRATHINK #255 - New Year's Eve Build
 */

// Error reporting (disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Session configuration
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// =====================================================
// Database Configuration
// (Reads from environment variables when available, e.g. on AWS EC2/
// Elastic Beanstalk. Falls back to local dev defaults otherwise.)
// =====================================================
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_NAME', getenv('DB_NAME') ?: 'online_resume_system');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_CHARSET', 'utf8mb4');

// =====================================================
// Application Configuration
// (APP_URL auto-detects protocol + host so it works both locally
// and once deployed behind any public domain/IP without edits.)
// =====================================================
$__scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$__host   = $_SERVER['HTTP_HOST'] ?? '127.0.0.1:9090';
define('APP_NAME', 'Online Resume System');
define('APP_URL', getenv('APP_URL') ?: ($__scheme . '://' . $__host));
define('APP_VERSION', '1.0.0');


// =====================================================
// Path Configuration
// =====================================================
define('ROOT_PATH', dirname(__DIR__) . DIRECTORY_SEPARATOR);
define('INCLUDES_PATH', ROOT_PATH . 'includes' . DIRECTORY_SEPARATOR);
define('ASSETS_PATH', ROOT_PATH . 'assets' . DIRECTORY_SEPARATOR);
define('ADMIN_PATH', ROOT_PATH . 'admin' . DIRECTORY_SEPARATOR);
define('UPLOADS_PATH', ASSETS_PATH . 'images' . DIRECTORY_SEPARATOR);

// =====================================================
// URL Paths
// =====================================================
define('ASSETS_URL', APP_URL . '/assets');
define('CSS_URL', ASSETS_URL . '/css');
define('JS_URL', ASSETS_URL . '/js');
define('IMAGES_URL', ASSETS_URL . '/images');

// =====================================================
// Theme Colors (Cobalt Blue + White)
// =====================================================
define('PRIMARY_COLOR', '#0047AB');
define('PRIMARY_DARK', '#003380');
define('PRIMARY_LIGHT', '#1E5DC8');

// =====================================================
// PDO Database Connection
// =====================================================
try {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];

    $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
} catch (PDOException $e) {
    // In production, log this error instead of displaying
    die("Database connection failed: " . $e->getMessage());
}

// =====================================================
// Helper function to get database connection
// =====================================================
function getDB() {
    global $pdo;
    return $pdo;
}

// =====================================================
// Security Functions
// =====================================================
/**
 * Sanitize output to prevent XSS
 */
function e($string) {
    return htmlspecialchars($string ?? '', ENT_QUOTES, 'UTF-8');
}

/**
 * Generate CSRF token
 */
function generateCSRFToken() {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

/**
 * Verify CSRF token
 */
function verifyCSRFToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Get CSRF input field
 */
function csrfField() {
    return '<input type="hidden" name="csrf_token" value="' . e(generateCSRFToken()) . '">';
}
