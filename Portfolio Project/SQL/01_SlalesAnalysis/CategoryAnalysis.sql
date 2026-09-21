USE AdventureWorks;

WITH CategoryAnalysis AS
(
    SELECT
        c.ProductCategoryID AS Category,
        d.UnitPrice AS Price,
        d.OrderQty AS Quantity,
        d.SalesOrderID AS OrderID
    FROM Production.Product a

    JOIN Production.ProductSubcategory b
    ON a.ProductSubcategoryID = b.ProductSubcategoryID

    JOIN Production.ProductCategory c
    ON b.ProductCategoryID = c.ProductCategoryID

    JOIN Sales.SalesOrderDetail d
    ON a.ProductID = d.ProductID

    GROUP BY
        c.ProductCategoryID,
        d.UnitPrice,
        d.OrderQty,
        d.SalesOrderID
)
,
FirstStep AS
(
    SELECT
        Category,
        SUM(Price * Quantity) AS Revenue,
        SUM(Quantity) AS UnitsSold,
        COUNT(DISTINCT OrderID) AS Orders
    FROM CategoryAnalysis

    GROUP BY
        Category

) 
,
SecondStep AS
(
    SELECT 
        *,
        SUM(Revenue) OVER() AS TotalRevenue
    FROM FirstStep
)

SELECT
    Category,
    Revenue,
    UnitsSold,
    Orders,
    Revenue/TotalRevenue AS RevenueShare
FROM SecondStep

ORDER BY
 Revenue DESC