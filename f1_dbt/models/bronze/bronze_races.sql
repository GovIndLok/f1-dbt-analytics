{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'races_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/races.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)