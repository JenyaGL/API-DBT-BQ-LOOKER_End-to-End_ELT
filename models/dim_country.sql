WITH source_data AS (
    SELECT DISTINCT country, region 
    FROM {{ ref('stg_ucdp_conflicts') }}
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['country']) }} AS country_id,
    country,
    region
FROM source_data