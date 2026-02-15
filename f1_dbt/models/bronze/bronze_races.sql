{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'races_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/races.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)