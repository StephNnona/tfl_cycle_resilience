-- View: Monthly Trends (Full Year 2025)
CREATE OR REPLACE VIEW `tfl-efficiency-project.tfl_efficiency_us.v_monthly_trends_2025` AS
SELECT
  d.year AS year,
  d.month AS month_number,
  d.month_name,
  COUNT(f.journey_id) AS total_trips,
  ROUND(AVG(f.duration_minutes),2) AS avg_dur_minutes
FROM `tfl-efficiency-project.tfl_efficiency_us.fact_cycling_trip` f
JOIN `tfl-efficiency-project.tfl_efficiency_us.dim_date` d
  ON f.date_id = d.date_id
GROUP BY 1,2,3
ORDER BY 1,2;
