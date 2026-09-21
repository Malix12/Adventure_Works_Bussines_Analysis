USE AdventureWorks;

WITH CustoemerAnalysis AS
(
    SELECT
        b.CustomerID AS ID,
        CONCAT(a.FirstName,' ',a.LastName) AS FullName,
        c.SalesOrderID AS Orders,
        d.UnitPrice as Price,
        d.OrderQty AS Quantity,
        c.OrderDate aS OrderDate

    FROM Person.Person a

    JOIN Sales.Customer b
    ON a.BusinessEntityID = b.PersonID

    JOIN Sales.SalesOrderHeader c
    ON b.CustomerID = c.CustomerID

    JOIN Sales.SalesOrderDetail d
    ON c.SalesOrderID = d.SalesOrderID

    GROUP BY 
        b.CustomerID,
        a.FirstName,
        a.LastName,
        c.SalesOrderID,
        d.UnitPrice,
        d.OrderQty,
        c.OrderDate

)
,
FirstStep AS
(
    SELECT
        ID,
        FullName,
        SUM(Price * Quantity) AS Revenue,
        COUNT(DISTINCT Orders) AS NumOfOrders,
        SUM(Quantity) AS UnitsPurchased,
        MIN(OrderDate) AS FirstOrder,
        MAX(OrderDate) AS LastOrder
    FROM CustoemerAnalysis

    GROUP BY 
        ID,
        FullName
)
,
SecondStep AS
(
    SELECT 
        *,
        SUM(Revenue) OVER() AS TotalRevenue,
        DATEDIFF(DAY,LastOrder,'2025-06-29') AS LastOrderInterval
    FROM FirstStep
)
SELECT
    ID,
    FullName,
    Revenue,
    NumOfOrders,
    UnitsPurchased,
    Revenue/NumOfOrders AS AvgOrderValue,
    FirstOrder,
    LastOrder,
    RANK() OVER(
        ORDER BY Revenue DESC
    ) AS Rank,
    Revenue/TotalRevenue AS RevenueShare,
    CASE 
        WHEN LastOrderInterval <= 365 THEN 'Active'
        ELSE 'Inactive'
    END AS Status
        


FROM SecondStep

