{{ config(materialized='table') }}

WITH date_range AS (
    SELECT 
        CAST('2026-01-01' AS DATE) + INTERVAL (i) DAY AS date_day
    FROM range(0, 365) t(i)
)
SELECT
    date_day AS date_key,
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    MONTHNAME(date_day) AS month_name,
    DAY(date_day) AS day,
    DAYNAME(date_day) AS day_name,
    DAYOFWEEK(date_day) AS day_of_week,
    WEEK(date_day) AS week_of_year,
    CASE WHEN DAYOFWEEK(date_day) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM date_range