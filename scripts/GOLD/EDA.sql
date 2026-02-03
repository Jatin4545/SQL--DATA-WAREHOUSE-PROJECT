/* ================================================================
   FILE NAME    : DATA_EXPLORATION_AND_DESCRIPTIVE_ANALYTICS.sql
   AUTHOR       : Jatin Rathour
   DESCRIPTION  : Data exploration and descriptive analytics queries
                 to understand database structure, date ranges,
                 customer demographics, sales measures, magnitude
                 analysis, and top/bottom performance.

   DATA SOURCES
   ------------
   GOLD.FACT_SALES
   GOLD.DIM_CUSTOMERS
   GOLD_PRODUCT_DIM

================================================================ */


/* ================================================================
   1. DATABASE STRUCTURE EXPLORATION
   ---------------------------------------------------------------
   Explore all tables available in the database.
================================================================ */
SELECT *
FROM INFORMATION_SCHEMA.TABLES;


/* ================================================================
   Explore columns for DIM_CUSTOMERS table
================================================================ */
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DIM_CUSTOMERS';


/* ================================================================
   Preview Product Dimension
================================================================ */
SELECT
    CATEGORY,
    SUB_CATEGORY,
    PRODUCT_NAME
FROM GOLD_PRODUCT_DIM
ORDER BY CATEGORY, SUB_CATEGORY, PRODUCT_NAME;


/* ================================================================
   2. DATE EXPLORATION
   ---------------------------------------------------------------
   Identify first and last order dates.
================================================================ */
SELECT
    MIN(ORDER_DATE) AS FIRST_ORDER_DATE,
    MAX(ORDER_DATE) AS LAST_ORDER_DATE
FROM GOLD.FACT_SALES;


/* ================================================================
   Calculate number of years of available sales data
================================================================ */
SELECT
    DATEDIFF(YEAR, MIN(ORDER_DATE), MAX(ORDER_DATE)) AS YEARS_OF_DATA
FROM GOLD.FACT_SALES;


/* ================================================================
   Preview Customer Dimension
================================================================ */
SELECT *
FROM GOLD.DIM_CUSTOMERS;


/* ================================================================
   Find oldest and youngest customers and their ages
================================================================ */
SELECT
    MIN(BIRTH_DATE) AS OLDEST_BIRTH_DATE,
    DATEDIFF(YEAR, MIN(BIRTH_DATE), GETDATE()) AS OLDEST_CUSTOMER_AGE,
    MAX(BIRTH_DATE) AS YOUNGEST_BIRTH_DATE,
    DATEDIFF(YEAR, MAX(BIRTH_DATE), GETDATE()) AS YOUNGEST_CUSTOMER_AGE
FROM GOLD.DIM_CUSTOMERS;


/* ================================================================
   3. MEASURE EXPLORATION
   ---------------------------------------------------------------
   Understand core business measures.
================================================================ */
SELECT *
FROM GOLD.FACT_SALES;


/* Total Sales */
SELECT SUM(SALES) AS TOTAL_SALES
FROM GOLD.FACT_SALES;


/* Total Quantity Sold */
SELECT SUM(QUANTITY) AS TOTAL_QUANTITY
FROM GOLD.FACT_SALES;


/* Average Selling Price */
SELECT AVG(PRICE) AS AVG_PRICE
FROM GOLD.FACT_SALES;


/* Total Orders */
SELECT COUNT(ORDER_NUMBER) AS TOTAL_ORDERS
FROM GOLD.FACT_SALES;

SELECT COUNT(DISTINCT ORDER_NUMBER) AS DISTINCT_ORDERS
FROM GOLD.FACT_SALES;


/* Total Products */
SELECT COUNT(DISTINCT PRODUCT_KEY) AS TOTAL_PRODUCTS
FROM GOLD_PRODUCT_DIM;


/* Total Customers (who placed orders) */
SELECT COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMERS
FROM GOLD.FACT_SALES;


/* ================================================================
   Customers who have placed at least one order
================================================================ */
SELECT COUNT(*) AS CUSTOMERS_WITH_ORDERS
FROM GOLD.DIM_CUSTOMERS GC
WHERE EXISTS (
    SELECT 1
    FROM GOLD.FACT_SALES GS
    WHERE GC.CUSTOMER_KEY = GS.CUSTOMER_KEY
);


/* ================================================================
   Consolidated KPI Report
================================================================ */
SELECT 'TOTAL_SALES' AS MEASURE, SUM(SALES) AS VALUE FROM GOLD.FACT_SALES
UNION
SELECT 'TOTAL_QUANTITY', SUM(QUANTITY) FROM GOLD.FACT_SALES
UNION
SELECT 'AVG_PRICE', AVG(PRICE) FROM GOLD.FACT_SALES
UNION
SELECT 'TOTAL_ORDERS', COUNT(DISTINCT ORDER_NUMBER) FROM GOLD.FACT_SALES
UNION
SELECT 'TOTAL_PRODUCTS', COUNT(DISTINCT PRODUCT_KEY) FROM GOLD_PRODUCT_DIM
UNION
SELECT 'TOTAL_CUSTOMERS', COUNT(DISTINCT CUSTOMER_KEY) FROM GOLD.FACT_SALES;


/* ================================================================
   4. MAGNITUDE ANALYSIS (Measures by Dimensions)
================================================================ */


/* Customers by Gender */
SELECT
    GENDER,
    COUNT(CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM GOLD.DIM_CUSTOMERS
GROUP BY GENDER;


/* Customers by Country */
SELECT
    COUNTRY,
    COUNT(CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM GOLD.DIM_CUSTOMERS
GROUP BY COUNTRY
ORDER BY TOTAL_CUSTOMERS DESC;


/* Products by Category */
SELECT
    CATEGORY,
    COUNT(PRODUCT_ID) AS TOTAL_PRODUCTS
FROM GOLD_PRODUCT_DIM
GROUP BY CATEGORY
ORDER BY TOTAL_PRODUCTS DESC;


/* Average Product Cost by Category */
SELECT
    CATEGORY,
    AVG(PRODUCT_COST) AS AVERAGE_COST
FROM GOLD_PRODUCT_DIM
GROUP BY CATEGORY
ORDER BY AVERAGE_COST DESC;


/* Revenue by Category */
SELECT
    GP.CATEGORY,
    SUM(GS.SALES) AS REVENUE
FROM GOLD.FACT_SALES GS
LEFT JOIN GOLD_PRODUCT_DIM GP
    ON GP.PRODUCT_KEY = GS.PRODUCT_KEY
GROUP BY GP.CATEGORY
ORDER BY REVENUE DESC;


/* Revenue by Customer */
SELECT
    GC.CUSTOMER_KEY,
    GC.FIRST_NAME,
    GC.LAST_NAME,
    SUM(GS.SALES) AS REVENUE
FROM GOLD.FACT_SALES GS
LEFT JOIN GOLD.DIM_CUSTOMERS GC
    ON GC.CUSTOMER_KEY = GS.CUSTOMER_KEY
GROUP BY
    GC.CUSTOMER_KEY,
    GC.FIRST_NAME,
    GC.LAST_NAME
ORDER BY REVENUE DESC;


/* Quantity Sold by Country */
SELECT
    GC.COUNTRY,
    SUM(GS.QUANTITY) AS TOTAL_QUANTITY
FROM GOLD.FACT_SALES GS
LEFT JOIN GOLD.DIM_CUSTOMERS GC
    ON GC.CUSTOMER_KEY = GS.CUSTOMER_KEY
GROUP BY GC.COUNTRY
ORDER BY TOTAL_QUANTITY DESC;


/* ================================================================
   5. TOP-N / BOTTOM-N ANALYSIS
================================================================ */


/* Top 5 Products by Revenue */
SELECT TOP 5
    GP.PRODUCT_NAME,
    SUM(GS.SALES) AS REVENUE
FROM GOLD.FACT_SALES GS
LEFT JOIN GOLD_PRODUCT_DIM GP
    ON GP.PRODUCT_KEY = GS.PRODUCT_KEY
GROUP BY GP.PRODUCT_NAME
ORDER BY REVENUE DESC;


/* Bottom 5 Products by Revenue */
SELECT TOP 5
    GP.PRODUCT_NAME,
    SUM(GS.SALES) AS REVENUE
FROM GOLD.FACT_SALES GS
LEFT JOIN GOLD_PRODUCT_DIM GP
    ON GP.PRODUCT_KEY = GS.PRODUCT_KEY
GROUP BY GP.PRODUCT_NAME
ORDER BY REVENUE ASC;


/* Top 5 Sub-Categories by Revenue */
SELECT TOP 5
    GP.SUB_CATEGORY,
    SUM(GS.SALES) AS REVENUE
FROM GOLD.FACT_SALES GS
LEFT JOIN GOLD_PRODUCT_DIM GP
    ON GP.PRODUCT_KEY = GS.PRODUCT_KEY
GROUP BY GP.SUB_CATEGORY
ORDER BY REVENUE DESC;
