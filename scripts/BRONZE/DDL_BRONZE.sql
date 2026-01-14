--  CREATE BRONZE LAYER TABLE
--============================================================================================
--SCRIPT  PURPOSE 
--THIS SCRIPT CREATES TABLE IN THE BRONZE SCHEMA , DROP EXISTING TABLE IF ALREADY EXISTS
--RUN THIS SCRIPT TO RE- DESIGN THE DDL STRUCTURE OF BRNZE TABLE 
--================================================================================================
CREATE TABLE BRONZE.CRM_CUST_INFO(
cst_id INT  ,
cst_key  NVARCHAR(50) ,
cst_firstname  VARCHAR(50) ,
cst_lastname  VARCHAR(50)  ,
cst_marital_status  VARCHAR(50),
cst_gndr  VARCHAR(20),
cst_create_date  DATE
)


CREATE TABLE BRONZE.CRM_PRD_INFO(
prd_id INT,
prd_key  NVARCHAR(50),
prd_nm  NVARCHAR(50),
prd_cost INT,
prd_line   NVARCHAR(50),
prd_start_dt  DATETIME,
prd_end_dt DATETIME
)


CREATE TABLE BRONZE.CRM_SALES_DETAILS(
sls_ord_num NVARCHAR(50),
sls_prd_key  NVARCHAR(50),
sls_cust_id   INT,
sls_order_dt  INT,
sls_ship_dt  INT,
sls_due_dt INT,
sls_sales  INT,
sls_quantity  INT,
sls_price  INT

)


CREATE TABLE BRONZE.ERP_CUST_AZ12(
CID  NVARCHAR(50),
BDATE  DATE ,
GEN  VARCHAR(50)
)


CREATE TABLE BRONZE.ERP_LOC_A101(
CID  NVARCHAR(50),
CNTRY  NVARCHAR(50)
)

CREATE TABLE BRONZE.ERP_PX_CAT_G1V2(
ID NVARCHAR(50),
CAT NVARCHAR(50),
SUBCAT  NVARCHAR(50),
MAINTENANCE  NVARCHAR(50)
)



--  INSERT  DATAAAAAAAAA

CREATE OR ALTER PROCEDURE BRONZE.LOAD_BRONZE  AS 
BEGIN

DECLARE @START_TIME DATETIME, @END_TIME DATETIME, @BATCH_START_TIME DATETIME , @BATCH_END_TIME DATETIME
BEGIN TRY

	SET  @BATCH_START_TIME  =GETDATE()
	PRINT '=============================================='
	PRINT 'LOADING BRONZE DATA'
	PRINT '=============================================='


	PRINT '-----------------------------------------------'
	PRINT 'LOADING CRM DATA'
	PRINT '-----------------------------------------------'

	SET @START_TIME = GETDATE()
	TRUNCATE TABLE BRONZE.CRM_CUST_INFO

	BULK INSERT BRONZE.CRM_CUST_INFO
	FROM  'C:\Users\HP-1\Downloads\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	with( firstrow=2,
	fieldterminator =',',
	TABLOCK
	)
	SET @END_TIME = GETDATE()
	PRINT '>>LOAD DURATION :' + CAST(DATEDIFF(SECOND, @START_TIME,@END_TIME )AS NVARCHAR)+ ' SECONDS'




  
	SET @START_TIME = GETDATE()
	TRUNCATE TABLE BRONZE.CRM_PRD_INFO

	BULK INSERT BRONZE.CRM_PRD_INFO
	FROM  'C:\Users\HP-1\Downloads\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	with( firstrow=2,
	fieldterminator =',',
	TABLOCK
	)
	SET @END_TIME = GETDATE()
	PRINT '>>LOAD DURATION :' + CAST(DATEDIFF(SECOND, @START_TIME,@END_TIME )AS NVARCHAR)+ ' SECONDS'



  

	SET @START_TIME = GETDATE()
	TRUNCATE TABLE BRONZE.CRM_SALES_DETAILS

	BULK INSERT BRONZE.CRM_SALES_DETAILS
	FROM  'C:\Users\HP-1\Downloads\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	with( firstrow=2,
	fieldterminator =',',
	TABLOCK
	)
	SET @END_TIME = GETDATE()
	PRINT '>>LOAD DURATION :' + CAST(DATEDIFF(SECOND, @START_TIME,@END_TIME )AS NVARCHAR)+ ' SECONDS'



  

	PRINT '-----------------------------------------------'
	PRINT 'LOADING ERP DATA'
	PRINT '-----------------------------------------------'


	SET @START_TIME = GETDATE()
	TRUNCATE TABLE BRONZE.ERP_CUST_AZ12

	BULK INSERT BRONZE.ERP_CUST_AZ12
	FROM  'C:\Users\HP-1\Downloads\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	with( firstrow=2,
	fieldterminator =',',
	TABLOCK
	)
	SET @END_TIME = GETDATE()
	PRINT '>>LOAD DURATION :' + CAST(DATEDIFF(SECOND, @START_TIME,@END_TIME )AS NVARCHAR)+ ' SECONDS'




  

	SET @START_TIME = GETDATE()
	TRUNCATE TABLE BRONZE.ERP_LOC_A101

	BULK INSERT BRONZE.ERP_LOC_A101
	FROM  'C:\Users\HP-1\Downloads\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	with( firstrow=2,
	fieldterminator =',',
	TABLOCK
	)
	SET @END_TIME = GETDATE()
	PRINT '>>LOAD DURATION :' + CAST(DATEDIFF(SECOND, @START_TIME,@END_TIME )AS NVARCHAR)+ ' SECONDS'



  

	SET @START_TIME = GETDATE()
	TRUNCATE TABLE BRONZE.ERP_PX_CAT_G1V2

	BULK INSERT BRONZE.ERP_PX_CAT_G1V2
	FROM  'C:\Users\HP-1\Downloads\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	with( firstrow=2,
	fieldterminator =',',
	TABLOCK
	)
	SET @END_TIME = GETDATE()
	PRINT '>>LOAD DURATION :' + CAST(DATEDIFF(SECOND, @START_TIME,@END_TIME )AS NVARCHAR)+ ' SECONDS'

	SET  @BATCH_END_TIME  =GETDATE()
	PRINT '>>LOAD  BATCH DURATION :' + CAST(DATEDIFF(SECOND,  @BATCH_START_TIME, @BATCH_END_TIME )AS NVARCHAR)+ ' SECONDS'

END TRY 



  
BEGIN CATCH
	PRINT '==================================================='
	PRINT 'ERROR OCCRED DUURING LOADING BRONZE LAYER'
	PRINT 'ERROR MESSAGE :' + ERROR_MESSAGE();
	PRINT 'ERROR MESSAGE :' + CAST (ERROR_NUMBER() AS NVARCHAR)
	PRINT 'ERROR MESSAGE :' + CAST (ERROR_STATE() AS NVARCHAR)
	PRINT '==================================================='

END CATCH
END


EXEC BRONZE.LOAD_BRONZE

