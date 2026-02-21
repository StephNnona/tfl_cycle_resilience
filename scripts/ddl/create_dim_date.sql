CREATE OR REPLACE TABLE `tfl-efficiency-project.tfl_efficiency_us.dim_date` AS
WITH date_series AS (
 SELECT date
 FROM UNNEST(GENERATE_DATE_ARRAY('2025-01-01', '2025-12-31')) AS date
)
SELECT
 date AS date_id,
 EXTRACT(YEAR FROM date) AS year,
 EXTRACT(MONTH FROM date) AS month,
 FORMAT_DATE('%B', date) AS month_name,
 EXTRACT(QUARTER FROM date) AS quarter,
 EXTRACT(DAY FROM date) AS day,
 FORMAT_DATE('%A', date) AS day_name,
 EXTRACT(DAYOFWEEK FROM date) AS day_of_week,
 CASE WHEN EXTRACT(DAYOFWEEK FROM date) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
 CASE WHEN EXTRACT(MONTH FROM date) IN (12, 1, 2) THEN "Winter"
      WHEN EXTRACT(MONTH FROM date) IN (3, 4, 5) THEN "Spring"
      WHEN EXTRACT(MONTH FROM date) IN (6, 7, 8) THEN "Summer"
      ELSE "Autumn" END AS season
FROM date_series;