
-- The ref() function links this model to the staging model
WITH staged_conflicts AS (
    SELECT * FROM {{ ref('stg_ucdp_conflicts') }}
    )

SELECT 
    country,
    region,
    conflict_year,
    COUNT(event_id) AS total_conflict_events,
    SUM(estimated_fatalities) AS total_fatalities
FROM staged_conflicts
GROUP BY 1, 2, 3
ORDER BY total_fatalities DESC