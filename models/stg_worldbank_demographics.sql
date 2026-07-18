WITH raw_data AS (
SELECT 
    string_field_0 AS country_name,
    string_field_1 AS country_code,
    string_field_2 AS metric_name, 
    string_field_3 AS metric_code,
    string_field_4 AS year_1989,
    string_field_5 AS year_1990,
    string_field_6 AS year_1991,
    string_field_7 AS year_1992,
    string_field_8 AS year_1993,
    string_field_9 AS year_1994,
    string_field_10 AS year_1995,
    string_field_11 AS year_1996,
    string_field_12 AS year_1997,
    string_field_13 AS year_1998,
    string_field_14 AS year_1999,
    string_field_15 AS year_2000,
    string_field_16 AS year_2001,
    string_field_17 AS year_2002,
    string_field_18 AS year_2003,
    string_field_19 AS year_2004,
    string_field_20 AS year_2005,
    string_field_21 AS year_2006,
    string_field_22 AS year_2007,
    string_field_23 AS year_2008,
    string_field_24 AS year_2009,
    string_field_25 AS year_2010,
    string_field_26 AS year_2011,
    string_field_27 AS year_2012,
    string_field_28 AS year_2013,
    string_field_29 AS year_2014,
    string_field_30 AS year_2015,
    string_field_31 AS year_2016,
    string_field_32 AS year_2017,
    string_field_33 AS year_2018,
    string_field_34 AS year_2019,
    string_field_35 AS year_2020, 
    string_field_36 AS year_2021,
    string_field_37 AS year_2022,
    string_field_38 AS year_2023,
    string_field_39 AS year_2024,
    string_field_40 AS year_2025
    
FROM {{ source('Worldbank_raw', 'raw_worldbank_demographics') }}
-- 1. This removes the header row from your actual data
WHERE string_field_0 != 'Country Name' 
-- 2. World Bank CSVs usually have 5 blank rows at the very bottom, this drops them!
AND string_field_0 IS NOT NULL

),

unpivoted_data AS (
    SELECT 
        country_name,
        country_code,
        metric_name,
        year_string,
        raw_value
    FROM raw_data
    -- This magically rotates the year columns into rows!
    UNPIVOT(
        raw_value FOR year_string IN (

            year_1989, year_1990, year_1991, year_1992, year_1993,
            year_1994, year_1995, year_1996, year_1997, year_1998, year_1999, year_2000, year_2001,
            year_2002, year_2003, year_2004, year_2005, year_2006, year_2007, year_2008, year_2009,
            year_2010, year_2011, year_2012, year_2013, year_2014, year_2015, year_2016, year_2017,
            year_2018, year_2019, year_2020, year_2021, year_2022, year_2023, year_2024, year_2025
        )
    )
)

SELECT 
    country_name,
    country_code,
    -- Simplify the metric names so they are easier to query later
    CASE 
        WHEN metric_name LIKE '%Population%' THEN 'population'
        WHEN metric_name LIKE '%GDP%' THEN 'gdp'
        ELSE 'unknown'
    END AS metric,
    -- Strip the word "year_" out and turn it into a real integer (e.g., 2020)
    CAST(REPLACE(year_string, 'year_', '') AS INT64) AS year,
    -- Safely convert the numbers, turning the ".." dots into true NULLs
    SAFE_CAST(raw_value AS FLOAT64) AS metric_value
    
FROM unpivoted_data