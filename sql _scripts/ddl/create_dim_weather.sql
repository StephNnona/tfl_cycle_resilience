CREATE OR REPLACE TABLE `tfl-efficiency-project.tfl_efficiency_us.dim_weather` AS
WITH weather_stats AS (
    SELECT 
    date AS weather_date,
    ROUND(AVG(CASE
        WHEN temp = 9999.9 THEN NULL  -- Handle missing temperature values (9999.9) by setting them to NULL
        ELSE (temp - 32) * 5/9    --convert temperature from Fahrenheit to Celsius 
    END), 1) AS avg_temp_celsius,
    ROUND(AVG(CASE 
        WHEN prcp = 99.99 THEN 0   -- Handle missing precipitation values (99.99) by setting them to 0
        ELSE prcp * 25.4  -- Convert precipitation from inches to mm
    END), 2) AS rain_mm,
    ROUND(AVG(CASE 
        WHEN SAFE_CAST(wdsp AS FLOAT64) = 999.9 THEN NULL  -- Handle missing wind speed values (999.9) by setting them to NULL
        ELSE SAFE_CAST(wdsp AS FLOAT64) * 1.151  -- Convert wind speed from knots to mph   
    END), 1) AS wind_speed_mph
FROM `bigquery-public-data.noaa_gsod.gsod2025`
WHERE stn IN ('037720', '037700', '037690', '037810', '037760')  -- Covers Greater London stations
GROUP BY weather_date
)
SELECT *,
    CASE
        WHEN rain_mm = 0 THEN "No Rain"
        WHEN rain_mm <= 2 THEN "Light Rain"
        ELSE "Heavy Rain"
    END AS rain_category,
    CASE
        WHEN avg_temp_celsius < 5 THEN "Cold"
        WHEN avg_temp_celsius <20 THEN "Mild"
        WHEN avg_temp_celsius <28 THEN "Warm"
        ELSE "Hot"
    END AS temperature_category,
    CASE                -- Binary indicator for heavy rain created for resilience analysis
        WHEN rain_mm > 2 THEN 1
        ELSE 0
    END AS is_heavy_rain_indicator,
    CASE                -- Binary indicator for hot day created for resilience analysis
        WHEN avg_temp_celsius > 28 THEN 1 
        ELSE 0 
    END AS is_hot_day_indicator,
    CASE 
        WHEN rain_mm > 2 AND avg_temp_celsius > 28 THEN "Severe Weather"  -- Define severe weather as heavy rain and hot temperature
        WHEN rain_mm > 2 THEN "Heavy Rain Only"
        WHEN avg_temp_celsius > 28 THEN "Hot Day Only"
        ELSE "Normal Weather"
    END AS weather_severity_level
FROM weather_stats;