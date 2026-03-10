{{
  config(
    materialized = 'table',
    tags = ['dimension']
    )
}}

WITH source_constructors AS (
    SELECT * FROM {{ ref('silver_constructors') }}
),

final AS (
    SELECT
        constructorId,

        constructorRef,
        constructorName,
        nationality as constructorNationality,
        wikipediaUrl as constructorUrl,

        root_team_name,

        is_rebrand,
        is_successor_team,
        is_current_name
    FROM source_constructors
)

SELECT * FROM final