 /*
===============================================================================
DDL Script: Create Gold Layer Views
===============================================================================

Purpose:
    This script defines the views for the Gold layer of the data warehouse.
    The Gold layer represents the final, business-ready data model based on a
    Star Schema design (fact and dimension tables).

    Each view transforms and integrates data from the Silver layer to provide
    a clean, enriched, and analytics-ready dataset.

Usage:
    - These views are intended for analytical queries and reporting purposes.
    - They can be directly consumed by BI tools such as Power BI.

===============================================================================
*/

-- =============================================================================
-- View: Gold.dim_customers
-- =============================================================================

IF OBJECT_ID('Gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW Gold.dim_customers;
GO
CREATE VIEW Gold.dim_customers AS

SELECT 
	ROW_NUMBER() OVER(ORDER BY CI.cst_iD) AS customer_key,
	CI.cst_iD AS customer_id,
	CI.cst_key AS customer_number,
	CI.cst_firstname AS first_name,
	CI.cst_lastname AS last_name,
		LA.cntry AS country,
	CI.cst_marital_status AS marital_status,

	CASE WHEN CI.cst_gndr != 'n/a' THEN CI.cst_gndr
		 ELSE COALESCE(CA.gen, 'n/a')
	END AS gender, 

	CA.bdate AS birthday,
	CI.cst_create_date AS create_date


FROM Silver.crm_cust_info AS CI
LEFT JOIN Silver.erp_cust_az12 AS CA
ON CA.cid  = CI.cst_key

LEFT JOIN Silver.erp_loc_a101 AS LA
ON CI.cst_key = LA.cid

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('Gold.dim_products', 'V') IS NOT NULL
    DROP VIEW Gold.dim_products;
GO


CREATE OR ALTER VIEW Gold.dim_products AS 

SELECT 
	ROW_NUMBER() OVER(ORDER BY PRI.prd_start_dt, PRI.prd_key ) AS product_key ,
	PRI.prd_id AS product_id,
	PRI.prd_key AS product_number,
	PRI.prd_nm AS product_name,
	PRI.cat_id AS category_id,
	PC.cat AS category,
	PC.subcat AS subcategory,
	PC.maintenance,
	PRI.prd_line AS product_line,
	PRI.prd_cost AS product_cost,
	PRI.prd_start_dt AS start_date
	
FROM Silver.crm_prd_info AS PRI
JOIN Silver.erp_px_cat_g1v2 AS PC
ON PRI.cat_id = PC.id

WHERE PRI.prd_end_dt IS NULL -- FILTER OUT ALL HISTORICAL DATA >> NO NEED FOR END DATE ANY MORE

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW Gold.fact_sales;
GO


CREATE OR ALTER VIEW Gold.Fact_sales AS 

SELECT 
	sls_ord_num AS order_number,
	PR.product_key,
	CU.customer_key,
	sls_order_dt AS order_date,
	sls_ship_dt AS shipping_date,
	sls_due_dt AS due_date,
	sls_sales AS sales_amount,
	sls_quantity AS quantity,
	sls_price AS price
	

FROM Silver.crm_sales_details AS SD
LEFT JOIN Gold.dim_products AS PR
ON  SD.sls_prd_key = PR. product_number

LEFT JOIN Gold.dim_customers AS CU
ON SD.sls_cust_id = CU.customer_id










