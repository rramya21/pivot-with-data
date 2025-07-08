-- Data Insights for Netflix_Churn_Analysis


-- 1. How many customers are in the dataset?

SELECT COUNT(*) AS total_customers
FROM netflix_customer;

-- answer: 5000
 

-- 2. How many customers churned?

SELECT COUNT(*) AS churned_customers
FROM netflix_customer
WHERE churned =1;

-- answer: 2515

-- 3. What’s the average monthly fee paid by customers?
SELECT AVG(monthly_fee) AS avg_monthly_fee
FROM netflix_customer;
-- answer: 13.683399999999592

-- 4. Show all unique plan types

SELECT DISTINCT subscription_type
FROM netflix_customer;

-- answer: Basic, Standard, Premium

-- 5. Find the youngest and oldest customer.
SELECT MIN(age) AS youngest, MAX(age) AS oldest
FROM netflix_customer;

-- answer: youngest- 18 & oldest-	70


-- 6. What’s the churn rate?
SELECT
	ROUND(AVG(CASE WHEN churned =1 THEN 1 ELSE 0 END)*100,2) AS churn_rate
FROM netflix_customer;
    
    -- answer: 50.30% is churn_rate
    
-- 7. What's the average age of churned vs. non-churned customers?
SELECT
	churned,
    ROUND(AVG(age),1) AS avg_age
FROM netflix_customer
GROUP BY churned;

-- answer: avg age of 1 (Churned Cost) is 43.8 and that of 0(active customer) is 43.9

-- 8. Which country has the highest churn rate?

-- Method  without CTE

SELECT
	region,
    ROUND(SUM(churned)*100/COUNT(*),2) AS churn_rate
FROM netflix_customer
GROUP BY region
ORDER BY churn_rate DESC
LIMIT 1;
    
-- answer Europe: 51.57%

-- Method using a CTE

WITH churn_stats AS (
  SELECT
    region,
    COUNT(*) AS total_customers,
    SUM(churned) AS churned_customers
  FROM netflix_customer
  GROUP BY region
)
SELECT 
  region,
  ROUND(churned_customers * 100.0 / total_customers, 2) AS churn_rate
FROM churn_stats
ORDER BY churn_rate DESC
LIMIT 1;

-- CTE method answer: Europe 51.57%


-- 9. What’s the total revenue from non-churned customers?
SELECT 
	ROUND(SUM(monthly_fee),1) AS retained_revenue
FROM netflix_customer
WHERE churned =0;

-- ANSWER: $35407.2

-- 10. How many customers are there per plan type?
SELECT subscription_type, COUNT(*) AS users
FROM netflix_customer
GROUP BY subscription_type
ORDER BY users DESC;

-- ANSWER: Premium 1693, Basic 1661, Standard 1646

-- 11. What is the ARPU (Average Revenue per User) per plan?
SELECT
	subscription_type,
    ROUND(AVG(monthly_fee),2) AS ARPU
FROM netflix_customer
GROUP BY subscription_type;

-- ANSWER:  Basic	8.99 Standard	13.9 Premium	17.99

-- 12. Which age group has the highest churn?
SELECT
	CASE
		WHEN age < 25 THEN 'Under 25'
        WHEN age < 35 THEN '25-34'
        WHEN age < 45 THEN '35-44'
        WHEN age < 55 THEN '45-54'
        ELSE '55+'
	END AS age_group,
    ROUND(SUM(churned)*100/COUNT(*),2) AS churn_rate
FROM netflix_customer
GROUP BY age_group
ORDER BY churn_rate DESC;

-- ANSWER:
-- 45-54	53.97
-- Under 25	50.64
-- 25-34	50.26
-- 55+	49.03
-- 35-44	48.56

-- 13. What’s the average tenure (login days) for churned vs. active users?
SELECT
	churned,
    ROUND(AVG(last_login_days),1) AS avg_login_days
FROM netflix_customer
GROUP BY churned;

-- ANSWER: 1	38.3 & 0	21.8

-- 14. What’s the correlation between login days and monthly_fee?
SELECT
	ROUND(AVG(last_login_days * monthly_fee) -
	AVG(last_login_days) * AVG(monthly_fee),2) AS covariance
	FROM netflix_customer;
    
-- ANSWER: COVARIANCE:-0.05 (USE EXCEL FOR =CORREL)

-- 15. Which gender-plan combination has the highest churn rate?

SELECT
	gender,
	subscription_type,
    ROUND(SUM(churned)*100/COUNT(*),2) AS churn_rate
FROM netflix_customer
GROUP BY gender, subscription_type
ORDER BY churn_rate DESC;


-- answer (load query for table)

-- 16. Which plan has the highest revenue from active users?

SELECT subscription_type, SUM(monthly_fee) AS revenue
FROM netflix_customer
WHERE churned = 0
GROUP BY subscription_type
ORDER BY revenue DESC;

-- answer (load query for table)

-- 17. How many customers are in each age group?
SELECT
	CASE
		WHEN age < 25 THEN 'Under 25'
        WHEN age < 35 THEN '25-34'
        WHEN age < 45 THEN '35-44'
        WHEN age < 55 THEN '45-54'
        ELSE '55+'
	END AS age_group,
COUNT(*) AS users
FROM netflix_customer
GROUP BY age_group
ORDER BY users DESC;

-- answer (load query for table)

-- 18. Find churned users with high monthly fees
SELECT *
FROM netflix_customer
WHERE churned = 1 AND monthly_fee > 17;

-- Answer: Highest monthly fee is $17.99. 740 churned customers were paying 17.99

-- 19. Show customers who churned and haven't logged in for the longest time.
SELECT *
FROM netflix_customer
WHERE churned =1
ORDER BY last_login_days DESC
LIMIT 10;

-- answer (load query for table)

-- 20. Create a churn score card
SELECT
	customer_id,
    subscription_type,
    last_login_days,
    monthly_fee,
    CASE
		WHEN last_login_days >= 60 AND monthly_fee >= 15 then 'High Risk'
        WHEN last_login_days >=  60 then 'Medium Risk'
        ELSE 'Low Risk'
	END AS churn_risk
FROM netflix_customer
ORDER BY churn_risk;

-- answer (load query for table)

-- 21 Customer lifetime value (LTV) estimate.
-- LTV is the total revenue a customer is expected to generate over their time with the company.

-- Without CTE
SELECT 
  customer_id,
  subscription_type,
  monthly_fee,
  last_login_days,
  churned,
  ROUND(last_login_days / 30.0, 1) AS estimated_tenure_months,
  ROUND(monthly_fee * (last_login_days / 30.0), 2) AS estimated_ltv
FROM netflix_customer;

-- Explanation: 
-- Estimate tenure in months (using login days as proxy)
-- Calculate LTV

-- With CTE

WITH customer_base AS (
  SELECT 
    customer_id,
    subscription_type,
    monthly_fee,
    last_login_days,
    churned,
    ROUND(last_login_days / 30.0, 1) AS estimated_tenure_months,
    ROUND(monthly_fee * (last_login_days / 30.0), 2) AS estimated_ltv
  FROM netflix_customer
)

SELECT *
FROM customer_base;

