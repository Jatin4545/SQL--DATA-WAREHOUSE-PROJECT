/*
================================================================================
DDL Script: Create Gold Views
================================================================================

Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
================================================================================
*/

CREATE VIEW GOLD.DIM_CUSTOMERS AS
SELECT 
ROW_NUMBER() OVER(ORDER BY CST_ID)  AS CUSTOMER_KEY,
CI.cst_id AS  CUSTOMER_ID,
CI.cst_key  AS CUSTOMER_NUMBER,
CI.cst_firstname  AS FIRST_NAME,
CI.cst_lastname AS  LAST_NAME,
CI.cst_marital_status  AS MARITAL_STATUS,
CA.BDATE  AS BIRTH_DATE,
CI.cst_create_date  AS CREATE_DATE,
CASE WHEN  CI.cst_gndr != 'n/a' THEN CI.cst_gndr
   ELSE COALESCE(CA.GEN, 'n/a')
   end as GENDER,
LO.CNTRY AS COUNTRY
FROM SILVER.CRM_CUST_INFO CI
LEFT JOIN SILVER.ERP_CUST_AZ12 CA
ON        CA.CID= CI.CST_KEY
LEFT JOIN SILVER.ERP_LOC_A101 LO
ON        LO.CID= CI.CST_KEY


--sales layer
CREATE VIEW GOLD.FACT_SALES AS 
select sls_ord_num as ORDER_NUMBER ,
pd.product_key AS PRODUCT_KEY,
cd.customer_key  AS CUSTOMER_KEY,
sls_order_dt   AS  ORDER_DATE,
sls_ship_dt  AS  SHIP_DATE,
sls_due_dt AS DUE_DATE,
sls_sales  AS SALES ,
sls_quantity  AS QUANTITY,
sls_price AS PRICE
from silver.crm_sales_details sd
left join gold_product_dim pd
on sd.sls_prd_key=  pd.product_number
LEFT JOIN GOLD.DIM_CUSTOMERS CD
ON CD.CUSTOMER_ID= sd.sls_cust_id
