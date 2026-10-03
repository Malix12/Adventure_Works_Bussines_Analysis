USE AdventureWorks;

GO

CREATE VIEW YoYView AS

With FirstStep AS(
SELECT
    Date,
    Revenue,
    LAG(Revenue,12) OVER(
        ORDER BY Date ASC
    ) AS YoY
FROM MonthlyGrowthView
)
,
SecondStep AS (
    SELECT
        *,
        (Revenue - YoY)/YoY AS PercentualChange
    FROM FirstStep
)

SELECT * FROM SecondStep



