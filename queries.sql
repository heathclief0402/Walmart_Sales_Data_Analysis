-- create database

use database sale;
use schema sale_data;
CREATE OR REPLACE TABLE sales_data_raw (
    invoice_id         VARCHAR,
    branch             VARCHAR,
    city               VARCHAR,
    customer_type      VARCHAR,
    gender             VARCHAR,
    product_line       VARCHAR,
    unit_price         VARCHAR,
    quantity           VARCHAR,
    vat                VARCHAR,
    total              VARCHAR,
    date               VARCHAR,
    time               VARCHAR,
    payment            VARCHAR,
    cogs               VARCHAR,
    gross_margin_pct   VARCHAR,
    gross_income       VARCHAR,
    rating             VARCHAR
);
 -- SELECT * FROM sales_data_raw LIMIT 20;

-- restructure the data

CREATE OR REPLACE TABLE sales_data_cleaned AS
SELECT
    invoice_id,
    branch,
    city,
    customer_type,
    gender,
    product_line,
    TRY_CAST(unit_price AS DECIMAL(10, 2)) AS unit_price,
    TRY_CAST(quantity AS INT) AS quantity,
    TRY_CAST(vat AS FLOAT) AS vat,
    TRY_CAST(total AS DECIMAL(12, 4)) AS total,
    TRY_TO_DATE(date, 'YYYY-MM-DD') AS date,
    TRY_TO_TIME(time, 'HH24:MI:SS') AS time,
    payment,
    TRY_CAST(cogs AS DECIMAL(10, 2)) AS cogs,
    TRY_CAST(gross_margin_pct AS FLOAT) AS gross_margin_pct,
    TRY_CAST(gross_income AS DECIMAL(12, 4)) AS gross_income,
    TRY_CAST(rating AS FLOAT) AS rating
FROM sales_data_raw;
-- DESCRIBE TABLE sales_data_cleaned; -- to see if the table present the corret schema before doing any analysis.

-- 1. DATA WRANGLING: Check for NULLs
-- --------------------------------------
-- Check columns that might have NULL values
SELECT 
    COUNT(*) AS total_rows,
    COUNT_IF(invoice_id IS NULL) AS null_invoice_id,
    COUNT_IF(branch IS NULL) AS null_branch,
    COUNT_IF(city IS NULL) AS null_city,
    COUNT_IF(customer_type IS NULL) AS null_customer_type,
    COUNT_IF(gender IS NULL) AS null_gender,
    COUNT_IF(product_line IS NULL) AS null_product_line,
    COUNT_IF(unit_price IS NULL) AS null_unit_price,
    COUNT_IF(quantity IS NULL) AS null_quantity,
    COUNT_IF(vat IS NULL) AS null_vat,
    COUNT_IF(total IS NULL) AS null_total,
    COUNT_IF(date IS NULL) AS null_date,
    COUNT_IF(time IS NULL) AS null_time,
    COUNT_IF(payment IS NULL) AS null_payment,
    COUNT_IF(cogs IS NULL) AS null_cogs,
    COUNT_IF(gross_margin_pct IS NULL) AS null_gross_margin_pct,
    COUNT_IF(gross_income IS NULL) AS null_gross_income,
    COUNT_IF(rating IS NULL) AS null_rating
FROM sales_data_cleaned;


-- data engineering

ALTER TABLE sales_data_cleaned 
ADD COLUMN time_of_day VARCHAR(20);

ALTER TABLE sales_data_cleaned 
ADD COLUMN day_name VARCHAR(10);

ALTER TABLE sales_data_cleaned 
ADD COLUMN month_name VARCHAR(10);


UPDATE sales_data_cleaned
SET time_of_day = CASE 
    WHEN EXTRACT(HOUR FROM time) BETWEEN 0 AND 11 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 16 THEN 'Afternoon'
    ELSE 'Evening'
END;

UPDATE sales_data_cleaned
SET day_name = TO_CHAR(date, 'DY');

UPDATE sales_data_cleaned
SET month_name = TO_CHAR(date, 'MON');

SELECT date, time, time_of_day, day_name, month_name
FROM sales_data_cleaned
LIMIT 10;


-- generic questions

-- 2. How many distinct cities are present in the dataset?
select count(distinct city) as distict_city_count from sales_data_cleaned;

/*
DISTICT_CITY_COUNT
3
*/

-- 3. In which city is each branch situated?

SELECT DISTINCT branch, city
FROM sale.sale_data.sales_data_cleaned;

/*
BRANCH	CITY
A	Yangon
C	Naypyitaw
B	Mandalay
*/

-- product analysis
/*
format by: 
-- question
query 
output
*/


/*
output

*/

-- 3. How many distinct product lines are there in the dataset?

SELECT COUNT(DISTINCT product_line) AS distinct_product_lines
FROM sale.sale_data.sales_data_cleaned;

/*
output

DISTINCT_PRODUCT_LINES
6
*/

-- 4. What is the most common payment method?
SELECT payment, COUNT(*) AS count
FROM sale.sale_data.sales_data_cleaned
GROUP BY payment
ORDER BY count DESC
LIMIT 1;

/*
output

PAYMENT	COUNT
Ewallet	345
*/

-- 5. What is the most selling product line?

SELECT product_line, SUM(quantity) AS total_quantity_sold
FROM sale.sale_data.sales_data_cleaned
GROUP BY product_line
ORDER BY total_quantity_sold DESC
LIMIT 1;

/*
output

PRODUCT_LINE	TOTAL_QUANTITY_SOLD
Electronic accessories	971
*/

-- 6. What is the total revenue by month?

SELECT month_name, SUM(total) AS total_revenue
FROM sale.sale_data.sales_data_cleaned
GROUP BY month_name
ORDER BY total_revenue DESC;

/*
output

MONTH_NAME	TOTAL_REVENUE
Jan	116291.8680
Mar	109455.5070
Feb	97219.3740
*/

-- 7. Which month recorded the highest Cost of Goods Sold (COGS)?

SELECT month_name, SUM(cogs) AS total_cogs
FROM sale.sale_data.sales_data_cleaned
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

/*
output

MONTH_NAME	TOTAL_COGS
Jan	110754.16
*/

-- 8. Which product line generated the highest revenue?

SELECT product_line, SUM(total) AS total_revenue
FROM sale.sale_data.sales_data_cleaned
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

/*
output

PRODUCT_LINE	TOTAL_REVENUE
Food and beverages	56144.8440
*/

-- 9. Which city has the highest revenue?

SELECT city, SUM(total) AS total_revenue
FROM sale.sale_data.sales_data_cleaned
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

/*
output

PRODUCT_LINE	TOTAL_REVENUE
Food and beverages	56144.8440
*/

-- 10. Which product line incurred the highest VAT?

SELECT product_line, SUM(vat) AS total_vat
FROM sale.sale_data.sales_data_cleaned
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

/*
output

PRODUCT_LINE	TOTAL_VAT
Food and beverages	2673.564
*/


-- 11. Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,' based on whether its sales are above the average.

WITH product_sales AS (
    SELECT product_line, SUM(total) AS total_sales
    FROM sale.sale_data.sales_data_cleaned
    GROUP BY product_line
),
avg_sales AS (
    SELECT AVG(total_sales) AS avg_total_sales
    FROM product_sales
)
SELECT 
    ps.product_line,
    ps.total_sales,
    CASE 
        WHEN ps.total_sales > a.avg_total_sales THEN 'Good'
        ELSE 'Bad'
    END AS product_category
FROM product_sales ps
CROSS JOIN avg_sales a;

/*
output

PRODUCT_LINE	TOTAL_SALES	PRODUCT_CATEGORY
Health and beauty	49193.7390	Bad
Electronic accessories	54337.5315	Good
Home and lifestyle	53861.9130	Good
Sports and travel	55122.8265	Good
Food and beverages	56144.8440	Good
Fashion accessories	54305.8950	Good
*/

-- 12. Which branch sold more products than average product sold?

WITH branch_sales AS (
    SELECT branch, SUM(quantity) AS total_quantity
    FROM sale.sale_data.sales_data_cleaned
    GROUP BY branch
),
avg_sales AS (
    SELECT AVG(total_quantity) AS avg_quantity
    FROM branch_sales
)
SELECT 
    bs.branch,
    bs.total_quantity
FROM branch_sales bs
JOIN avg_sales a ON bs.total_quantity > a.avg_quantity;

/*
output

BRANCH	TOTAL_QUANTITY
A	1859
*/

-- 13. What is the most common product line by gender?

SELECT gender, product_line, COUNT(*) AS count
FROM sale.sale_data.sales_data_cleaned
GROUP BY gender, product_line
QUALIFY ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) = 1;

/*

GENDER	PRODUCT_LINE	COUNT
Female	Fashion accessories	96
Male	Health and beauty	88

*/

-- 14. What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM sale.sale_data.sales_data_cleaned
GROUP BY product_line
ORDER BY avg_rating DESC;

/*

PRODUCT_LINE	AVG_RATING
Food and beverages	7.11
Fashion accessories	7.03
Health and beauty	7
Electronic accessories	6.92
Sports and travel	6.92
Home and lifestyle	6.84
*/

-- sale_analysis

/*
format by: 
-- question
query 
output
*/


/*
output

*/

-- Number of sales made in each time of the day per weekday

SELECT 
    day_name,
    time_of_day,
    COUNT(*) AS total_sales
FROM sale.sale_data.sales_data_cleaned
GROUP BY day_name, time_of_day
ORDER BY day_name, time_of_day;

/*
output

DAY_NAME	TIME_OF_DAY	TOTAL_SALES
Fri	Afternoon	68
Fri	Evening	42
Fri	Morning	29
Mon	Afternoon	64
Mon	Evening	40
Mon	Morning	21
Sat	Afternoon	69
Sat	Evening	67
Sat	Morning	28
Sun	Afternoon	59
Sun	Evening	52
Sun	Morning	22
Thu	Afternoon	61
Thu	Evening	44
Thu	Morning	33
Tue	Afternoon	62
Tue	Evening	60
Tue	Morning	36
Wed	Afternoon	71
Wed	Evening	50
Wed	Morning	22
*/

-- Identify the customer type that generates the highest revenue

SELECT 
    customer_type,
    SUM(total) AS total_revenue
FROM sale.sale_data.sales_data_cleaned
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

/*
output

CUSTOMER_TYPE	TOTAL_REVENUE
Member	164223.4440
*/


--  Which city has the largest tax percent/VAT?

SELECT 
    city,
    SUM(vat) AS total_vat
FROM sale.sale_data.sales_data_cleaned
GROUP BY city
ORDER BY total_vat DESC
LIMIT 1;

/*
output

CITY	TOTAL_VAT
Naypyitaw	5265.1765
*/


-- Which customer type pays the most VAT?
SELECT 
    customer_type,
    SUM(vat) AS total_vat
FROM sale.sale_data.sales_data_cleaned
GROUP BY customer_type
ORDER BY total_vat DESC
LIMIT 1;

/*
output

CUSTOMER_TYPE	TOTAL_VAT
Member	7820.164
*/

-- Revenue by Branch

SELECT branch, SUM(total) AS total_revenue
FROM sale.sale_data.sales_data_cleaned
GROUP BY branch
ORDER BY total_revenue DESC;

/*
BRANCH	TOTAL_REVENUE
C	110568.7065
A	106200.3705
B	106197.6720
*/

-- customer analysis

/*
format by: 
-- question
query 
output
*/


/*
output

*/


-- How many unique customer types does the data have?

SELECT COUNT(DISTINCT customer_type) AS unique_customer_types
FROM sale.sale_data.sales_data_cleaned;

/*
UNIQUE_CUSTOMER_TYPES
2

*/

-- How many unique payment methods does the data have?

SELECT COUNT(DISTINCT payment) AS unique_payment_methods
FROM sale.sale_data.sales_data_cleaned;

/*
UNIQUE_PAYMENT_METHODS
3

*/

-- Which is the most common customer type?
SELECT customer_type, COUNT(*) AS count
FROM sale.sale_data.sales_data_cleaned
GROUP BY customer_type
ORDER BY count DESC
LIMIT 1;

/*
CUSTOMER_TYPE	COUNT
Member	501

*/

-- Which customer type buys the most (by quantity)?

SELECT 
    customer_type,
    SUM(quantity) AS total_quantity
FROM sale.sale_data.sales_data_cleaned
GROUP BY customer_type
ORDER BY total_quantity DESC
LIMIT 1;

/*
CUSTOMER_TYPE	TOTAL_QUANTITY
Member	2785

*/

-- What is the gender of most of the customers?

SELECT gender, COUNT(*) AS total_customers
FROM sale.sale_data.sales_data_cleaned
GROUP BY gender
ORDER BY total_customers DESC
LIMIT 1;

/*
GENDER	TOTAL_CUSTOMERS
Female	501

*/

-- What is the gender distribution per branch?

SELECT 
    branch,
    gender,
    COUNT(*) AS customer_count
FROM sale.sale_data.sales_data_cleaned
GROUP BY branch, gender
ORDER BY branch, customer_count DESC;

/*
BRANCH	GENDER	CUSTOMER_COUNT
A	Male	179
A	Female	161
B	Male	170
B	Female	162
C	Female	178
C	Male	150

*/

-- Which time of the day do customers give most ratings?

SELECT 
    time_of_day,
    COUNT(rating) AS rating_count
FROM sale.sale_data.sales_data_cleaned
GROUP BY time_of_day
ORDER BY rating_count DESC;

/*
TIME_OF_DAY	RATING_COUNT
Afternoon	454
Evening	355
Morning	191

*/

-- Which time of the day do customers give most ratings per branch?

SELECT 
    branch,
    time_of_day,
    COUNT(rating) AS rating_count
FROM sale.sale_data.sales_data_cleaned
GROUP BY branch, time_of_day
ORDER BY branch, rating_count DESC;

/*
BRANCH	TIME_OF_DAY	RATING_COUNT
A	Afternoon	158
A	Evening	109
A	Morning	73
B	Afternoon	142
B	Evening	131
B	Morning	59
C	Afternoon	154
C	Evening	115
C	Morning	59
*/

-- Which day of the week has the best average ratings?

SELECT 
    day_name,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sale.sale_data.sales_data_cleaned
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;

/*
DAY_NAME	AVG_RATING
Mon	7.15
*/

-- Which day of the week has the best average ratings per branch?

SELECT 
    branch,
    day_name,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sale.sale_data.sales_data_cleaned
GROUP BY branch, day_name
QUALIFY ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) = 1;

/*
BRANCH	DAY_NAME	AVG_RATING
A	Fri	7.31
C	Fri	7.28
B	Mon	7.34
*/

-- AOV by customer type or product line

SELECT customer_type, ROUND(SUM(total)/COUNT(DISTINCT invoice_id), 2) AS avg_order_value
FROM sale.sale_data.sales_data_cleaned
GROUP BY customer_type;

/*
CUSTOMER_TYPE	AVG_ORDER_VALUE
Member	327.79
Normal	318.12
*/

-- AOV by Gender

SELECT gender, ROUND(SUM(total)/COUNT(DISTINCT invoice_id), 2) AS avg_order_value
FROM sale.sale_data.sales_data_cleaned
GROUP BY gender;

/*
GENDER	AVG_ORDER_VALUE
Female	335.10
Male	310.79
*/










