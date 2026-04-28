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

-- Koi table
CREATE TABLE IF NOT EXISTS koi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    organization_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    age INT,
    variety VARCHAR(100),
    breeder VARCHAR(100),
    sex ENUM('male', 'female', 'unknown') NOT NULL DEFAULT 'unknown',
    size_cm DOUBLE,
    status ENUM('healthy', 'injured', 'sick', 'deceased') NOT NULL DEFAULT 'healthy',
    pond_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (organization_id) REFERENCES organizations(id),
    FOREIGN KEY (pond_id) REFERENCES ponds(id)
);

-- Koi pond assignment history
CREATE TABLE IF NOT EXISTS koi_pond_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    koi_id INT NOT NULL,
    from_pond_id INT,
    to_pond_id INT,
    moved_by INT NOT NULL,
    moved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(255),
    FOREIGN KEY (koi_id) REFERENCES koi(id),
    FOREIGN KEY (from_pond_id) REFERENCES ponds(id),
    FOREIGN KEY (to_pond_id) REFERENCES ponds(id),
    FOREIGN KEY (moved_by) REFERENCES users(id)
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