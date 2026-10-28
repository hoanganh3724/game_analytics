{{ config(
    materialized='table',
    schema='gold'
) }}

WITH user_cohort AS (
    SELECT 
        user_pseudo_id,
        first_seen_date AS cohort_date,
        primary_os_version
    FROM {{ ref('dim_user_devices') }}
),
user_activity AS (
    SELECT DISTINCT
        user_pseudo_id,
        metric_date AS activity_date
    FROM {{ ref('mart_user_daily_summary') }}
)
SELECT 
    c.cohort_date,
    c.primary_os_version,
    COUNT(DISTINCT c.user_pseudo_id) AS cohort_size,
    
    -- D1 Retention
    COUNT(DISTINCT CASE WHEN a.activity_date = c.cohort_date + INTERVAL 1 DAY THEN a.user_pseudo_id END) AS d1_retained_users,
    ROUND(COUNT(DISTINCT CASE WHEN a.activity_date = c.cohort_date + INTERVAL 1 DAY THEN a.user_pseudo_id END) * 100.0 / NULLIF(COUNT(DISTINCT c.user_pseudo_id), 0), 2) AS d1_retention_pct,
    
    -- D3 Retention
    COUNT(DISTINCT CASE WHEN a.activity_date = c.cohort_date + INTERVAL 3 DAY THEN a.user_pseudo_id END) AS d3_retained_users,
    ROUND(COUNT(DISTINCT CASE WHEN a.activity_date = c.cohort_date + INTERVAL 3 DAY THEN a.user_pseudo_id END) * 100.0 / NULLIF(COUNT(DISTINCT c.user_pseudo_id), 0), 2) AS d3_retention_pct,
    
    -- D7 Retention
    COUNT(DISTINCT CASE WHEN a.activity_date = c.cohort_date + INTERVAL 7 DAY THEN a.user_pseudo_id END) AS d7_retained_users,
    ROUND(COUNT(DISTINCT CASE WHEN a.activity_date = c.cohort_date + INTERVAL 7 DAY THEN a.user_pseudo_id END) * 100.0 / NULLIF(COUNT(DISTINCT c.user_pseudo_id), 0), 2) AS d7_retention_pct

FROM user_cohort c
LEFT JOIN user_activity a ON c.user_pseudo_id = a.user_pseudo_id
GROUP BY c.cohort_date, c.primary_os_version
ORDER BY c.cohort_date DESC