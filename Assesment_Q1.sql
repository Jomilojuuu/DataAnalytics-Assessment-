/* Assessment_Q1.sql*/

/* 
  The goal is to identify users who have both regular savings plans and investment funds.
  The plan_flags CTE calculates counts of each type of plan per user (owner_id) and 
  only users with at least one regular savings AND one investment fund are kept.
*/
WITH plan_flags AS (
  SELECT owner_id,
         SUM(is_regular_savings = 1) AS savings_count,
         SUM(is_a_fund = 1)          AS investment_count
  FROM plans_plan
  GROUP BY owner_id
  HAVING savings_count > 0 AND investment_count > 0
), 
/*
  Then i calculate total deposits for each user by summing confirmed savings amounts.
  The deposits CTE sums all confirmed deposits for each user's savings accounts.
  The confirmed amounts are stored in kobo (smallest currency unit), so divide by 100 to convert to Naira (₦).
*/

deposits AS (
  SELECT p.owner_id,
         SUM(s.confirmed_amount)/100.0 AS total_deposits   -- convert kobo→₦
  FROM plans_plan        p
  JOIN savings_savingsaccount s ON s.plan_id = p.id
  GROUP BY p.owner_id
)

/* 
  Lastly, select users who meet the criteria (both savings and investment plans).
  Then join with user details to get full name and include counts of plan types and total deposits.
  Then sort by total deposits in descending order.
*/
SELECT u.id           AS owner_id,
       CONCAT(u.first_name,' ',u.last_name) AS name,
       f.savings_count,
       f.investment_count,
       d.total_deposits
FROM plan_flags f
JOIN users_customuser u ON u.id = f.owner_id
JOIN deposits d         ON d.owner_id = f.owner_id
ORDER BY d.total_deposits DESC;
