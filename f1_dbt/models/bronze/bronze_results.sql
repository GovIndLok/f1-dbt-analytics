{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'results_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/results.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)