-- ============================================================
-- RetailEdge Analytics | SQL Server
-- Script 01: Create Database
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RetailEdgeWarehouse')
BEGIN
    CREATE DATABASE RetailEdgeWarehouse;
    PRINT 'Database RetailEdgeWarehouse created successfully.';
END
ELSE
    PRINT 'Database RetailEdgeWarehouse already exists.';
GO

USE RetailEdgeWarehouse;
GO
