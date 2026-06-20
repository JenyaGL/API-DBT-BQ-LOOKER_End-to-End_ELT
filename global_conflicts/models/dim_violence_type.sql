{{ config(materialized='table') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['type_of_violence']) }} AS violence_type_id,
    type_of_violence,
    CASE 
        WHEN type_of_violence = 1 THEN 'State-based'
        WHEN type_of_violence = 2 THEN 'Non-state'
        WHEN type_of_violence = 3 THEN 'One-sided'
        ELSE 'Other'
    END AS description
FROM {{ ref('stg_ucdp_conflicts') }}