{{ config(materialized='table') }}

WITH user_first_date AS (
    SELECT
        user_pseudo_id,
        MIN(start_date) AS install_date
    FROM {{ ref('fact_gameplay_sessions') }}
    GROUP BY user_pseudo_id
),

user_activity AS (
    SELECT DISTINCT
        user_pseudo_id,
        start_date AS activity_date
    FROM {{ ref('fact_gameplay_sessions') }}
)

SELECT
    f.install_date,
    u.activity_date,
    CAST(u.activity_date - f.install_date AS INTEGER) AS day_number,
    COUNT(DISTINCT f.user_pseudo_id) AS active_users
FROM user_first_date f
JOIN user_activity u 
    ON f.user_pseudo_id = u.user_pseudo_id
   AND u.activity_date >= f.install_date
GROUP BY 1, 2, 3