/* Assessment_Q3.sql*/
/*CTE: last_tx -The goal is to get the most recent *inflow* date for every plan.*/
WITH last_tx AS (          -- most recent inflow per plan
    SELECT
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY plan_id
)

SELECT
    p.id                           AS plan_id,
    p.owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund         = 1 THEN 'Investment'
        ELSE 'Unknown'
    END                            AS type,
    l.last_transaction_date,
    /* Days since last funding (or since plan creation if never funded) */
    IFNULL(                        -- NULL → never funded
        DATEDIFF(CURDATE(), l.last_transaction_date),
        DATEDIFF(CURDATE(), p.created_on)
    )                              AS inactivity_days
FROM plans_plan            p
LEFT JOIN last_tx          l ON l.plan_id = p.id
WHERE p.status_id = 1                                  -- active
  /* Select plans with no funding in the last year (or never funded) */
  AND (
        l.last_transaction_date IS NULL
     OR l.last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 365 DAY)
      )
ORDER BY inactivity_days DESC, plan_id;
