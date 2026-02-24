CREATE OR REPLACE TABLE `tfl-efficiency-project.tfl_efficiency_us.dim_stations` AS
WITH station_raw AS (
    SELECT
        CAST(start_station_id AS INT64) AS station_id,
        start_station_name AS station_name
    FROM `tfl-efficiency-project.tfl_raw.cycle_trips_2025`
    UNION ALL
    SELECT
        CAST(end_station_id AS INT64) AS station_id,
        end_station_name AS station_name
    FROM `tfl-efficiency-project.tfl_raw.cycle_trips_2025`
    WHERE end_station_id IS NOT NULL
)
SELECT DISTINCT
    station_id,
    station_name
FROM station_raw;