USE AdventureWorks;

WITH Top10Products AS
(
    SELECT
        a.ProductID AS Product,
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
        a.ProductID,
        c.ProductCategoryID,
        d.UnitPrice,
        d.OrderQty,
        d.SalesOrderID
)
,
FirstStep AS
(
    SELECT
        Product,
        Category,
        SUM(Price * Quantity) AS Revenue,
        SUM(Quantity) AS UnitsSold,
        COUNT(DISTINCT OrderID) AS Orders
    FROM Top10Products

    GROUP BY
        Product,
        Category
)
,SecondStep AS
(
SELECT
    *,
    RANK() OVER(
        ORDER BY Revenue DESC
    ) AS RevenueRank
FROM FirstStep
)

SELECT TOP 10
    *
FROM SecondStep 