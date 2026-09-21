 
DROP VIEW IF EXISTS ProductAnalysisView

GO

CREATE VIEW ProductAnalysisView
AS
WITH ProductAnalysis AS
(
    SELECT
        a.ProductID AS ID,
        a.Name AS Product,
        c.ProductCategoryID AS Category,
        b.ProductSubcategoryID AS Subcategory,
        d.UnitPrice AS Price,
        d.OrderQty AS Quantity,
        d.SalesOrderID AS SaleID
    FROM Production.Product a

    JOIN Production.ProductSubcategory b
    ON a.ProductSubcategoryID = b.ProductSubcategoryID

    JOIN Production.ProductCategory c
    ON b.ProductCategoryID = c.ProductCategoryID

    JOIN Sales.SalesOrderDetail d
    ON a.ProductID = d.ProductID

    GROUP BY
        a.ProductID,
        a.Name,
        c.ProductCategoryID,
        b.ProductSubcategoryID,
        d.UnitPrice,
        d.OrderQty,
        d.SalesOrderID
)
,
FirstStep AS
(
    SELECT
        ID,
        Product,
        Category,
        Subcategory,
        SUM(Price * Quantity) AS Revenue,
        COUNT(DISTINCT SaleID) AS NumOfOrders

    FROM ProductAnalysis

    GROUP BY
        ID,
        Product,
        Category,
        Subcategory
)
,
SecondStep AS
(
    SELECT
        ID,
        Product,
        Category,
        Subcategory,
        Revenue,
        NumOfOrders,
        Revenue/NumOfOrders AS AverageOrderValue
    FROM FirstStep
)
,
ThirdStep AS
(
    SELECT
        *,
        RANK() OVER(
            ORDER BY Revenue DESC
        ) AS Rank
    FROM SecondStep
)

SELECT * FROM ThirdStep
;

GO

SELECT * FROM ProductAnalysisView;

SELECT TOP 10 * FROM ProductAnalysisView;

SELECT TOP 10 * FROM ProductAnalysisView
ORDER BY Rank DESC;

SELECT 
    *,
    RANK() OVER(
        PARTITION BY Category
        ORDER BY Revenue DESC
    ) AS CategoryRank
FROM ProductAnalysisView;

DROP VIEW IF EXISTS CategoryAnalysisView

GO

CREATE VIEW CategoryAnalysisView AS

WITH CategoryAnalysis AS(
    SELECT
        c.ProductCategoryID AS Category,
        d.UnitPrice AS Price,
        d.OrderQty AS Quantity
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
        d.OrderQty
)
,FirstStep AS
(
    SELECT
        Category,
        SUM(Price * Quantity) AS Revenue
    FROM CategoryAnalysis

    GROUP BY
        Category
)

SELECT * FROM FirstStep

GO

SELECT * FROM CategoryAnalysisView
ORDER BY Revenue DESC

DROP VIEW IF EXISTS SubcategoryAnalysisView

GO

CREATE VIEW SubcategoryAnalysisView AS

WITH SubcategoryAnalysis AS
(
    SELECT
        b.ProductSubcategoryID AS Subcategory,
        d.UnitPrice AS Price,
        d.OrderQty AS Quantity
    FROM Production.Product a 

    JOIN Production.ProductSubcategory b
    ON a.ProductSubcategoryID = b.ProductSubcategoryID

    JOIN Sales.SalesOrderDetail d
    ON a.ProductID = d.ProductID

    GROUP BY
        b.ProductSubcategoryID,
        d.UnitPrice,
        d.OrderQty
)
,
FirstStep AS(
    SELECT
        Subcategory,
        SUM(Price * Quantity) AS Revenue
    FROM SubcategoryAnalysis

    GROUP BY Subcategory
)

SELECT * FROM FirstStep;

GO

SELECT * FROM SubcategoryAnalysisView
ORDER BY Revenue DESC

