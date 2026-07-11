{{ config(materialized='table') }}

WITH yearly_country_stats AS (
    -- Step 1: Aggregate the data by Country and Year
    SELECT 
        country,
        conflict_year,
        SUM(estimated_fatalities) AS total_fatalities,
        COUNT(event_id) AS total_events,
        COUNT(DISTINCT type_of_violence) AS violence_types_present
    FROM {{ ref('stg_ucdp_conflicts') }}
    GROUP BY country, conflict_year
),

rolling_features AS (
    -- Step 2: Use Window Functions to "look ahead" 5 years
    SELECT
        country,
        conflict_year,
        total_fatalities,
        total_events,
        violence_types_present,
        
        -- This looks at the next 5 years for the same country and sums the events
        SUM(total_events) OVER (
            PARTITION BY country 
            ORDER BY conflict_year 
            RANGE BETWEEN 1 FOLLOWING AND 5 FOLLOWING
        ) AS future_events_5yr
    FROM yearly_country_stats
)

-- Step 3: Create the final binary label for the ML Model (1 = Yes, 0 = No)
SELECT
    country,
    conflict_year,
    total_fatalities,
    total_events,
    violence_types_present,
    IF(IFNULL(future_events_5yr, 0) > 0, 1, 0) AS target_conflict_next_5_years
FROM rolling_features