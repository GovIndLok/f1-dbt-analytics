{{
  config(
    materialized = 'table',
    tags = ['bronze']
    )
}}

-- dbt source: {{ source('source', 'circuits_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/circuits.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)