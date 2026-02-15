{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'drivers_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/drivers.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)