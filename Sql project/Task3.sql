-- Average transit time (in hours) across all shipments.------------------------------------------------
use dhl;
select * from routes;
SELECT 
    r.Route_ID,
    COUNT(s.Shipment_ID) AS Total_Shipments,

    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60),
        2
    ) AS Avg_Transit_Time_Hours
FROM Shipments s
JOIN Routes r 
    ON s.Route_ID = r.Route_ID
GROUP BY r.Route_ID
ORDER BY Avg_Transit_Time_Hours DESC;

--  Average delay (in hours) per route.----------------------------------------------------

select 
     r.Route_ID,
     ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60),
        2
    ) AS Avg_Transit_Time_Hours
    from shipments s
    join routes r
		 ON s.Route_ID = r.Route_ID
    group by r.Route_ID
    order by r. Route_ID;
    
    -- Distance-to-time efficiency ratio = Distance_KM / Avg_Transit_Time_Hours. ------------------------------
    
 SELECT 
    r.Route_ID,
    r.Distance_KM,

    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60),
        2
    ) AS Avg_Transit_Time_Hours,

    ROUND(
        r.Distance_KM / 
        AVG(TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60),
        2
    ) AS Distance_Time_Efficiency_KM_per_Hour
FROM Routes r
JOIN Shipments s 
    ON r.Route_ID = s.Route_ID
GROUP BY r.Route_ID, r.Distance_KM
ORDER BY Distance_Time_Efficiency_KM_per_Hour DESC;

-- Identify 3 routes with the worst efficiency ratio (lowest distance-to-time)------------------------------------------------

SELECT 
    r.Route_ID,
    r.Distance_KM,

    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60),
        2
    ) AS Avg_Transit_Time_Hours,

    ROUND(
        r.Distance_KM /
        AVG(TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60),
        2
    ) AS Efficiency_KM_per_Hour
FROM Routes r
JOIN Shipments s 
    ON r.Route_ID = s.Route_ID
GROUP BY r.Route_ID, r.Distance_KM
ORDER BY Efficiency_KM_per_Hour ASC   -- lowest = worst
LIMIT 3;

-- Find routes with >20% of shipments delayed beyond expected transit time-----------------------------

SELECT
    r.Route_ID,
    r.Avg_Transit_Time_Hours,

    COUNT(s.Shipment_ID) AS Total_Shipments,

    SUM(
        CASE 
            WHEN (TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60)
                 > r.Avg_Transit_Time_Hours
            THEN 1 ELSE 0
        END
    ) AS Delayed_Shipments,

    ROUND(
        100 * 
        SUM(
            CASE 
                WHEN (TIMESTAMPDIFF(MINUTE, s.Pickup_Date, s.Delivery_Date) / 60)
                     > r.Avg_Transit_Time_Hours
                THEN 1 ELSE 0
            END
        ) / COUNT(s.Shipment_ID),
        2
    ) AS Delay_Percentage
FROM Shipments s
JOIN Routes r 
    ON s.Route_ID = r.Route_ID
GROUP BY r.Route_ID,  r.Avg_Transit_Time_Hours
HAVING Delay_Percentage > 20
ORDER BY Delay_Percentage DESC;

-- Recommend potential routes or hub pairs for optimization -----------------------------------------------------

select Route_ID,Source_Country,Destination_Country,Distance_KM,Avg_Transit_Time_Hours from routes
where Avg_Transit_Time_Hours<20 and Distance_KM>6000
order by Avg_Transit_Time_Hours desc


