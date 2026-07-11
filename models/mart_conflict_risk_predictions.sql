{{ config(materialized='table') }}

WITH latest_country_data AS (
    -- Step 1: Grab only the most recent year of data for each country
    -- We explicitly list only the features the ML model expects, plus the ones we want in the final output.
    SELECT 
        country,
        conflict_year,
        total_fatalities,
        total_events,
        violence_types_present
    FROM {{ ref('mart_country_conflict_features') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY country ORDER BY conflict_year DESC) = 1
),

predictions AS (
    -- Step 2: Feed that recent data into your BigQuery ML model
    -- We explicitly select the original columns we need for the dashboard, 
    -- PLUS the specific probability array column that ML.PREDICT generates.
    SELECT 
        country,
        conflict_year,
        total_events,
        predicted_target_conflict_next_5_years_probs
    FROM ML.PREDICT(
        MODEL `global-conflicts-500009.raw_conflict_data.predict_conflict_risk`, 
        (
            SELECT 
                country,
                conflict_year,
                total_fatalities,
                total_events,
                violence_types_present
            FROM latest_country_data
        )
    )
)

-- Step 3: Clean up the output for your final dashboard
SELECT 
    country,
    conflict_year AS last_data_year,
    total_events AS recent_conflict_events,
    
    -- BQML outputs an array of probabilities. We extract the probability of '1' (Conflict)
    ROUND(prob.prob * 100, 2) AS conflict_probability_percent,
    
    -- Categorize the risk based on the probability percentage
    CASE 
        WHEN prob.prob > 0.97 THEN 'Critical Risk'
        WHEN prob.prob > 0.95 THEN 'High Risk'
        WHEN prob.prob > 0.82 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category

FROM predictions, UNNEST(predicted_target_conflict_next_5_years_probs) AS prob
WHERE prob.label = 1 
ORDER BY conflict_probability_percent DESC