select * from routes;
-- Calculate delivery delay (in hours)-------------------------------------------------------
SELECT 
    Shipment_ID,
    Order_ID,
    Pickup_Date,
    Delivery_Date,
    TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date) AS Delivery_Delay_Hours
FROM shipments;

-- Find the Top 10 delayed routes based on average delay hours. -----------------------------------------------
SELECT 
    r.Route_ID,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60), 2) AS Avg_Delay_Hours,
    COUNT(s.Shipment_ID) AS Total_Shipments
FROM shipments s
JOIN routes r 
    ON s.Route_ID = r.Route_ID
GROUP BY r.Route_ID
ORDER BY Avg_Delay_Hours DESC
LIMIT 10;

-- Use SQL window functions to rank shipments by delay within each Warehouse_ID.----------------------------------------------------
SELECT
    s.Shipment_ID,
    s.Warehouse_ID,
    s.Pickup_Date,
    s.Delivery_Date,

    ROUND(
        TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60, 
        2
    ) AS Delay_Hours,

    RANK() OVER (
        PARTITION BY s.Warehouse_ID
        ORDER BY TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) DESC
    ) AS Delay_Rank
FROM Shipments s;

-- Identify the average delay per Delivery_Type (Express / Standard) to compare service-level efficiency.----------------------------------------

SELECT 
    o.Delivery_Type,
    COUNT(s.Shipment_ID) AS Total_Shipments,

    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60),
        2
    ) AS Avg_Delay_Hours
FROM Shipments s
join orders o 
    on o.Order_ID = s.Order_ID
GROUP BY o.Delivery_Type
ORDER BY Avg_Delay_Hours DESC;

    



