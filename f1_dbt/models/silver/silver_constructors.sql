{{
    config(
        materialized = 'table',
        schema = var('silver_schema')
    )
}}

/*
    silver_constructors
    -------------------
    Constructor dimension enriched with team lineage tracking from seed_constructor_lineage.

    Grain: one row per constructor-era. A constructor that left and returned
    (e.g. Renault 2002-2011 then 2016-2020) will appear in multiple rows.

    Rebrands  → same team_lineage_id, combined stats (e.g. Toro Rosso → AlphaTauri → RB)
    Successions → new team_lineage_id, separate stats, linked via predecessor_lineage_id (e.g. Kick Sauber → Audi)

    Source: bronze_constructors  (raw CSV data)
    Lineage: seed_constructor_lineage (reference seed, SCD2 tracked via snapshot_constructor_lineage)
*/

WITH source AS (
    SELECT * FROM {{ ref('bronze_constructors') }}
),

cleaned AS (
    SELECT
        CAST(constructorId AS INTEGER)                                          AS constructor_id,
        LOWER(COALESCE(NULLIF(TRIM(constructorRef), ''), 'unknown'))            AS constructor_ref,
        COALESCE(NULLIF(TRIM(name), ''), 'Unknown')                             AS constructor_name,
        COALESCE(NULLIF(TRIM(nationality), ''), 'Unknown')                      AS nationality,
        NULLIF(TRIM(url), '')                                                   AS wikipedia_url
    FROM source
    WHERE constructorId IS NOT NULL
),

with_lineage AS (
    SELECT
        -- Core constructor fields
        c.constructor_id,
        c.constructor_ref,
        c.constructor_name,
        c.nationality,
        c.wikipedia_url,

        -- Lineage enrichment from seed_constructor_lineage
        -- Falls back to a generated value for constructors not in the seed
        COALESCE(lin.team_lineage_id,    c.constructor_ref || '_lineage')       AS team_lineage_id,
        COALESCE(lin.root_team_name,     c.constructor_name)                    AS root_team_name,
        COALESCE(lin.lineage_sequence,   1)                                     AS lineage_sequence,
        lin.rebrand_year_start,
        lin.rebrand_year_end,
        lin.predecessor_lineage_id,
        lin.succession_type,
        lin.rebrand_notes,

        -- Computed lineage flags
        CASE WHEN lin.constructor_ref IS NOT NULL    THEN TRUE ELSE FALSE END   AS is_part_of_lineage,
        CASE WHEN lin.lineage_sequence > 1           THEN TRUE ELSE FALSE END   AS is_rebrand,
        CASE WHEN lin.predecessor_lineage_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_successor_team,
        CASE WHEN lin.rebrand_year_end IS NULL       THEN TRUE ELSE FALSE END   AS is_current_name

    FROM cleaned c
    LEFT JOIN {{ ref('seed_constructor_lineage') }} lin
        ON c.constructor_ref = lin.constructor_ref
)

SELECT * FROM with_lineage
