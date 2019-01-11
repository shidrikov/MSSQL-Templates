

/* Конвертация типов */

SELECT CAST('001' AS INT)
SELECT CAST('abc' AS INT)

SELECT CONVERT(INT, '001')
SELECT CONVERT(INT, 'abc')

SELECT CONVERT(DATE, '01/02/2017', 101)
SELECT CONVERT(DATE, '01/02/2017', 103)

SELECT TRY_CAST('14/02/2017' AS DATE)
SELECT TRY_CAST('1' AS INT)

SELECT TRY_CONVERT(DATE, '14/02/2017', 101)
SELECT TRY_CONVERT(DATE, '14/02/2017', 103)

SELECT FORMAT(SYSDATETIME(), 'yyyy-MM-dd')

SELECT PARSE('Monday, 13 December 2010' AS datetime2 USING 'en-US');


/* Дата и время */

SELECT GETDATE()
SELECT GETUTCDATE()
SELECT SYSDATETIME()
SELECT SYSUTCDATETIME()
SELECT CURRENT_TIMESTAMP
SELECT SYSDATETIMEOFFSET()

SELECT DATEPART (WEEKDAY, '09/25/2018')
SELECT DATEPART (QUARTER, '09/25/2018')
SELECT DATEFROMPARTS (2018, 7, 2)
SELECT YEAR ('09/25/2018'), MONTH ('09/25/2018'), DAY ('09/25/2018')

SELECT EOMONTH ('09/25/2018')
SELECT EOMONTH ('09/25/2018', -1)

SELECT DATEADD (MONTH, 1, GETDATE())
SELECT DATEDIFF (SECOND, '02/14/2017', '02/15/2017')
SELECT DATEDIFF_BIG (MILLISECOND, '01/01/2017' , '01/01/2018')

SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '+02:00')

SELECT TODATETIMEOFFSET(SYSDATETIME(), '+02:00')

DECLARE @dt AS DATETIME2 = '20170212 14:00:00.0000000';
SELECT @dt AT TIME ZONE 'Pacific Standard Time';


/* Строки */

SELECT 'Good' + ' ' + 'morning';
SELECT CONCAT('Good', ' ', 'morning');
SELECT 'It is' + NULL

SET CONCAT_NULL_YIELDS_NULL OFF
SELECT 'It is' + NULL
SET CONCAT_NULL_YIELDS_NULL ON

SELECT SUBSTRING('Some long string', 6, 4)
SELECT LEFT('Some long string', 4)
SELECT RIGHT('Some long string', 6)
SELECT CHARINDEX('string', 'Some long string')
SELECT CHARINDEX('i', 'Some long string')
SELECT PATINDEX('%o_g%', 'Some long string')

SELECT LEN('Some long string')
SELECT DATALENGTH('Some long string')
SELECT DATALENGTH(N'Some long string')

SELECT REPLACE('Ivanov & Partners', '&', 'and');
SELECT REPLICATE('Re', 10)
SELECT STUFF('This is an example', 6, 2, 'was')

SELECT UPPER('Space')
SELECT LOWER('Space')
SELECT LTRIM('  Space')
SELECT RTRIM('Space  ')
SELECT FORMAT(1759, '0000000000')

DECLARE @orderids AS VARCHAR(MAX) = N'10248,10542,10731,10765,10812';
SELECT value
FROM STRING_SPLIT(@orderids, ',');


/* @@ROWCOUNT */

CREATE TABLE #T (ID INT)
INSERT #T VALUES (1), (2)
SELECT @@ROWCOUNT AS [Rows]
DROP TABLE #T


/* Compression */

CREATE TABLE player (ID INT, info VARBINARY(MAX))

INSERT INTO player (ID, info )  
VALUES (1, COMPRESS(N'{"sport":"Tennis","age": 28,"rank":1,"points":15258, turn":17}'));  

SELECT ID, CAST(DECOMPRESS(info) AS NVARCHAR(MAX)) AS info  
FROM player;  

DROP TABLE player


/* CONTEXT_INFO */

DECLARE @mycontextinfo AS VARBINARY(128) = 
	CAST('us_english' AS VARBINARY(128));

SET CONTEXT_INFO @mycontextinfo;

SELECT CAST(CONTEXT_INFO() AS VARCHAR(128)) AS mycontextinfo;


/* Session context */

EXEC sys.sp_set_session_context
 @key = N'languagez', @value = 2, @read_only = 1; 

SELECT SESSION_CONTEXT(N'languagez') AS [language];


SELECT NEWID()
--NEWSEQUENTIALID() -- Only in a DEFAULT expression for a column of type 'uniqueidentifier' in a CREATE TABLE or ALTER TABLE statement. 

SELECT SCOPE_IDENTITY()
SELECT @@IDENTITY


/* Арифметические операции */

SELECT 3 + 2  -- 5
SELECT 3 - 2  -- 1
SELECT 3 + NULL

SELECT 3 * 2  -- 6
SELECT 3 * CAST(2 AS NUMERIC(10, 2)) -- 6.00
SELECT 3 * 2 * 1.0  -- 6.0

SELECT 3 / 2  -- 1 
SELECT 3.0 / 2  -- 1.500000
SELECT 3. / 2  -- 1.500000

SELECT 10 % 3  -- 1 


/* Агрегатные функции */

CREATE TABLE Orders (OrderID INT, Amount INT);
INSERT Orders VALUES (1, 25), (2, 14), (3, 58);

SELECT 
  SUM(Amount),
  COUNT(*),
  MIN(Amount),
  MAX(Amount),
  AVG(Amount),
  AVG(Amount * 1.0)
FROM Orders

-- Расчет медианы

DECLARE @c AS INT = (SELECT COUNT(*) FROM Orders);

SELECT AVG(1.0 * Amount) AS Median
FROM ( 
  SELECT Amount FROM Orders ORDER BY Amount
  OFFSET (@cnt - 1) / 2 ROWS FETCH NEXT 2 - @c % 2 ROWS ONLY ) AS D;

DROP TABLE Orders;


/* Search argument */

--WHERE <column> <operator> <expression>

CREATE NONCLUSTERED INDEX [Orders_OrderDate]
ON [Sales].[Orders] ([OrderDate])

SELECT orderid, orderdate 
FROM Sales.Orders
WHERE YEAR(orderdate) = 2015;

SELECT orderid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate < '20160101';


/* Determinism */
-- https://docs.microsoft.com/ru-ru/sql/relational-databases/user-defined-functions/deterministic-and-nondeterministic-functions?view=sql-server-2017

-- Детерминированные
ABS, SQRT, COALESCE, ISNULL, DATEDIFF, DAY

--Недетерминированные
GETDATE, NEWID, ROW_NUMBER, LAG, LEAD

-- Не всегда детерминированные
CAST, CONVERT, CHECKSUM, ISDATE, RAND
