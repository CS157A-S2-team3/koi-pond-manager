-- One-shot dev database setup.
-- Run from the project root:
--   mysql -u root -p < sql/setup.sql
--
-- Creates the koipondmanager schema and seeds:
--   * the ChampKoi org and an admin user
--   * 6 pond locations + 55 ponds
--   * ~35 water tests, and 2 treatments across a subset of the ponds
--
-- Default login (DEV ONLY): admin@champkoi.com / champkoi

SOURCE sql/schema.sql;
SOURCE sql/seed_champkoi_ponds.sql;
SOURCE sql/seed_champkoi_activity.sql;
