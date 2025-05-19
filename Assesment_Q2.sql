/* Assessment_Q2.sql*/
/* tx CTE
  The goal is to pull every savings-account transaction.
  For each customer (owner_id):
– total_tx: total number of individual transactions.
– active_months: number of distinct months the customer has been active.
N.B + 1 ensures we count both boundary months so we never divide by zero later on.*/

WITH tx AS (
    SELECT
        owner_id                          AS customer_id,
        COUNT(*)                          AS total_tx,
        TIMESTAMPDIFF(
            MONTH,
            MIN(transaction_date),
            MAX(transaction_date)
        ) + 1                             AS active_months   -- avoid div/0
    FROM savings_savingsaccount
    GROUP BY owner_id
),

/*freq CTE- It computes the average transaction frequency.
The avg_tx_per_month = total transactions ÷ months active */
        
freq AS (
    SELECT
        customer_id,
        total_tx / active_months          AS avg_tx_per_month
    FROM tx
),

/* bucket CTE
  Then i map each customer into a qualitative frequency bucket:
	-High: ≥ 10 tx / month
	-Medium: 3 – 9.9 tx / month
	-Low   : < 3 tx / month*/
    
bucket AS (
    SELECT
        CASE
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month >= 3  THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END                               AS frequency_category,
        avg_tx_per_month
    FROM freq
)

/*Finally
  One row per frequency bucket:
The customer_count is number of customers in the bucket
The avg_transactions_per_month is the mean monthly tx rate*/

SELECT
    frequency_category,
    COUNT(*)                              AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1)       AS avg_transactions_per_month
FROM bucket
GROUP BY frequency_category
ORDER BY FIELD(frequency_category,
               'High Frequency',
               'Medium Frequency',
               'Low Frequency');
