CREATE OR REPLACE TABLE `tfl-efficiency-project.tfl_efficiency_us.dim_weather` AS
SELECT 
    date AS weather_date,
    CASE 
     WHEN temp = 9999.9 THEN NULL  -- Handle missing temperature values (9999.9) by setting them to NULL
     ELSE ROUND((temp - 32) * 5/9, 1)    --convert temperature from Fahrenheit to Celsius 
    END AS avg_temp_celsius,
    CASE 
     WHEN prcp = 99.99 THEN 0   -- Handle missing precipitation values (99.99) by setting them to 0
     ELSE  ROUND(prcp * 25.4, 2)  -- Convert precipitation from inches to mm
    END AS rain_mm,
    CASE 
     WHEN SAFE_CAST(wdsp AS FLOAT64) = 999.9 THEN NULL  -- Handle missing wind speed values (999.9) by setting them to NULL
     ELSE ROUND(SAFE_CAST(wdsp AS FLOAT64) * 1.151, 1)  -- Convert wind speed from knots to mph   
    END AS wind_speed_mph
FROM `bigquery-public-data.noaa_gsod.gsod2025`
WHERE stn = '037720'  -- London Heathrow station;