{{
  config(
    materialized = 'table',
    )
}}  

-- dbt source: {{ source('source', 'constructor_results_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/constructor_results.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)