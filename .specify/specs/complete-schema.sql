-- RenoRadar Complete Database Schema
-- MariaDB 10.6+ / MySQL 8.0+
-- All tables use InnoDB with utf8mb4_unicode_ci

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- 001 - CORE PLATFORM
-- ============================================

-- Static pages (About, Terms, Privacy, etc.)
CREATE TABLE IF NOT EXISTS `pages` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `slug` VARCHAR(100) NOT NULL UNIQUE,
    `title` VARCHAR(200) NOT NULL,
    `content` LONGTEXT NOT NULL,
    `meta_title` VARCHAR(200),
    `meta_description` VARCHAR(300),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Blog posts / Guides
CREATE TABLE IF NOT EXISTS `blog_posts` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `slug` VARCHAR(200) NOT NULL UNIQUE,
    `title` VARCHAR(300) NOT NULL,
    `excerpt` TEXT,
    `content` LONGTEXT NOT NULL,
    `featured_image` VARCHAR(500),
    `category` ENUM('buying-guides', 'selling-tips', 'renovation-advice', 'market-insights') NOT NULL,
    `author_name` VARCHAR(100),
    `meta_title` VARCHAR(200),
    `meta_description` VARCHAR(300),
    `is_published` TINYINT(1) DEFAULT 0,
    `published_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_slug` (`slug`),
    INDEX `idx_category` (`category`),
    INDEX `idx_published` (`is_published`, `published_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Contact form submissions
CREATE TABLE IF NOT EXISTS `contact_submissions` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `subject` VARCHAR(200) NOT NULL,
    `message` TEXT NOT NULL,
    `ip_address` VARCHAR(45),
    `user_agent` TEXT,
    `is_read` TINYINT(1) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_created` (`created_at`),
    INDEX `idx_read` (`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Newsletter subscribers
CREATE TABLE IF NOT EXISTS `newsletter_subscribers` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `is_confirmed` TINYINT(1) DEFAULT 0,
    `confirmation_token` VARCHAR(64),
    `confirmed_at` TIMESTAMP NULL,
    `unsubscribed_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_email` (`email`),
    INDEX `idx_confirmed` (`is_confirmed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 002 - USER AUTHENTICATION
-- ============================================

-- Users table
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `first_name` VARCHAR(100) NOT NULL,
    `last_name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20),
    `avatar` VARCHAR(500),
    `role` ENUM('user', 'seller', 'admin') DEFAULT 'user',
    `subscription_tier` ENUM('free', 'premium') DEFAULT 'free',
    `subscription_expires_at` TIMESTAMP NULL,
    `email_verified_at` TIMESTAMP NULL,
    `email_verification_token` VARCHAR(64),
    `email_verification_expires_at` TIMESTAMP NULL,
    `marketing_opt_in` TINYINT(1) DEFAULT 0,
    `failed_login_attempts` INT UNSIGNED DEFAULT 0,
    `locked_until` TIMESTAMP NULL,
    `last_login_at` TIMESTAMP NULL,
    `last_login_ip` VARCHAR(45),
    `deleted_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_email` (`email`),
    INDEX `idx_role` (`role`),
    INDEX `idx_subscription` (`subscription_tier`),
    INDEX `idx_deleted` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Password reset tokens
CREATE TABLE IF NOT EXISTS `password_resets` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) NOT NULL,
    `token` VARCHAR(64) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NOT NULL,
    `used_at` TIMESTAMP NULL,
    INDEX `idx_email` (`email`),
    INDEX `idx_token` (`token`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Remember me tokens
CREATE TABLE IF NOT EXISTS `remember_tokens` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `token_hash` VARCHAR(64) NOT NULL,
    `expires_at` TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_token` (`token_hash`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Authentication audit logs
CREATE TABLE IF NOT EXISTS `auth_logs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED,
    `action` ENUM('login', 'logout', 'register', 'password_reset', 'email_verify', 'failed_login', 'lockout') NOT NULL,
    `ip_address` VARCHAR(45),
    `user_agent` TEXT,
    `metadata` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_action` (`action`),
    INDEX `idx_created` (`created_at`),
    INDEX `idx_ip` (`ip_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 003 - PROPERTY LISTINGS
-- ============================================

-- Properties
CREATE TABLE IF NOT EXISTS `properties` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `slug` VARCHAR(300) NOT NULL UNIQUE,
    `title` VARCHAR(200) NOT NULL,
    `property_type` ENUM('detached', 'semi-detached', 'terraced', 'end-terrace', 'flat', 'maisonette', 'bungalow', 'cottage', 'barn-conversion', 'commercial', 'land', 'other') NOT NULL,
    `condition_type` ENUM('total-renovation', 'structural-issues', 'needs-modernisation', 'cosmetic-updates', 'good-condition') NOT NULL,
    `description` TEXT NOT NULL,
    `price` DECIMAL(12, 2) NOT NULL,
    `price_qualifier` ENUM('offers-over', 'offers-around', 'guide-price', 'fixed-price') DEFAULT 'guide-price',
    `bedrooms` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `bathrooms` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `living_area_sqft` INT UNSIGNED,
    `land_area_sqft` INT UNSIGNED,
    `year_built` YEAR,
    `epc_rating` ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G', 'unknown') DEFAULT 'unknown',
    `council_tax_band` ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H') NULL,
    `tenure` ENUM('freehold', 'leasehold', 'share-of-freehold') NULL,
    `lease_years_remaining` INT UNSIGNED NULL,
    `address_line_1` VARCHAR(200) NOT NULL,
    `address_line_2` VARCHAR(200),
    `city` VARCHAR(100) NOT NULL,
    `county` VARCHAR(100),
    `postcode` VARCHAR(10) NOT NULL,
    `postcode_area` VARCHAR(4) NOT NULL,
    `latitude` DECIMAL(10, 8),
    `longitude` DECIMAL(11, 8),
    `video_url` VARCHAR(500),
    `virtual_tour_url` VARCHAR(500),
    `floor_plan_path` VARCHAR(500),
    `status` ENUM('draft', 'pending-payment', 'active', 'paused', 'sold', 'deleted') DEFAULT 'draft',
    `is_premium` TINYINT(1) DEFAULT 0,
    `premium_expires_at` TIMESTAMP NULL,
    `viewing_notes` TEXT,
    `view_count` INT UNSIGNED DEFAULT 0,
    `favorite_count` INT UNSIGNED DEFAULT 0,
    `inquiry_count` INT UNSIGNED DEFAULT 0,
    `published_at` TIMESTAMP NULL,
    `sold_at` TIMESTAMP NULL,
    `deleted_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_slug` (`slug`),
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`property_type`),
    INDEX `idx_condition` (`condition_type`),
    INDEX `idx_price` (`price`),
    INDEX `idx_bedrooms` (`bedrooms`),
    INDEX `idx_location` (`postcode_area`, `city`),
    INDEX `idx_premium` (`is_premium`, `published_at`),
    FULLTEXT `idx_search` (`title`, `description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Property images
CREATE TABLE IF NOT EXISTS `property_images` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `property_id` INT UNSIGNED NOT NULL,
    `filename` VARCHAR(255) NOT NULL,
    `original_filename` VARCHAR(255) NOT NULL,
    `path` VARCHAR(500) NOT NULL,
    `thumbnail_path` VARCHAR(500),
    `medium_path` VARCHAR(500),
    `large_path` VARCHAR(500),
    `alt_text` VARCHAR(200),
    `sort_order` TINYINT UNSIGNED DEFAULT 0,
    `is_primary` TINYINT(1) DEFAULT 0,
    `file_size` INT UNSIGNED,
    `width` INT UNSIGNED,
    `height` INT UNSIGNED,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    INDEX `idx_property` (`property_id`),
    INDEX `idx_primary` (`property_id`, `is_primary`),
    INDEX `idx_sort` (`property_id`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Property features
CREATE TABLE IF NOT EXISTS `property_features` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `property_id` INT UNSIGNED NOT NULL,
    `feature` VARCHAR(200) NOT NULL,
    `sort_order` TINYINT UNSIGNED DEFAULT 0,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    INDEX `idx_property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User favorites
CREATE TABLE IF NOT EXISTS `favorites` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `property_id` INT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_user_property` (`user_id`, `property_id`),
    INDEX `idx_user` (`user_id`),
    INDEX `idx_property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Property inquiries
CREATE TABLE IF NOT EXISTS `property_inquiries` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `property_id` INT UNSIGNED NOT NULL,
    `user_id` INT UNSIGNED NULL,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(20),
    `message` TEXT NOT NULL,
    `ip_address` VARCHAR(45),
    `is_read` TINYINT(1) DEFAULT 0,
    `replied_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    INDEX `idx_property` (`property_id`),
    INDEX `idx_user` (`user_id`),
    INDEX `idx_read` (`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listing drafts
CREATE TABLE IF NOT EXISTS `listing_drafts` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `current_step` TINYINT UNSIGNED DEFAULT 1,
    `data` JSON NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_user` (`user_id`),
    INDEX `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 004 - SEARCH & FILTERING
-- ============================================

-- Saved searches
CREATE TABLE IF NOT EXISTS `saved_searches` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `criteria` JSON NOT NULL,
    `alert_enabled` TINYINT(1) DEFAULT 0,
    `last_run_at` TIMESTAMP NULL,
    `results_count` INT UNSIGNED DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_alert` (`alert_enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Search analytics
CREATE TABLE IF NOT EXISTS `search_logs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NULL,
    `session_id` VARCHAR(64),
    `search_term` VARCHAR(200),
    `filters` JSON,
    `results_count` INT UNSIGNED,
    `clicked_property_id` INT UNSIGNED NULL,
    `ip_address` VARCHAR(45),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_created` (`created_at`),
    INDEX `idx_term` (`search_term`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Location reference data
CREATE TABLE IF NOT EXISTS `locations` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `type` ENUM('city', 'town', 'county', 'region', 'postcode_area') NOT NULL,
    `parent_id` INT UNSIGNED NULL,
    `latitude` DECIMAL(10, 8),
    `longitude` DECIMAL(11, 8),
    `property_count` INT UNSIGNED DEFAULT 0,
    FOREIGN KEY (`parent_id`) REFERENCES `locations`(`id`) ON DELETE SET NULL,
    INDEX `idx_name` (`name`),
    INDEX `idx_type` (`type`),
    FULLTEXT `idx_search` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 005 - PAYMENTS & SUBSCRIPTIONS
-- ============================================

-- Payments
CREATE TABLE IF NOT EXISTS `payments` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `paypal_order_id` VARCHAR(50) UNIQUE,
    `paypal_capture_id` VARCHAR(50),
    `type` ENUM('listing', 'listing_premium', 'listing_renewal', 'subscription') NOT NULL,
    `product_code` VARCHAR(50) NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `currency` VARCHAR(3) DEFAULT 'GBP',
    `status` ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    `metadata` JSON,
    `paid_at` TIMESTAMP NULL,
    `refunded_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_paypal_order` (`paypal_order_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Subscriptions
CREATE TABLE IF NOT EXISTS `subscriptions` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `paypal_subscription_id` VARCHAR(50) UNIQUE,
    `paypal_plan_id` VARCHAR(50) NOT NULL,
    `type` ENUM('buyer_monthly', 'buyer_annual', 'listing_premium') NOT NULL,
    `status` ENUM('pending', 'active', 'cancelled', 'suspended', 'expired') DEFAULT 'pending',
    `current_period_start` TIMESTAMP NULL,
    `current_period_end` TIMESTAMP NULL,
    `cancelled_at` TIMESTAMP NULL,
    `cancel_reason` TEXT,
    `trial_ends_at` TIMESTAMP NULL,
    `metadata` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_paypal_subscription` (`paypal_subscription_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`type`),
    INDEX `idx_period_end` (`current_period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Invoices
CREATE TABLE IF NOT EXISTS `invoices` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `payment_id` INT UNSIGNED NULL,
    `subscription_id` INT UNSIGNED NULL,
    `invoice_number` VARCHAR(50) NOT NULL UNIQUE,
    `type` ENUM('payment', 'subscription', 'refund') NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `subtotal` DECIMAL(10, 2) NOT NULL,
    `vat_rate` DECIMAL(5, 2) DEFAULT 20.00,
    `vat_amount` DECIMAL(10, 2) NOT NULL,
    `total` DECIMAL(10, 2) NOT NULL,
    `currency` VARCHAR(3) DEFAULT 'GBP',
    `status` ENUM('draft', 'issued', 'paid', 'refunded') DEFAULT 'draft',
    `issued_at` TIMESTAMP NULL,
    `paid_at` TIMESTAMP NULL,
    `pdf_path` VARCHAR(500) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions`(`id`) ON DELETE SET NULL,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_number` (`invoice_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Webhook logs
CREATE TABLE IF NOT EXISTS `webhook_logs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `provider` VARCHAR(20) NOT NULL,
    `event_id` VARCHAR(100) NOT NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payload` JSON NOT NULL,
    `status` ENUM('received', 'processed', 'failed') DEFAULT 'received',
    `error_message` TEXT,
    `processed_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_event` (`provider`, `event_id`),
    INDEX `idx_type` (`event_type`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 006 - ALERTS & NOTIFICATIONS
-- ============================================

-- Property alerts
CREATE TABLE IF NOT EXISTS `alerts` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `criteria` JSON NOT NULL,
    `frequency` ENUM('instant', 'daily', 'weekly') DEFAULT 'instant',
    `is_active` TINYINT(1) DEFAULT 1,
    `last_sent_at` TIMESTAMP NULL,
    `last_matched_at` TIMESTAMP NULL,
    `match_count` INT UNSIGNED DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_active` (`is_active`),
    INDEX `idx_frequency` (`frequency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- In-app notifications
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `title` VARCHAR(200) NOT NULL,
    `message` TEXT NOT NULL,
    `data` JSON,
    `link` VARCHAR(500),
    `is_read` TINYINT(1) DEFAULT 0,
    `read_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_read` (`is_read`),
    INDEX `idx_type` (`type`),
    INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Email queue
CREATE TABLE IF NOT EXISTS `email_queue` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `template` VARCHAR(100) NOT NULL,
    `subject` VARCHAR(200) NOT NULL,
    `data` JSON NOT NULL,
    `priority` TINYINT UNSIGNED DEFAULT 5,
    `status` ENUM('pending', 'processing', 'sent', 'failed') DEFAULT 'pending',
    `attempts` TINYINT UNSIGNED DEFAULT 0,
    `max_attempts` TINYINT UNSIGNED DEFAULT 3,
    `last_error` TEXT,
    `scheduled_for` TIMESTAMP NULL,
    `sent_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_status` (`status`),
    INDEX `idx_scheduled` (`scheduled_for`),
    INDEX `idx_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notification preferences
CREATE TABLE IF NOT EXISTS `notification_preferences` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL UNIQUE,
    `property_alerts` TINYINT(1) DEFAULT 1,
    `price_changes` TINYINT(1) DEFAULT 1,
    `sold_notifications` TINYINT(1) DEFAULT 1,
    `inquiry_notifications` TINYINT(1) DEFAULT 1,
    `listing_updates` TINYINT(1) DEFAULT 1,
    `weekly_stats` TINYINT(1) DEFAULT 1,
    `marketing_emails` TINYINT(1) DEFAULT 0,
    `newsletter` TINYINT(1) DEFAULT 0,
    `unsubscribe_token` VARCHAR(64) UNIQUE,
    `unsubscribed_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user` (`user_id`),
    INDEX `idx_token` (`unsubscribe_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Alert-property matches
CREATE TABLE IF NOT EXISTS `alert_property_matches` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `alert_id` INT UNSIGNED NOT NULL,
    `property_id` INT UNSIGNED NOT NULL,
    `notified_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`alert_id`) REFERENCES `alerts`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_alert_property` (`alert_id`, `property_id`),
    INDEX `idx_notified` (`notified_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 007 - ADMIN DASHBOARD
-- ============================================

-- Application settings
CREATE TABLE IF NOT EXISTS `settings` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `key` VARCHAR(100) NOT NULL UNIQUE,
    `value` TEXT,
    `type` ENUM('string', 'integer', 'boolean', 'json') DEFAULT 'string',
    `group_name` VARCHAR(50) DEFAULT 'general',
    `description` VARCHAR(255),
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_key` (`key`),
    INDEX `idx_group` (`group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admin audit logs
CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `admin_id` INT UNSIGNED NOT NULL,
    `action` VARCHAR(100) NOT NULL,
    `entity_type` VARCHAR(50),
    `entity_id` INT UNSIGNED,
    `old_values` JSON,
    `new_values` JSON,
    `ip_address` VARCHAR(45),
    `user_agent` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_admin` (`admin_id`),
    INDEX `idx_action` (`action`),
    INDEX `idx_entity` (`entity_type`, `entity_id`),
    INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
