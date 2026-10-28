{{ config(materialized='table') }}

WITH date_spine AS (
    SELECT CAST(date_day AS DATE) AS date_day
    FROM UNNEST(
        generate_series(DATE '2026-07-01', DATE '2026-09-30', INTERVAL 1 DAY)
    ) AS t(date_day)
)

SELECT
    CAST(strftime(date_day, '%Y%m%d') AS INTEGER) AS date_key,
    date_day,
    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(MONTH FROM date_day) AS month,
    EXTRACT(DAY FROM date_day) AS day,
    DAYNAME(date_day) AS day_of_week,
    CASE WHEN EXTRACT(ISODOW FROM date_day) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM date_spine