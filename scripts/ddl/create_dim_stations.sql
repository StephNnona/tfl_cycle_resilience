CREATE OR REPLACE TABLE `tfl-efficiency-project.tfl_efficiency_eu.dim_stations` AS
SELECT 
    id AS station_id,
    name AS station_name,
    latitude,
    longitude,
    docks_count
FROM `bigquery-public-data.london_bicycles.cycle_stations`;