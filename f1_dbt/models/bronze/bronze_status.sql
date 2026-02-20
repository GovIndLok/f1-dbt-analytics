{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'status_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/status.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)