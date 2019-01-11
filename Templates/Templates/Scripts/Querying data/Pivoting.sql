

/*** PIVOT ***/

-- Выделяем необходимые данные для PIVOT
WITH pivotData AS (
  SELECT ToRows, ToColumns, ToAggregate
  FROM SomeTable
)
-- Применяем PIVOT
SELECT ToRows, [ToColumns1]..[ToColumnsN] 
FROM pivotData
  PIVOT (SUM(ToAggregate) FOR ToColumns IN ([ToColumns1]..[ToColumnsN])) AS pvt


-- Коротко
WITH pivotData AS (SELECT R, C, A) FROM MyTable) 
SELECT R, [C1]..[CN] FROM pivotData PIVOT (SUM(A) FOR C IN ([C1]..[CN])) AS pvt


SELECT 
	PostalCityID,
	CustomerCategoryID,
	CustomerID
FROM Sales.Customers 
ORDER BY PostalCityID, CustomerCategoryID;


WITH pivotData AS (
  SELECT 
    PostalCityID,
  	CustomerCategoryID,
  	CustomerID
  FROM Sales.Customers
)
SELECT 
  PostalCityID,
  [1] AS [Agent],
  [2] AS [Wholesaler],
  [3] AS [Novelty Shop],
  [4] AS [Supermarket],
  [5] AS [Computer Store],
  [6] AS [Gift Store],
  [7] AS [Corporate],
  [8] AS [General Retailer]
FROM pivotData
  PIVOT (COUNT(CustomerID) FOR [CustomerCategoryID] IN ([1],[2],[3],[4],[5],[6],[7],[8])) AS pvt
  

/*** UNPIVOT ***/

--SELECT < column list >, < names column >, < values column >
--FROM < source table >
--UNPIVOT( < values column > FOR < names column > IN( <source columns> ) ) AS U;

SELECT Сol, Nam, Val
FROM MyTable
UNPIVOT (Val FOR Nam IN(Col1..ColN)) AS u;

SELECT 
  [OrderID],
  [SalespersonPersonID],
  [PickedByPersonID],
  [ContactPersonID]
FROM [Sales].[Orders]

SELECT OrderID, PersonType, PersonID
FROM [Sales].[Orders]
UNPIVOT (
  PersonID FOR PersonType IN (SalespersonPersonID, PickedByPersonID, ContactPersonID)
) AS U;