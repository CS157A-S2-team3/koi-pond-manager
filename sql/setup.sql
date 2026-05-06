-- One-shot dev database setup.
-- Run from the project root:
--   mysql -u root -p < sql/setup.sql
--
-- Creates the koipondmanager schema and seeds the ChampKoi org, an admin user,
-- and the canonical 6 pond locations + 55 ponds. Safe to re-run.
--
-- Default login (DEV ONLY): admin@champkoi.com / champkoi

SOURCE sql/schema.sql;
SOURCE sql/seed_champkoi_ponds.sql;
