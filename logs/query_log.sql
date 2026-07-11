-- created_at: 2026-07-11T14:13:20.999241+00:00
-- finished_at: 2026-07-11T14:13:24.614551+00:00
-- elapsed: 3.6s
-- outcome: success
-- dialect: bigquery
-- node_id: not available
-- query_id: nxgEfBcPZXTiJuh7ofBBd7bVXy1
-- desc: execute adapter call
/* {"app": "dbt", "connection_name": "", "dbt_version": "2.0.0", "profile_name": "global_conflicts", "target_name": "dev"} */

    select distinct schema_name from `global-conflicts-500009`.INFORMATION_SCHEMA.SCHEMATA;
  ;
-- created_at: 2026-07-11T14:13:24.657689+00:00
-- finished_at: 2026-07-11T14:13:27.550042+00:00
-- elapsed: 2.9s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.mart_conflict_risk_predictions
-- query_id: waETvfX72OfpKI1TjBGZhQflQHl
-- desc: get_relation > list_relations call
SELECT
    table_catalog,
    table_schema,
    table_name,
    table_type
FROM 
    `global-conflicts-500009`.`raw_conflict_data`.INFORMATION_SCHEMA.TABLES;
-- created_at: 2026-07-11T14:13:27.869593+00:00
-- finished_at: 2026-07-11T14:13:31.647957+00:00
-- elapsed: 3.8s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.mart_conflict_risk_predictions
-- query_id: ZbEb6NcTdElNtliqos1OWiUF3hd
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.mart_conflict_risk_predictions", "profile_name": "global_conflicts", "target_name": "dev"} */

  
    

    create or replace table `global-conflicts-500009`.`raw_conflict_data`.`mart_conflict_risk_predictions`
      
    
    

    
    OPTIONS()
    as (
      

WITH latest_country_data AS (
    -- Step 1: Grab only the most recent year of data for each country
    -- We explicitly list only the features the ML model expects, plus the ones we want in the final output.
    SELECT 
        country,
        conflict_year,
        total_fatalities,
        total_events,
        violence_types_present
    FROM `global-conflicts-500009`.`raw_conflict_data`.`mart_country_conflict_features`
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
    );
  ;
