-- Koi Pond Manager Database Schema

CREATE DATABASE IF NOT EXISTS koipondmanager;
USE koipondmanager;

-- Organizations table
CREATE TABLE IF NOT EXISTS organizations (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100)  NOT NULL,
    defaultTimezone VARCHAR(10)   NOT NULL DEFAULT 'pst',
    primaryUseType  VARCHAR(100)  NOT NULL,
    unitPreference  VARCHAR(10)   NOT NULL DEFAULT 'F',
    defaultStockingDensity  VARCHAR(100) NOT NULL DEFAULT 'standard'
);

-- Ponds table
CREATE TABLE IF NOT EXISTS ponds (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL,
    location    VARCHAR(255),
    volume      DOUBLE        NOT NULL,
    volume_unit VARCHAR(10)   NOT NULL DEFAULT 'gallons',
    length      DOUBLE,
    width       DOUBLE,
    depth       DOUBLE,
    filtration_type   VARCHAR(100),
    uv_bulb_count     INT DEFAULT 0,
    uv_bulb_wattage   DOUBLE DEFAULT 0,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pond_id) REFERENCES ponds(id) ON DELETE SET NULL
);

-- Treatment Table 
CREATE TABLE IF NOT EXISTS treatments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pond_id INT NOT NULL,
    user_id INT NOT NULL,
    medication VARCHAR(100),
    purpose VARCHAR(255),
    dosage DOUBLE,
    dosage_unit VARCHAR(50),
    duration INT,
    pond_volume DOUBLE,
    notes TEXT,
    quarantine BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for recurring maintenance
CREATE TABLE IF NOT EXISTS MaintenanceSchedule (
    id INT AUTO_INCREMENT PRIMARY KEY,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'Active',
    freq VARCHAR(50) NOT NULL, -- Daily, Weekly, Monthly, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    created_by_user_id INT
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
