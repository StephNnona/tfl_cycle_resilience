-- View: Staion Weather Impact Analysis (Jan - Aug 2025)

CREATE OR REPLACE VIEW `tfl-efficiency-project.tfl_efficiency_us.v_station_weather_impact` AS
WITH station_weather AS (
    SELECT
        f.start_station_id,
        s.station_name,
        w.weather_severity_level,
        COUNT(DISTINCT f.date_id) AS unique_days,
        COUNT(f.journey_id) AS total_trips,
    FROM `tfl-efficiency-project.tfl_efficiency_us.fact_cycling_trip` f
    JOIN `tfl-efficiency-project.tfl_efficiency_us.dim_weather` w
        ON f.date_id = w.weather_date
    JOIN `tfl-efficiency-project.tfl_efficiency_us.dim_stations` s
        ON f.start_station_id = s.station_id
    WHERE f.date_id BETWEEN '2025-01-01' AND '2025-08-24'
    GROUP BY 1,2,3
),
station_avg AS (
    SELECT
        start_station_id,
        station_name,
        weather_severity_level,
        ROUND(station_weather.total_trips/station_weather.unique_days,0) AS avg_trips_per_day
    FROM station_weather
)
SELECT
    start_station_id,
    station_name,
    weather_severity_level,
    avg_trips_per_day,
    MAX(CASE                                                                 -- Normal weather baseline per station
           WHEN weather_severity_level = 'Normal Weather' THEN avg_trips_per_day
        END) OVER (PARTITION BY start_station_id) AS normal_baseline,
    ROUND(100 * (1- SAFE_DIVIDE(avg_trips_per_day, MAX(CASE                  -- % drop from normal baseline (positive = drop)
           WHEN weather_severity_level = 'Normal Weather' THEN avg_trips_per_day
        END) OVER (PARTITION BY start_station_id))), 1) AS pct_change_from_normal
FROM station_avg;