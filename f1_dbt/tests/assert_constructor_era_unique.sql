-- Test: assert_constructor_era_unique
-- Each (constructor_id, rebrand_year_start) pair must be unique.
-- Constructors NOT in the lineage seed have NULL rebrand_year_start,
-- so uniqueness for those is guaranteed by the source bronze_constructors.
-- Any duplicates returned = test failure.

SELECT
    constructor_id,
    rebrand_year_start,
    COUNT(*) AS row_count
FROM {{ ref('silver_constructors') }}
WHERE rebrand_year_start IS NOT NULL
GROUP BY constructor_id, rebrand_year_start
HAVING COUNT(*) > 1
