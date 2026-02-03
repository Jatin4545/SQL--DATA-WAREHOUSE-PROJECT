/* ============================================================
   VIEW NAME      : GOLD.REPORT_CUSTOMER
   DESCRIPTION    : Creates a customer-level analytical report
                    combining sales and customer data.
                    Computes customer lifetime metrics,
                    aggregates sales behavior, and assigns
                    customer segments (VIP / REGULAR / NEW).

   AUTHOR         : Jatin Rathour
   CREATED DATE   : 2026-02-03

   DATA SOURCES
   -------------
   GOLD.FACT_SALES
   GOLD.DIM_CUSTOMERS

   OUTPUT
   ------
   One row per customer with:
   - Demographics
   - Order & product metrics
   - Customer lifespan
   - Average order value
   - Average monthly spending
   - Customer segment

============================================================ */

CREATE VIEW GOLD.REPORT_CUSTOMER AS

/* ============================================================
   BASE_QUERY CTE
   ------------------------------------------------------------
   Joins fact sales with customer dimension.
   Derives customer name and age.
   Filters out records with NULL order dates.
============================================================ */
WITH BASE_QUERY AS (
    SELECT  
        F.ORDER_NUMBER,
        F.PRODUCT_KEY,
        F.ORDER_DATE,
        F.SALES,
        F.QUANTITY,

        C.CUSTOMER_KEY,
        C.CUSTOMER_NUMBER,
        CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS CUSTOMER_NAME,

        -- Calculate customer age
        DATEDIFF(YEAR, C.BIRTH_DATE, GETDATE()) AS AGE

    FROM GOLD.FACT_SALES F
    LEFT JOIN GOLD.DIM_CUSTOMERS C
        ON F.CUSTOMER_KEY = C.CUSTOMER_KEY
    WHERE F.ORDER_DATE IS NOT NULL
),

/* ============================================================
   CUSTOMER_AGGREGATION CTE
   ------------------------------------------------------------
   Aggregates transactional data to customer level.
   Calculates total orders, sales, quantity, products,
   and customer lifespan.
============================================================ */
CUSTOMER_AGGREGATION AS (
    SELECT
        CUSTOMER_KEY,
        CUSTOMER_NUMBER,
        CUSTOMER_NAME,
        AGE,

        -- Number of unique orders
        COUNT(DISTINCT ORDER_NUMBER) AS TOTAL_ORDERS,

        -- Total sales amount
        SUM(SALES) AS TOTAL_SALES,

        -- Total quantity purchased
        SUM(QUANTITY) AS TOTAL_QUANTITY,

        -- Number of distinct products purchased
        COUNT(DISTINCT PRODUCT_KEY) AS TOTAL_PRODUCT,

        -- Months between first and last order
        DATEDIFF(MONTH, MIN(ORDER_DATE), MAX(ORDER_DATE)) AS LIFESPAN

    FROM BASE_QUERY
    GROUP BY
        CUSTOMER_KEY,
        CUSTOMER_NUMBER,
        CUSTOMER_NAME,
        AGE
)

/* ============================================================
   FINAL SELECT
   ------------------------------------------------------------
   Builds final customer report.
   Assigns customer segment.
   Calculates average order value
   and average monthly spending.
============================================================ */
SELECT
    CUSTOMER_KEY,
    CUSTOMER_NUMBER,
    CUSTOMER_NAME,
    AGE,

    /* -------------------------------
       Customer Segmentation Logic
       -------------------------------
       VIP      : Lifespan >= 12 months AND Sales > 5000
       REGULAR  : Lifespan >= 12 months AND Sales <= 5000
       NEW      : Lifespan < 12 months
    -------------------------------- */
    CASE
        WHEN LIFESPAN >= 12 AND TOTAL_SALES > 5000 THEN 'VIP'
        WHEN LIFESPAN >= 12 AND TOTAL_SALES <= 5000 THEN 'REGULAR'
        ELSE 'NEW'
    END AS CUSTOMER_SEGMENT,

    TOTAL_ORDERS,
    TOTAL_SALES,
    TOTAL_QUANTITY,
    TOTAL_PRODUCT,
    LIFESPAN,

    /* -------------------------------
       Average Order Value
       ------------------------------- */
    CASE
        WHEN TOTAL_SALES = 0 THEN 0
        ELSE TOTAL_SALES / TOTAL_ORDERS
    END AS AVG_ORDER_VALUE,

    /* -------------------------------
       Average Monthly Spending
       ------------------------------- */
    CASE
        WHEN TOTAL_SALES = 0 OR LIFESPAN = 0 THEN TOTAL_SALES
        ELSE TOTAL_SALES / LIFESPAN
    END AS AVG_MONTHLY_SPENDING

FROM CUSTOMER_AGGREGATION;
