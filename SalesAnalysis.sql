USE AdventureWorks;

WITH SalesAnalysis AS
(
    SELECT
        d.SalesOrderID AS SalesOrderID,
        c.CustomerID AS CustomerID,
        d.UnitPrice AS UnitPrice,
        d.OrderQty AS OrderQty,
        c.OrderDate AS OrderDate
    FROM Person.Person a

    JOIN Sales.Customer b
    ON a.BusinessEntityID = b.PersonID

    JOIN Sales.SalesOrderHeader c
    ON b.CustomerID = c.CustomerID

    JOIN Sales.SalesOrderDetail d
    ON c.SalesOrderID = d.SalesOrderID

    GROUP BY
        c.OrderDate,
        d.SalesOrderID,
        c.CustomerID,
        d.UnitPrice,
        d.OrderQty
       
)
,
SemiStep AS
(
    SELECT
        SUM(UnitPrice * OrderQty) AS TotalRevenue,
        COUNT(DISTINCT SalesOrderID) TotalOrders,
        SUM(OrderQty) AS UnitsSold,
        MAX(OrderDate) AS FirstOrderDate,
        MIN(OrderDate) AS LastOrderDate,
        COUNT(DISTINCT CustomerID) AS UniqueCustomers
    FROM SalesAnalysis
)

SELECT
    TotalRevenue,
    TotalOrders,
    UnitsSold,
    TotalRevenue/TotalOrders AS AverageOrderValue,
    FirstOrderDate,
    LastOrderDate,
    UniqueCustomers
FROM SemiStep