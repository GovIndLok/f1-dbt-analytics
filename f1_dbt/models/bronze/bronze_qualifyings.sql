{{
  config(
    materialized = 'table',
    tags = ['bronze']
    )
}}

-- dbt source: {{ source('source', 'qualifying_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/qualifying.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)