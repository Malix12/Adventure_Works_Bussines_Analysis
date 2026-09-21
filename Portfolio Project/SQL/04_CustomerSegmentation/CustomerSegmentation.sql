USE AdventureWorks;

WITH CustomerSegmentation AS
(
    SELECT 
        CONCAT(a.FirstName,' ',a.LastName) AS FullName,
        c.OrderDate AS OrderDate,
        c.SalesOrderID AS OrderID,
        d.UnitPrice AS Price,
        d.OrderQty AS Quantity
    FROM Person.Person a

    JOIN Sales.Customer b
    ON a.BusinessEntityID = b.PersonID

    JOIN Sales.SalesOrderHeader c
    ON b.CustomerID = c.CustomerID

    JOIN Sales.SalesOrderDetail d
    ON c.SalesOrderID = d.SalesOrderID

    GROUP BY 
        a.FirstName,
        a.LastName,
        c.OrderDate,
        c.SalesOrderID,
        d.UnitPrice,
        d.OrderQty
)
,
FirstStep AS(
    SELECT
        FullName,
        DATEDIFF(DAY,MAX(OrderDate),'2025-06-30') AS Recency,
        COUNT(DISTINCT OrderID) AS Frequency,
        SUM(Price * Quantity) AS Monetary
    FROM CustomerSegmentation

    GROUP BY FullName
)

SELECT 
    *,
    CASE
        WHEN Monetary >= 15000 THEN 'Platinum'
        WHEN Monetary >= 10000 THEN 'Gold'
        WHEN Monetary >= 7000 THEN 'Silver'
        WHEN Monetary >= 3000 THEN 'Bronze'
        ELSE 'No Segment'
    END AS CustomerSegment
FROM FirstStep

ORDER BY Monetary DESC