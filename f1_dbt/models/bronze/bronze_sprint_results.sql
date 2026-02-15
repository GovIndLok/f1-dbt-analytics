{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'sprint_results_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/sprint_results.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)