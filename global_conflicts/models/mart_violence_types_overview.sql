WITH staged_conflicts AS (
    SELECT * FROM {{ ref('stg_ucdp_conflicts') }}
)

SELECT 
    type_of_violence,
    COUNT(event_id) AS total_events,
    SUM(estimated_fatalities) AS total_fatalities,
    COUNT(DISTINCT country) AS total_countries_affected
FROM staged_conflicts
GROUP BY 1
ORDER BY total_fatalities DESC