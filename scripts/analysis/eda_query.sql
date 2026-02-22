SELECT 
    CASE 
        WHEN duration_minutes > 1440 THEN 'Over 24 Hours (Likely Error)'
        WHEN duration_minutes > 180 THEN '3-24 Hours (Long Rental)'
        WHEN duration_minutes > 30 THEN '30-180 Mins (Leisure)'
        ELSE 'Under 30 Mins (Commuter)'
    END AS trip_category,
    COUNT(*) AS total_trips,
    ROUND(AVG(duration_minutes), 1) AS avg_duration,
    MIN(duration_minutes) AS shortest_trip,
    MAX(duration_minutes) AS longest_trip
FROM `tfl-efficiency-project.tfl_efficiency_us.fact_cycling_trip`
GROUP BY 1
ORDER BY avg_duration DESC;