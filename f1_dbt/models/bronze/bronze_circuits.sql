{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'circuits_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/circuits.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)