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

-- Pond locations: per-org facility groups (e.g. "Big Ponds", "Quarantine GH")
CREATE TABLE IF NOT EXISTS pond_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    organization_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    prefix VARCHAR(10) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_org_location (organization_id, name),
    FOREIGN KEY (organization_id) REFERENCES organizations(id)
);

-- Ponds table
CREATE TABLE IF NOT EXISTS ponds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    organization_id INT NOT NULL,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100),
    location_id INT NOT NULL,
    volume DOUBLE,
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
    UNIQUE KEY uniq_org_code (organization_id, code),
    FOREIGN KEY (organization_id) REFERENCES organizations(id),
    FOREIGN KEY (location_id) REFERENCES pond_locations(id)
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
    organization_id INT NOT NULL,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'Active',
    freq VARCHAR(50) NOT NULL, -- Daily, Weekly, Biweekly, Monthly
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (organization_id) REFERENCES organizations(id),
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
    image_url VARCHAR(500),
    shopify_product_id VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_org_shopify_product (organization_id, shopify_product_id),
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

-- Pond health view: a single per-pond row joining the latest water test,
-- koi counts, and active treatments. Backs the Health page.
CREATE OR REPLACE VIEW pond_health AS
-- Get the pond and test attributes for each pond (but only keep the latest at the end)
WITH ranked_tests AS (
    SELECT pond_id, ph, ammonia, nitrite, temperature, created_at,
          --  For each pond, number the rows from newest to oldest so we can get the latest test
           ROW_NUMBER() OVER 
           (PARTITION BY pond_id ORDER BY created_at DESC) AS rn
    FROM water_tests
)
SELECT
    -- Pond fields
    p.id                                AS pond_id,
    p.organization_id                   AS organization_id,
    p.code                              AS code,
    p.name                              AS name,
    p.volume                            AS volume,
    p.is_quarantine                     AS is_quarantine,

    -- Location fields
    l.name                              AS location_name,
    l.display_order                     AS location_order,

    -- Latest test fields
    lt.created_at                       AS last_test_at,
    lt.ph                               AS last_ph,
    lt.ammonia                          AS last_ammonia,
    lt.nitrite                          AS last_nitrite,
    lt.temperature                      AS last_temperature,
    DATEDIFF(CURDATE(), DATE(lt.created_at)) AS days_since_test,
    (SELECT COUNT(*) FROM koi k        WHERE k.pond_id = p.id) AS koi_count,
    (SELECT COUNT(*) FROM koi k        WHERE k.pond_id = p.id AND k.status <> 'healthy') AS unhealthy_koi_count,
    (SELECT COUNT(*) FROM treatments t WHERE t.pond_id = p.id
        AND DATE_ADD(t.created_at, INTERVAL t.duration DAY) >= CURDATE()) AS active_treatment_count
FROM ponds p
-- Every pond belongs to a location
JOIN pond_locations l ON p.location_id = l.id
-- Join only the newest test for that pond
LEFT JOIN ranked_tests lt ON lt.pond_id = p.id AND lt.rn = 1;