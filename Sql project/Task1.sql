use dhl;
select * from orders;
select * from shipments;
-- Order_ID duplicate--
SELECT Order_ID, COUNT(*) AS total
FROM orders
GROUP BY Order_ID
HAVING COUNT(*) > 1 ;

-- Shipment_ID duplicate-------------------------------------------
SELECT Shipment_ID, COUNT(*) AS total
FROM shipments
GROUP BY Shipment_ID
HAVING COUNT(*) > 1;

 -- count of missing delay hous ------------------------------------------
select count( Delay_Hours)
from shipments 
where Delay_Hours = null; 

-- date formate-------------------------------------------------------------- 
SELECT 
DATE_FORMAT(Order_Date, '%Y-%m-%d %h:%i:%S') AS Order_Date
FROM orders;
SELECT 
DATE_FORMAT(Pickup_Date, '%Y-%m-%d %h:%i:%S') AS Pickup_Date
FROM shipments;
SELECT 
DATE_FORMAT(Delivery_Date, '%Y-%m-%d %h:%i:%S') AS Delivery_Date
FROM shipments;
ALTER TABLE orders
MODIFY Order_Date DATETIME;
ALTER TABLE shipments 
MODIFY Pickup_Date DATETIME;
ALTER TABLE shipments
MODIFY Delivery_Date DATETIME;

-- no Delivery_Date occurs before Pickup_Date----------------------------------------------
select Pickup_Date, Delivery_Date
from shipments
where Pickup_Date > Delivery_Date;

-- Validate referential integrity between Orders, Routes, Warehouses, and Shipments--------------------------------------------------

SELECT *
FROM Orders o
LEFT JOIN Shipments s 
ON o.Order_ID = s.Order_ID
WHERE s.Order_ID IS NULL; 

SELECT s.Shipment_ID
FROM shipments s
LEFT JOIN routes r
ON s.Route_ID = r.Route_ID
WHERE r.Route_ID IS NULL;

SELECT s.Shipment_ID
FROM shipments s
LEFT JOIN warehouses w
ON s.Warehouse_ID = w.Warehouse_ID
WHERE w.Warehouse_ID IS NULL;


select (SELECT COUNT(*) FROM Orders o 
 LEFT JOIN Shipments s ON o.Order_ID=s.Order_ID 
 WHERE s.Order_ID IS NULL) AS Missing_Shipments;

select(SELECT count(*)
FROM shipments s
LEFT JOIN routes r
ON s.Route_ID = r.Route_ID
WHERE r.Route_ID IS NULL) as Invalaid_routes;

select(SELECT count(*)
FROM shipments s
LEFT JOIN warehouses w
ON s.Warehouse_ID = w.Warehouse_ID
WHERE w.Warehouse_ID IS NULL) as Invalaid_warehouse;
