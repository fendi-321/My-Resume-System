-- Online Resume System Database Schema
-- ULTRATHINK #255 - New Year's Eve Build
-- Created: December 31, 2025

-- Create database
CREATE DATABASE IF NOT EXISTS online_resume_system;
USE online_resume_system;

-- =====================================================
-- Table: users (Admin Authentication)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Default admin user (password: admin123)
-- Password hash generated with password_hash('admin123', PASSWORD_DEFAULT)
INSERT INTO users (email, password_hash) VALUES
('admin@gmail.com', '$2y$10$F2I3DCF4DGGjVYuq60e3IOLmh/IljlWokFt1GSViIp6nh.HT8Dh5y');

-- =====================================================
-- Table: profile (Personal Info - Single Row)
-- =====================================================
CREATE TABLE IF NOT EXISTS profile (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    job_title VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    location VARCHAR(255),
    linkedin_url VARCHAR(500),
    website_url VARCHAR(500),
    profile_image VARCHAR(500),
    summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Default profile data
INSERT INTO profile (full_name, job_title, email, phone, location, summary) VALUES
('John Doe', 'Full Stack Developer', 'john.doe@example.com', '+60 123 456 789', 'Kuala Lumpur, Malaysia', 'Results-driven software developer with 5+ years of experience in building scalable web applications. Proficient in PHP, JavaScript, and modern frameworks. Passionate about clean code and user-centric design.');

-- =====================================================
-- Table: experiences (Work History)
-- =====================================================
CREATE TABLE IF NOT EXISTS experiences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    job_title VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,
    is_current TINYINT(1) DEFAULT 0,
    description TEXT,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample experience data
INSERT INTO experiences (company_name, job_title, location, start_date, end_date, is_current, description, display_order) VALUES
('Tech Solutions Sdn Bhd', 'Senior Developer', 'Kuala Lumpur, Malaysia', '2022-01-01', NULL, 1, '- Led development of enterprise web applications\n- Mentored junior developers\n- Implemented CI/CD pipelines', 1),
('Digital Agency Co', 'Web Developer', 'Petaling Jaya, Malaysia', '2019-06-01', '2021-12-31', 0, '- Developed custom WordPress themes\n- Built REST APIs with Laravel\n- Managed client projects', 2);

-- =====================================================
-- Table: education (Academic Background)
-- =====================================================
CREATE TABLE IF NOT EXISTS education (
    id INT AUTO_INCREMENT PRIMARY KEY,
    institution VARCHAR(255) NOT NULL,
    degree VARCHAR(255) NOT NULL,
    field_of_study VARCHAR(255),
    location VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample education data
INSERT INTO education (institution, degree, field_of_study, location, start_date, end_date, display_order) VALUES
('University of Malaya', 'Bachelor of Computer Science', 'Software Engineering', 'Kuala Lumpur, Malaysia', '2015-09-01', '2019-06-30', 1);

-- =====================================================
-- Table: skills (Technical & Soft Skills)
-- =====================================================
CREATE TABLE IF NOT EXISTS skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    proficiency_level ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert') DEFAULT 'Intermediate',
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample skills data
INSERT INTO skills (skill_name, category, proficiency_level, display_order) VALUES
('PHP', 'Programming', 'Expert', 1),
('JavaScript', 'Programming', 'Advanced', 2),
('MySQL', 'Database', 'Advanced', 3),
('Laravel', 'Framework', 'Expert', 4),
('Vue.js', 'Framework', 'Advanced', 5),
('HTML/CSS', 'Frontend', 'Expert', 6),
('Git', 'Tools', 'Advanced', 7),
('REST API', 'Backend', 'Advanced', 8);

-- =====================================================
-- Table: certifications (Professional Certifications)
-- =====================================================
CREATE TABLE IF NOT EXISTS certifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cert_name VARCHAR(255) NOT NULL,
    issuing_org VARCHAR(255) NOT NULL,
    issue_date DATE,
    expiry_date DATE,
    credential_url VARCHAR(500),
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample certification data
INSERT INTO certifications (cert_name, issuing_org, issue_date, display_order) VALUES
('AWS Certified Developer', 'Amazon Web Services', '2023-03-15', 1),
('PHP Certified Developer', 'Zend Technologies', '2022-08-20', 2);

-- =====================================================
-- Table: projects (Portfolio Projects)
-- =====================================================
CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,
    technologies_used VARCHAR(500),
    project_url VARCHAR(500),
    start_date DATE,
    end_date DATE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample project data
INSERT INTO projects (project_name, description, technologies_used, project_url, start_date, end_date, display_order) VALUES
('E-Commerce Platform', 'Built a complete e-commerce solution with payment integration', 'Laravel, Vue.js, MySQL, Stripe', 'https://github.com/example/ecommerce', '2023-01-01', '2023-06-30', 1),
('Task Management System', 'Developed a collaborative task management application', 'PHP, JavaScript, MySQL, Bootstrap', 'https://github.com/example/taskmanager', '2022-06-01', '2022-12-31', 2);
