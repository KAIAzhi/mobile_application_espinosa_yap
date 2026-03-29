-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Mar 29, 2026 at 08:47 PM
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
(1, 3, 27, 'User 1', 'user1@example.com', '09179846344', '$2y$10$dummyhash', 1, 'active', NULL, '2026-03-28 13:55:13', '2026-03-28 13:55:13'),
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

--
-- Indexes for dumped tables
--

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`barangay_id`) REFERENCES `barangays` (`barangay_id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
