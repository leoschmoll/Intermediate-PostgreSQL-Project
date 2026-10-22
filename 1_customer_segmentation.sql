WITH customer_ltv AS (
	SELECT
		customerkey,
		cleaned_name,
		sum(total_net_revenue) AS total_ltv
	FROM
		cohort_analysis
	GROUP BY
		customerkey,
		cleaned_name
),
customers_segment AS (
	SELECT
		PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY	total_ltv) AS ltv_25th_percentile,	
		PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY	total_ltv) AS ltv_75th_percentile
	FROM
		customer_ltv
),
segment_values AS (
	SELECT
		c.*,
		CASE
			WHEN total_ltv < cs.ltv_25th_percentile THEN '1 - Low-Value'
			WHEN total_ltv <= cs.ltv_75th_percentile THEN '2 - Mid-Value'
			ELSE '3 - High-Value'
		END AS customer_segment
	FROM
		customer_ltv c,
		customers_segment cs
)
SELECT
	customer_segment,
	sum(total_ltv) AS total_ltv,
	count(customerkey) AS customer_count,
	sum(total_ltv) / count(customerkey) AS avg_ltv
FROM
	segment_values
GROUP BY
	customer_segment
ORDER BY
	customer_segment DESC