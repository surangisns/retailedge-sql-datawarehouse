-- ============================================================
-- RetailEdge Analytics | SQL Server
-- Script 04: Load CSV Data into Bronze Tables
-- Update the file paths below to match your local folder.
-- ============================================================

USE RetailEdgeWarehouse;
GO

-- ⚠️  Update this path to match where you saved the CSV files
-- Example: C:\RetailEdge\datasets\

BULK INSERT bronze.raw_customers
FROM 'C:\RetailEdge\datasets\customers.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      TABLOCK, CODEPAGE = '65001');
GO

BULK INSERT bronze.raw_products
FROM 'C:\RetailEdge\datasets\products.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      TABLOCK, CODEPAGE = '65001');
GO

BULK INSERT bronze.raw_regions
FROM 'C:\RetailEdge\datasets\regions.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      TABLOCK, CODEPAGE = '65001');
GO

BULK INSERT bronze.raw_sales_channels
FROM 'C:\RetailEdge\datasets\sales_channels.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      TABLOCK, CODEPAGE = '65001');
GO

BULK INSERT bronze.raw_promotions
FROM 'C:\RetailEdge\datasets\promotions.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      TABLOCK, CODEPAGE = '65001');
GO

BULK INSERT bronze.raw_orders
FROM 'C:\RetailEdge\datasets\orders.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      TABLOCK, CODEPAGE = '65001');
GO

BULK INSERT bronze.raw_order_items
FROM 'C:\RetailEdge\datasets\order_items.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      TABLOCK, CODEPAGE = '65001');
GO

BULK INSERT bronze.raw_returns
FROM 'C:\RetailEdge\datasets\returns.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      TABLOCK, CODEPAGE = '65001');
GO

-- Verify row counts
SELECT 'raw_customers'    AS table_name, COUNT(*) AS row_count FROM bronze.raw_customers    UNION ALL
SELECT 'raw_products',    COUNT(*) FROM bronze.raw_products    UNION ALL
SELECT 'raw_regions',     COUNT(*) FROM bronze.raw_regions     UNION ALL
SELECT 'raw_sales_channels', COUNT(*) FROM bronze.raw_sales_channels UNION ALL
SELECT 'raw_promotions',  COUNT(*) FROM bronze.raw_promotions  UNION ALL
SELECT 'raw_orders',      COUNT(*) FROM bronze.raw_orders      UNION ALL
SELECT 'raw_order_items', COUNT(*) FROM bronze.raw_order_items UNION ALL
SELECT 'raw_returns',     COUNT(*) FROM bronze.raw_returns;
