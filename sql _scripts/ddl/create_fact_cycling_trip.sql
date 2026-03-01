CREATE OR REPLACE TABLE `tfl-efficiency-project.tfl_efficiency_us.fact_cycling_trip`
PARTITION BY date_id
CLUSTER BY start_station_id
AS
SELECT
    rental_id AS journey_id,
    DATE(start_date) AS date_id,
    EXTRACT(HOUR FROM start_date) AS start_hour,
    CAST(start_station_id AS INT64) AS start_station_id,
    CAST(end_station_id AS INT64) AS end_station_id,
    CAST(duration_ms AS INT64) AS duration_ms,
    duration_ms/60000.0 AS duration_minutes, 
FROM `tfl-efficiency-project.tfl_raw.cycle_trips_2025`
WHERE end_station_id IS NOT NULL
    AND duration_ms IS NOT NULL
    AND (duration_ms/60000.0) <= 1440 -- Filter out trips longer than 24 hours 
    AND duration_ms >= 60000; -- Filter out trips shorter than 1 minute              