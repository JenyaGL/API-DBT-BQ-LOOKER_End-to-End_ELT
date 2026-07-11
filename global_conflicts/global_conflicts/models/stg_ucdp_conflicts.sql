{{
    config(
        materialized='incremental',
        unique_key='event_id'
    )
}}

WITH raw_conflicts AS (
    SELECT *,
    -- This stamps the data for our final records so we know when dbt ran
    CURRENT_TIMESTAMP() as loaded_at_timestamp
    FROM {{ source('raw_ucdp', 'raw_data') }}
    
    {% if is_incremental() %}
    -- We CANNOT filter by the timestamp because we are generating it live.
    -- We MUST use the unique 'id' to detect genuinely new rows from the API.
    WHERE id > (SELECT MAX(event_id) FROM {{ this }})
    {% endif %}
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