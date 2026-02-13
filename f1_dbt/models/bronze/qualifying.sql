{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'qualifying_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/qualifying.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)