{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'results_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/results.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)