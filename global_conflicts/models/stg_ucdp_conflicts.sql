WITH raw_conflicts AS (
    -- The source function tells dbt to look at the sources.yml file
    SELECT * FROM {{ source('raw_ucdp', 'raw_data') }}
),

renamed_and_cleaned AS (
    SELECT 
        id AS event_id,
        year AS conflict_year,
        active_year,
        type_of_violence,
        conflict_name,
        country,
        region,
        latitude,
        longitude,
        best AS estimated_fatalities,
        date_start,
        date_end
    FROM raw_conflicts
    -- Filter out any rows where the country name is completely blank
    WHERE country IS NOT NULL
)

SELECT * FROM renamed_and_cleaned