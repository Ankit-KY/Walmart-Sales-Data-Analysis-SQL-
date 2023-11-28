-- Create Database
CREATE DATABASE IF NOT EXISTS Walmart_salesdata;

-- Create table
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10 , 3 ) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6 , 4 ) NOT NULL,
    total DECIMAL(12 , 4 ) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10 , 2 ) NOT NULL,
    gross_margin_pct FLOAT(11 , 9 ),
    gross_income DECIMAL(12 , 4 ) NOT NULL,
    rating FLOAT(2 , 1 )
);

-- =========================== DATA CLEANING =========================================
SELECT * FROM sales;

-- Add Time of Day column
SELECT time, (CASE
				WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
                ELSE "Evening"
			END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales 
SET time_of_day = (CASE
				WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
                ELSE "Evening"
			END);

-- Add Day Name
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales 
SET day_name = DAYNAME(date);

-- Add Month Name
ALTER TABLE sales ADD COLUMN month VARCHAR(10);
UPDATE sales
SET month = MONTHNAME(date);

-- =====================BUSSINESS QUESTIONS TO ANSWER============================
-- ------------------------------------------------------------------------------
-- GENERIC QUESTION =============================================================

-- Q1. How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- Q2. In which city is each branch?
SELECT
	DISTINCT city, branch
FROM sales;

-- =============================================================================
-- PRODUCT======================================================================

 -- How many unique product lines does the data have?
 SELECT
	DISTINCT product_line
FROM sales;

-- What is the most selling product line?
SELECT 
	DISTINCT product_line, SUM(quantity) AS qty
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- What is the total revenue by month?
SELECT 
	month, SUM(total) AS total_revenue
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

-- 	Which month had the maximum cogs?
SELECT 
	month, SUM(cogs) as cogs
FROM sales
GROUP BY month
ORDER BY cogs DESC;

-- Which product line had the largest revenue?
SELECT
	product_line, SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- Which city has the largest revenue?
SELECT
	city, branch, SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- Which product line has the largest VAT?
SELECT
	product_line, AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product line showing
	-- "Good", "Bad". Good if its greater than average sales.
SELECT AVG(quantity) AS avg_qty
FROM sales;

SELECT product_line,
	(CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
	END) AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more product than average product sold?
SELECT branch,
	SUM(quantity) AS qty
FROM sales 
GROUP BY branch
HAVING SUM(quantity) > AVG(quantity);

-- What is the most common product line by gender?
SELECT product_line, gender,
	COUNT(gender) AS cnt
FROM sales
GROUP BY product_line, gender
ORDER BY cnt DESC;

-- What is the average rating of each product line?
SELECT product_line,
	ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ==================================================================================
-- CUSTOMER==========================================================================

-- How many unique customer type does the data have?
SELECT 
	DISTINCT customer_type
FROM sales;

-- How many unique payment method does the data have?
SELECT
	DISTINCT payment_method
FROM sales;

-- What is the most common customer type?
SELECT
	customer_type,
    COUNT(customer_type) AS cnt
FROM sales
GROUP BY customer_type
ORDER BY cnt DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*) AS cnt
FROM sales
GROUP BY customer_type
ORDER BY cnt DESC;

-- What is the gender of most of the customers?
SELECT
	gender,
    COUNT(gender) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- What is the gender distribution per branch?
SELECT
	branch,
    gender,
    COUNT(*) as cnt
FROM sales
GROUP BY branch, gender
ORDER BY branch ASC;
-- Gender per branch is more or less the same hence, I don't think has
	-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT 
    time_of_day, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
	-- more or less the same rating each time of the day.alter


-- Which time of day do customers give most ratings per branch?
SELECT
	time_of_day,
    ROUND(AVG(rating), 2) AS rating
FROM sales
GROUP BY time_of_day
ORDER BY rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
	-- little more to get better ratings.


-- Which day of the weeek has the best average rating?
SELECT
	day_name,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
	-- why is that the case, how many sales are made on these days?

-- Which day of week has the best average rating per branch?
SELECT
	day_name,
    branch,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY day_name, branch
ORDER BY avg_rating DESC;

-- ================================================================================
-- SALES===========================================================================

-- Number of sales made in each time of the day per weekday?
SELECT
	day_name,
    time_of_day,
    COUNT(*) AS cnt
FROM sales
GROUP BY day_name, time_of_day
ORDER BY cnt DESC;
-- Evenings experience most sales, the stores are 
	-- filled during the evening hours
    
-- Which of the customer type bring the most revenue?
SELECT
	customer_type,
    ROUND(SUM(total), 2) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax/VAT percentage?
SELECT
	city,
	ROUND(AVG(VAT), 2) AS vat_pct
FROM sales
GROUP BY city
ORDER BY vat_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
    ROUND(AVG(VAT), 2) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- ======================================================================================
#########################################################################################
#########################################################################################