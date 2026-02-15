{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'status_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/status.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)