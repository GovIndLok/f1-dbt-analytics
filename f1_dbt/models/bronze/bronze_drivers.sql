{{
  config(
    materialized = 'table',
    tags = ['bronze']
    )
}}

-- dbt source: {{ source('source', 'drivers_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/drivers.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)