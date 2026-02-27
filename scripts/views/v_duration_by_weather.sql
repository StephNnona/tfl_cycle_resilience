-- View: Average trip duration by weather severity level (Jan - Aug 2025)
CREATE OR REPLACE VIEW `tfl-efficiency-project.tfl_efficiency_us.v_duration_by_weather` AS
SELECT
    w.weather_severity_level,
    ROUND(AVG(f.duration_minutes),2) AS avg_duration
FROM `tfl-efficiency-project.tfl_efficiency_us.fact_cycling_trip` f
JOIN `tfl-efficiency-project.tfl_efficiency_us.dim_weather` w
    ON f.date_id = w.weather_date
WHERE f.date_id BETWEEN '2025-01-01' AND '2025-08-24'
GROUP BY 1;