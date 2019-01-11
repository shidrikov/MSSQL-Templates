

/*** Window functions ***/

/*** Window ranking functions ***/

SELECT CustomerID, OrderID, OrderDate,
  ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNum,
  RANK()       OVER (ORDER BY OrderDate) AS Rnk,
  DENSE_RANK() OVER (ORDER BY OrderDate) AS DenseRnk,
  NTILE(100)   OVER (ORDER BY OrderDate) AS Ntile100
FROM Sales.Orders;

SELECT CustomerID, OrderID, OrderDate,
  ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS RowNum,
  RANK()       OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS Rnk,
  DENSE_RANK() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS DenseRnk,
  NTILE(100)   OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS Ntile100
FROM Sales.Orders;


/*** Window aggregate functions ***/

SELECT 
  [InvoiceLineID], 
  [InvoiceID], 
  SUM(Quantity) OVER (PARTITION BY [InvoiceID] ORDER BY [InvoiceLineID]) AS [QuantitySum]
FROM [Sales].[InvoiceLines]
ORDER BY [InvoiceLineID]

SELECT 
  [InvoiceLineID], 
  [InvoiceID], 
  SUM(Quantity) OVER (PARTITION BY [InvoiceID] 
                      ORDER BY [InvoiceLineID]
                      ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS [QuantitySum]
FROM [Sales].[InvoiceLines]
ORDER BY [InvoiceLineID]


/*** Window frames ***/

SELECT [InvoiceLineID], [InvoiceID], Quantity FROM [Sales].[InvoiceLines]
ORDER BY [InvoiceLineID]

SELECT 
  [InvoiceLineID], 
  [InvoiceID], 
  SUM(Quantity) OVER (PARTITION BY [InvoiceID] 
                      ORDER BY [InvoiceLineID]
					  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [QuantitySum]
					  --ROWS UNBOUNDED PRECEDING) AS [QuantitySum]
FROM [Sales].[InvoiceLines_]
ORDER BY [InvoiceLineID]


SELECT 
  [InvoiceLineID], 
  [InvoiceID], 
  SUM(Quantity) OVER (PARTITION BY [InvoiceID] 
                      ORDER BY [InvoiceLineID]
					  RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [QuantitySum]
					  --ROWS UNBOUNDED PRECEDING) AS [QuantitySum]
FROM [Sales].[InvoiceLines_]
ORDER BY [InvoiceLineID]

SELECT * INTO [Sales].[InvoiceLines_] FROM [Sales].[InvoiceLines]
SELECT * FROM [Sales].[InvoiceLines_] ORDER BY InvoiceLineID INSERT [Sales].[InvoiceLines_]
SELECT * FROM [Sales].[InvoiceLines] WHERE InvoiceLineID = 7

SELECT [InvoiceLineID], [InvoiceID], Quantity FROM [Sales].[InvoiceLines]
ORDER BY [InvoiceLineID]

SELECT 
  [InvoiceLineID], 
  [InvoiceID], 
  SUM(Quantity) OVER (PARTITION BY [InvoiceID] 
                      ORDER BY [InvoiceLineID]
					  ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS [QuantitySum]
FROM [Sales].[InvoiceLines]
ORDER BY [InvoiceLineID]


SELECT [InvoiceLineID], [InvoiceID], Quantity FROM [Sales].[InvoiceLines]
ORDER BY [InvoiceLineID]

SELECT 
  [InvoiceLineID], 
  [InvoiceID], 
  SUM(Quantity) OVER (PARTITION BY [InvoiceID] 
                      ORDER BY [InvoiceLineID]
					  ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS [QuantitySum]
FROM [Sales].[InvoiceLines]
ORDER BY [InvoiceLineID]



/*** Window offset functions ***/

SELECT 
  [CustomerID], [OrderID], [OrderDate], [ExpectedDeliveryDate],
  LAG([ExpectedDeliveryDate])  OVER (PARTITION BY [CustomerID] ORDER BY [OrderDate], [OrderID]) AS prev_val,
  LEAD([ExpectedDeliveryDate]) OVER (PARTITION BY [CustomerID] ORDER BY [OrderDate], [OrderID]) AS next_val
FROM Sales.Orders;
