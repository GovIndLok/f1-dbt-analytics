{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'constructor_standings_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/constructor_standings.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)