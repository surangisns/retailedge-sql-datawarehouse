# 🏪 RetailEdge Analytics: SQL Data Warehouse

> **Bronze · Silver · Gold Medallion Architecture**
> SQL Server · PostgreSQL · Power BI · GitHub

![SQL](https://img.shields.io/badge/SQL-Server%20%7C%20PostgreSQL-blue?style=flat-square&logo=microsoftsqlserver)
![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?style=flat-square&logo=powerbi)
![Architecture](https://img.shields.io/badge/Architecture-Medallion%20Bronze--Silver--Gold-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

---

## 📌 Project Overview

This project builds a **production-style SQL data warehouse** for a fictional Australian retail and e-commerce company called **RetailEdge Pty Ltd**.

Raw sales data from four disconnected business systems is ingested, cleaned, transformed, and modelled into a **star schema** ready for Power BI reporting — following the industry-standard **Bronze → Silver → Gold medallion architecture**.

> 💡 This is my **second portfolio project**, complementing my [NDIS Power BI Dashboard](https://github.com/surangisns/ndis-powerbi-dashboard) by showing the **data engineering layer that sits behind any analytics dashboard**.

---

## 🎯 Business Problem

RetailEdge has sales data spread across four systems:

| System | Data |
|--------|------|
| E-commerce Platform | Orders and order line items |
| CRM | Customer master records |
| ERP | Products and regions |
| Returns Portal | Product returns and refunds |

Analysts cannot answer basic questions like:
- Which products are driving the most revenue?
- Which customer segments are most valuable?
- How do sales differ by region and sales channel?
- What is the product return rate by category?
- What does the monthly revenue trend look like?

**This data warehouse solves that** by consolidating, cleaning, and modelling all data into a single trusted source of truth.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              SOURCE SYSTEMS                     │
│   CRM · ERP · E-commerce · Returns Portal      │
└────────────────────┬────────────────────────────┘
                     │  CSV Export
                     ▼
┌─────────────────────────────────────────────────┐
│           BRONZE LAYER  (schema: bronze)        │
│  Raw ingestion — data loaded as-is from CSV     │
│  No transformations · Preserves source issues   │
└────────────────────┬────────────────────────────┘
                     │  SQL Transform + Clean
                     ▼
┌─────────────────────────────────────────────────┐
│           SILVER LAYER  (schema: silver)        │
│  Cleaned · Standardised · Deduplicated          │
│  Dates normalised · Nulls handled · DQ checked  │
└────────────────────┬────────────────────────────┘
                     │  Dimensional Modelling
                     ▼
┌─────────────────────────────────────────────────┐
│           GOLD LAYER  (schema: gold)            │
│  Star Schema · Dimensions + Facts               │
│  Optimised for Power BI and analytics queries   │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
            📊 Power BI Dashboard
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| **SQL Server 2019** | Primary database and ETL engine |
| **PostgreSQL 15** | Alternative database scripts provided |
| **Excel / CSV** | Source data format |
| **Power BI Desktop** | Dashboard and reporting layer |
| **GitHub** | Version control and portfolio showcase |

---

## 📂 Repository Structure

```
retailedge-sql-datawarehouse/
│
├── 📁 datasets/                    ← 8 raw CSV source files
│   ├── customers.csv               (500 rows)
│   ├── products.csv                (98 rows)
│   ├── orders.csv                  (2,000 rows)
│   ├── order_items.csv             (3,444 rows)
│   ├── returns.csv                 (300 rows)
│   ├── regions.csv                 (20 rows)
│   ├── sales_channels.csv          (8 rows)
│   └── promotions.csv              (15 rows)
│
├── 📁 sql_server/                  ← SQL Server scripts (T-SQL)
│   ├── 01_create_database.sql
│   ├── 02_create_schemas.sql
│   ├── 03_bronze_tables.sql
│   ├── 04_load_csv_data.sql
│   ├── 05_silver_tables.sql
│   ├── 06_bronze_to_silver.sql
│   ├── 07_gold_dimensions.sql
│   ├── 08_gold_facts.sql
│   └── 09_create_indexes.sql
│
├── 📁 postgresql/                  ← PostgreSQL scripts
│   ├── 01_create_database.sql
│   ├── 02_create_schemas.sql
│   ├── 03_bronze_tables.sql
│   ├── 04_load_csv_data.sql
│   ├── 05_silver_tables.sql
│   ├── 06_bronze_to_silver.sql
│   ├── 07_gold_dimensions.sql
│   ├── 08_gold_facts.sql
│   └── 09_create_indexes.sql
│
├── 📁 data_quality/                ← DQ validation scripts
│   ├── dq_null_checks.sql
│   ├── dq_duplicate_checks.sql
│   ├── dq_referential_integrity.sql
│   ├── dq_date_validation.sql
│   └── dq_reconciliation.sql
│
├── 📁 analytics/                   ← Business analytics queries
│   ├── revenue_analysis.sql
│   ├── customer_analysis.sql
│   ├── product_analysis.sql
│   ├── regional_analysis.sql
│   └── channel_analysis.sql
│
├── 📁 powerbi/
│   └── RetailEdge_Dashboard.pbix
│
├── 📁 docs/
│   ├── architecture_diagram.png
│   ├── star_schema_diagram.png
│   └── data_dictionary.md
│
├── 📁 screenshots/
│   ├── 01_total_revenue.png … 10_customer_lifetime_value.png   (SQL query results)
│   └── dashboard_01_executive_overview.png … dashboard_04_regional_sales.png   (Power BI pages)
│
└── 📄 README.md
```

---

## 📊 Dataset Description

| File | Rows | Description | Key Data Quality Issues |
|------|------|-------------|------------------------|
| `customers.csv` | 500 | Customer master from CRM | Duplicate emails, mixed date formats, inconsistent gender codes |
| `products.csv` | 98 | Product catalogue from ERP | Negative unit costs, inconsistent active flags |
| `orders.csv` | 2,000 | Order headers from e-commerce | Delivery before shipping, null region IDs, orphaned customer IDs |
| `order_items.csv` | 3,444 | Order line items | Negative quantities, line total mismatches, null product IDs |
| `returns.csv` | 300 | Returns and refunds | Return before order date, refund exceeding sale price |
| `regions.csv` | 20 | Geographic region reference | Duplicate names, inconsistent country spelling |
| `sales_channels.csv` | 8 | Sales channel reference | Duplicate names, commission > 100% |
| `promotions.csv` | 15 | Discount campaigns | End date before start date, mixed date formats |

> All data quality issues are intentional and realistic — they are resolved in the Silver layer transformation scripts.

---

## ⚙️ ELT Process
This project follows an **ELT** pattern, not traditional ETL — raw data is **Loaded** into Bronze first, completely untouched, and all cleaning and modelling (**Transform**) happens afterward using SQL inside the warehouse itself, as data moves Bronze → Silver → Gold.
### Bronze Layer — Raw Ingestion
- CSV files loaded as-is using `BULK INSERT` (SQL Server) or `\COPY` (PostgreSQL)
- No transformation — data is preserved exactly as received
- `dwh_load_ts` timestamp added to track when each row was loaded

### Silver Layer — Clean & Standardise
- **Deduplication** using `ROW_NUMBER() OVER (PARTITION BY ...)`
- **Date normalisation** — mixed formats (DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD) converted to standard `DATE`
- **Gender standardisation** — M/Male/m/Female/F → Male/Female/Other
- **Active flag normalisation** — Y/N/1/0/yes/no → consistent boolean
- **Null handling** — defaults applied, invalid nulls flagged
- **Referential integrity** — orphaned records identified and excluded

### Gold Layer — Dimensional Model
- **Surrogate keys** added to all dimension tables — `BIGINT IDENTITY(1,1)` in SQL Server, `BIGSERIAL` in PostgreSQL
- **dim_date** pre-populated as a full date spine (2019–2025, 2,557 rows)
- **Age band** derived in `dim_customer` from date of birth, with an explicit `Unknown` bucket for records where date of birth couldn't be parsed — kept visible in reporting rather than silently dropped, since it represents real revenue
- **dim_region** includes a placeholder row (`region_id = -1`, `region_name = 'No Region (Partner Order)'`) to capture orders from partner-marketplace channels that don't carry a region in the source system — avoids silently losing revenue to unmatched joins
- **fact_sales** built by joining Silver order + order_items with all dimension keys, using `ISNULL(region_id, -1)` so every row resolves to a valid region key
- **fact_returns** linked back to fact_sales via order and product keys

---

## ⭐ Star Schema

```
                    dim_date
                       │
        dim_region ────┤
                       │
dim_sales_channel ─────┼──── fact_sales ──── dim_customer
                       │
        dim_product ───┤
                       │
                    fact_returns
```

### Dimension Tables

| Table | Grain | Key Columns |
|-------|-------|-------------|
| `dim_customer` | One row per customer | customer_key, customer_id, full_name, segment, age_band |
| `dim_product` | One row per product | product_key, product_id, name, category, subcategory, brand |
| `dim_date` | One row per calendar day | date_key (YYYYMMDD), year, quarter, month, week, day |
| `dim_region` | One row per region (+1 placeholder row for unmatched orders) | region_key, region_id, region_name, state, country, zone |
| `dim_sales_channel` | One row per channel | channel_key, channel_id, channel_name, channel_type |

### Fact Tables

| Table | Grain | Measures |
|-------|-------|---------|
| `fact_sales` | One row per order line item | quantity_sold, unit_price, discount_amount, gross_sales_amount, net_sales_amount |
| `fact_returns` | One row per return event | refund_amount, return_reason, return_status |

---

## ✅ Data Quality Checks

Validation scripts are run after each layer:

| Check | Script |
|-------|--------|
| Duplicate records | `dq_duplicate_checks.sql` |
| Null values on critical columns | `dq_null_checks.sql` |
| Invalid date ranges (delivery before shipping, return before order) | `dq_date_validation.sql` |
| Negative amounts and quantities | `dq_null_checks.sql` |
| Missing foreign keys (referential integrity) | `dq_referential_integrity.sql` |
| Row count reconciliation Bronze vs Silver | `dq_reconciliation.sql` |
| Sales total reconciliation | `dq_reconciliation.sql` |
| Unmatched region_id on fact_sales resolved to placeholder dimension row rather than dropped | `07_gold_dimensions.sql` / `08_gold_facts.sql` |

---

## 📈 Analytics Queries

10 business analytics queries built on the Gold layer:

| # | Query | File |
|---|-------|------|
| 1 | Total revenue | `revenue_analysis.sql` |
| 2 | Monthly sales trend | `revenue_analysis.sql` |
| 3 | Top 10 products by revenue | `product_analysis.sql` |
| 4 | Top 10 customers by lifetime value | `customer_analysis.sql` |
| 5 | Sales by region | `regional_analysis.sql` |
| 6 | Sales by channel | `channel_analysis.sql` |
| 7 | Average order value (AOV) by month | `revenue_analysis.sql` |
| 8 | Product return rate | `product_analysis.sql` |
| 9 | Product category performance | `product_analysis.sql` |
| 10 | Customer lifetime value (CLV) | `customer_analysis.sql` |

---

## 📊 Power BI Dashboard

Power BI Desktop connects directly to the **Gold layer** in SQL Server, via Import mode, with a custom navy/white theme applied across all four pages. Top-N rankings (top 10 products, top 10 customers) are implemented with `RANKX` DAX measures rather than the built-in Top N filter, for more transparent and reusable logic.

**Report Pages:**

| Page | Key Visuals |
|------|-------------|
| **1. Executive Overview** | KPI cards (Total Revenue, Total Orders, Total Units Sold, Avg Order Value) · Monthly Revenue Trend (line chart) · Revenue by Category (bar) · Revenue by Sales Channel (donut) |
| **2. Product Performance** | Top 10 Products by Revenue (table, RANKX-filtered) · Return Rate by Category (bar) · Units Sold by Category (bar) · Average Margin % by Brand (bar) |
| **3. Customer Analytics** | KPI cards (Total Customers, Avg Customer Lifetime Value) · Top 10 Customers by Revenue (table, RANKX-filtered) · Revenue by Customer Segment (donut) · Revenue by Age Band (bar) · Customers by State (bar) |
| **4. Regional Sales** | KPI cards (Total Regions, Avg Revenue per Region) · Revenue by Region (bar) · Revenue by State (table) · Revenue by Zone (donut) |

File: [`powerbi/RetailEdge_Dashboard.pbix`](powerbi/RetailEdge_Dashboard.pbix)

---

## 🖥️ Dashboard Screenshots

### Executive Overview
![Executive Overview](screenshots/dashboard_01_executive_overview.png)

### Product Performance
![Product Performance](screenshots/dashboard_02_product_performance.png)

### Customer Analytics
![Customer Analytics](screenshots/dashboard_03_customer_analytics.png)

### Regional Sales
![Regional Sales](screenshots/dashboard_04_regional_sales.png)

---

## 📸 Analytics Query Results

### Total Revenue
![Total Revenue](screenshots/01_total_revenue.png)

### Monthly Sales Trend
![Monthly Sales Trend](screenshots/02_monthly_sales_trend.png)

### Top Products by Revenue
![Top Products](screenshots/03_top_Products.png)

### Top Customers
![Top Customers](screenshots/04_top_customers.png)

### Sales by Region
![Sales by Region](screenshots/05_sales_by_region.png)

### Sales by Channel
![Sales by Channel](screenshots/06_sales_by_channel.png)

### Average Order Value
![Average Order Value](screenshots/07_average_order_value.png)

### Product Return Rate
![Return Rate](screenshots/08_return_rate.png)

### Category Performance
![Category Performance](screenshots/09_category_performance.png)

### Customer Lifetime Value
![Customer Lifetime Value](screenshots/10_customer_lifetime_value.png)

---

## 💡 Key Learnings

- Designing a **medallion architecture** (Bronze/Silver/Gold) from scratch
- **Dimensional modelling** — facts, dimensions, surrogate keys, date spines
- Writing **SQL-based ELT transformations** for real-world messy data
- Building **data quality checks** as part of the pipeline
- Handling **unmatched foreign keys with a placeholder dimension row** instead of silently dropping revenue
- Understanding **why star schemas** exist and how Power BI uses them
- Writing **RANKX-based DAX measures** for dynamic Top-N filtering
- Managing a **structured SQL project on GitHub**

---

## 🚀 Future Improvements

- [ ] Automate ELT pipeline using Python scripts
- [ ] Add Slowly Changing Dimension (SCD Type 2) for dim_customer
- [ ] Add incremental load logic instead of full refresh
- [ ] Build a data quality dashboard in Power BI
- [ ] Add unit tests for SQL transformations

---

## 👤 Author

**Surangani Bandara**
Data Analyst | Power BI | SQL | Python

🔗 [GitHub Profile](https://github.com/surangisns)
🔗 [First Portfolio Project — NDIS Power BI Dashboard](https://github.com/surangisns/ndis-powerbi-dashboard)

---

*This project was built as part of a data analytics portfolio to demonstrate SQL data engineering, dimensional modelling, and ELT design skills.*
