-- =====================================================
-- RescueHub Database Schema
-- For: 3rd Year College Capstone Project
-- Database: MySQL 8.0 or newer (recommended)
--
-- Requires 8.0+ for: CHECK constraints, functional indexes
--   (e.g. DATE(created_at)), reliable INFORMATION_SCHEMA behavior.
-- Tested against InnoDB + utf8mb4.
-- =====================================================

-- Drop database if exists (BE CAREFUL - only use in development)
-- DROP DATABASE IF EXISTS rescuehub_db;

-- Create database
CREATE DATABASE IF NOT EXISTS u721144579_rescuehub
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE u721144579_rescuehub;

-- =====================================================
-- 1. CORE TABLES
-- =====================================================            

-- 1.1 Barangays Table
CREATE TABLE barangays (
    barangay_id INT AUTO_INCREMENT PRIMARY KEY,
    barangay_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL DEFAULT 'Bacolod',
    province VARCHAR(50) NOT NULL DEFAULT 'Negros Occidental',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_barangay (barangay_name, city)
) ENGINE=InnoDB;

-- 1.2 Roles Table
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 1.3 Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    barangay_id INT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    mobile_number VARCHAR(15) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    status ENUM('active', 'suspended', 'inactive') DEFAULT 'active',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT,
    FOREIGN KEY (barangay_id) REFERENCES barangays(barangay_id) ON DELETE SET NULL,
    -- Ensure at least one contact method is provided
    CONSTRAINT chk_contact CHECK (
        email IS NOT NULL OR mobile_number IS NOT NULL
    )
) ENGINE=InnoDB;

-- =====================================================
-- 2. HAZARD REPORTING TABLES
-- =====================================================

-- 2.1 Hazard Types Table
CREATE TABLE hazard_types (
    hazard_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon_name VARCHAR(50),
    color_code VARCHAR(7) DEFAULT '#FF0000', -- Hex color for map markers
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2.2 Report Statuses Table
CREATE TABLE report_statuses (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    color_code VARCHAR(7) DEFAULT '#808080', -- Gray default
    sort_order INT DEFAULT 0,
    is_terminal BOOLEAN DEFAULT FALSE, -- Is this a final status?
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2.3 Hazard Reports Table (Main)
CREATE TABLE hazard_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_user_id INT NOT NULL,
    barangay_id INT NOT NULL,
    hazard_type_id INT NOT NULL,
    current_status_id INT NOT NULL,
    title VARCHAR(200),
    description TEXT,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    location_text VARCHAR(255),
    report_source ENUM('online', 'offline_sync') DEFAULT 'online',
    severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    is_anonymous BOOLEAN DEFAULT FALSE,
    -- Denormalized count: maintain ONLY via report_upvotes + trg_update_report_upvotes / trg_decrease_report_upvotes (do not UPDATE this column manually)
    upvotes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (reporter_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (barangay_id) REFERENCES barangays(barangay_id) ON DELETE RESTRICT,
    FOREIGN KEY (hazard_type_id) REFERENCES hazard_types(hazard_type_id) ON DELETE RESTRICT,
    FOREIGN KEY (current_status_id) REFERENCES report_statuses(status_id) ON DELETE RESTRICT,
    INDEX idx_location (latitude, longitude),
    INDEX idx_status (current_status_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- 2.4 Report Photos Table
CREATE TABLE report_photos (
    photo_id INT AUTO_INCREMENT PRIMARY KEY,
    report_id INT NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(255),
    file_size INT, -- in bytes
    is_primary BOOLEAN DEFAULT FALSE,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES hazard_reports(report_id) ON DELETE CASCADE,
    INDEX idx_report (report_id)
) ENGINE=InnoDB;

-- =====================================================
-- 3. STATUS HISTORY & AUDIT TABLES
-- =====================================================

-- 3.1 Report Status History (Audit Trail)
CREATE TABLE report_status_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    report_id INT NOT NULL,
    changed_by_user_id INT NOT NULL,
    old_status_id INT,
    new_status_id INT NOT NULL,
    remarks TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES hazard_reports(report_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (old_status_id) REFERENCES report_statuses(status_id) ON DELETE RESTRICT,
    FOREIGN KEY (new_status_id) REFERENCES report_statuses(status_id) ON DELETE RESTRICT,
    INDEX idx_report_history (report_id, changed_at)
) ENGINE=InnoDB;

-- =====================================================
-- 4. ASSIGNMENT & RESPONSE TRACKING
-- =====================================================

-- 4.1 Incident Assignments
CREATE TABLE incident_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    report_id INT NOT NULL,
    assigned_to_user_id INT NOT NULL,
    assigned_by_user_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_notes TEXT,
    arrived_at TIMESTAMP NULL,
    resolved_at TIMESTAMP NULL,
    status ENUM('assigned', 'en_route', 'on_site', 'resolved', 'cancelled') DEFAULT 'assigned',
    FOREIGN KEY (report_id) REFERENCES hazard_reports(report_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (assigned_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    INDEX idx_assignments (report_id, assigned_to_user_id)
) ENGINE=InnoDB;

-- =====================================================
-- 5. VOLUNTEER MANAGEMENT
-- =====================================================

-- 5.1 Volunteer Profiles (extends users)
CREATE TABLE volunteer_profiles (
    volunteer_id INT PRIMARY KEY, -- Same as user_id (1-to-1)
    availability_notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    verified_by_official_id INT,
    verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (volunteer_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by_official_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 5.2 Volunteer Skills (normalized)
CREATE TABLE volunteer_skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    volunteer_id INT NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    proficiency ENUM('beginner', 'intermediate', 'expert') DEFAULT 'intermediate',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (volunteer_id) REFERENCES volunteer_profiles(volunteer_id) ON DELETE CASCADE,
    UNIQUE KEY unique_volunteer_skill (volunteer_id, skill_name)
) ENGINE=InnoDB;

-- 5.3 Volunteer Availability Schedule (optional)
CREATE TABLE volunteer_availability (
    availability_id INT AUTO_INCREMENT PRIMARY KEY,
    volunteer_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    start_time TIME,
    end_time TIME,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (volunteer_id) REFERENCES volunteer_profiles(volunteer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- 6. NOTIFICATIONS
-- =====================================================

-- 6.1 Notifications Table
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    report_id INT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    notif_type ENUM('nearby_hazard', 'status_update', 'assignment', 'system', 'volunteer_call') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (report_id) REFERENCES hazard_reports(report_id) ON DELETE SET NULL,
    INDEX idx_user_notifications (user_id, is_read, created_at)
) ENGINE=InnoDB;

-- 6.2 Device Tokens for Push Notifications
CREATE TABLE device_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    device_token VARCHAR(255) NOT NULL,
    device_type ENUM('android', 'ios', 'web') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_device (user_id, device_token)
) ENGINE=InnoDB;

-- =====================================================
-- 7. EXPORT LOGS & REPORTING
-- =====================================================

-- 7.1 Export Logs
CREATE TABLE export_logs (
    export_id INT AUTO_INCREMENT PRIMARY KEY,
    generated_by_user_id INT NOT NULL,
    barangay_id INT,
    filters_used JSON, -- Store filter criteria as JSON
    file_url VARCHAR(500),
    file_name VARCHAR(255),
    record_count INT,
    export_format ENUM('pdf', 'excel', 'csv') DEFAULT 'pdf',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (generated_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (barangay_id) REFERENCES barangays(barangay_id) ON DELETE SET NULL,
    INDEX idx_export_user (generated_by_user_id, created_at)
) ENGINE=InnoDB;

-- =====================================================
-- 8. ADDITIONAL FEATURES
-- =====================================================

-- 8.1 Resource Inventory (for equipment tracking - extends FR-01)
CREATE TABLE resources (
    resource_id INT AUTO_INCREMENT PRIMARY KEY,
    barangay_id INT NOT NULL,
    resource_name VARCHAR(100) NOT NULL,
    resource_type ENUM('boat', 'generator', 'first_aid', 'vehicle', 'communication', 'other') NOT NULL,
    quantity INT DEFAULT 1,
    available_quantity INT DEFAULT 1,
    location_description TEXT,
    contact_person VARCHAR(100),
    contact_number VARCHAR(15),
    status ENUM('available', 'in_use', 'maintenance', 'unavailable') DEFAULT 'available',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (barangay_id) REFERENCES barangays(barangay_id) ON DELETE CASCADE,
    INDEX idx_resource_status (barangay_id, status)
) ENGINE=InnoDB;

-- 8.2 Report Upvotes (to prioritize critical issues)
-- Source of truth for votes; hazard_reports.upvotes is maintained by triggers on this table.
CREATE TABLE report_upvotes (
    upvote_id INT AUTO_INCREMENT PRIMARY KEY,
    report_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES hazard_reports(report_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_upvote (report_id, user_id)
) ENGINE=InnoDB;

-- =====================================================
-- INSERT INITIAL DATA
-- =====================================================

-- Insert Barangays (Bacolod City)
INSERT INTO barangays (barangay_name, city, province) VALUES
('Barangay 1', 'Bacolod', 'Negros Occidental'),
('Barangay 2', 'Bacolod', 'Negros Occidental'),
('Barangay 3', 'Bacolod', 'Negros Occidental'),
('Barangay 4', 'Bacolod', 'Negros Occidental'),
('Barangay 5', 'Bacolod', 'Negros Occidental'),
('Barangay 6', 'Bacolod', 'Negros Occidental'),
('Barangay 7', 'Bacolod', 'Negros Occidental'),
('Barangay 8', 'Bacolod', 'Negros Occidental'),
('Barangay 9', 'Bacolod', 'Negros Occidental'),
('Barangay 10', 'Bacolod', 'Negros Occidental'),
('Barangay 11', 'Bacolod', 'Negros Occidental'),
('Barangay 12', 'Bacolod', 'Negros Occidental'),
('Barangay 13', 'Bacolod', 'Negros Occidental'),
('Barangay 14', 'Bacolod', 'Negros Occidental'),
('Barangay 15', 'Bacolod', 'Negros Occidental'),
('Barangay 16', 'Bacolod', 'Negros Occidental'),
('Barangay 17', 'Bacolod', 'Negros Occidental'),
('Barangay 18', 'Bacolod', 'Negros Occidental'),
('Barangay 19', 'Bacolod', 'Negros Occidental'),
('Barangay 20', 'Bacolod', 'Negros Occidental'),
('Barangay 21', 'Bacolod', 'Negros Occidental'),
('Barangay 22', 'Bacolod', 'Negros Occidental'),
('Barangay 23', 'Bacolod', 'Negros Occidental'),
('Barangay 24', 'Bacolod', 'Negros Occidental'),
('Barangay 25', 'Bacolod', 'Negros Occidental'),
('Barangay 26', 'Bacolod', 'Negros Occidental'),
('Barangay 27', 'Bacolod', 'Negros Occidental'),
('Barangay 28', 'Bacolod', 'Negros Occidental'),
('Barangay 29', 'Bacolod', 'Negros Occidental'),
('Barangay 30', 'Bacolod', 'Negros Occidental'),
('Barangay 31', 'Bacolod', 'Negros Occidental'),
('Barangay 32', 'Bacolod', 'Negros Occidental'),
('Barangay 33', 'Bacolod', 'Negros Occidental'),
('Barangay 34', 'Bacolod', 'Negros Occidental'),
('Barangay 35', 'Bacolod', 'Negros Occidental'),
('Barangay 36', 'Bacolod', 'Negros Occidental'),
('Barangay 37', 'Bacolod', 'Negros Occidental'),
('Barangay 38', 'Bacolod', 'Negros Occidental'),
('Barangay 39', 'Bacolod', 'Negros Occidental'),
('Barangay 40', 'Bacolod', 'Negros Occidental'),
('Barangay 41', 'Bacolod', 'Negros Occidental');

-- Insert Roles
INSERT INTO roles (role_name, description) VALUES
('Resident', 'Regular community member who can report hazards'),
('Official', 'Barangay official who can manage reports'),
('LGU', 'Local Government Unit personnel with broader access'),
('Volunteer', 'Registered community volunteer'),
('Admin', 'System administrator with full access');

-- Insert Hazard Types
INSERT INTO hazard_types (name, description, icon_name, color_code) VALUES
('Flood', 'Flooded areas, rising water levels', 'flood', '#2196F3'),
('Low-hanging Wires', 'Electrical wires hanging dangerously low', 'wires', '#FF9800'),
('Landslide', 'Soil erosion or landslide risk', 'landslide', '#795548'),
('Fire', 'Fire incidents or fire hazards', 'fire', '#F44336'),
('Fallen Tree', 'Trees blocking roads or causing damage', 'tree', '#4CAF50'),
('Structural Collapse', 'Building or infrastructure damage', 'building', '#9C27B0'),
('Road Blockage', 'Roads blocked by debris or water', 'road', '#607D8B'),
('Power Outage', 'Electrical power interruption', 'power', '#FFC107'),
('Gas Leak', 'Suspected gas or chemical leak', 'gas', '#FF5722'),
('Medical Emergency', 'Medical assistance needed', 'medical', '#E91E63');

-- Insert Report Statuses
INSERT INTO report_statuses (status_name, description, color_code, sort_order, is_terminal) VALUES
('Pending', 'Report submitted, awaiting review', '#FFC107', 10, FALSE),
('Under Investigation', 'Officials are verifying the report', '#2196F3', 20, FALSE),
('Needs Utility Support', 'Requires assistance from utility companies', '#9C27B0', 25, FALSE),
('In Progress', 'Response team has been dispatched', '#FF9800', 30, FALSE),
('Cleared', 'Hazard has been resolved', '#4CAF50', 40, TRUE),
('Rejected', 'Report is invalid or duplicate', '#F44336', 50, TRUE),
('Cannot be Resolved', 'Beyond current capabilities', '#9E9E9E', 60, TRUE);

-- =====================================================
-- CREATE USEFUL VIEWS
-- =====================================================

-- View: Active Hazards with Details
-- Sort in the application or outer query; MySQL does not guarantee ORDER BY inside a view.
-- Example: SELECT * FROM view_active_hazards v ORDER BY
--   CASE v.severity WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 WHEN 'low' THEN 4 END,
--   v.created_at DESC;
CREATE VIEW view_active_hazards AS
SELECT 
    hr.report_id,
    hr.title,
    hr.description,
    ht.name AS hazard_type,
    ht.color_code AS hazard_color,
    rs.status_name AS current_status,
    rs.color_code AS status_color,
    hr.severity,
    hr.latitude,
    hr.longitude,
    hr.location_text,
    b.barangay_name,
    u.full_name AS reporter_name,
    hr.created_at,
    TIMESTAMPDIFF(HOUR, hr.created_at, NOW()) AS hours_since_report
FROM hazard_reports hr
JOIN hazard_types ht ON hr.hazard_type_id = ht.hazard_type_id
JOIN report_statuses rs ON hr.current_status_id = rs.status_id
JOIN barangays b ON hr.barangay_id = b.barangay_id
JOIN users u ON hr.reporter_user_id = u.user_id
WHERE rs.is_terminal = FALSE;

-- View: Barangay Statistics Dashboard
CREATE VIEW view_barangay_stats AS
SELECT 
    b.barangay_id,
    b.barangay_name,
    COUNT(DISTINCT u.user_id) AS total_residents,
    COUNT(DISTINCT v.volunteer_id) AS total_volunteers,
    COUNT(DISTINCT hr.report_id) AS total_reports,
    SUM(CASE WHEN rs.is_terminal = FALSE THEN 1 ELSE 0 END) AS active_reports,
    SUM(CASE WHEN rs.status_name = 'Cleared' THEN 1 ELSE 0 END) AS resolved_reports,
    SUM(CASE WHEN hr.severity = 'critical' AND rs.is_terminal = FALSE THEN 1 ELSE 0 END) AS critical_hazards,
    MAX(hr.created_at) AS latest_report
FROM barangays b
LEFT JOIN users u ON b.barangay_id = u.barangay_id
LEFT JOIN volunteer_profiles v ON u.user_id = v.volunteer_id
LEFT JOIN hazard_reports hr ON b.barangay_id = hr.barangay_id
LEFT JOIN report_statuses rs ON hr.current_status_id = rs.status_id
GROUP BY b.barangay_id, b.barangay_name;

-- =====================================================
-- CREATE STORED PROCEDURES
-- =====================================================

-- Procedure: Submit New Hazard Report (with status history)
DELIMITER $$
CREATE PROCEDURE sp_submit_hazard_report(
    IN p_user_id INT,
    IN p_barangay_id INT,
    IN p_hazard_type_id INT,
    IN p_title VARCHAR(200),
    IN p_description TEXT,
    IN p_latitude DECIMAL(10,8),
    IN p_longitude DECIMAL(11,8),
    IN p_location_text VARCHAR(255),
    IN p_severity VARCHAR(10)
)
BEGIN
    DECLARE v_report_id INT;
    DECLARE v_pending_status_id INT;
    
    -- Get pending status ID
    SELECT status_id INTO v_pending_status_id 
    FROM report_statuses 
    WHERE status_name = 'Pending'
    LIMIT 1;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Insert hazard report
    INSERT INTO hazard_reports (
        reporter_user_id, barangay_id, hazard_type_id, 
        current_status_id, title, description, 
        latitude, longitude, location_text, severity
    ) VALUES (
        p_user_id, p_barangay_id, p_hazard_type_id,
        v_pending_status_id, p_title, p_description,
        p_latitude, p_longitude, p_location_text, p_severity
    );
    
    SET v_report_id = LAST_INSERT_ID();
    
    -- Insert initial status history
    INSERT INTO report_status_history (
        report_id, changed_by_user_id, 
        old_status_id, new_status_id, remarks
    ) VALUES (
        v_report_id, p_user_id,
        NULL, v_pending_status_id, 'Initial report submission'
    );
    
    -- Create notification for barangay officials
    INSERT INTO notifications (user_id, report_id, title, message, notif_type)
    SELECT 
        u.user_id,
        v_report_id,
        'New Hazard Report',
        CONCAT('New ', ht.name, ' reported in your barangay'),
        'system'
    FROM users u
    JOIN hazard_reports hr ON hr.report_id = v_report_id
    JOIN hazard_types ht ON ht.hazard_type_id = hr.hazard_type_id
    WHERE u.barangay_id = p_barangay_id 
    AND u.role_id IN (SELECT role_id FROM roles WHERE role_name IN ('Official', 'LGU', 'Admin'));
    
    COMMIT;
    
    SELECT v_report_id AS report_id;
END$$
DELIMITER ;

-- Procedure: Update Report Status (with history)
DELIMITER $$
CREATE PROCEDURE sp_update_report_status(
    IN p_report_id INT,
    IN p_changed_by_user_id INT,
    IN p_new_status_id INT,
    IN p_remarks TEXT
)
BEGIN
    DECLARE v_old_status_id INT;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get current status
    SELECT current_status_id INTO v_old_status_id
    FROM hazard_reports
    WHERE report_id = p_report_id
    FOR UPDATE;
    
    -- Insert history
    INSERT INTO report_status_history (
        report_id, changed_by_user_id, 
        old_status_id, new_status_id, remarks
    ) VALUES (
        p_report_id, p_changed_by_user_id,
        v_old_status_id, p_new_status_id, p_remarks
    );
    
    -- Update report
    UPDATE hazard_reports 
    SET current_status_id = p_new_status_id
    WHERE report_id = p_report_id;
    
    -- Notify reporter
    INSERT INTO notifications (user_id, report_id, title, message, notif_type)
    SELECT 
        reporter_user_id,
        p_report_id,
        'Report Status Updated',
        CONCAT('Your report status has been updated to ', rs.status_name),
        'status_update'
    FROM hazard_reports hr
    JOIN report_statuses rs ON rs.status_id = p_new_status_id
    WHERE hr.report_id = p_report_id;
    
    COMMIT;
END$$
DELIMITER ;

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Additional indexes for common queries
CREATE INDEX idx_hazard_reports_location ON hazard_reports(barangay_id, hazard_type_id, current_status_id);
CREATE INDEX idx_hazard_reports_date ON hazard_reports(DATE(created_at));
CREATE INDEX idx_notifications_read ON notifications(user_id, is_read);
CREATE INDEX idx_users_role ON users(role_id, status);
CREATE INDEX idx_volunteer_skills ON volunteer_skills(volunteer_id, proficiency);

-- Full-text search indexes
CREATE FULLTEXT INDEX idx_hazard_search ON hazard_reports(title, description, location_text);
CREATE FULLTEXT INDEX idx_user_search ON users(full_name, email);

-- =====================================================
-- CREATE TRIGGERS
-- =====================================================

-- Trigger: Update report upvotes count (paired with report_upvotes table; do not UPDATE hazard_reports.upvotes directly)
DELIMITER $$
CREATE TRIGGER trg_update_report_upvotes
AFTER INSERT ON report_upvotes
FOR EACH ROW
BEGIN
    UPDATE hazard_reports 
    SET upvotes = upvotes + 1 
    WHERE report_id = NEW.report_id;
END$$
DELIMITER ;

-- Trigger: Decrease upvotes on delete
DELIMITER $$
CREATE TRIGGER trg_decrease_report_upvotes
AFTER DELETE ON report_upvotes
FOR EACH ROW
BEGIN
    UPDATE hazard_reports 
    SET upvotes = upvotes - 1 
    WHERE report_id = OLD.report_id;
END$$
DELIMITER ;

-- =====================================================
-- SAMPLE INSERT STATEMENTS (for testing)
-- =====================================================

-- Insert sample users (password = 'password123' hashed with bcrypt)
-- Note: You'll need to generate actual password hashes in your PHP code
-- These are just placeholder hashes
INSERT INTO users (role_id, barangay_id, full_name, email, mobile_number, password_hash, is_verified, status) VALUES
(1, 1, 'Juan Dela Cruz', 'juan@example.com', '09171234567', '$2y$10$YourHashedPasswordHere', TRUE, 'active'),
(2, 1, 'Maria Santos', 'maria.official@example.com', '09181234567', '$2y$10$YourHashedPasswordHere', TRUE, 'active'),
(4, 1, 'Pedro Gonzales', 'pedro.volunteer@example.com', '09191234567', '$2y$10$YourHashedPasswordHere', TRUE, 'active');

-- Insert sample hazard report
CALL sp_submit_hazard_report(
    1, -- user_id
    1, -- barangay_id
    2, -- hazard_type_id (Low-hanging wires)
    'Low wires along Mabini Street', -- title
    'Electrical wires hanging dangerously low near the school', -- description
    10.6765, -- latitude (Bacolod approx)
    122.9509, -- longitude (Bacolod approx)
    'Near Mabini Elementary School', -- location_text
    'high' -- severity
);

-- =====================================================
-- GRANT PERMISSIONS (adjust based on your PHP application user)
-- =====================================================

-- Create application user (replace with your actual credentials)
-- CREATE USER 'rescuehub_app'@'localhost' IDENTIFIED BY 'strong_password_here';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON rescuehub_db.* TO 'rescuehub_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE rescuehub_db.sp_submit_hazard_report TO 'rescuehub_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE rescuehub_db.sp_update_report_status TO 'rescuehub_app'@'localhost';
-- FLUSH PRIVILEGES;

-- =====================================================
-- DATABASE COMPLETED
-- =====================================================