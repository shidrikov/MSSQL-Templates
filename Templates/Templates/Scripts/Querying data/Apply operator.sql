

/* CROSS APPLY */

SELECT * FROM Sales.Customers
SELECT * FROM Sales.Orders

SELECT C.CustomerID, C.CustomerName, ORD.OrderID, ORD.OrderDate
FROM Sales.Customers C
  CROSS APPLY (SELECT TOP 2 OrderID, OrderDate
               FROM Sales.Orders O
               WHERE O.CustomerId = C.CustomerId ORDER BY OrderDate DESC) ORD
GO

CREATE FUNCTION dbo.Get2MostRecentOrders (@CustomerId INT)
RETURNS TABLE
AS
RETURN (
  SELECT TOP 2 OrderID, OrderDate
  FROM Sales.Orders O
  WHERE O.CustomerId = @CustomerId ORDER BY OrderDate DESC)
GO

SELECT C.CustomerID, C.CustomerName, ORD.OrderID, ORD.OrderDate
FROM Sales.Customers C
  CROSS APPLY dbo.Get2MostRecentOrders (C.CustomerID) ORD


/* OUTER APPLY */

SELECT * FROM [Sales].[Invoices]
SELECT * FROM [Sales].[InvoiceLines]

SELECT I.[InvoiceID], IL.[Description], IL.[UnitPrice]
FROM [Sales].[Invoices] I
OUTER APPLY (
  SELECT TOP 1 [InvoiceLineID], [Description], [UnitPrice]
  FROM [Sales].[InvoiceLines] IL1 
  WHERE IL1.InvoiceID = I.InvoiceID AND [Quantity] = 1
  ORDER BY [UnitPrice] ASC) IL
