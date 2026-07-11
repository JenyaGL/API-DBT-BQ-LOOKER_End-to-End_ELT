{{ config(materialized='table') }}

SELECT 
    c.country,
    c.region,
    f.side_a,
    f.side_b,
    d.year AS date_year,
    f.type_of_violence,
    SUM(f.estimated_fatalities) AS total_fatalities,
    COUNT(f.event_id) AS total_conflict_events,
    case when f.type_of_violence = 1 then 'State-based'
         when f.type_of_violence = 2 then 'Non-state-based'
         when f.type_of_violence = 3 then 'One-sided-violence'
         else 'Unknown'
    end as violence_type
FROM {{ ref('stg_ucdp_conflicts') }} f
LEFT JOIN {{ ref('dim_country') }} c ON f.country = c.country
LEFT JOIN {{ ref('dim_dates') }} d ON f.conflict_year = d.year
GROUP BY c.country, c.region, d.year, f.type_of_violence, f.side_a, f.side_b, violence_type
ORDER BY total_fatalities DESC