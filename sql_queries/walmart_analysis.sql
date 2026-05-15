-- =========================================
-- BUSINESS PROBLEM 1
-- Find different payment method and number of transactions, number of quantity sold
-- =========================================

SELECT 
	payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM Walmart
GROUP BY payment_method
ORDER BY no_qty_sold DESC;

-- =========================================
-- BUSINESS PROBLEM 2
-- Identify the Highest-rated category in each branch, displaying the branch, category
-- AVG RATING
-- =========================================

SELECT* 
FROM
(
	SELECT
		Branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rank_num
FROM Walmart 
GROUP BY Branch, category
) AS ranked_data
WHERE rank_num = 1; 

-- =========================================
-- BUSINESS PROBLEM 3
-- Identify the busiest day for each branch based on the number of transactions
-- =========================================

SELECT *
FROM
(SELECT 
    Branch,
    DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
    COUNT(*) AS no_transactions,
    RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank_num
FROM Walmart
GROUP BY Branch, day_name
) AS ranked_days
WHERE rank_num = 1; 

-- =========================================
-- BUSINESS PROBLEM 4
-- Calculate the total quantity of items sold per payment method. list payment_method and total_quantity
-- =========================================

SELECT 
	payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM Walmart
GROUP BY payment_method
ORDER BY no_qty_sold DESC;

-- =========================================
-- BUSINESS PROBLEM 5
-- Determine the average, minimum, and maximum rating of category for each city.
-- list the city, average_rating, min_rating, and  max_rating.
-- =========================================

SELECT 
	City,
    category,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart
GROUP BY City, category
ORDER BY City, category DESC;

-- =========================================
-- BUSINESS PROBLEM 6
-- Calculate the total profit for each category by considering the total_profit as (unit_price* quqntity* profit_margin ). 
-- List category and total_profit, ordered from highest to lowest profit.
-- =========================================

SELECT
	category,
    SUM(total) as total_revenue,
    SUM(total* profit_margin* quantity) as profit
FROM walmart
GROUP BY category
ORDER BY total_revenue DESC;

-- =========================================
-- BUSINESS PROBLEM 7
-- Determine the most common payment method for each branch. Display branch and preferred_payment_method.
-- =========================================

WITH cte
AS
(SELECT 
	Branch,
    payment_method,
    COUNT(*) as total_transactions,
    RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank_num
FROM walmart
GROUP BY Branch, payment_method
)
SELECT *
FROM cte
WHERE rank_num=1;

-- =========================================
-- BUSINESS PROBLEM 8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- FIND OUT EACH OF THE SHIFT AND NUMBER OF INVOICES
-- =========================================

SELECT
    Branch,
    CASE
        WHEN CAST(time AS TIME) < '12:00:00'
            THEN 'MORNING'
        WHEN CAST(time AS TIME) >= '12:00:00'
        AND CAST(time AS TIME) < '17:00:00'
            THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS time_shift,
    COUNT(*) AS invoice_count
FROM Walmart
GROUP BY Branch, time_shift
ORDER BY Branch, invoice_count;

-- =========================================
-- BUSINESS PROBLEM 9
-- Identify the top 5 branches with the
-- highest revenue decrease ratio
-- comparing 2022 vs 2023
-- =========================================

SELECT
    Branch,

    SUM(
        CASE
            WHEN YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
            THEN total
            ELSE 0
        END
    ) AS last_year_revenue,

    SUM(
        CASE
            WHEN YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
            THEN total
            ELSE 0
        END
    ) AS current_year_revenue,

    ROUND(
        (
            (
                SUM(
                    CASE
                        WHEN YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
                        THEN total
                        ELSE 0
                    END
                )
                -
                SUM(
                    CASE
                        WHEN YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
                        THEN total
                        ELSE 0
                    END
                )
            )
            /
            SUM(
                CASE
                    WHEN YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
                    THEN total
                    ELSE 0
                END
            )
        ) * 100,
        2
    ) AS revenue_decrease_ratio

FROM Walmart

GROUP BY Branch

ORDER BY revenue_decrease_ratio DESC

LIMIT 5;
