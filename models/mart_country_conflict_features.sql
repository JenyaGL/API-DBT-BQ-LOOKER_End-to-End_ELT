{{ config(materialized='table') }}

WITH yearly_country_stats AS (
    -- Step 1: Aggregate the UCDP conflict data
    SELECT 
        country,
        conflict_year AS year, -- Renaming to match economic data smoothly
        SUM(estimated_fatalities) AS total_fatalities,
        COUNT(event_id) AS total_events,
        COUNT(DISTINCT type_of_violence) AS violence_types_present
    FROM {{ ref('stg_ucdp_conflicts') }}
    GROUP BY country, conflict_year
),

rolling_features AS (
    -- Step 2: The ML Target (Shifted to a 2-year window to fix the "paranoid baseline")
    SELECT
        country,
        year,
        total_fatalities,
        total_events,
        violence_types_present,
        
        -- Look ahead exactly 2 years to define future risk
        SUM(total_events) OVER (
            PARTITION BY country 
            ORDER BY year 
            RANGE BETWEEN 1 FOLLOWING AND 2 FOLLOWING
        ) AS future_events_2yr
    FROM yearly_country_stats
),

economic_data AS (
    -- Step 3: Pivot the World Bank metrics into clean columns
    SELECT 
        country_name,
        year,
        MAX(CASE WHEN metric = 'population' THEN metric_value END) AS population,
        MAX(CASE WHEN metric = 'gdp' THEN metric_value END) AS gdp
    FROM {{ ref('stg_worldbank_demographics') }}
    GROUP BY country_name, year
)

-- Step 4: The Master Join & Feature Engineering
SELECT
    c.country,
    c.year,
    c.total_fatalities,
    c.total_events,
    c.violence_types_present,
    e.population,
    e.gdp,
    
    -- Engineered Context Features
    SAFE_DIVIDE(e.gdp, e.population) AS gdp_per_capita,
    SAFE_DIVIDE(c.total_fatalities, (e.population / 100000)) AS fatalities_per_100k_people,

    -- The Final Binary Label for the ML Model (1 = Risk, 0 = Peace)
    IF(IFNULL(c.future_events_2yr, 0) > 0, 1, 0) AS target_conflict_next_2_years

FROM rolling_features c
LEFT JOIN economic_data e 
    ON c.country = e.country_name 
    AND c.year = e.year