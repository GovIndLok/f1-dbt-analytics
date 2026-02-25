{{
  config(
    materialized = 'table',
    )
}}

SELECT
    year,
    url
FROM {{ ref('bronze_seasons') }}