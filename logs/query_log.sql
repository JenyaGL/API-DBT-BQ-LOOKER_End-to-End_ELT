<<<<<<< HEAD
=======
-- created_at: 2026-07-11T16:16:38.682896+00:00
-- finished_at: 2026-07-11T16:16:42.066676+00:00
-- elapsed: 3.4s
-- outcome: success
-- dialect: bigquery
-- node_id: not available
-- query_id: EfGPVJzY9OyASkblpeJxH9TZ2eo
-- desc: list_relations_in_parallel
SELECT
    table_catalog,
    table_schema,
    table_name,
    table_type
FROM 
    `global-conflicts-500009`.`raw_conflict_data`.INFORMATION_SCHEMA.TABLES;
-- created_at: 2026-07-11T16:16:42.144466+00:00
-- finished_at: 2026-07-11T16:16:45.241156+00:00
-- elapsed: 3.1s
-- outcome: success
-- dialect: bigquery
-- node_id: not available
-- query_id: 9yeIHHlMdkO59K4BsnPoleSjiXg
-- desc: execute adapter call
/* {"app": "dbt", "connection_name": "", "dbt_version": "2.0.0", "profile_name": "global_conflicts", "target_name": "dev"} */

    select distinct schema_name from `global-conflicts-500009`.INFORMATION_SCHEMA.SCHEMATA;
  ;
-- created_at: 2026-07-11T16:16:45.655744+00:00
-- finished_at: 2026-07-11T16:16:58.742444+00:00
-- elapsed: 13.1s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.stg_ucdp_conflicts
-- query_id: ev5GZOVrYo1MqdV9pHdTkT7UsAh
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.stg_ucdp_conflicts", "profile_name": "global_conflicts", "target_name": "dev"} */
-- back compat for old kwarg name
  
  
        
            
            
            
            
        
    

    

    merge into `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts` as DBT_INTERNAL_DEST
        using (

WITH raw_conflicts AS (
    SELECT *,
    -- This stamps the data for our final records so we know when dbt ran
    CURRENT_TIMESTAMP() as loaded_at_timestamp
    FROM `global-conflicts-500009`.`raw_conflict_data`.`raw_data`
    
    
    -- We CANNOT filter by the timestamp because we are generating it live.
    -- We MUST use the unique 'id' to detect genuinely new rows from the API.
    WHERE id > (SELECT MAX(event_id) FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts`)
    
),

renamed_and_cleaned AS (
    SELECT 
        id AS event_id,
        year AS conflict_year,
        type_of_violence,
        side_a,
        side_b,
        country,
        region,
        latitude,
        longitude,
        best AS estimated_fatalities,
        date_start,
        date_end,
        loaded_at_timestamp
    FROM raw_conflicts
    WHERE country IS NOT NULL
)

SELECT * FROM renamed_and_cleaned
        ) as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.event_id = DBT_INTERNAL_DEST.event_id))

    
    when matched then update set
        `event_id` = DBT_INTERNAL_SOURCE.`event_id`,`conflict_year` = DBT_INTERNAL_SOURCE.`conflict_year`,`type_of_violence` = DBT_INTERNAL_SOURCE.`type_of_violence`,`side_a` = DBT_INTERNAL_SOURCE.`side_a`,`side_b` = DBT_INTERNAL_SOURCE.`side_b`,`country` = DBT_INTERNAL_SOURCE.`country`,`region` = DBT_INTERNAL_SOURCE.`region`,`latitude` = DBT_INTERNAL_SOURCE.`latitude`,`longitude` = DBT_INTERNAL_SOURCE.`longitude`,`estimated_fatalities` = DBT_INTERNAL_SOURCE.`estimated_fatalities`,`date_start` = DBT_INTERNAL_SOURCE.`date_start`,`date_end` = DBT_INTERNAL_SOURCE.`date_end`,`loaded_at_timestamp` = DBT_INTERNAL_SOURCE.`loaded_at_timestamp`
    

    when not matched then insert
        (`event_id`, `conflict_year`, `type_of_violence`, `side_a`, `side_b`, `country`, `region`, `latitude`, `longitude`, `estimated_fatalities`, `date_start`, `date_end`, `loaded_at_timestamp`)
    values
        (`event_id`, `conflict_year`, `type_of_violence`, `side_a`, `side_b`, `country`, `region`, `latitude`, `longitude`, `estimated_fatalities`, `date_start`, `date_end`, `loaded_at_timestamp`)


    ;
-- created_at: 2026-07-11T16:16:58.768818+00:00
-- finished_at: 2026-07-11T16:17:01.204552+00:00
-- elapsed: 2.4s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.dim_country
-- query_id: uL4LUBXKoFxIsN5IENM5SADYhK2
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.dim_country", "profile_name": "global_conflicts", "target_name": "dev"} */


  create or replace view `global-conflicts-500009`.`raw_conflict_data`.`dim_country`
  OPTIONS()
  as WITH source_data AS (
    SELECT DISTINCT country, region 
    FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts`
)

SELECT 
    to_hex(md5(cast(coalesce(cast(country as string), '_dbt_utils_surrogate_key_null_') as string))) AS country_id,
    country,
    region
FROM source_data;

;
-- created_at: 2026-07-11T16:16:59.056552+00:00
-- finished_at: 2026-07-11T16:17:02.645044+00:00
-- elapsed: 3.6s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.dim_dates
-- query_id: 9aS3RW4g6I4M1IE05lcLExOfBAG
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.dim_dates", "profile_name": "global_conflicts", "target_name": "dev"} */

  
    

    create or replace table `global-conflicts-500009`.`raw_conflict_data`.`dim_dates`
      
    
    

    
    OPTIONS()
    as (
      

SELECT DISTINCT
    conflict_year AS date_key,
    conflict_year AS year,
    -- Add more calendar logic here as needed!
    '2026' AS fiscal_year
FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts`
    );
  ;
-- created_at: 2026-07-11T16:16:59.409014+00:00
-- finished_at: 2026-07-11T16:17:03.286113+00:00
-- elapsed: 3.9s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.mart_country_conflict_features
-- query_id: 5JzsL35bTPwvxCbND2WhmboceLE
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.mart_country_conflict_features", "profile_name": "global_conflicts", "target_name": "dev"} */

  
    

    create or replace table `global-conflicts-500009`.`raw_conflict_data`.`mart_country_conflict_features`
      
    
    

    
    OPTIONS()
    as (
      

WITH yearly_country_stats AS (
    -- Step 1: Aggregate the data by Country and Year
    SELECT 
        country,
        conflict_year,
        SUM(estimated_fatalities) AS total_fatalities,
        COUNT(event_id) AS total_events,
        COUNT(DISTINCT type_of_violence) AS violence_types_present
    FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts`
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
    );
  ;
-- created_at: 2026-07-11T16:16:59.642653+00:00
-- finished_at: 2026-07-11T16:17:03.398463+00:00
-- elapsed: 3.8s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.dim_violence_type
-- query_id: 2vKtc3qvXsaQZAdNr4Q55QyaMqO
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.dim_violence_type", "profile_name": "global_conflicts", "target_name": "dev"} */

  
    

    create or replace table `global-conflicts-500009`.`raw_conflict_data`.`dim_violence_type`
      
    
    

    
    OPTIONS()
    as (
      

SELECT DISTINCT
    to_hex(md5(cast(coalesce(cast(type_of_violence as string), '_dbt_utils_surrogate_key_null_') as string))) AS violence_type_id,
    type_of_violence,
    CASE 
        WHEN type_of_violence = 1 THEN 'State-based'
        WHEN type_of_violence = 2 THEN 'Non-state'
        WHEN type_of_violence = 3 THEN 'One-sided'
        ELSE 'Other'
    END AS description
FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts`
    );
  ;
-- created_at: 2026-07-11T16:16:59.371941+00:00
-- finished_at: 2026-07-11T16:17:03.560519+00:00
-- elapsed: 4.2s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.dim_actors
-- query_id: UlKVqCawkM72xdmxPocdwRMrDUn
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.dim_actors", "profile_name": "global_conflicts", "target_name": "dev"} */

  
    

    create or replace table `global-conflicts-500009`.`raw_conflict_data`.`dim_actors`
      
    
    

    
    OPTIONS()
    as (
      

WITH all_actors AS (
    SELECT side_a AS actor_name FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts`
    UNION DISTINCT
    SELECT side_b AS actor_name FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts`
)

SELECT 
    to_hex(md5(cast(coalesce(cast(actor_name as string), '_dbt_utils_surrogate_key_null_') as string))) AS actor_id,
    actor_name
FROM all_actors
WHERE actor_name IS NOT NULL
    );
  ;
-- created_at: 2026-07-11T16:17:02.655049+00:00
-- finished_at: 2026-07-11T16:17:05.417041+00:00
-- elapsed: 2.8s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.mart_conflict_fatalities_by_country
-- query_id: ygO2nnbsOyVTa6xTrz8rm3Uk3V4
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.mart_conflict_fatalities_by_country", "profile_name": "global_conflicts", "target_name": "dev"} */


  create or replace view `global-conflicts-500009`.`raw_conflict_data`.`mart_conflict_fatalities_by_country`
  OPTIONS()
  as SELECT 
    c.country,
    c.region,
    d.year AS conflict_year,
    SUM(f.estimated_fatalities) AS total_fatalities,
    COUNT(f.event_id) AS total_conflict_events
FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts` f
LEFT JOIN `global-conflicts-500009`.`raw_conflict_data`.`dim_country` c ON f.country = c.country
LEFT JOIN `global-conflicts-500009`.`raw_conflict_data`.`dim_dates` d ON f.conflict_year = d.year
GROUP BY c.country, c.region, d.year
ORDER BY total_fatalities DESC;

;
-- created_at: 2026-07-11T16:17:02.943955+00:00
-- finished_at: 2026-07-11T16:17:06.953900+00:00
-- elapsed: 4.0s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.mart_global_trends_by_year
-- query_id: 4ZurmRvEJHqTgZ2CQ6pfqLvUL8V
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.mart_global_trends_by_year", "profile_name": "global_conflicts", "target_name": "dev"} */

  
    

    create or replace table `global-conflicts-500009`.`raw_conflict_data`.`mart_global_trends_by_year`
      
    
    

    
    OPTIONS()
    as (
      

SELECT 
    d.year AS conflict_year,
    COUNT(f.event_id) AS total_conflict_events,
    SUM(f.estimated_fatalities) AS total_fatalities,
    ROUND(SUM(f.estimated_fatalities) / COUNT(f.event_id), 2) AS average_fatalities_per_event
FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts` f
LEFT JOIN `global-conflicts-500009`.`raw_conflict_data`.`dim_dates` d ON f.conflict_year = d.year
GROUP BY d.year
ORDER BY d.year DESC    
    );
  ;
-- created_at: 2026-07-11T16:17:03.003534+00:00
-- finished_at: 2026-07-11T16:17:07.045291+00:00
-- elapsed: 4.0s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.mart_violence_types_overview
-- query_id: pgBHPI9fDRbABnlZD94sf0BziNa
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.global_conflicts.mart_violence_types_overview", "profile_name": "global_conflicts", "target_name": "dev"} */

  
    

    create or replace table `global-conflicts-500009`.`raw_conflict_data`.`mart_violence_types_overview`
      
    
    

    
    OPTIONS()
    as (
      

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
FROM `global-conflicts-500009`.`raw_conflict_data`.`stg_ucdp_conflicts` f
LEFT JOIN `global-conflicts-500009`.`raw_conflict_data`.`dim_country` c ON f.country = c.country
LEFT JOIN `global-conflicts-500009`.`raw_conflict_data`.`dim_dates` d ON f.conflict_year = d.year
GROUP BY c.country, c.region, d.year, f.type_of_violence, f.side_a, f.side_b, violence_type
ORDER BY total_fatalities DESC
    );
  ;
-- created_at: 2026-07-11T16:17:03.599157+00:00
-- finished_at: 2026-07-11T16:17:07.478852+00:00
-- elapsed: 3.9s
-- outcome: success
-- dialect: bigquery
-- node_id: model.global_conflicts.mart_conflict_risk_predictions
-- query_id: bhH4mrkdEmPGFHzkfRKAQpAixyz
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
>>>>>>> 1955200967666fb1ead88af6363015f3e4da25cb
