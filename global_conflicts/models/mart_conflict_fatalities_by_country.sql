SELECT 
    c.country,
    c.region,
    d.year AS conflict_year,
    SUM(f.estimated_fatalities) AS total_fatalities,
    COUNT(f.event_id) AS total_conflict_events
FROM {{ ref('stg_ucdp_conflicts') }} f
LEFT JOIN {{ ref('dim_country') }} c ON f.country = c.country
LEFT JOIN {{ ref('dim_dates') }} d ON f.conflict_year = d.year
GROUP BY c.country, c.region, d.year
ORDER BY total_fatalities DESC