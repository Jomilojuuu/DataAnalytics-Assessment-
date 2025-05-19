/* Assessment_Q4.sql*/
/* The 'tx CTE'
Per customeris the total number of transactions and the mean value of each confirmed deposit (still stored in kobo).*/

WITH tx AS (
    SELECT
        owner_id                       AS customer_id,
        COUNT(*)                       AS total_tx,
        AVG(confirmed_amount)          AS avg_tx_value   -- still in kobo
    FROM savings_savingsaccount
    GROUP BY owner_id
),
/* cust CTE is the basic customer profile + tenure (months since sign-up).*/

cust AS (
    SELECT
        id                             AS customer_id,
        CONCAT(first_name,' ',last_name) AS name,
        TIMESTAMPDIFF(
            MONTH,
            created_on,
            CURDATE()
        )                             AS tenure_months
    FROM users_customuser
)

/*Finally- The estimated customer lifetime value(CLV) =(avg monthly tx count × 12) is annualised volume
                                                         × (avg tx value × 0.1 %) is profit per tx
                                                         × kobo to Naira conversion (÷100).*/

SELECT
    c.customer_id,
    c.name,
    c.tenure_months,
    t.total_tx                       AS total_transactions,
    ROUND(
        (t.total_tx / c.tenure_months) * 12 *          -- annualised tx count
        (t.avg_tx_value * 0.001) / 100.0,              -- 0.1 % profit, kobo to Naira
        2
    )                                 AS estimated_clv
FROM cust c
JOIN tx   t  ON t.customer_id = c.customer_id
WHERE c.tenure_months > 0                            -- exclude same-month sign-ups                  
ORDER BY estimated_clv DESC;
