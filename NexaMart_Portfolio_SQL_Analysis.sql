-- NexaMart Sales & Profitability Analysis
-- SQLite | Synthetic portfolio case study
--
-- DATA PREPARATION
-- Import these sheets from NexaMart_QA_Resolved.xlsx as SQLite tables:
--   Orders_Clean, Order_Items_Clean, Products, Branches
-- Use the Excel header row as column names. Preserve IDs as text and numeric
-- fields (quantity, price, cost, discount) as numbers.
-- The workbook contains QA_Exceptions, QA_Methods and Cost_Imputation for
-- the documented treatment of invalid rows and missing cost values.
--
-- BUSINESS DEFINITIONS
-- Eligible sales: order_status = 'Completed'. Cancelled orders are excluded.
-- Revenue = quantity * unit_price_idr * (1 - discount_pct)
-- COGS    = quantity * unit_cost_idr
-- Gross profit = revenue - COGS
-- Gross margin (%) = 100 * gross profit / revenue
-- Count distinct orders, not item rows, when reporting completed orders.

-- 1. Data inventory / quality checks
SELECT 'Orders_Clean' AS table_name, COUNT(*) AS row_count FROM Orders_Clean
UNION ALL
SELECT 'Order_Items_Clean', COUNT(*) FROM Order_Items_Clean;

SELECT COUNT(*) AS missing_unit_cost_rows
FROM Order_Items_Clean
WHERE unit_cost_idr IS NULL;

-- Reusable line-level business calculations for the analyses below.
-- Note: create this TEMP view in the same SQLite session as the queries.
CREATE TEMP VIEW IF NOT EXISTS completed_line_metrics AS
SELECT
    o.order_id,
    o.order_date,
    o.branch_id,
    i.line_id,
    i.product_id,
    i.quantity,
    i.discount_pct,
    i.quantity * i.unit_price_idr AS gross_sales_before_discount_idr,
    i.quantity * i.unit_price_idr * i.discount_pct AS discount_amount_idr,
    i.quantity * i.unit_price_idr * (1 - i.discount_pct) AS revenue_idr,
    i.quantity * i.unit_cost_idr AS cogs_idr,
    i.quantity * (i.unit_price_idr * (1 - i.discount_pct) - i.unit_cost_idr)
        AS gross_profit_idr
FROM Orders_Clean AS o
JOIN Order_Items_Clean AS i ON i.order_id = o.order_id
WHERE o.order_status = 'Completed';

-- 2. Company-wide KPIs
-- QA-verified expected values: revenue 33,176,965,950 IDR;
-- gross profit 3,017,014,093 IDR; gross margin about 9.09%.
SELECT
    COUNT(DISTINCT order_id) AS completed_orders,
    COUNT(*) AS completed_item_lines,
    CAST(ROUND(SUM(revenue_idr), 0) AS INTEGER) AS revenue_idr,
    CAST(ROUND(SUM(cogs_idr), 0) AS INTEGER) AS cogs_idr,
    CAST(ROUND(SUM(gross_profit_idr), 0) AS INTEGER) AS gross_profit_idr,
    ROUND(100.0 * SUM(gross_profit_idr) / NULLIF(SUM(revenue_idr), 0), 2)
        AS gross_margin_pct
FROM completed_line_metrics;

-- 3. Branch profitability comparison
-- Expected lowest margin: B06 ~8.53%; highest: B04 ~9.48%.
SELECT
    b.branch_id,
    b.city,
    COUNT(DISTINCT m.order_id) AS completed_orders,
    CAST(ROUND(SUM(m.revenue_idr), 0) AS INTEGER) AS revenue_idr,
    CAST(ROUND(SUM(m.gross_profit_idr), 0) AS INTEGER) AS gross_profit_idr,
    ROUND(100.0 * SUM(m.gross_profit_idr) / NULLIF(SUM(m.revenue_idr), 0), 2)
        AS gross_margin_pct
FROM completed_line_metrics AS m
JOIN Branches AS b ON b.branch_id = m.branch_id
GROUP BY b.branch_id, b.city
ORDER BY gross_margin_pct ASC;

-- 4. Yearly revenue and profit trend
SELECT
    SUBSTR(order_date, 1, 4) AS order_year,
    CAST(ROUND(SUM(revenue_idr), 0) AS INTEGER) AS revenue_idr,
    CAST(ROUND(SUM(gross_profit_idr), 0) AS INTEGER) AS gross_profit_idr,
    ROUND(100.0 * SUM(gross_profit_idr) / NULLIF(SUM(revenue_idr), 0), 2)
        AS gross_margin_pct
FROM completed_line_metrics
GROUP BY SUBSTR(order_date, 1, 4)
ORDER BY order_year;

-- 5. Product-category profitability
SELECT
    p.category,
    CAST(ROUND(SUM(m.revenue_idr), 0) AS INTEGER) AS revenue_idr,
    CAST(ROUND(SUM(m.gross_profit_idr), 0) AS INTEGER) AS gross_profit_idr,
    ROUND(100.0 * SUM(m.gross_profit_idr) / NULLIF(SUM(m.revenue_idr), 0), 2)
        AS gross_margin_pct
FROM completed_line_metrics AS m
JOIN Products AS p ON p.product_id = m.product_id
GROUP BY p.category
ORDER BY revenue_idr DESC;

-- 6. B06 vs B04: investigate measurable financial components
-- Weighted discount is calculated against sales before discount.
-- These measurements DO NOT prove the operational causes of the margin gap.
SELECT
    branch_id,
    CAST(ROUND(SUM(revenue_idr), 0) AS INTEGER) AS revenue_idr,
    CAST(ROUND(SUM(cogs_idr), 0) AS INTEGER) AS cogs_idr,
    CAST(ROUND(SUM(gross_profit_idr), 0) AS INTEGER) AS gross_profit_idr,
    ROUND(100.0 * SUM(discount_amount_idr)
        / NULLIF(SUM(gross_sales_before_discount_idr), 0), 2)
        AS weighted_discount_pct,
    ROUND(100.0 * SUM(gross_profit_idr)
        / NULLIF(SUM(revenue_idr), 0), 2) AS gross_margin_pct
FROM completed_line_metrics
WHERE branch_id IN ('B04', 'B06')
GROUP BY branch_id
ORDER BY branch_id;

-- 7. Compare B04 and B06 product mix (by category)
SELECT
    m.branch_id,
    p.category,
    COUNT(*) AS sold_item_lines,
    CAST(ROUND(SUM(m.revenue_idr), 0) AS INTEGER) AS revenue_idr,
    ROUND(100.0 * SUM(m.revenue_idr)
        / NULLIF(SUM(SUM(m.revenue_idr)) OVER (PARTITION BY m.branch_id), 0), 2)
        AS branch_revenue_share_pct,
    ROUND(100.0 * SUM(m.gross_profit_idr)
        / NULLIF(SUM(m.revenue_idr), 0), 2) AS gross_margin_pct
FROM completed_line_metrics AS m
JOIN Products AS p ON p.product_id = m.product_id
WHERE m.branch_id IN ('B04', 'B06')
GROUP BY m.branch_id, p.category
ORDER BY m.branch_id, revenue_idr DESC;

-- LIMITATION
-- Supplier contracts, campaign metadata and operations logs are absent.
-- Two unit costs are documented estimates. Treat recommendations as
-- hypotheses for investigation, not proven operational root causes.
