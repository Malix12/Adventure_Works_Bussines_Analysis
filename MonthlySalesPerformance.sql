USE AdventureWorks;

WITH MonthlySalesPerformance AS
(
    SELECT
        YEAR(a.OrderDate) AS Year,
        MONTH(a.OrderDate) AS Month,
        b.UnitPrice AS UnitPrice,
        a.SalesOrderID AS SalesOrderID,
        b.OrderQty AS OrderQty
    FROM Sales.SalesOrderHeader a

    JOIN Sales.SalesOrderDetail b
    ON a.SalesOrderID = b.SalesOrderID

    GROUP BY
        a.OrderDate,
        a.SalesOrderID,
        b.UnitPrice,
        b.OrderQty
)
,
SemiStep AS
(
    SELECT
        [Year],
        [Month],
        SUM(UnitPrice*OrderQty) AS Revenue,
        COUNT(DISTINCT SalesOrderID) AS Orders,
        SUM(OrderQty) AS UnitsSold
    FROM MonthlySalesPerformance

    GROUP BY
        [Year],
        [Month]
)

SELECT
    *
FROM SemiStep

ORDER BY
    [Year] DESC,
    [Month] DESC