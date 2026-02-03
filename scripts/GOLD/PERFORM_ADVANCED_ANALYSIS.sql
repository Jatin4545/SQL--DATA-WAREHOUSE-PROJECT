/* ================================================================
   FILE NAME     : ADVANCED_DATA_ANALYTICS.sql
   AUTHOR        : Jatin Rathour
   DESCRIPTION   : Collection of advanced analytical SQL queries
                   used for business intelligence and reporting.

   ANALYSIS TYPES COVERED
   ----------------------
   1. Change Over Time Analysis
   2. Cumulative & Moving Average Analysis
   3. Performance Trend Analysis
   4. Product Yearly Performance vs Average
   5. Part-to-Whole Contribution Analysis
   6. Product Cost Segmentation
   7. Customer Behavioral Segmentation

   DATA SOURCES
   ------------
   GOLD.FACT_SALES
   GOLD_PRODUCT_DIM
   GOLD.DIM_CUSTOMERS
================================================================ */


/* ================================================================
   1. CHANGE OVER TIME ANALYSIS
   ---------------------------------------------------------------
   Analyze yearly sales performance and customer activity.
================================================================ */
SELECT  
    YEAR(ORDER_DATE) AS ORDER_YEAR,
    COUNT(DISTINCT CUSTOMER_KEY) AS CUSTOMER_COUNT,
    SUM(QUANTITY) AS TOTAL_QUANTITY,
    SUM(SALES) AS TOTAL_SALES
FROM GOLD.FACT_SALES
WHERE ORDER_DATE IS NOT NULL
GROUP BY YEAR(ORDER_DATE)
ORDER BY ORDER_YEAR;


/* ================================================================
   2. CUMULATIVE ANALYSIS
   ---------------------------------------------------------------
   - Calculate monthly total sales.
   - Compute running total of sales within each year.
   - Calculate moving average of product price.
================================================================ */
SELECT
    ORDER_DATE,
    TOTAL_SALES,
    SUM(TOTAL_SALES) OVER (
        PARTITION BY YEAR(ORDER_DATE)
        ORDER BY ORDER_DATE
    ) AS RUNNING_TOTAL,
    AVG(AVG_PRICE) OVER (
        PARTITION BY YEAR(ORDER_DATE)
        ORDER BY ORDER_DATE
    ) AS MOVING_AVERAGE
FROM (
    SELECT
        DATETRUNC(MONTH, ORDER_DATE) AS ORDER_DATE,
        SUM(SALES) AS TOTAL_SALES,
        AVG(PRICE) AS AVG_PRICE
    FROM GOLD.FACT_SALES
    WHERE ORDER_DATE IS NOT NULL
    GROUP BY DATETRUNC(MONTH, ORDER_DATE)
) T;


/* ================================================================
   3. PERFORMANCE TREND ANALYSIS
   ---------------------------------------------------------------
   Compare monthly sales with previous month sales
   using LAG() function.
================================================================ */
SELECT
    YEAR(ORDER_DATE) AS YEAR,
    MONTH(ORDER_DATE) AS MONTH,
    SUM(SALES) AS TOTAL_SALES,
    LAG(SUM(SALES)) OVER (
        ORDER BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)
    ) AS PREVIOUS_SALES
FROM GOLD.FACT_SALES
WHERE ORDER_DATE IS NOT NULL
GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)
ORDER BY YEAR(ORDER_DATE), MONTH(ORDER_DATE);


/* ================================================================
   4. PRODUCT YEARLY PERFORMANCE ANALYSIS
   ---------------------------------------------------------------
   Compare each product's yearly sales with:
   - Its average sales
   - Determine if above / equal / below average
================================================================ */
WITH SALES_ANALYSIS AS (
    SELECT
        YEAR(ORDER_DATE) AS ORDER_YEAR,
        GP.PRODUCT_NAME,
        SUM(GS.SALES) AS TOTAL_SALES
    FROM GOLD.FACT_SALES GS
    LEFT JOIN GOLD_PRODUCT_DIM GP
        ON GP.PRODUCT_KEY = GS.PRODUCT_KEY
    WHERE ORDER_DATE IS NOT NULL
    GROUP BY YEAR(ORDER_DATE), GP.PRODUCT_NAME
)
SELECT
    ORDER_YEAR,
    PRODUCT_NAME,
    TOTAL_SALES,
    AVG(TOTAL_SALES) OVER (
        PARTITION BY PRODUCT_NAME
    ) AS AVG_SALES,

    (TOTAL_SALES -
     AVG(TOTAL_SALES) OVER (PARTITION BY PRODUCT_NAME)
    ) AS SALES_COMPARISON,

    CASE
        WHEN TOTAL_SALES >
             AVG(TOTAL_SALES) OVER (PARTITION BY PRODUCT_NAME)
        THEN 'ABOVE_AVERAGE'
        WHEN TOTAL_SALES =
             AVG(TOTAL_SALES) OVER (PARTITION BY PRODUCT_NAME)
        THEN 'AVERAGE'
        ELSE 'BELOW_AVERAGE'
    END AS ANALYSE_PERFORMANCE
FROM SALES_ANALYSIS
ORDER BY PRODUCT_NAME, ORDER_YEAR;


/* ================================================================
   5. PART-TO-WHOLE ANALYSIS
   ---------------------------------------------------------------
   Identify which product category contributes most
   to overall sales.
================================================================ */
WITH CATEGORY_SALES AS (
    SELECT
        GP.CATEGORY,
        SUM(GS.SALES) AS TOTAL_SALES
    FROM GOLD.FACT_SALES GS
    LEFT JOIN GOLD_PRODUCT_DIM GP
        ON GP.PRODUCT_KEY = GS.PRODUCT_KEY
    GROUP BY GP.CATEGORY
)
SELECT
    CATEGORY,
    TOTAL_SALES,
    SUM(TOTAL_SALES) OVER () AS OVERALL_SALES,
    CONCAT(
        ROUND(
            (CAST(TOTAL_SALES AS FLOAT)
             / SUM(TOTAL_SALES) OVER ()) * 100,
            2
        ),
        '%'
    ) AS TOTAL_CONTRIBUTION
FROM CATEGORY_SALES;


/* ================================================================
   6. PRODUCT COST SEGMENTATION
   ---------------------------------------------------------------
   Segment products into cost ranges and count
   how many products fall in each segment.
================================================================ */
WITH SEGMENT AS (
    SELECT
        PRODUCT_KEY,
        PRODUCT_NAME,
        PRODUCT_COST,
        CASE
            WHEN PRODUCT_COST < 100 THEN 'BELOW 100'
            WHEN PRODUCT_COST BETWEEN 100 AND 500 THEN '100-500'
            WHEN PRODUCT_COST BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'ABOVE 1000'
        END AS PRODUCT_SEGMENT
    FROM GOLD_PRODUCT_DIM
)
SELECT
    PRODUCT_SEGMENT,
    COUNT(PRODUCT_NAME) AS PRODUCTS
FROM SEGMENT
GROUP BY PRODUCT_SEGMENT
ORDER BY PRODUCTS DESC;


/* ================================================================
   7. CUSTOMER BEHAVIORAL SEGMENTATION
   ---------------------------------------------------------------
   Segment customers based on:
   - Relationship duration
   - Total sales value
================================================================ */
WITH SEGMENT AS (
    SELECT
        GC.CUSTOMER_KEY AS CUSTOMER,
        MIN(ORDER_DATE) AS FIRST_ORDER,
        MAX(ORDER_DATE) AS LAST_ORDER,
        SUM(GS.SALES) AS TOTAL_SALES
    FROM GOLD.DIM_CUSTOMERS GC
    LEFT JOIN GOLD.FACT_SALES GS
        ON GS.CUSTOMER_KEY = GC.CUSTOMER_KEY
    GROUP BY GC.CUSTOMER_KEY
),
DIFFERENCES AS (
    SELECT
        CUSTOMER,
        DATEDIFF(MONTH, FIRST_ORDER, LAST_ORDER) AS DATE_DIFFERENCE,
        TOTAL_SALES,
        CASE
            WHEN DATEDIFF(MONTH, FIRST_ORDER, LAST_ORDER) >= 12
                 AND TOTAL_SALES > 5000 THEN 'VIP'
            WHEN DATEDIFF(MONTH, FIRST_ORDER, LAST_ORDER) >= 12
                 AND TOTAL_SALES <= 5000 THEN 'REGULAR'
            ELSE 'NEW'
        END AS CUSTOMER_SEGMENT
    FROM SEGMENT
)
SELECT
    CUSTOMER_SEGMENT,
    COUNT(CUSTOMER) AS TOTAL_CUSTOMERS
FROM DIFFERENCES
GROUP BY CUSTOMER_SEGMENT;
