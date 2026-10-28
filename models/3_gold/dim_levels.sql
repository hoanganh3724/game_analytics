{{ config(materialized='table') }}

WITH base_levels AS (
    SELECT DISTINCT level_id
    FROM {{ ref('int_level_gameplay') }}
    WHERE level_id IS NOT NULL
)

SELECT
    level_id,
    CASE 
        WHEN level_id BETWEEN 1 AND 100 THEN 'Tier 1: Easy (1-100)'
        WHEN level_id BETWEEN 101 AND 250 THEN 'Tier 2: Medium (101-250)'
        WHEN level_id BETWEEN 251 AND 400 THEN 'Tier 3: Hard (251-400)'
        ELSE 'Tier 4: Expert (401-500)'
    END AS level_difficulty_tier
FROM base_levels
ORDER BY level_id ASC