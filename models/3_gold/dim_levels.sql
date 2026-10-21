{{ config(materialized='table') }}

SELECT DISTINCT
    level_id,
    'Level ' || level_id AS level_display_name
FROM {{ ref('int_level_gameplay') }}
WHERE level_id IS NOT NULL