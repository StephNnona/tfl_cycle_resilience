# TfL Cycling Weather Resilience Analysis (2025)

## Project Overview

This project analyses the resilience of London's Santander Cycle network under adverse weather conditions. Specifically, it evaluates how heavy rainfall impacts cycling demand across:

- The overall network

- Different times of day

- Individual docking stations

## Objectives

To assess behavioural elasticity and spatial resilience within the cycling network. This project also demonstrates:

- BigQuery Performance Optimisation - Joining multi-million row datasets while maintaining low cost and high speed

- Star schema modelling (Fact & Dimension tables)

- Advanced SQL (CTEs, Window Functions, Aggregations)

## Key Questions

1. How does heavy rain affect overall cycling demand?

2. Which hours of the day are most elastic under weather stress?

3. Does trip duration change during rain?

4. Are certain stations more resilient than others?

5. Is weather sensitivity explained by baseline demand levels?

6. Where might operational resilience improvements have the greatest impact?

## Data Sources

1. TfL Santander Cycles Journey Data (2025)
   - Raw CSV extracts (Jan - Dec 2025)

   - Cleaned and standardised before warehouse loading

   - Uploaded into BigQuery

2. NOAA GSOD Weather Data (Jan - Aug 2025)
   - bigquery-public-data.noaa_gsod.gsod2025

   - Filtered for Greater London weather stations

   - Converted from:
     - Fahrenheit -> Celsius

     - Inches -> mm

   - Classified into:
     - Normal Weather

     - Heavy Rain Only

## Data Model

A Star Schema was implemented in BigQuery.

### Fact Table

fact_cycling_trip

- journey_id
- date_id
- start_hour
- start_station_id
- end_station_id
- duration\_\_ms
- duration_minutes

Partitioned by:

- date_id

Clustered by:

- start_station_id

### Dimension Tables

dim_date

- date_id
- month_number
- month_name

* day_of_week
* etc.

dim_stations: Created from 2025 raw journey data.

- station_id
- station_name

dim_weather

- weather_date
- avg_temp_celsius
- rain_mm
- wind_speed_mph

* weather_severity_level
* etc.

  Note: 2025 weather data was available for January through to 24 August 2025, so weather-based analysis is limited to those months.

```markdown
The full Entity Relationship Diagram (ERD) can be found here: [View ERD](data_model/erd.md)
```

## Data Cleaning & Quality

1. Handling schema drift (raw cycle hire data): 24 separate CSV files with inconsistent column names and order.  
   Resolution using a Python script:
   - Standardised column order and names
   - Cast ID columns to Int64 to prevent Pandas from converting them to Floats due to missing values.
   - Identified and removed duplicate columns across monthly extracts.

2. Resolving Data Type Inconsistencies (BigQuery SQL): During the ingestion of the NOAA weather data, I encountered data type mismatches. The weather metrics were stored as STRING types, which prevented mathematical analysis.  
   Resolution:
   - Utilized SAFE_CAST(wdsp AS FLOAT64) to convert wind speed strings into numbers.
   - Transformed sensor error codes (e.g., 999.9 for wind and 99.99 for rain) into NULL or 0 to prevent extreme outliers from skewing results.

3. Mismatch between station dimension and 2025 cycle journey: Some station IDs in the 2025 raw data were not present in public dataset for cycle station found in BigQuery.  
   Resolution:
   - Rebuilt dim_station from 2025 raw data
   - Included all active station IDs

4. Weather coverage data gaps: 2025 weather dataset only available up to 24 August 2025.  
   Resolution:
   - Weather analysis covers between Jan - Aug 2025
   - Other operational analyses based on full year data

5. Cycle duration outliers: Maximum cycle duration observed was 301,435 minutes which is likely an operational anomaly.  
   Resolution:
   - Removed journeys < 1 minute (system noise / accidental unlocks)
   - Removed journeys > 1440 minutes (operational anomalies)

6. Sensor redundancy: The primary NOAA weather sensor for London (Heathrow) reported near-zero rainfall for the 2025 period.  
   Resolution:
   - Aggregated data from 5 London sensors, calculating a daily average for temperature and rainfall
   - Weather variance captured

## Tooling

- Google BigQuery
- SQL
- VS Code
- Git & GitHub
- Looker Studio
- Pandas

## BigQuery Optimisation

Partitioning and Clustering: The fact table (~9M rows) is partitioned by journey date and clustered by start station ID to optimise scan efficiency and reduce BigQuery compute cost when performing time-based and station-level aggregations.

Metric: Partitioning reduced scan volume from 68.59MB to 8.59MB when filtering by a single month (an 87% reduction in processed data).

## Dashboard Layout

### Page 1 – Network Overview

- Total trips (2025)

- Peak-hour share (~49% of trips occur 6–9AM & 4–6PM)

- Maximum morning commute drop (~36%)

- Monthly trend

- Hourly demand profile (Normal vs Heavy Rain)

Key Finding:

- Heavy rain reduces demand significantly, but peak-hour structure remains intact.

### Page 2 – Temporal Resilience

- Hourly elasticity under heavy rain

- Average trips per hour (Normal vs Rain)

- Trip duration comparison

Findings:

- Early commute hours (6–8AM) exhibit highest elasticity

- Peak structure persists under stress

- Average trip duration decreases during heavy rain  
  → Suggests discretionary/leisure trips reduce first

### Page 3 – Spatial Resilience

- Interactive baseline threshold filter

- Ranking of most resilient and most weather-sensitive stations

Findings:

- Institutional and commuter-linked stations demonstrate relative stability

- Park-adjacent and retail-centred areas show greater contraction

## Behavioural Insight

Rain appears to disproportionately reduce discretionary cycling activity while preserving structured commuter demand.

The network contracts — but does not collapse.

## Dashboard

You can view the interactive dashboard here:

[View Live Report](https://lookerstudio.google.com/reporting/4b5ee763-c227-440f-b46e-02fd5774f6c0)

If access issues occur, please contact me.

## Operational Implications

Based on observed demand elasticity patterns:

- Early morning commuter corridors (6–8AM) represent the highest leverage window for resilience interventions.

- High-volume institutional and transport-adjacent hubs demonstrate structural importance and should be prioritised for reliability-focused improvements.

- Stations in park-adjacent and retail-centred areas show greater discretionary sensitivity to heavy rain, suggesting weather impacts trip purpose composition.

Targeted improvements in high-volume commuter corridors may stabilise peak demand and reduce substitution pressure on alternative transport modes.

## Ethics

- No personal or identifiable data is used
- Analysis is conducted at a system level, not individual behaviour
- Weather impacts are discussed as correlations, not causal claims
- This project is intended as decision-support analysis, not predictive modelling.

## Reproducing the Project

1. Create a BigQuery dataset (US region recommended due to NOAA GSOD Data).

2. Upload TfL 2025 journey CSV files into BigQuery
   (raw files are excluded from this repository via .gitignore).

3. Run SQL scripts in order:
   - Create dimension tables (dim_date, dim_weather, dim_stations)

   - Create fact_cycling_trip (partitioned by date_id, clustered by start_station_id)

   - Create analytical views (v_peak_hour_weather_impact, v_station_weather_impact, v_duration_by_weather, v_monthly_trends_2025)

4. Connect Looker Studio to the fact table and analytical views to rebuild the dashboard pages.
