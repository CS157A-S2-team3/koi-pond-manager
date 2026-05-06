-- ChampKoi facility pond seed
--
-- Self-contained dev bootstrap. Creates the ChampKoi organization and an admin
-- user if they don't already exist, then seeds the canonical 6 location groups
-- and 55 ponds. Safe to re-run — uses INSERT IGNORE / WHERE NOT EXISTS so
-- nothing duplicates.
--
-- Default credentials (DEV ONLY):
--   email:    admin@champkoi.com
--   password: champkoi   (hash: 55570be6, see PasswordUtil.java)

USE koipondmanager;

-- 1. Organization (created only if no org named 'ChampKoi' exists)
INSERT INTO organizations (name, timezone, use_type, unit_preference, stocking_density)
SELECT 'ChampKoi', 'America/Los_Angeles', 'dealer', 'imperial', 'standard'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'ChampKoi');

SET @org_id = (SELECT id FROM organizations WHERE name = 'ChampKoi' LIMIT 1);

-- 2. Admin user (UNIQUE on email makes this naturally idempotent)
INSERT IGNORE INTO users (full_name, email, password_hash, role, organization_id)
VALUES ('ChampKoi Admin', 'admin@champkoi.com', '55570be6', 'admin', @org_id);

-- 3. Pond locations
INSERT IGNORE INTO pond_locations (organization_id, name, prefix, display_order) VALUES
    (@org_id, 'Big Ponds',     'C',  1),
    (@org_id, 'Quad Ponds',    'W',  2),
    (@org_id, 'Fiberglass',    'F',  3),
    (@org_id, 'Greenhouse',    'G',  4),
    (@org_id, 'Quarantine GH', 'Q',  5),
    (@org_id, 'Tosai Tanks',   'S',  6);
    -- (@org_id, 'In Japan',      'JP', 7);  -- TODO: enable once we track the in-Japan holding pond here

-- SET @loc_jp = (SELECT id FROM pond_locations WHERE organization_id = @org_id AND name = 'In Japan');
SET @loc_c  = (SELECT id FROM pond_locations WHERE organization_id = @org_id AND name = 'Big Ponds');
SET @loc_w  = (SELECT id FROM pond_locations WHERE organization_id = @org_id AND name = 'Quad Ponds');
SET @loc_f  = (SELECT id FROM pond_locations WHERE organization_id = @org_id AND name = 'Fiberglass');
SET @loc_g  = (SELECT id FROM pond_locations WHERE organization_id = @org_id AND name = 'Greenhouse');
SET @loc_q  = (SELECT id FROM pond_locations WHERE organization_id = @org_id AND name = 'Quarantine GH');
SET @loc_s  = (SELECT id FROM pond_locations WHERE organization_id = @org_id AND name = 'Tosai Tanks');

-- 4. Ponds
INSERT IGNORE INTO ponds (organization_id, code, name, location_id, is_quarantine) VALUES
    (@org_id, 'C1',  'C1',  @loc_c,  FALSE),
    (@org_id, 'C2',  'C2',  @loc_c,  FALSE),
    (@org_id, 'C3',  'C3',  @loc_c,  FALSE),

    (@org_id, 'W1',  'W1',  @loc_w,  FALSE),
    (@org_id, 'W2',  'W2',  @loc_w,  FALSE),
    (@org_id, 'W3',  'W3',  @loc_w,  FALSE),
    (@org_id, 'W4',  'W4',  @loc_w,  FALSE),
    (@org_id, 'W5',  'W5',  @loc_w,  FALSE),
    (@org_id, 'W6',  'W6',  @loc_w,  FALSE),
    (@org_id, 'W7',  'W7',  @loc_w,  FALSE),
    (@org_id, 'W8',  'W8',  @loc_w,  FALSE),

    (@org_id, 'F1',  'F1',  @loc_f,  FALSE),
    (@org_id, 'F2',  'F2',  @loc_f,  FALSE),
    (@org_id, 'F3',  'F3',  @loc_f,  FALSE),
    (@org_id, 'F4',  'F4',  @loc_f,  FALSE),
    (@org_id, 'F5',  'F5',  @loc_f,  FALSE),
    (@org_id, 'F6',  'F6',  @loc_f,  FALSE),
    (@org_id, 'F7',  'F7',  @loc_f,  FALSE),
    (@org_id, 'F8',  'F8',  @loc_f,  FALSE),
    (@org_id, 'F9',  'F9',  @loc_f,  FALSE),
    (@org_id, 'F10', 'F10', @loc_f,  FALSE),
    (@org_id, 'F11', 'F11', @loc_f,  FALSE),
    (@org_id, 'F12', 'F12', @loc_f,  FALSE),

    (@org_id, 'G1',  'G1',  @loc_g,  FALSE),
    (@org_id, 'G2',  'G2',  @loc_g,  FALSE),
    (@org_id, 'G3',  'G3',  @loc_g,  FALSE),
    (@org_id, 'G4',  'G4',  @loc_g,  FALSE),
    (@org_id, 'G5',  'G5',  @loc_g,  FALSE),
    (@org_id, 'G6',  'G6',  @loc_g,  FALSE),
    (@org_id, 'G7',  'G7',  @loc_g,  FALSE),
    (@org_id, 'G8',  'G8',  @loc_g,  FALSE),

    (@org_id, 'Q1',  'Q1',  @loc_q,  TRUE),
    (@org_id, 'Q2',  'Q2',  @loc_q,  TRUE),
    (@org_id, 'Q3',  'Q3',  @loc_q,  TRUE),
    (@org_id, 'Q4',  'Q4',  @loc_q,  TRUE),

    (@org_id, 'S1A', 'S1A', @loc_s,  FALSE),
    (@org_id, 'S1B', 'S1B', @loc_s,  FALSE),
    (@org_id, 'S1C', 'S1C', @loc_s,  FALSE),
    (@org_id, 'S1D', 'S1D', @loc_s,  FALSE),
    (@org_id, 'S2A', 'S2A', @loc_s,  FALSE),
    (@org_id, 'S2B', 'S2B', @loc_s,  FALSE),
    (@org_id, 'S2C', 'S2C', @loc_s,  FALSE),
    (@org_id, 'S2D', 'S2D', @loc_s,  FALSE),
    (@org_id, 'S3A', 'S3A', @loc_s,  FALSE),
    (@org_id, 'S3B', 'S3B', @loc_s,  FALSE),
    (@org_id, 'S3C', 'S3C', @loc_s,  FALSE),
    (@org_id, 'S3D', 'S3D', @loc_s,  FALSE),
    (@org_id, 'S3E', 'S3E', @loc_s,  FALSE),
    (@org_id, 'S3F', 'S3F', @loc_s,  FALSE),
    (@org_id, 'S4A', 'S4A', @loc_s,  FALSE),
    (@org_id, 'S4B', 'S4B', @loc_s,  FALSE),
    (@org_id, 'S4C', 'S4C', @loc_s,  FALSE),
    (@org_id, 'S4D', 'S4D', @loc_s,  FALSE),
    (@org_id, 'S4E', 'S4E', @loc_s,  FALSE),
    (@org_id, 'S4F', 'S4F', @loc_s,  FALSE);

-- TODO: enable once we track the in-Japan holding pond here
-- INSERT INTO ponds (organization_id, code, name, location_id, is_quarantine) VALUES
--     (@org_id, 'JP', 'JP', @loc_jp, FALSE);
