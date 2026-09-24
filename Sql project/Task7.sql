/*Create SQL queries to calculate and summarize the following KPIs: 
● Average Delivery Delay per Source_Country.---------------------------------------------------------------------*/

SELECT
    r.Source_Country,
    ROUND(AVG(s.Delay_Hours), 2) AS avg_delivery_delay_hours
FROM routes r
JOIN Shipments s
    ON r.Route_ID = s.Route_ID
WHERE s.Delay_Hours IS NOT NULL
GROUP BY r.Source_Country
ORDER BY avg_delivery_delay_hours DESC;

-- On-Time Delivery % = (Total On-Time Deliveries / Total Deliveries) * 100.--------------------------------------------------

SELECT
    ROUND(
        SUM(CASE 
                WHEN Delay_Hours = 0 THEN 1 
                ELSE 0 
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_percentage
FROM Shipments;

-- Average Delay (in hours) per Route_ID. --------------------------------------------------------

SELECT
    Route_ID,
    ROUND(AVG(Delay_Hours), 2) AS avg_delay_hours
FROM Shipments
WHERE Delay_Hours IS NOT NULL
GROUP BY Route_ID
ORDER BY avg_delay_hours DESC;

-- Warehouse Utilization % = (Shipments_Handled / Capacity_per_day) * 100.---------------------------------------

SELECT
    w.Warehouse_ID,
    w.Capacity_per_day,
    COUNT(s.Shipment_ID) AS shipments_handled,
    ROUND(
        COUNT(s.Shipment_ID) * 100.0 / w.Capacity_per_day,
        2
    ) AS warehouse_utilization_percentage
FROM Warehouses w
LEFT JOIN Shipments s
    ON w.Warehouse_ID = s.Warehouse_ID
GROUP BY
    w.Warehouse_ID,
    w.Capacity_per_day
ORDER BY warehouse_utilization_percentage DESC;

-- Use aggregation and CASE statements to compute these metrics and create summarized KPI tables-----------------------------------


SELECT
    COUNT(*) AS total_deliveries,

    SUM(
        CASE 
            WHEN Delay_Hours = 0 THEN 1 
            ELSE 0 
        END
    ) AS on_time_deliveries,

    ROUND(
        SUM(
            CASE 
                WHEN Delay_Hours = 0 THEN 1 
                ELSE 0 
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_percentage,

    ROUND(AVG(Delay_Hours), 2) AS avg_delay_hours,

    SUM(
        CASE 
            WHEN Delay_Hours > 120 THEN 1 
            ELSE 0 
        END
    ) AS high_delay_shipments
FROM Shipments;

