{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'seasons_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/seasons.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)