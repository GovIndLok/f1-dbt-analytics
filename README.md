# F1 Analytics Platform — Technical Documentation
> **Role Target:** Data Engineer | Analytics Engineer
> **Stack:** dbt Core · Databricks · Unity Catalog · Delta Lake

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Architecture Design](#3-architecture-design)
4. [Source Data Model](#4-source-data-model)
5. [Bronze Layer](#5-bronze-layer)
6. [Silver Layer](#6-silver-layer)
7. [Seeds](#7-seeds)
8. [Snapshots (SCD Type 2)](#8-snapshots-scd-type-2)
9. [Testing Strategy](#9-testing-strategy)

---

## 1. Project Overview

An end-to-end data pipeline for Formula 1 race analytics built on a **Medallion Architecture** using **dbt Core** for transformations and **Databricks** as the data platform.

**Current Phase (Implementation till now):** 
Historical data ingestion and transformation spanning Bronze and Silver layers, alongside Seed-based business mappings and SCD Type 2 Snapshots. The unified Gold layer mapping for business KPIs is planned for the next phase.

---

## 2. Tech Stack

| Component | Technology |
|---|---|
| Data Platform | Databricks |
| Storage Format | Delta Lake |
| Transformation | dbt Core |
| Source Data | F1 CSV Dataset |
| Architecture Pattern | Medallion (Bronze → Silver) |

---

## 3. Architecture Design

### Catalog Structure

```text
f1_championship (catalog)
├── source          ← Raw CSV files setup definitions
├── bronze          ← Raw Delta tables ingestion
├── silver          ← Cleaned, deduplicated, type-cast tables
├── snapshots       ← SCD Type 2 historical dimension tracking
└── reference       ← dbt Seeds (Reference/lookup data)
```

Schema configuration is parameterized via `dbt_project.yml` for flexibility:
```yaml
vars:
  catalog: "f1_championship"
  source_schema: "source"
  bronze_schema: "bronze"
  silver_schema: "silver"
  reference_schema: "reference"
```

---

## 4. Source Data Model
Here is the UML diagram that details the relationships and structure of the raw F1 source data:

![F1 Source Data UML Model](src/f1_UML.png)

---

## 5. Bronze Layer

### Purpose
Ingest raw data sources logically modeled into Databricks Delta tables with minimal transformation. Captures raw data fidelity ensuring robust traceability.

### Implemented Models
Support covers 15 individual staging models, including:
- `bronze_circuits`, `bronze_constructors`, `bronze_drivers`
- `bronze_races`, `bronze_results`, `bronze_lap_times`
- `bronze_sprint_results`, `bronze_pit_stops`, `bronze_qualifyings`
- `bronze_seasons`, `bronze_driver_standings`, `bronze_constructor_standings`

---

## 6. Silver Layer

### Purpose
Apply core transformations to produce clean, strict, and analytics-ready unified data:
1. **Null / missing value handling** logic implementations
2. **Deduplication** strategies implemented through analytical logic.
3. **Data typing and casting optimizations**

### Implemented Models
Extends directly from the Bronze layer counterparts, curating raw inputs into reliable entities (e.g., `silver_circuits`, `silver_drivers`, `silver_results`).
Features logic segregations like `silver_driver_num.sql` to manage complex F1 business logic correctly.

---

## 7. Seeds

Static and human-readable CSV files version-controlled directly in the repository for reference data enrichment. Assigned cleanly to the `reference` schema.

### 1. `seed_constructor_lineage.csv`
Encodes F1 team rebrand and succession relationships.
- Resolves complexities linking F1 teams identities that shift over time via buybacks and title-rebrands.
- **Tracking metadata fields include:** `constructor_ref`, `team_lineage_id`, `root_team_name`, `lineage_sequence`, `rebrand_year_start/end`, `succession_type`.

### 2. `status.csv`
Maps the generic identifier `statusId` from F1 records to definitive, informative statuses, providing immediate analytical context representing cases like 'Finished', 'Disqualified', or 'Accident'.

---

## 8. Snapshots (SCD Type 2)

Leverages robust configuration YAML to automatically generate Slowly Changing Dimensions (SCD Type 2) across vital records, reducing codebase burden.

### Snapshot Implementations
- **Constructor Lineage Snapshot (`constructor_lineage.yml`):**
  Monitors changes directly to tracking columns validating structural rebrands over time, preserving historic fidelity using `check` strategies.
- **Driver Snapshots (`driver.yml`):**
  Identifies structural tracking specific to persistent pilot records across years.

---

## 9. Testing Strategy

Strict schema validations configured at each level combining standard dbt logic constructs (`schema.yml`, `source.yml`):
- **Bronze:** Essential identifier presence (e.g., `unique` and `not_null` conditions).
- **Silver:** Promoted, strict assertion metrics verifying transformed data remains fully relational.
- **Seeds/Snapshots:** Validation preserving deterministic state across static maps.

---
*Generated for F1 Analytics Platform — Phase 1 implementation reference*
