CREATE OR REPLACE VIEW `tfl-efficiency-project.tfl_efficiency_us.v_peak_hour_weather_impact` AS
WITH hourly_trips AS (
    SELECT
        f.start_hour,
        w.weather_severity_level,
        COUNT(DISTINCT f.date_id) AS unique_days,
        COUNT(f.journey_id) AS total_trips,
    FROM `tfl-efficiency-project.tfl_efficiency_us.fact_cycling_trip` f
    JOIN `tfl-efficiency-project.tfl_efficiency_us.dim_weather` w
        ON f.date_id = w.weather_date
    WHERE f.date_id BETWEEN '2025-01-01' AND '2025-08-24'
    GROUP BY 1,2
),
hourly_avg AS (
    SELECT
    start_hour,
    weather_severity_level,
    ROUND(hourly_trips.total_trips/hourly_trips.unique_days,0) AS avg_trips_per_hour
FROM hourly_trips
)
SELECT
    start_hour,
    weather_severity_level,
    avg_trips_per_hour,
    MAX(CASE                                                -- Normal weather baseline per hour
        WHEN weather_severity_level = 'Normal Weather'
            THEN hourly_avg.avg_trips_per_hour
        END) OVER (PARTITION BY start_hour) AS normal_baseline,
    ROUND(100 * (1 - avg_trips_per_hour/ (MAX(CASE          -- Percentage drop in average trips hour for heavy rain days vs normal weather days
                            WHEN weather_severity_level = 'Normal Weather'
                            THEN hourly_avg.avg_trips_per_hour
                        END) OVER (PARTITION BY start_hour))),1
    ) AS pct_drop
FROM hourly_avg;