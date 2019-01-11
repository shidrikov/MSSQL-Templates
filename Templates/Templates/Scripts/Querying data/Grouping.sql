

/*** GROUP BY ***/

SELECT CustomerID, OrderDate, COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY CustomerID, OrderDate
UNION ALL
SELECT CustomerID, NULL AS OrderDate, COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY CustomerID;



/*** GROUPING SETS ***/

SELECT CustomerID, OrderDate, COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY GROUPING SETS (
	(CustomerID, OrderDate), 
	(CustomerID)
);

SELECT CustomerID, OrderDate, COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY CustomerID, OrderDate
UNION ALL
SELECT CustomerID, NULL AS OrderDate, COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY CustomerID;


/*** ROLLUP ***/

SELECT CustomerID, OrderDate, COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY GROUPING SETS (
	(CustomerID, OrderDate), 
	(CustomerID), 
	()
);

SELECT 
  CustomerID, 
  OrderDate, 
  COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY ROLLUP (CustomerID, OrderDate)


/*** CUBE ***/

SELECT CustomerID, OrderDate, COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY GROUPING SETS (
	(CustomerID, OrderDate),
	(CustomerID),
	(OrderDate), 
	()
);

SELECT 
  CustomerID, 
  OrderDate, 
  COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY CUBE (CustomerID, OrderDate)


/*** Grouping combinations ***/

SELECT CustomerID, OrderDate, SalespersonPersonID, COUNT(*) AS [Orders]
FROM Sales.Orders
GROUP BY 
	GROUPING SETS ((CustomerID), ()), 
	ROLLUP (SalespersonPersonID, OrderDate), 
	CUBE((CustomerID, OrderDate))


/*** GROUPING and GROUPING_ID functions ***/

-- Если колонка для группировки не допускает значения NULL, то интерпретировать результат просто:

SELECT [SupplierID], -- not nullable
	   [UnitPackageID], -- not nullable
	   COUNT(*) AS [ItemCount] 
FROM [Warehouse].[StockItems]
GROUP BY CUBE ([SupplierID], [UnitPackageID])
ORDER BY [SupplierID], [UnitPackageID]

-- А как быть, если колонка для группировки допускает значения NULL?

SELECT [Brand], -- nullable
	   [ColorID], -- nullable
	   COUNT(*) AS [ItemCount] 
FROM [Warehouse].[StockItems]
GROUP BY CUBE ([ColorID], [Brand])
ORDER BY Brand, ColorID

-- Функция GROUPING позволяет определить, является ли строка сгруппированной по конкретной колонке

SELECT [Brand],
	   [ColorID],
	   COUNT(*) AS [ItemCount] ,
	   GROUPING([Brand])   AS IsGroupedBy_Brand,
	   GROUPING([ColorID]) AS IsGroupedBy_Color
FROM [Warehouse].[StockItems]
GROUP BY CUBE ([Brand], [ColorID])
ORDER BY Brand, ColorID

-- Функция GROUPING_ID позволяет определить уровень группировки

SELECT [Brand],
	   [ColorID],
	   COUNT(*) AS [ItemCount] ,
	   GROUPING_ID([Brand], [ColorID]) AS GroupLevel
FROM [Warehouse].[StockItems]
GROUP BY CUBE ([Brand], [ColorID])
ORDER BY Brand, ColorID

SELECT [Brand],
	   [ColorID],
	   COUNT(*) AS [ItemCount] ,
	   GROUPING_ID([Brand], [ColorID]) AS GroupLevel,
	   CASE 
		 WHEN GROUPING_ID([Brand], [ColorID]) = 0 THEN 'Brand, ColorID'
		 WHEN GROUPING_ID([Brand], [ColorID]) = 1 THEN 'ColorID'
		 WHEN GROUPING_ID([Brand], [ColorID]) = 2 THEN 'Brand'
		 WHEN GROUPING_ID([Brand], [ColorID]) = 3 THEN 'Total' END AS GroupedBy
FROM [Warehouse].[StockItems]
GROUP BY CUBE ([Brand], [ColorID])
ORDER BY Brand, ColorID
