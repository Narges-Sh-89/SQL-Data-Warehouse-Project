 /*
===============================================================================
Data Quality Checks (Gold Layer)
===============================================================================

Purpose:
    This script validates the integrity, consistency, and reliability of the
    Gold layer data model. The checks ensure that the final analytical layer
    is accurate and ready for reporting and business intelligence use.

    The validations include:
    - Ensuring uniqueness of surrogate keys in dimension tables
    - Verifying referential integrity between fact and dimension tables
    - Validating relationships within the star schema for analytical correctness

Usage Notes:
    - Run these checks after the Gold layer has been fully built.
    - Any issues identified should be analyzed and resolved before using the
      data for reporting or dashboarding purposes.

===============================================================================
*/

-- ====================================================================
-- Data Quality Check: Gold.dim_customers
-- ====================================================================
-- Validate uniqueness of customer key in gold.dim_customers
-- Expected result: No records returned

SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM Gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'Gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in Gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM Gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'Gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN Gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  




