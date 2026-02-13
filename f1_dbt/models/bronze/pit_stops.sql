{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'pit_stops_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/pit_stops.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)