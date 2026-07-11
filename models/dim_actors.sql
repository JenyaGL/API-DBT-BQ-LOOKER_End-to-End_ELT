{{ config(materialized='table') }}

WITH all_actors AS (
    SELECT side_a AS actor_name FROM {{ ref('stg_ucdp_conflicts') }}
    UNION DISTINCT
    SELECT side_b AS actor_name FROM {{ ref('stg_ucdp_conflicts') }}
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['actor_name']) }} AS actor_id,
    actor_name
FROM all_actors
WHERE actor_name IS NOT NULL