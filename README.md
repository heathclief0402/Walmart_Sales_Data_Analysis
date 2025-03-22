# Walmart Sales Data Analysis Using Snowflake

## 1. Executive Summary
I conducted a comprehensive analysis of Walmart’s sales data using Snowflake SQL, focusing on customer behavior, product performance, and regional trends across three cities: Yangon, Mandalay, and Naypyitaw. The data includes 1,000 clean and complete transactions.

Key findings:
- **Branch C (Naypyitaw)** recorded the highest VAT value at **$5,265.18**, suggesting strong revenue performance.
- **January** had the highest revenue (**$116,291.87**) and COGS (**$110,754.16**).
- **Electronic Accessories** was the most sold category (**971 units**).
- **Food and Beverages** brought in the most revenue (**$56,144.84**) and VAT (**$2,673.56**), and received the highest average rating (**7.11**).
- **Members** spent more (**$164,223.44**), purchased more (**2,785 items**), and paid more VAT (**$7,820.16**) than normal customers.
- **Afternoon** was the most active shopping period (**454 ratings**, highest sales volume), especially on **Wednesdays** (**71 sales**).
- **Monday** received the highest average rating (**7.15**). Branch-level top rating days: **Friday** for Branches A and C, **Monday** for Branch B.

### Key Recommendations:
- Prioritize stocking and promotions for **Food and Beverages**.
- Focus operational staffing on **afternoons** and **Wednesdays**.
- Expand **membership program** outreach and incentives.
- Target gender preferences in campaigns (e.g., **Fashion Accessories** for females, **Health and Beauty** for males).

## 2. Overview
This project aims to provide actionable insights into Walmart's regional sales performance using transactional data. I designed this analysis to answer key business questions such as:

- Which city performs best in sales?
- What time periods yield higher revenues?
- How do customer types and order trends vary?

### Key Focus Areas:
- Revenue trends
- Order volumes
- Seasonality (month/day/time)
- Store performance by city
- Customer behavior by type and gender

## 3. Data Overview
The dataset, sourced from the Kaggle Walmart Sales Forecasting competition, contains **1,000 rows** and was ingested into Snowflake under the `sale` database and `sale_data` schema. I created two tables:

- `sales_data_raw`: Original raw data with all fields as `VARCHAR`
- `sales_data_cleaned`: Cleaned and enriched table with appropriate data types and engineered columns for analysis

### Table: `sales_data_cleaned`
This table contains 17 original fields plus 3 engineered columns. Below is an overview of its structure:

| Column Name        | Description |
|--------------------|-------------|
| `invoice_id`       | Unique identifier for each transaction |
| `branch`           | Store branch code (A, B, C) |
| `city`             | City where the branch is located (Yangon, Mandalay, Naypyitaw) |
| `customer_type`    | Type of customer (Member or Normal) |
| `gender`           | Gender of the customer (Male or Female) |
| `product_line`     | Product category purchased (e.g., Health and Beauty, Fashion Accessories) |
| `unit_price`       | Price per unit of product (converted to DECIMAL) |
| `quantity`         | Number of units purchased (converted to INTEGER) |
| `vat`              | Value-added tax (5% of COGS; stored as FLOAT) |
| `total`            | Total amount including VAT (unit_price * quantity + VAT) |
| `date`             | Date of transaction (converted to DATE) |
| `time`             | Time of transaction (converted to TIME) |
| `payment`          | Payment method used (Cash, Ewallet, Credit Card) |
| `cogs`             | Cost of goods sold before VAT |
| `gross_margin_pct` | Gross margin percentage (typically fixed at 4.76%) |
| `gross_income`     | Profit per transaction (Cogs * Gross Margin %) |
| `rating`           | Customer satisfaction rating (scale of 1 to 10) |

### Engineered Columns:
- `time_of_day`: Categorized the time into Morning, Afternoon, or Evening using the HOUR extracted from the `time` column
- `day_name`: Derived from the `date` to get abbreviated day of the week (e.g., Mon, Tue)
- `month_name`: Derived from the `date` to get abbreviated month (e.g., Jan, Feb)

The `sales_data_cleaned` table was fully validated and contains **no null values**. These transformations allowed me to explore shopping behavior across different timeframes, evaluate customer segments, and identify sales trends with high granularity.
- **Naypyitaw** led all branches in VAT value (**$5,265.18**) and likely revenue.
- **January** recorded the highest revenue (**$116,291.87**) and COGS (**$110,754.16**).
- **Electronic Accessories** was the most sold product line (**971 units**).
- **Food and Beverages** topped in revenue (**$56,144.84**) and VAT (**$2,673.56**), and received the highest average rating (**7.11**).
- **Members** contributed the highest revenue (**$164,223.44**), VAT (**$7,820.16**), and purchased the most items (**2,785**).
- **Afternoon** was the most active shopping time (**454 ratings**, highest weekday sales occurred on **Wednesday Afternoon** with **71** sales).
- **Monday** had the highest overall average customer rating (**7.15**).
- Ratings per branch were highest on:
  - **Branch A**: Friday (**7.31**)
  - **Branch B**: Monday (**7.34**)
  - **Branch C**: Friday (**7.28**)
- **Female** customers slightly outnumbered males (**501 vs 499**) and favored **Fashion Accessories**.
- **Male** customers favored **Health and Beauty**.

## 5. Exploratory Data Analysis (EDA)

The Exploratory Data Analysis (EDA) phase helped me understand the basic structure and behavioral patterns within the data. Before building any deep analysis, I needed to ensure I had a solid grasp on the variety, scope, and early trends in the dataset.

### What I Explored and Why:
- **City and Branch Mapping**: Verified that Branch A is in **Yangon**, Branch B in **Mandalay**, and Branch C in **Naypyitaw**.
- **Product Line Diversity**: There are 6 distinct product lines.
- **Payment Preference**: **Ewallet** was the most used method (**345 times**).
- **Sales Volume Leaders**: **Electronic Accessories** led with **971 units sold**.
- **Monthly Revenue/COGS**: **January** had highest revenue and COGS.
- **Top Revenue Product Line**: **Food and Beverages** with **$56,144.84**.
- **Top VAT Contributor**: **Food and Beverages** at **$2,673.56**.
- **Highest VAT City**: **Naypyitaw** at **$5,265.18**.
- **Revenue by Customer Type**: **Members** spent more (**$164,223.44**), paid more VAT (**$7,820.16**), and purchased more (**2,785 items**).
- **Top Gender for Volume**: **Females** slightly lead (**501 vs 499**).
- **Gender-Product Relationship**:
  - **Females**: Fashion Accessories (96 purchases)
  - **Males**: Health and Beauty (88 purchases)
- **Most Active Time for Ratings**: **Afternoon** (454 entries)
- **Peak Sales Period**: **Wednesday Afternoon** (71 transactions)
- **Best Average Ratings**:
  - Overall: **Monday** (**7.15**)
  - Branch A: **Friday** (**7.31**)
  - Branch B: **Monday** (**7.34**)
  - Branch C: **Friday** (**7.28**)

This EDA gave me confidence in the data structure and highlighted clear areas for detailed analysis. It revealed seasonality, product preferences, city-specific trends, and customer behavior patterns—all of which informed the rest of my project.


## 6. Detailed Analysis

a. **Revenue Trends**  
**January** drove the highest revenue (**$116,291.87**), aligning with potential seasonal spending. The **Food and Beverages** category led in total revenue (**$56,144.84**) and VAT collected (**$2,673.56**), indicating both popularity and margin strength. **Members** contributed significantly more to revenue (**$164,223.44**) than normal customers. Among branches, **Branch C (Naypyitaw)** led in revenue (**$110,568.71**), slightly ahead of Branches A and B.

b. **Order Count Patterns**  
Order volumes were highest in **Afternoon** sessions, especially on **Wednesdays** where the peak occurred (**71 sales**). This pattern highlights a clear behavioral trend in when customers prefer to shop. Branch A handled more than average product volume (**1,859 units**), showing operational robustness. The most sold product line was **Electronic Accessories** with **971 units**, suggesting consistent consumer interest in this category.

c. **Average Order Value (AOV) Trends**  
AOV was higher for **Members** (**$327.79**) than **Normal** customers (**$318.12**), reinforcing the importance of customer loyalty programs. AOV by gender revealed that **Females** spent more per order (**$335.10**) compared to **Males** (**$310.79**), which may influence targeted marketing strategies.

High-revenue product categories like **Food and Beverages** and **Fashion Accessories** contributed to strong basket sizes. The correlation between higher AOV and member/female segments can support prioritizing campaigns aimed at these groups.

d. **Regional Performance**  
Among the three cities, **Naypyitaw (Branch C)** had the highest total revenue (**$110,568.71**) and VAT (**$5,265.18**), indicating both high sales volume and product mix value. This location may benefit from further investment and operational scaling. **Yangon (Branch A)** and **Mandalay (Branch B)** followed closely in revenue, showing healthy competition across branches.

e. **Customer and Demographic Behavior**  
**Members** were the most valuable customer group across all metrics: revenue, VAT, quantity purchased, and AOV. **Female** customers slightly outnumbered males (**501 vs 499**) and showed a stronger AOV. They preferred **Fashion Accessories**, while **Males** leaned toward **Health and Beauty**. These insights support targeted demographic marketing strategies.

f. **Rating and Satisfaction Trends**  
Ratings peaked in the **Afternoon**, aligned with sales activity. **Monday** had the highest overall average rating (**7.15**), which may relate to a better customer experience or lower volume pressure early in the week. By branch:
- **Branch A** scored highest on **Friday** (**7.31**)
- **Branch B** peaked on **Monday** (**7.34**)
- **Branch C** also performed best on **Friday** (**7.28**)

## 7. Actionable Recommendations
- **Branch Strategy**: Prioritize Naypyitaw’s success model for broader use, and uplift Mandalay’s performance.
- **Promotions**: Launch deals during slow periods and reinforce afternoon peaks.
- **Loyalty Expansion**: Convert normal customers to members to boost revenue.
- **Gender Targeting**: Market Fashion Accessories to female shoppers and Health & Beauty to males.
- **Staffing Optimization**: Increase staff during afternoon and Wednesday peaks.
- **Rating-Driven Campaigns**: Use high-rating days (Monday, Friday) to roll out promotions or collect feedback.

This project demonstrates my ability to use Snowflake SQL for end-to-end data cleaning, transformation, and analysis to drive strategic business insights.

