{{ config(materialized='table') }}

SELECT DISTINCT
    conflict_year AS date_key,
    conflict_year AS year,
    -- Add more calendar logic here as needed!
    '2026' AS fiscal_year
FROM {{ ref('stg_ucdp_conflicts') }}