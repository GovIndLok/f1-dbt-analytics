{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'driver_standings_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/driver_standings.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)