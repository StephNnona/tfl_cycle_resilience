-- Weather Resilience Summary (Jan - Aug 2025)

-- Average number of trips per day by weather severity level
SELECT
    w.weather_severity_level,
    COUNT(DISTINCT date_id) AS unique_days,
    COUNT(f.journey_id) AS total_trips,
    ROUND(COUNT(f.journey_id)/COUNT(DISTINCT date_id),0) AS avg_trips_per_day
FROM `tfl-efficiency-project.tfl_efficiency_us.fact_cycling_trip` f
JOIN `tfl-efficiency-project.tfl_efficiency_us.dim_weather` w
    ON f.date_id = w.weather_date
WHERE f.date_id BETWEEN '2025-01-01' AND '2025-08-24'
GROUP BY 1;

-- Average trip duration by weather severity level
SELECT
    w.weather_severity_level,
    COUNT(f.journey_id) AS total_trips,
    ROUND(AVG(f.duration_minutes),2) AS avg_duration
FROM `tfl-efficiency-project.tfl_efficiency_us.fact_cycling_trip` f
JOIN `tfl-efficiency-project.tfl_efficiency_us.dim_weather` w
    ON f.date_id = w.weather_date
WHERE f.date_id BETWEEN '2025-01-01' AND '2025-08-24'
GROUP BY 1
ORDER BY 2 DESC;