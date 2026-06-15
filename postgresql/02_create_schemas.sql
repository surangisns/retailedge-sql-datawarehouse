-- ============================================================
-- RetailEdge Analytics | PostgreSQL
-- Script 02: Create Schemas
-- ============================================================

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

RAISE NOTICE 'Schemas bronze, silver, gold created.';
