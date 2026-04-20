-- Koi Pond Manager Database Schema

CREATE DATABASE IF NOT EXISTS koipondmanager;
USE koipondmanager;

-- Organizations table
CREATE TABLE IF NOT EXISTS organizations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    use_type ENUM('dealer', 'hobbyist', 'contractor') NOT NULL DEFAULT 'hobbyist',
    unit_preference ENUM('imperial', 'metric') NOT NULL DEFAULT 'imperial',
    stocking_density ENUM('conservative', 'standard', 'aggressive') NOT NULL DEFAULT 'standard',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'manager', 'operator', 'viewer') NOT NULL DEFAULT 'viewer',
    organization_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (organization_id) REFERENCES organizations(id)
);

-- Ponds table
CREATE TABLE IF NOT EXISTS ponds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    organization_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    volume DOUBLE NOT NULL,
    volume_unit VARCHAR(10) NOT NULL DEFAULT 'gallons',
    length DOUBLE,
    width DOUBLE,
    depth DOUBLE,
    filtration_type VARCHAR(100),
    uv_bulb_count INT DEFAULT 0,
    uv_bulb_wattage DOUBLE DEFAULT 0,
    is_quarantine BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (organization_id) REFERENCES organizations(id)
);

-- Koi table
CREATE TABLE IF NOT EXISTS koi (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL,
    age         INT,
    variety     VARCHAR(100),
    breeder     VARCHAR(100),
    sex         VARCHAR(10),
    size_cm     DOUBLE,
    pond_id     INT,
    image_data  MEDIUMBLOB,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pond_id) REFERENCES ponds(id) ON DELETE SET NULL
);

-- Treatments table
CREATE TABLE IF NOT EXISTS treatments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pond_id INT NOT NULL,
    user_id INT NOT NULL,
    medication VARCHAR(100) NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    dosage DOUBLE NOT NULL,
    dosage_unit VARCHAR(50) NOT NULL,
    duration INT NOT NULL,
    pond_volume DOUBLE NOT NULL,
    notes TEXT,
    quarantine BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pond_id) REFERENCES ponds(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Table for recurring maintenance
CREATE TABLE IF NOT EXISTS MaintenanceSchedule (
    id INT AUTO_INCREMENT PRIMARY KEY,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'Active',
    freq VARCHAR(50) NOT NULL, -- Daily, Weekly, Biweekly, Monthly
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Table for generated maintenance tasks
CREATE TABLE IF NOT EXISTS MaintenanceTask (
    schedule_id INT NOT NULL,
    due_at DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    completed_by_user_id INT,
    PRIMARY KEY (schedule_id, due_at),
    FOREIGN KEY (schedule_id) REFERENCES MaintenanceSchedule(id) ON DELETE CASCADE
);

-- Water tests table
CREATE TABLE IF NOT EXISTS water_tests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pond_id INT NOT NULL,
    user_id INT NOT NULL,
    ph DOUBLE,
    temperature DOUBLE,
    ammonia DOUBLE,
    nitrite DOUBLE,
    nitrate DOUBLE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pond_id) REFERENCES ponds(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);