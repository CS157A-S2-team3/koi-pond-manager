-- Koi Pond Manager Database Schema

CREATE DATABASE IF NOT EXISTS koipondmanager;
USE koipondmanager;

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

-- Treatment Table 
CREATE TABLE treatments (
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
