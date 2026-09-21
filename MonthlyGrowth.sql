USE AdventureWorks;

WITH MonthlyGrowth AS
(
    SELECT
        YEAR(a.OrderDate) AS Year,
        MONTH(a.OrderDate) AS Month,
        b.UnitPrice AS UnitPrice,
        b.OrderQty AS OrderQty
    FROM Sales.SalesOrderHeader a

    JOIN Sales.SalesOrderDetail b
    ON a.SalesOrderID = b.SalesOrderID

    GROUP BY
        a.OrderDate,
        b.UnitPrice,
        b.OrderQty
)
,
SemiStep AS
(
    SELECT 
        [Year],
        [Month],
        SUM(UnitPrice * OrderQty) AS Revenue

    FROM MonthlyGrowth

    GROUP BY
        [Year],
        [Month]
) 
,
PreviousMonth AS
(
    SELECT
        *,
        LAG(Revenue) OVER(
            ORDER BY [Year], [Month]
        ) AS PreviousMonth,
        SUM(Revenue) OVER(
            ORDER BY [Year]DESC, [Month]DESC
        )AS Cumulative
    FROM SemiStep
)

SELECT 
    [Year],
    [Month],
    Revenue,
    PreviousMonth,
    ((Revenue - PreviousMonth)/PreviousMonth) AS MoMGrowth,
    Cumulative
FROM PreviousMonth

ORDER BY
    [Year] DESC,
    [Month] DESC