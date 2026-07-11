{{ config(materialized='table') }}

SELECT 
    d.year AS conflict_year,
    COUNT(f.event_id) AS total_conflict_events,
    SUM(f.estimated_fatalities) AS total_fatalities,
    ROUND(SUM(f.estimated_fatalities) / COUNT(f.event_id), 2) AS average_fatalities_per_event
FROM {{ ref('stg_ucdp_conflicts') }} f
LEFT JOIN {{ ref('dim_dates') }} d ON f.conflict_year = d.year
GROUP BY d.year
ORDER BY d.year DESC    