/*
=============================================================
Database and Schema Setup
=============================================================
Purpose:
    This script is responsible for creating the 'DataWarehouse' database if it does not already exist.
    If a previous version of the database is found, it will be dropped and recreated to ensure a clean setup.
    It also defines the core schemas used in this project: 'bronze', 'silver', and 'gold'.
Important Note:
    Executing this script will remove the existing 'DataWarehouse' database (if present) along with all its data.
    This action is irreversible, so make sure any required data is backed up before running the script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO

CREATE SCHEMA gold;
GO

