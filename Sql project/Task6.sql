
-- For each shipment, display the latest status (Delivered, In Transit, or Returned) along with the latest Delivery_Date----------------------------------
SELECT
    Shipment_ID,
    Delivery_Status AS Latest_Status,
    Delivery_Date AS Latest_Delivery_Date
FROM (
        SELECT
            Shipment_ID,
            Delivery_Status,
            Delivery_Date,
            ROW_NUMBER() OVER (
                PARTITION BY Shipment_ID
                ORDER BY Delivery_Date DESC
            ) AS rn
        FROM shipments
     ) t
WHERE rn = 1
ORDER BY Shipment_ID;

-- Identify routes where the majority of shipments are still “In Transit” or “Returned”.-----------------------------------------------

SELECT
    Route_ID,
    COUNT(*) AS Total_Shipments,
    SUM(CASE WHEN Delivery_Status IN ('In Transit', 'Returned') THEN 1 ELSE 0 END) AS Problem_Shipments,
    ROUND(
        (SUM(CASE WHEN Delivery_Status IN ('In Transit', 'Returned') THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
    ) AS Problem_Percentage
FROM shipments
GROUP BY Route_ID
HAVING (SUM(CASE WHEN Delivery_Status IN ('In Transit', 'Returned') THEN 1 ELSE 0 END) / COUNT(*)) > 0.5
ORDER BY Problem_Percentage DESC;

-- Find the most frequent delay reasons (if available in delay-related columns or flags)----------------------------------------

SELECT
    Delay_Reason,
    COUNT(*) AS delay_count
FROM Shipments
WHERE Delay_Reason IS NOT NULL
  AND Delay_Reason <> 'No Delay'
GROUP BY Delay_Reason
ORDER BY delay_count DESC;

-- Identify orders with exceptionally high delay (>120 hours) to investigate potential bottlenecks ----------------------------------

SELECT
    Shipment_ID,
    Order_ID,
    Route_ID,
    Agent_ID,
    Warehouse_ID,
    Delay_Hours,
    Delay_Reason,
    Delivery_Status
FROM Shipments
WHERE Delay_Hours > 120
ORDER BY Delay_Hours DESC;






