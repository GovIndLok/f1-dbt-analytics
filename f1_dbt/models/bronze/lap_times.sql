{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'lap_times_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/lap_times.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)