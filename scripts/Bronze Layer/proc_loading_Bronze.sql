
 /*
===============================================================================
Stored Procedure: Load Data into Bronze Layer (Source → Bronze)
===============================================================================

Description:
    This stored procedure is responsible for loading raw data into the 'bronze' layer
    from external CSV files. It ensures that the Bronze tables are refreshed before each load.

Key Steps:
    - Clears existing data from Bronze tables using TRUNCATE.
    - Imports data from CSV files into the corresponding tables using BULK INSERT.

Parameters:
    None.
    This procedure does not accept input parameters and does not return any output.

Example Usage:
    EXEC bronze.load_bronze;

===============================================================================
*/


CREATE OR ALTER PROCEDURE Bronze.load_bronze AS 
BEGIN

	DECLARE @Start_time DATETIME , @End_time DATETIME , @Batch_start_time DATETIME , @Batch_End_time DATETIME;
	
	BEGIN TRY
		SET @Batch_start_time = GETDATE();
		PRINT '==========================================================';
		PRINT ' LOADING BRONZE LAYER';
		PRINT '==========================================================' ;

		PRINT '----------------------------------------------------------';
		PRINT ' LOADING CRM TABLES'
		PRINT '----------------------------------------------------------';

		SET @Start_time = GETDATE();
		TRUNCATE TABLE Bronze.crm_cust_info ;
		PRINT ' >>> INSERTING INTO : bronze.crm_cust_info' ;
		BULK INSERT Bronze.crm_cust_info
		FROM 'D:\online courses\SQL\Baraa- Done\SQL\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @End_time = GETDATE();
		PRINT ' THE LOADING DURATION :' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT ' >> ---------------------------------------';

		SET @Start_time = GETDATE();
		TRUNCATE TABLE Bronze.crm_prd_info ;
		PRINT ' >>> INSERTING INTO : bronze.crm_prd_info' ;
		BULK INSERT Bronze.crm_prd_info
		FROM 'D:\online courses\SQL\Baraa- Done\SQL\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
		SET @End_time = GETDATE();
		PRINT ' THE LOADING DURATION :' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT ' >> ---------------------------------------';

		SET @Start_time = GETDATE();
		TRUNCATE TABLE Bronze.crm_sales_details ;
		PRINT ' >>> INSERTING INTO : bronze.crm_sales_details' ;
		BULK INSERT Bronze.crm_sales_details
		FROM 'D:\online courses\SQL\Baraa- Done\SQL\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		)
				SET @End_time = GETDATE();
		PRINT ' THE LOADING DURATION :' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT ' >> ---------------------------------------';

		PRINT '----------------------------------------------------------';
		PRINT ' LOADING ERP TABLES'
		PRINT '----------------------------------------------------------';
		
		
		SET @Start_time = GETDATE();
		TRUNCATE TABLE Bronze.erp_cust_az12 ;
		PRINT ' >>> INSERTING INTO : bronze.erp_cust_az12' ;
		BULK INSERT Bronze.erp_cust_az12
		FROM 'D:\online courses\SQL\Baraa- Done\SQL\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT ' THE LOADING DURATION :' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT ' >> ---------------------------------------';

		SET @Start_time = GETDATE();
		TRUNCATE TABLE Bronze.erp_loc_a101 ;
		PRINT ' >>> INSERTING INTO : bronze.erp_loc_a101' ;
		BULK INSERT Bronze.erp_loc_a101
		FROM 'D:\online courses\SQL\Baraa- Done\SQL\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT ' THE LOADING DURATION :' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT ' >> ---------------------------------------';

		SET @Start_time = GETDATE();
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2 ;
		PRINT ' >>> INSERTING INTO : bronze.erp_px_cat_g1v2' ;
		BULK INSERT Bronze.erp_px_cat_g1v2
		FROM 'D:\online courses\SQL\Baraa- Done\SQL\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT ' THE LOADING DURATION :' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT ' >> ---------------------------------------';

		SET @Batch_End_time = GETDATE();
		PRINT '==========================================================';
		PRINT ' THE BRONZE LAYER LOADING IS COMPLETED';
		PRINT ' THE TOTAL BRONZE LAYER LOADING DURATION: ' + CAST(DATEDIFF(SECOND, @Batch_start_time, @Batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '==========================================================';
	
	END TRY
	BEGIN CATCH
		PRINT '==========================================================';
		PRINT ' ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT ' ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT ' ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '==========================================================' ;
	END CATCH
	
END
