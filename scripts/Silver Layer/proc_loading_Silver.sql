 /*
===============================================================================
Stored Procedure: Load Data into Silver Layer (Bronze → Silver)
===============================================================================

Description:
    This stored procedure performs the ETL process to move data from the
    'bronze' layer into the 'silver' layer. It applies basic transformations
    and data cleansing to prepare the data for analytical use.

Key Steps:
    - Truncates existing Silver tables to ensure a fresh load.
    - Inserts cleaned and transformed data from Bronze into Silver tables.

Parameters:
    None.
    This procedure does not accept input parameters and does not return any output.

Example Usage:
    EXEC silver.load_silver;

===============================================================================
*/


CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
	

		DECLARE @Start_time DATETIME , @End_time DATETIME, @Batch_start_time DATETIME , @Batch_end_time DATETIME

	BEGIN TRY 

		SET @Batch_start_time = GETDATE();
		PRINT' ==========================================================';
		PRINT(' LOADING SILVER LAYER ...');
		PRINT' ==========================================================';

		PRINT '----------------------------------------------------------';
		PRINT ' LOADING CRM TABLES'
		PRINT '----------------------------------------------------------';


		SET @Start_time = GETDATE();
		PRINT' >>TRUNCATING TABLE : Silver.crm_cust_info';
		TRUNCATE TABLE Silver.crm_cust_info;
		PRINT' >>> INSERTING DATA INTO TABLE: Silver.crm_cust_info';
		INSERT INTO Silver.crm_cust_info ( cst_iD, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
		
		SELECT 
			cst_iD,
			cst_key,
			TRIM(cst_firstname) AS TrimmedFirstname, 
			TRIM(cst_lastname) AS TrimmedLastname , 
	
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a' 
			END AS cst_marital_status,

			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a' 
			END AS cst_gndr,

			cst_create_date 

		FROM(
			SELECT 
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_iD ORDER BY cst_create_date DESC) AS FlagLast

			FROM Bronze.crm_cust_info
			WHERE cst_iD IS NOT NULL)t

		WHERE FlagLast = 1

		SET @End_time = GETDATE();
		PRINT' THE LOADING DURATION:' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS VARCHAR) + 'seconds'
		PRINT ' >> -------------------------------------------------------------------------'




		SET @Start_time = GETDATE();
		PRINT' >>TRUNCATING TABLE : Silver.crm_prd_info';
		TRUNCATE TABLE Silver.crm_prd_info;
		PRINT' >>> INSERTING DATA INTO TABLE: Silver.crm_prd_info';
		INSERT INTO Silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
		
		SELECT
			prd_id,
 			REPLACE(SUBSTRING(prd_key,1, 5), '-' ,'_') AS cat_id,
			SUBSTRING(prd_key,7, LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,

			CASE UPPER(TRIM(prd_line))
				WHEN 'S' THEN 'Other Sales '
				WHEN 'M' THEN 'Mountain'
				WHEN 'T'  THEN 'Touring'
				WHEN 'R' THEN 'Road'
				ELSE 'n/a'
			END AS prd_line,

			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt

		FROM Bronze.crm_prd_info

		SET @End_time = GETDATE();
		PRINT' THE LOADING DURATION:' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS VARCHAR) + 'seconds'
		PRINT ' >> -------------------------------------------------------------------------'


		SET @Start_time = GETDATE();
		PRINT' >>TRUNCATING TABLE : Silver.crm_sales_details';
		TRUNCATE TABLE Silver.crm_sales_details;
		PRINT' >>> INSERTING DATA INTO TABLE: Silver.crm_sales_details';
		INSERT INTO Silver.crm_sales_details (sls_ord_num , sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt,sls_sales, sls_quantity, sls_price) 

		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,

			CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) < 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			 END  AS sls_ord_dt ,

			CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) < 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
			END  AS sls_ship_dt,

			CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) < 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
			END  AS sls_due_dt,
		
			CASE WHEN  sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_quantity) * ABS(sls_price) THEN ABS(sls_quantity) * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, 

			sls_quantity,

			CASE  WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity,0)
				  ELSE sls_price
			END AS sls_price 
	
		FROM Bronze.crm_sales_details 

		SET @End_time = GETDATE();
		PRINT' THE LOADING DURATION:' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS VARCHAR) + 'seconds'
		PRINT ' >> -------------------------------------------------------------------------'


		PRINT '----------------------------------------------------------';
		PRINT ' LOADING ERP TABLES'
		PRINT '----------------------------------------------------------';


		SET @Start_time = GETDATE();
		PRINT' >>TRUNCATING TABLE : Silver.erp_cust_az12';
		TRUNCATE TABLE Silver.erp_cust_az12;
		PRINT' >>> INSERTING DATA INTO TABLE: Silver.erp_cust_az12';
		INSERT INTO Silver.erp_cust_az12 (cid, bdate,gen)

		SELECT 

			CASE WHEN cid LIKE 'NAS%' THEN REPLACE(cid, 'NAS', '')
				 ELSE cid
			END AS cid, 

			CASE WHEN bdate >= GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate,

			CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				 WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				 ELSE 'n/a'
			END AS gen
		
		FROM Bronze.erp_cust_az12

		SET @End_time = GETDATE();
		PRINT' THE LOADING DURATION:' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS VARCHAR) + 'seconds'
		PRINT ' >> -------------------------------------------------------------------------'


		SET @Start_time = GETDATE();
		PRINT' >>TRUNCATING TABLE : Silver.erp_loc_a101';
		TRUNCATE TABLE Silver.erp_loc_a101;
		PRINT' >>> INSERTING DATA INTO TABLE: Silver.erp_loc_a101';
		INSERT INTO Silver.erp_loc_a101 (cid , cntry)

		SELECT 
			REPLACE(cid,'-','') AS cid, 
			CASE 
				WHEN UPPER(TRIM(cntry)) IN ('US', 'UNITED STATES', 'United States') THEN 'USA'
				WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) IN ('UK', 'UNITED KINGDOM') THEN 'United Kingdom'
				WHEN cntry IS NULL OR TRIM(cntry) ='' THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry

		FROM Bronze.erp_loc_a101

		SET @End_time = GETDATE();
		PRINT' THE LOADING DURATION:' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS VARCHAR) + 'seconds'
		PRINT ' >> -------------------------------------------------------------------------'


		SET @Start_time = GETDATE();
		PRINT' >>TRUNCATING TABLE : Silver.erp_px_cat_g1v2';
		TRUNCATE TABLE Silver.erp_px_cat_g1v2;
		PRINT' >>> INSERTING DATA INTO TABLE: Silver.erp_px_cat_g1v2';
		INSERT INTO Silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)

		SELECT 
				id,
				cat,
				subcat,
				maintenance
      
		FROM Bronze.erp_px_cat_g1v2

		SET @End_time = GETDATE();
		PRINT' THE LOADING DURATION:' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS VARCHAR) + 'seconds'
		PRINT ' >> -------------------------------------------------------------------------'

		SET @Batch_end_time = GETDATE();
		PRINT' ===================================================';
		PRINT(' THE SILVER LAYER LOADING IS COMPLETED');
		PRINT' ===================================================';
		PRINT' THE TOTAL SILVER LAYER LOADING DURATION:' + CAST(DATEDIFF(SECOND, @Batch_start_time, @Batch_end_time) AS VARCHAR) + 'seconds'

	END TRY

	BEGIN CATCH
		PRINT '==========================================================';
		PRINT ' ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT ' ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT ' ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '==========================================================' ;

	END CATCH
END
