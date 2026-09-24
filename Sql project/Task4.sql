
-- Find the top 3 warehouses with the highest average delay in shipments dispatched.------------------------------------
SELECT 
    o.Warehouse_ID,
    ROUND(AVG(
        TIMESTAMPDIFF(HOUR, s.Expected_Delivery_Date, s.Delivery_Date)
    ), 2) AS Avg_Delay_Hours
FROM orders o
JOIN shipments s
    ON o.Order_ID = s.Order_ID
WHERE s.Delivery_Date > s.Expected_Delivery_Date
GROUP BY o.Warehouse_ID
ORDER BY Avg_Delay_Hours DESC
LIMIT 3;

-- Calculate total shipments vs delayed shipments for each warehouse.-----------------------------------------------
SELECT
    Warehouse_ID,
    COUNT(*) AS Total_Shipments,
    SUM(CASE WHEN Delay_Hours > 0 THEN 1 ELSE 0 END) AS Delayed_Shipments,
    ROUND(
        (SUM(CASE WHEN Delay_Hours > 0 THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
    ) AS Delay_Percentage
FROM shipments
GROUP BY Warehouse_ID
ORDER BY Delay_Percentage DESC;

-- Use CTEs to identify warehouses where average delay exceeds the global average delay ----------------------------------------------

WITH Warehouse_Avg AS (
    SELECT
        Warehouse_ID,
        AVG(Delay_Hours) AS Avg_Warehouse_Delay
    FROM shipments
    WHERE Delay_Hours > 0
    GROUP BY Warehouse_ID
),
Global_Avg AS (
    SELECT
        AVG(Delay_Hours) AS Global_Avg_Delay
    FROM shipments
    WHERE Delay_Hours > 0
)
SELECT
    w.Warehouse_ID,
    ROUND(w.Avg_Warehouse_Delay, 2) AS Avg_Warehouse_Delay,
    ROUND(g.Global_Avg_Delay, 2) AS Global_Avg_Delay
FROM Warehouse_Avg w
CROSS JOIN Global_Avg g
WHERE w.Avg_Warehouse_Delay > g.Global_Avg_Delay
ORDER BY w.Avg_Warehouse_Delay DESC;

-- Rank all warehouses based on on-time delivery percentage.-------------------------------------------------------------------

WITH Warehouse_Performance AS (
    SELECT
        Warehouse_ID,
        COUNT(*) AS Total_Shipments,
        SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) AS OnTime_Shipments
    FROM shipments
    GROUP BY Warehouse_ID
)
SELECT
    Warehouse_ID,
    Total_Shipments,
    OnTime_Shipments,
    ROUND((OnTime_Shipments / Total_Shipments) * 100, 2) AS OnTime_Percentage,
    RANK() OVER (ORDER BY (OnTime_Shipments / Total_Shipments) DESC) AS Performance_Rank
FROM Warehouse_Performance
ORDER BY Performance_Rank;




