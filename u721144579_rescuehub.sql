-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Apr 06, 2026 at 07:56 PM
-- Server version: 11.8.6-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u721144579_rescuehub`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`u721144579_rescuehubuser`@`127.0.0.1` PROCEDURE `sp_submit_hazard_report` (IN `p_user_id` INT, IN `p_barangay_id` INT, IN `p_hazard_type_id` INT, IN `p_title` VARCHAR(200), IN `p_description` TEXT, IN `p_latitude` DECIMAL(10,8), IN `p_longitude` DECIMAL(11,8), IN `p_location_text` VARCHAR(255), IN `p_severity` VARCHAR(10))   BEGIN
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

CREATE DEFINER=`u721144579_rescuehubuser`@`127.0.0.1` PROCEDURE `sp_update_report_status` (IN `p_report_id` INT, IN `p_changed_by_user_id` INT, IN `p_new_status_id` INT, IN `p_remarks` TEXT)   BEGIN
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

-- --------------------------------------------------------

--
-- Table structure for table `barangays`
--

CREATE TABLE `barangays` (
  `barangay_id` int(11) NOT NULL,
  `barangay_name` varchar(100) NOT NULL,
  `city` varchar(50) NOT NULL DEFAULT 'Bacolod',
  `province` varchar(50) NOT NULL DEFAULT 'Negros Occidental',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `barangays`
--

INSERT INTO `barangays` (`barangay_id`, `barangay_name`, `city`, `province`, `created_at`, `updated_at`) VALUES
(1, 'Barangay 1', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(2, 'Barangay 2', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(3, 'Barangay 3', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(4, 'Barangay 4', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(5, 'Barangay 5', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(6, 'Barangay 6', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(7, 'Barangay 7', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(8, 'Barangay 8', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(9, 'Barangay 9', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(10, 'Barangay 10', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(11, 'Barangay 11', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(12, 'Barangay 12', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(13, 'Barangay 13', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(14, 'Barangay 14', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(15, 'Barangay 15', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(16, 'Barangay 16', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(17, 'Barangay 17', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(18, 'Barangay 18', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(19, 'Barangay 19', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(20, 'Barangay 20', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(21, 'Barangay 21', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(22, 'Barangay 22', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(23, 'Barangay 23', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(24, 'Barangay 24', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(25, 'Barangay 25', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(26, 'Barangay 26', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(27, 'Barangay 27', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(28, 'Barangay 28', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(29, 'Barangay 29', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(30, 'Barangay 30', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(31, 'Barangay 31', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(32, 'Barangay 32', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(33, 'Barangay 33', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(34, 'Barangay 34', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(35, 'Barangay 35', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(36, 'Barangay 36', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(37, 'Barangay 37', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(38, 'Barangay 38', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(39, 'Barangay 39', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(40, 'Barangay 40', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31'),
(41, 'Barangay 41', 'Bacolod', 'Negros Occidental', '2026-03-28 12:09:31', '2026-03-28 12:09:31');

-- --------------------------------------------------------

--
-- Table structure for table `device_tokens`
--

CREATE TABLE `device_tokens` (
  `token_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `device_token` varchar(255) NOT NULL,
  `device_type` enum('android','ios','web') NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `last_used` timestamp NULL DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `export_logs`
--

CREATE TABLE `export_logs` (
  `export_id` int(11) NOT NULL,
  `generated_by_user_id` int(11) NOT NULL,
  `barangay_id` int(11) DEFAULT NULL,
  `filters_used` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`filters_used`)),
  `file_url` varchar(500) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `record_count` int(11) DEFAULT NULL,
  `export_format` enum('pdf','excel','csv') DEFAULT 'pdf',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hazard_reports`
--

CREATE TABLE `hazard_reports` (
  `report_id` int(11) NOT NULL,
  `reporter_user_id` int(11) NOT NULL,
  `barangay_id` int(11) NOT NULL,
  `hazard_type_id` int(11) NOT NULL,
  `current_status_id` int(11) NOT NULL,
  `title` varchar(200) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `location_text` varchar(255) DEFAULT NULL,
  `report_source` enum('online','offline_sync') DEFAULT 'online',
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `is_anonymous` tinyint(1) DEFAULT 0,
  `upvotes` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hazard_types`
--

CREATE TABLE `hazard_types` (
  `hazard_type_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `icon_name` varchar(50) DEFAULT NULL,
  `color_code` varchar(7) DEFAULT '#FF0000',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `hazard_types`
--

INSERT INTO `hazard_types` (`hazard_type_id`, `name`, `description`, `icon_name`, `color_code`, `is_active`, `created_at`) VALUES
(1, 'Flood', 'Flooded areas, rising water levels', 'flood', '#2196F3', 1, '2026-03-28 12:09:31'),
(2, 'Low-hanging Wires', 'Electrical wires hanging dangerously low', 'wires', '#FF9800', 1, '2026-03-28 12:09:31'),
(3, 'Landslide', 'Soil erosion or landslide risk', 'landslide', '#795548', 1, '2026-03-28 12:09:31'),
(4, 'Fire', 'Fire incidents or fire hazards', 'fire', '#F44336', 1, '2026-03-28 12:09:31'),
(5, 'Fallen Tree', 'Trees blocking roads or causing damage', 'tree', '#4CAF50', 1, '2026-03-28 12:09:31'),
(6, 'Structural Collapse', 'Building or infrastructure damage', 'building', '#9C27B0', 1, '2026-03-28 12:09:31'),
(7, 'Road Blockage', 'Roads blocked by debris or water', 'road', '#607D8B', 1, '2026-03-28 12:09:31'),
(8, 'Power Outage', 'Electrical power interruption', 'power', '#FFC107', 1, '2026-03-28 12:09:31'),
(9, 'Gas Leak', 'Suspected gas or chemical leak', 'gas', '#FF5722', 1, '2026-03-28 12:09:31'),
(10, 'Medical Emergency', 'Medical assistance needed', 'medical', '#E91E63', 1, '2026-03-28 12:09:31');

-- --------------------------------------------------------

--
-- Table structure for table `incident_assignments`
--

CREATE TABLE `incident_assignments` (
  `assignment_id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `assigned_to_user_id` int(11) NOT NULL,
  `assigned_by_user_id` int(11) NOT NULL,
  `assigned_at` timestamp NULL DEFAULT current_timestamp(),
  `response_notes` text DEFAULT NULL,
  `arrived_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `status` enum('assigned','en_route','on_site','resolved','cancelled') DEFAULT 'assigned'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `report_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `notif_type` enum('nearby_hazard','status_update','assignment','system','volunteer_call') NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `action_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `report_photos`
--

CREATE TABLE `report_photos` (
  `photo_id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `file_url` varchar(500) NOT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `uploaded_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `report_statuses`
--

CREATE TABLE `report_statuses` (
  `status_id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `color_code` varchar(7) DEFAULT '#808080',
  `sort_order` int(11) DEFAULT 0,
  `is_terminal` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `report_statuses`
--

INSERT INTO `report_statuses` (`status_id`, `status_name`, `description`, `color_code`, `sort_order`, `is_terminal`, `created_at`) VALUES
(1, 'Pending', 'Report submitted, awaiting review', '#FFC107', 10, 0, '2026-03-28 12:09:31'),
(2, 'Under Investigation', 'Officials are verifying the report', '#2196F3', 20, 0, '2026-03-28 12:09:31'),
(3, 'Needs Utility Support', 'Requires assistance from utility companies', '#9C27B0', 25, 0, '2026-03-28 12:09:31'),
(4, 'In Progress', 'Response team has been dispatched', '#FF9800', 30, 0, '2026-03-28 12:09:31'),
(5, 'Cleared', 'Hazard has been resolved', '#4CAF50', 40, 1, '2026-03-28 12:09:31'),
(6, 'Rejected', 'Report is invalid or duplicate', '#F44336', 50, 1, '2026-03-28 12:09:31'),
(7, 'Cannot be Resolved', 'Beyond current capabilities', '#9E9E9E', 60, 1, '2026-03-28 12:09:31');

-- --------------------------------------------------------

--
-- Table structure for table `report_status_history`
--

CREATE TABLE `report_status_history` (
  `history_id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `changed_by_user_id` int(11) NOT NULL,
  `old_status_id` int(11) DEFAULT NULL,
  `new_status_id` int(11) NOT NULL,
  `remarks` text DEFAULT NULL,
  `changed_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `report_upvotes`
--

CREATE TABLE `report_upvotes` (
  `upvote_id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `resources`
--

CREATE TABLE `resources` (
  `resource_id` int(11) NOT NULL,
  `barangay_id` int(11) NOT NULL,
  `resource_name` varchar(100) NOT NULL,
  `resource_type` enum('boat','generator','first_aid','vehicle','communication','other') NOT NULL,
  `quantity` int(11) DEFAULT 1,
  `available_quantity` int(11) DEFAULT 1,
  `location_description` text DEFAULT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `contact_number` varchar(15) DEFAULT NULL,
  `status` enum('available','in_use','maintenance','unavailable') DEFAULT 'available',
  `last_updated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`, `description`, `created_at`) VALUES
(1, 'Resident', 'Regular community member who can report hazards', '2026-03-28 12:09:31'),
(2, 'Official', 'Barangay official who can manage reports', '2026-03-28 12:09:31'),
(3, 'LGU', 'Local Government Unit personnel with broader access', '2026-03-28 12:09:31'),
(4, 'Volunteer', 'Registered community volunteer', '2026-03-28 12:09:31'),
(5, 'Admin', 'System administrator with full access', '2026-03-28 12:09:31');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `barangay_id` int(11) DEFAULT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `mobile_number` varchar(15) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `status` enum('active','suspended','inactive') DEFAULT 'active',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `role_id`, `barangay_id`, `full_name`, `email`, `mobile_number`, `password_hash`, `is_verified`, `status`, `last_login`, `created_at`, `updated_at`) VALUES
(1, 3, 27, 'User 1', 'user1@example.com', '09179846344', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 'active', '2026-04-05 20:43:09', '2026-03-28 13:55:13', '2026-04-05 20:43:09'),
(2, 5, 35, 'User 2', 'user2@example.com', '09173240032', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(3, 1, 22, 'User 3', 'user3@example.com', '09173351313', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(4, 1, 20, 'User 4', 'user4@example.com', '09170624252', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(5, 5, 14, 'User 5', 'user5@example.com', '09179454701', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(6, 4, 35, 'User 6', 'user6@example.com', '09179521313', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(7, 2, 21, 'User 7', 'user7@example.com', '09176428182', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(8, 4, 33, 'User 8', 'user8@example.com', '09177179154', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(9, 2, 39, 'User 9', 'user9@example.com', '09170771427', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(10, 3, 20, 'User 10', 'user10@example.com', '09177877086', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(11, 3, 4, 'User 11', 'user11@example.com', '09179338343', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(12, 3, 15, 'User 12', 'user12@example.com', '09174386175', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(13, 1, 20, 'User 13', 'user13@example.com', '09178758819', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(14, 5, 10, 'User 14', 'user14@example.com', '09172278824', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(15, 3, 25, 'User 15', 'user15@example.com', '09175817852', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(16, 1, 40, 'User 16', 'user16@example.com', '09173899986', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(17, 1, 6, 'User 17', 'user17@example.com', '09174916937', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(18, 1, 33, 'User 18', 'user18@example.com', '09178055360', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(19, 4, 34, 'User 19', 'user19@example.com', '09171671584', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
(20, 2, 15, 'User 20', 'user20@example.com', '09176232049', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_active_hazards`
-- (See below for the actual view)
--
CREATE TABLE `view_active_hazards` (
`report_id` int(11)
,`title` varchar(200)
,`description` text
,`hazard_type` varchar(50)
,`hazard_color` varchar(7)
,`current_status` varchar(50)
,`status_color` varchar(7)
,`severity` enum('low','medium','high','critical')
,`latitude` decimal(10,8)
,`longitude` decimal(11,8)
,`location_text` varchar(255)
,`barangay_name` varchar(100)
,`reporter_name` varchar(100)
,`created_at` timestamp
,`hours_since_report` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_barangay_stats`
-- (See below for the actual view)
--
CREATE TABLE `view_barangay_stats` (
`barangay_id` int(11)
,`barangay_name` varchar(100)
,`total_residents` bigint(21)
,`total_volunteers` bigint(21)
,`total_reports` bigint(21)
,`active_reports` decimal(22,0)
,`resolved_reports` decimal(22,0)
,`critical_hazards` decimal(22,0)
,`latest_report` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_availability`
--

CREATE TABLE `volunteer_availability` (
  `availability_id` int(11) NOT NULL,
  `volunteer_id` int(11) NOT NULL,
  `day_of_week` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_profiles`
--

CREATE TABLE `volunteer_profiles` (
  `volunteer_id` int(11) NOT NULL,
  `availability_notes` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `verified_by_official_id` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_skills`
--

CREATE TABLE `volunteer_skills` (
  `skill_id` int(11) NOT NULL,
  `volunteer_id` int(11) NOT NULL,
  `skill_name` varchar(100) NOT NULL,
  `proficiency` enum('beginner','intermediate','expert') DEFAULT 'intermediate',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `barangays`
--
ALTER TABLE `barangays`
  ADD PRIMARY KEY (`barangay_id`),
  ADD UNIQUE KEY `unique_barangay` (`barangay_name`,`city`);

--
-- Indexes for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD PRIMARY KEY (`token_id`),
  ADD UNIQUE KEY `unique_device` (`user_id`,`device_token`);

--
-- Indexes for table `export_logs`
--
ALTER TABLE `export_logs`
  ADD PRIMARY KEY (`export_id`),
  ADD KEY `barangay_id` (`barangay_id`),
  ADD KEY `idx_export_user` (`generated_by_user_id`,`created_at`);

--
-- Indexes for table `hazard_reports`
--
ALTER TABLE `hazard_reports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `reporter_user_id` (`reporter_user_id`),
  ADD KEY `hazard_type_id` (`hazard_type_id`),
  ADD KEY `idx_location` (`latitude`,`longitude`),
  ADD KEY `idx_status` (`current_status_id`),
  ADD KEY `idx_created` (`created_at`),
  ADD KEY `idx_hazard_reports_location` (`barangay_id`,`hazard_type_id`,`current_status_id`);

--
-- Indexes for table `hazard_types`
--
ALTER TABLE `hazard_types`
  ADD PRIMARY KEY (`hazard_type_id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `incident_assignments`
--
ALTER TABLE `incident_assignments`
  ADD PRIMARY KEY (`assignment_id`),
  ADD KEY `assigned_to_user_id` (`assigned_to_user_id`),
  ADD KEY `assigned_by_user_id` (`assigned_by_user_id`),
  ADD KEY `idx_assignments` (`report_id`,`assigned_to_user_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `report_id` (`report_id`),
  ADD KEY `idx_user_notifications` (`user_id`,`is_read`,`created_at`);

--
-- Indexes for table `report_photos`
--
ALTER TABLE `report_photos`
  ADD PRIMARY KEY (`photo_id`),
  ADD KEY `idx_report` (`report_id`);

--
-- Indexes for table `report_statuses`
--
ALTER TABLE `report_statuses`
  ADD PRIMARY KEY (`status_id`),
  ADD UNIQUE KEY `status_name` (`status_name`);

--
-- Indexes for table `report_status_history`
--
ALTER TABLE `report_status_history`
  ADD PRIMARY KEY (`history_id`),
  ADD KEY `changed_by_user_id` (`changed_by_user_id`),
  ADD KEY `old_status_id` (`old_status_id`),
  ADD KEY `new_status_id` (`new_status_id`),
  ADD KEY `idx_report_history` (`report_id`,`changed_at`);

--
-- Indexes for table `report_upvotes`
--
ALTER TABLE `report_upvotes`
  ADD PRIMARY KEY (`upvote_id`),
  ADD UNIQUE KEY `unique_upvote` (`report_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `resources`
--
ALTER TABLE `resources`
  ADD PRIMARY KEY (`resource_id`),
  ADD KEY `idx_resource_status` (`barangay_id`,`status`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `role_name` (`role_name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `mobile_number` (`mobile_number`),
  ADD KEY `role_id` (`role_id`),
  ADD KEY `barangay_id` (`barangay_id`);

--
-- Indexes for table `volunteer_availability`
--
ALTER TABLE `volunteer_availability`
  ADD PRIMARY KEY (`availability_id`),
  ADD KEY `volunteer_id` (`volunteer_id`);

--
-- Indexes for table `volunteer_profiles`
--
ALTER TABLE `volunteer_profiles`
  ADD PRIMARY KEY (`volunteer_id`),
  ADD KEY `verified_by_official_id` (`verified_by_official_id`);

--
-- Indexes for table `volunteer_skills`
--
ALTER TABLE `volunteer_skills`
  ADD PRIMARY KEY (`skill_id`),
  ADD UNIQUE KEY `unique_volunteer_skill` (`volunteer_id`,`skill_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `barangays`
--
ALTER TABLE `barangays`
  MODIFY `barangay_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `device_tokens`
--
ALTER TABLE `device_tokens`
  MODIFY `token_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `export_logs`
--
ALTER TABLE `export_logs`
  MODIFY `export_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hazard_reports`
--
ALTER TABLE `hazard_reports`
  MODIFY `report_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hazard_types`
--
ALTER TABLE `hazard_types`
  MODIFY `hazard_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `incident_assignments`
--
ALTER TABLE `incident_assignments`
  MODIFY `assignment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `report_photos`
--
ALTER TABLE `report_photos`
  MODIFY `photo_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `report_statuses`
--
ALTER TABLE `report_statuses`
  MODIFY `status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `report_status_history`
--
ALTER TABLE `report_status_history`
  MODIFY `history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `report_upvotes`
--
ALTER TABLE `report_upvotes`
  MODIFY `upvote_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `resources`
--
ALTER TABLE `resources`
  MODIFY `resource_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `volunteer_availability`
--
ALTER TABLE `volunteer_availability`
  MODIFY `availability_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `volunteer_skills`
--
ALTER TABLE `volunteer_skills`
  MODIFY `skill_id` int(11) NOT NULL AUTO_INCREMENT;

-- --------------------------------------------------------

--
-- Structure for view `view_active_hazards`
--
DROP TABLE IF EXISTS `view_active_hazards`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u721144579_rescuehubuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `view_active_hazards`  AS SELECT `hr`.`report_id` AS `report_id`, `hr`.`title` AS `title`, `hr`.`description` AS `description`, `ht`.`name` AS `hazard_type`, `ht`.`color_code` AS `hazard_color`, `rs`.`status_name` AS `current_status`, `rs`.`color_code` AS `status_color`, `hr`.`severity` AS `severity`, `hr`.`latitude` AS `latitude`, `hr`.`longitude` AS `longitude`, `hr`.`location_text` AS `location_text`, `b`.`barangay_name` AS `barangay_name`, `u`.`full_name` AS `reporter_name`, `hr`.`created_at` AS `created_at`, timestampdiff(HOUR,`hr`.`created_at`,current_timestamp()) AS `hours_since_report` FROM ((((`hazard_reports` `hr` join `hazard_types` `ht` on(`hr`.`hazard_type_id` = `ht`.`hazard_type_id`)) join `report_statuses` `rs` on(`hr`.`current_status_id` = `rs`.`status_id`)) join `barangays` `b` on(`hr`.`barangay_id` = `b`.`barangay_id`)) join `users` `u` on(`hr`.`reporter_user_id` = `u`.`user_id`)) WHERE `rs`.`is_terminal` = 0 ;

-- --------------------------------------------------------

--
-- Structure for view `view_barangay_stats`
--
DROP TABLE IF EXISTS `view_barangay_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u721144579_rescuehubuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `view_barangay_stats`  AS SELECT `b`.`barangay_id` AS `barangay_id`, `b`.`barangay_name` AS `barangay_name`, count(distinct `u`.`user_id`) AS `total_residents`, count(distinct `v`.`volunteer_id`) AS `total_volunteers`, count(distinct `hr`.`report_id`) AS `total_reports`, sum(case when `rs`.`is_terminal` = 0 then 1 else 0 end) AS `active_reports`, sum(case when `rs`.`status_name` = 'Cleared' then 1 else 0 end) AS `resolved_reports`, sum(case when `hr`.`severity` = 'critical' and `rs`.`is_terminal` = 0 then 1 else 0 end) AS `critical_hazards`, max(`hr`.`created_at`) AS `latest_report` FROM ((((`barangays` `b` left join `users` `u` on(`b`.`barangay_id` = `u`.`barangay_id`)) left join `volunteer_profiles` `v` on(`u`.`user_id` = `v`.`volunteer_id`)) left join `hazard_reports` `hr` on(`b`.`barangay_id` = `hr`.`barangay_id`)) left join `report_statuses` `rs` on(`hr`.`current_status_id` = `rs`.`status_id`)) GROUP BY `b`.`barangay_id`, `b`.`barangay_name` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD CONSTRAINT `device_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `export_logs`
--
ALTER TABLE `export_logs`
  ADD CONSTRAINT `export_logs_ibfk_1` FOREIGN KEY (`generated_by_user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `export_logs_ibfk_2` FOREIGN KEY (`barangay_id`) REFERENCES `barangays` (`barangay_id`) ON DELETE SET NULL;

--
-- Constraints for table `hazard_reports`
--
ALTER TABLE `hazard_reports`
  ADD CONSTRAINT `hazard_reports_ibfk_1` FOREIGN KEY (`reporter_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `hazard_reports_ibfk_2` FOREIGN KEY (`barangay_id`) REFERENCES `barangays` (`barangay_id`),
  ADD CONSTRAINT `hazard_reports_ibfk_3` FOREIGN KEY (`hazard_type_id`) REFERENCES `hazard_types` (`hazard_type_id`),
  ADD CONSTRAINT `hazard_reports_ibfk_4` FOREIGN KEY (`current_status_id`) REFERENCES `report_statuses` (`status_id`);

--
-- Constraints for table `incident_assignments`
--
ALTER TABLE `incident_assignments`
  ADD CONSTRAINT `incident_assignments_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `hazard_reports` (`report_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `incident_assignments_ibfk_2` FOREIGN KEY (`assigned_to_user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `incident_assignments_ibfk_3` FOREIGN KEY (`assigned_by_user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`report_id`) REFERENCES `hazard_reports` (`report_id`) ON DELETE SET NULL;

--
-- Constraints for table `report_photos`
--
ALTER TABLE `report_photos`
  ADD CONSTRAINT `report_photos_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `hazard_reports` (`report_id`) ON DELETE CASCADE;

--
-- Constraints for table `report_status_history`
--
ALTER TABLE `report_status_history`
  ADD CONSTRAINT `report_status_history_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `hazard_reports` (`report_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `report_status_history_ibfk_2` FOREIGN KEY (`changed_by_user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `report_status_history_ibfk_3` FOREIGN KEY (`old_status_id`) REFERENCES `report_statuses` (`status_id`),
  ADD CONSTRAINT `report_status_history_ibfk_4` FOREIGN KEY (`new_status_id`) REFERENCES `report_statuses` (`status_id`);

--
-- Constraints for table `report_upvotes`
--
ALTER TABLE `report_upvotes`
  ADD CONSTRAINT `report_upvotes_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `hazard_reports` (`report_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `report_upvotes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `resources`
--
ALTER TABLE `resources`
  ADD CONSTRAINT `resources_ibfk_1` FOREIGN KEY (`barangay_id`) REFERENCES `barangays` (`barangay_id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`barangay_id`) REFERENCES `barangays` (`barangay_id`) ON DELETE SET NULL;

--
-- Constraints for table `volunteer_availability`
--
ALTER TABLE `volunteer_availability`
  ADD CONSTRAINT `volunteer_availability_ibfk_1` FOREIGN KEY (`volunteer_id`) REFERENCES `volunteer_profiles` (`volunteer_id`) ON DELETE CASCADE;

--
-- Constraints for table `volunteer_profiles`
--
ALTER TABLE `volunteer_profiles`
  ADD CONSTRAINT `volunteer_profiles_ibfk_1` FOREIGN KEY (`volunteer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `volunteer_profiles_ibfk_2` FOREIGN KEY (`verified_by_official_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `volunteer_skills`
--
ALTER TABLE `volunteer_skills`
  ADD CONSTRAINT `volunteer_skills_ibfk_1` FOREIGN KEY (`volunteer_id`) REFERENCES `volunteer_profiles` (`volunteer_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
