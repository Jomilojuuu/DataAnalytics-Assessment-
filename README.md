# DataAnalytics-Assessment-
My SQL Assessment Approach
When I received the four-part SQL assessment, I treated it exactly as I would a real-world analyst brief: I started by understanding the business question, then translated that need into the smallest, clearest set of queries that deliver an answer—and nothing more. What follows is a narrative of how I tackled each question, the reasoning behind my design choices, and the bumps I hit along the way.

Question 1 – Pinpointing Cross-Sell Prospects
Business goal: Surface customers who already hold both a savings plan and an investment fund, then rank them by how much money they have deposited.
My instinct was to aggregate once and keep the logic visible. I built a CTE that counts, per customer, how many “regular-savings” plans and how many “fund” plans exist. By pushing the dual-product filter into a HAVING clause, I avoided a second pass over the same table. A second CTE summed every confirmed deposit, all stored in kobo, so I divided by 100 to reach Naira. The final SELECT simply joins those CTEs to the user table for names and orders by total inflow.
The elegance here is that the heavy work (counts and sums) is done exactly once; the output stage is lightweight and self-explanatory.

Question 2 – Segmenting by Transaction Frequency
Business goal: label customers as High, Medium, or Low frequency based on average monthly activity.
Two subtleties needed attention. First, a brand-new customer technically has one transaction per month, not zero, so I added + 1 to the month to avoid division by zero. Second, the bucket labels must be business-friendly, so I used a CASE expression to hard-code ≥ 10 as High, 3-9 as Medium, and ≤ 2 as Low. Once each customer was tagged, it was a simple aggregation to count how many fell into each bucket and to show the average rate per group. Ordering the result High → Low matched the stakeholder’s slide deck style.

Question 3 – Flagging Dormant Accounts
Business goal: find active plans with no deposits in the last year (or none at all).
I first captured the latest inflow date for every plan in one CTE. In the main query, I joined that CTE back to plans_plan, limited rows to active plans, and calculated inactivity_days. If a plan had never been funded, the IFNULL function gracefully substituted the plan’s creation date. A simple date comparison isolated the dormant ones. 

Question 4 – Estimating Customer Lifetime Value (CLV)
Business goal: produce a quick-and-dirty CLV using tenure, volume, and a 0.1 % margin assumption.
This required stitching two perspectives together: transaction behaviour (total_tx, AVG(confirmed_amount)) and customer timeline (tenure_months). Once joined, I annualised the transaction rate, applied the profit margin in kobo, converted to Naira, and rounded to two decimals. I deliberately excluded users whose tenure was zero months; including them would have inflated the CLV denominator and misled Marketing. Final ordering by CLV lets the team grab the top spenders instantly.

Challenges and Resolutions
My first import of the dump file failed with an error which was easily fixed by reconnecting the database to a server local connection root. 

Missing data dictionary
Field names such as user_id were not reflected in the second question query. I ran a full description and SHOW FULL COLUMNS, also small SELECT samples to infer meaning. Keeping a scratch pad of those discoveries saved time on later questions.

Currency scale confusion
Amounts are stored in kobo; early test outputs looked very high until I realised I’d forgotten the / 100. I now treat currency conversion as a first-class step and comment on it loudly in every query.

Zero-division edge cases
Brand-new users can create fresh maths hazards. In Question 2, I fixed this with the + 1 trick; in Question 4, I added a WHERE tenure_months > 0 guard. These tiny defences make the queries production-safe.

Finally, the common thread across all four scripts is clarity first, optimisation second. By doing the computationally expensive work in CTEs and by labelling each step with plain-English comments, I produced code that a teammate can read next month without deciphering cryptic alias chains.

From a personal growth angle, this exercise reinforced two timeless lessons:

Know your data types. Units (kobo vs Naira) bite hard if you let them.

Guard the corners. A single zero-month customer can topple a division line.

I’m confident these solutions meet the assessment’s accuracy and readability goals while reflecting how I tackle real business questions every day.
