USE walmart_db;
SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

-- Business Problems
-- Q.1 Find different payment methods and number of transactions, number of quantity sold

SELECT
	payment_method,
    COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

SELECT *
FROM
(
	SELECT
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as category_rank
	FROM walmart
	GROUP BY branch, category
) AS ranked_data
WHERE category_rank = 1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions
SELECT date
FROM walmart
LIMIT 10;
SELECT
    `date`,
    STR_TO_DATE(TRIM(`date`), '%d/%m/%y') AS converted_date,
    DAYNAME(STR_TO_DATE(TRIM(`date`), '%d/%m/%y')) AS day_name
FROM walmart
LIMIT 10;
SELECT *
FROM
(
	SELECT 
		branch,
		DAYNAME(STR_TO_DATE(date,'%d/%m/%y')) as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS branch_rank
	FROM walmart
    GROUP BY branch, day_name
) AS ranked_data
WHERE branch_rank = 1;

-- Q.4 Calculate the total quantity of items sold per payment. List payment_method and total_quantity.

SELECT 
	payment_method,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q.5 Determine the average, minimum and maximum rating of products for each city.
-- List the city, average_rating, min_rating and max_rating.alter

SELECT
	city,
    category,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart
GROUP BY city, category;

-- Q.6 Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered  from highest to lowest profit.

SELECT
	category,
    SUM(total) as total_revenue,
    SUM(total * profit_margin) as profit
FROM walmart
GROUP BY category;

-- Q.3 Determine the most common payment method for each branch. 
-- Display branch and the preferred_payment_metgod.

WITH cte
AS
(SELECT
	branch,
    payment_method,
    COUNT(*) as total_trans,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS payment_rank
FROM walmart
GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE payment_rank = 1;


-- Q.8 Categorize sales into 3 groups MORNING, AFTERNOON, EVENING
-- Find out each of the shift and number of invoices

SELECT
	branch,
CASE 
		WHEN HOUR(STR_TO_DATE(`time`, '%H:%i:%s')) < 12 THEN 'Morning'
		WHEN HOUR(STR_TO_DATE(`time`, '%H:%i:%s')) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS day_time,
    COUNT(*) AS total_orders
FROM  walmart
GROUP BY branch, day_time
ORDER BY branch, total_orders DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;