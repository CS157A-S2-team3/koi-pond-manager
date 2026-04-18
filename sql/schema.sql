-- Koi Pond Manager Database Schema

CREATE DATABASE IF NOT EXISTS koipondmanager;
USE koipondmanager;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ponds table
CREATE TABLE IF NOT EXISTS ponds (
    id INT AUTO_INCREMENT PRIMARY KEY,
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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

ALTER TABLE ponds
ADD COLUMN is_quarantine BOOLEAN DEFAULT FALSE;

