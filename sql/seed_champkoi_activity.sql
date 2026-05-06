-- ChampKoi activity seed: water tests, treatments, and pond-volume backfills
-- on a subset of the seeded ponds.
--
-- Water-quality issues you should see on /health.jsp after running this:
--   * C2 — high ammonia on the latest test
--   * W1 — pH below safe range on the latest test
--   * Q1 — active 14-day Ich-X treatment (informational badge)
-- The "test overdue" and "unhealthy fish" flags only fire for ponds that have
-- imported koi assigned, so what you see on /health.jsp depends on what the
-- import pulled in.
--
-- To reseed, drop the database and re-run sql/setup.sql.

USE koipondmanager;

SET @org_id = (SELECT id FROM organizations WHERE name = 'ChampKoi' LIMIT 1);
SET @uid    = (SELECT id FROM users WHERE email = 'admin@champkoi.com' LIMIT 1);

-- Pond ID lookups (only the ponds we're going to populate)
SET @c1 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'C1');
SET @c2 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'C2');
SET @c3 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'C3');
SET @w1 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'W1');
SET @w2 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'W2');
SET @w3 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'W3');
SET @w4 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'W4');
SET @g1 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'G1');
SET @g2 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'G2');
SET @g3 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'G3');
SET @q1 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'Q1');
SET @f1 = (SELECT id FROM ponds WHERE organization_id = @org_id AND code = 'F1');

-- Backfill pond physical specs on the demo ponds
UPDATE ponds SET volume = 8000, length = 12, width = 10, depth = 4,
                 filtration_type = 'Bead filter + UV', uv_bulb_count = 2, uv_bulb_wattage = 55
WHERE organization_id = @org_id AND code IN ('C1','C2','C3');

UPDATE ponds SET volume = 3000, length = 8, width = 6, depth = 3,
                 filtration_type = 'Bead filter', uv_bulb_count = 1, uv_bulb_wattage = 40
WHERE organization_id = @org_id AND code IN ('W1','W2','W3','W4');

UPDATE ponds SET volume = 2000, length = 6, width = 5, depth = 3,
                 filtration_type = 'Drum filter', uv_bulb_count = 1, uv_bulb_wattage = 40
WHERE organization_id = @org_id AND code IN ('G1','G2','G3');

UPDATE ponds SET volume = 500, length = 4, width = 3, depth = 2,
                 filtration_type = 'Sponge filter'
WHERE organization_id = @org_id AND code = 'Q1';

UPDATE ponds SET volume = 1500, length = 5, width = 4, depth = 2.5,
                 filtration_type = 'Bead filter'
WHERE organization_id = @org_id AND code = 'F1';

-- Water tests. Time-based pattern designed to drive the Pond Health view:
--   * Most ponds: a 4-week series with the latest test in the last 1-3 days
--   * C2: latest test (1d ago) shows ammonia 0.45 → flags as toxic
--   * W1: latest test (2d ago) shows pH 5.9 → flags as out of range
--   * G1: only old tests (oldest 21d, latest 10d) → flags as overdue if koi assigned
--   * Q1: recent tests during treatment, values mid-range
INSERT INTO water_tests (pond_id, user_id, ph, temperature, ammonia, nitrite, nitrate, notes, created_at)
    -- C1 (healthy, recent)
    SELECT @c1, @uid, 7.40, 19.0, 0.02, 0.03, 12.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 28 DAY) UNION ALL
    SELECT @c1, @uid, 7.50, 20.0, 0.03, 0.04, 14.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 21 DAY) UNION ALL
    SELECT @c1, @uid, 7.45, 21.0, 0.02, 0.04, 16.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 14 DAY) UNION ALL
    SELECT @c1, @uid, 7.50, 21.0, 0.02, 0.03, 18.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 7 DAY) UNION ALL
    SELECT @c1, @uid, 7.55, 22.0, 0.03, 0.03, 20.0, 'Routine weekly',                      DATE_SUB(NOW(), INTERVAL 2 DAY) UNION ALL

    -- C2 (latest test shows ammonia spike)
    SELECT @c2, @uid, 7.40, 19.5, 0.02, 0.03, 10.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 21 DAY) UNION ALL
    SELECT @c2, @uid, 7.45, 20.5, 0.04, 0.05, 14.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 14 DAY) UNION ALL
    SELECT @c2, @uid, 7.50, 21.0, 0.10, 0.08, 22.0, 'Ammonia creeping up',                 DATE_SUB(NOW(), INTERVAL 7 DAY) UNION ALL
    SELECT @c2, @uid, 7.50, 21.5, 0.45, 0.12, 28.0, 'Ammonia spike — check filtration',    DATE_SUB(NOW(), INTERVAL 1 DAY) UNION ALL

    -- C3 (healthy, recent)
    SELECT @c3, @uid, 7.40, 19.0, 0.02, 0.02, 10.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 28 DAY) UNION ALL
    SELECT @c3, @uid, 7.45, 20.0, 0.02, 0.03, 12.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 21 DAY) UNION ALL
    SELECT @c3, @uid, 7.50, 21.0, 0.03, 0.03, 14.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 10 DAY) UNION ALL
    SELECT @c3, @uid, 7.45, 21.0, 0.02, 0.04, 16.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 3 DAY) UNION ALL

    -- W1 (latest test shows pH crash)
    SELECT @w1, @uid, 7.30, 18.0, 0.03, 0.04, 12.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 21 DAY) UNION ALL
    SELECT @w1, @uid, 7.20, 19.0, 0.04, 0.05, 14.0, 'pH drifting down',                    DATE_SUB(NOW(), INTERVAL 14 DAY) UNION ALL
    SELECT @w1, @uid, 6.80, 19.0, 0.05, 0.06, 18.0, 'pH still falling — added buffer',     DATE_SUB(NOW(), INTERVAL 7 DAY) UNION ALL
    SELECT @w1, @uid, 5.90, 19.5, 0.06, 0.08, 22.0, 'pH crash — investigating KH',         DATE_SUB(NOW(), INTERVAL 2 DAY) UNION ALL

    -- W2, W3, W4 (healthy, recent)
    SELECT @w2, @uid, 7.40, 19.0, 0.02, 0.03, 10.0, NULL, DATE_SUB(NOW(), INTERVAL 21 DAY) UNION ALL
    SELECT @w2, @uid, 7.45, 20.0, 0.03, 0.04, 14.0, NULL, DATE_SUB(NOW(), INTERVAL 10 DAY) UNION ALL
    SELECT @w2, @uid, 7.50, 21.0, 0.02, 0.03, 16.0, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY) UNION ALL
    SELECT @w3, @uid, 7.45, 19.5, 0.03, 0.04, 12.0, NULL, DATE_SUB(NOW(), INTERVAL 18 DAY) UNION ALL
    SELECT @w3, @uid, 7.50, 20.5, 0.02, 0.03, 14.0, NULL, DATE_SUB(NOW(), INTERVAL 9 DAY) UNION ALL
    SELECT @w3, @uid, 7.50, 21.0, 0.02, 0.04, 16.0, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY) UNION ALL
    SELECT @w4, @uid, 7.40, 19.0, 0.03, 0.04, 12.0, NULL, DATE_SUB(NOW(), INTERVAL 14 DAY) UNION ALL
    SELECT @w4, @uid, 7.50, 20.0, 0.02, 0.03, 14.0, NULL, DATE_SUB(NOW(), INTERVAL 4 DAY) UNION ALL

    -- G1 (overdue: latest test 10 days ago, koi present)
    SELECT @g1, @uid, 7.40, 18.5, 0.02, 0.03, 10.0, NULL,                                  DATE_SUB(NOW(), INTERVAL 21 DAY) UNION ALL
    SELECT @g1, @uid, 7.45, 19.5, 0.03, 0.04, 14.0, 'Overdue for next test',               DATE_SUB(NOW(), INTERVAL 10 DAY) UNION ALL

    -- G2, G3 (healthy, recent)
    SELECT @g2, @uid, 7.45, 19.0, 0.02, 0.03, 12.0, NULL, DATE_SUB(NOW(), INTERVAL 18 DAY) UNION ALL
    SELECT @g2, @uid, 7.50, 20.0, 0.02, 0.04, 14.0, NULL, DATE_SUB(NOW(), INTERVAL 9 DAY)  UNION ALL
    SELECT @g2, @uid, 7.50, 21.0, 0.03, 0.03, 16.0, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)  UNION ALL
    SELECT @g3, @uid, 7.40, 19.0, 0.02, 0.03, 12.0, NULL, DATE_SUB(NOW(), INTERVAL 14 DAY) UNION ALL
    SELECT @g3, @uid, 7.45, 20.0, 0.02, 0.03, 14.0, NULL, DATE_SUB(NOW(), INTERVAL 5 DAY)  UNION ALL

    -- Q1 (treatment in progress; values trending healthy)
    SELECT @q1, @uid, 7.20, 22.0, 0.15, 0.20, 30.0, 'Ich-X day 1',                         DATE_SUB(NOW(), INTERVAL 4 DAY) UNION ALL
    SELECT @q1, @uid, 7.30, 22.0, 0.10, 0.15, 25.0, 'Ich-X day 3',                         DATE_SUB(NOW(), INTERVAL 2 DAY) UNION ALL
    SELECT @q1, @uid, 7.40, 22.0, 0.05, 0.10, 22.0, 'Ich-X day 4',                         DATE_SUB(NOW(), INTERVAL 1 DAY) UNION ALL

    -- F1 (healthy, recent)
    SELECT @f1, @uid, 7.40, 19.0, 0.02, 0.03, 10.0, NULL, DATE_SUB(NOW(), INTERVAL 12 DAY) UNION ALL
    SELECT @f1, @uid, 7.50, 20.0, 0.02, 0.03, 14.0, NULL, DATE_SUB(NOW(), INTERVAL 4 DAY);

-- Treatments: one active (Q1, ongoing 14-day Ich-X) and one historical (C2, ammonia binder)
INSERT INTO treatments (pond_id, user_id, medication, purpose, dosage, dosage_unit, duration, pond_volume, notes, quarantine, created_at) VALUES
    (@q1, @uid, 'Ich-X', 'White spot disease in quarantined koi',
     5.0, 'tsp/100gal', 14, 500.0,  'Day 4 of 14',                      TRUE,  DATE_SUB(NOW(), INTERVAL 4 DAY)),
    (@c2, @uid, 'Prime', 'Ammonia binder',
     1.0, 'mL/10gal',    1, 8000.0, 'One-shot dose for ammonia spike',  FALSE, DATE_SUB(NOW(), INTERVAL 30 DAY));
