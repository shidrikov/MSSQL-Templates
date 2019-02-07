

/*
	This example demonstrates difference in handling phantom reads between different isolation levels
		1. Open each session script in a separate SSMS window
		2. Run refreshing script from session 1
		3. Run transaction 1. Then, after 5 seconds, run transaction 2
		4. Run transaction 1. Then, after 5 seconds, run transaction 3
		5. Run transaction 1. Then, after 5 seconds, run transaction 4
*/

--=====================================
-- Session #1
--=====================================

SELECT @@SPID

-- Refresh the example

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SampleTable')
   DROP TABLE SampleTable

CREATE TABLE [SampleTable]
(
 [Id]          [int] IDENTITY(1,1) NOT NULL,
 [Name]        [varchar](100) NULL,
 [Value]       [varchar](100) NULL,
 [DateChanged] [datetime] DEFAULT(GETDATE()) NULL,
 CONSTRAINT [PK_SampleTable] PRIMARY KEY CLUSTERED ([Id] ASC)
)

INSERT INTO SampleTable(Name, Value) 
SELECT 'Name1', 'Value1'
UNION ALL 
SELECT 'Name2', 'Value2'
UNION ALL 
SELECT 'Name3', 'Value3'


-- Transaction 1

SELECT * FROM SampleTable
BEGIN TRAN  
   INSERT INTO SampleTable(Name, Value) VALUES('Name4', 'Value4')
   --UPDATE SampleTable SET Name = Name + Name
   --UPDATE SampleTable SET Name = Name + Name WHERE Name = 'Name1'
   --UPDATE SampleTable SET Name = Name + Name WHERE ID = 2
   DELETE FROM SampleTable WHERE ID = 4
   WAITFOR DELAY '00:00:10'  
COMMIT TRAN


--=====================================
-- Session #2: READ COMMITTED
--=====================================

SELECT @@SPID

-- Transaction 2

BEGIN TRAN
   SELECT * FROM SampleTable
       WAITFOR DELAY '00:00:10'  
   SELECT * FROM SampleTable
       WAITFOR DELAY '00:00:10'  
   SELECT * FROM SampleTable
ROLLBACK

SELECT b.name, c.name, a.* 
FROM sys.dm_tran_locks a
INNER JOIN sys.databases b ON a.resource_database_id = database_id
INNER JOIN sys.objects c ON a.resource_associated_entity_id = object_id
 

--=====================================
-- Session #3: REPEATABLE READ
--=====================================

SELECT @@SPID

-- Transaction 3

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ  
BEGIN TRAN
   SELECT * FROM SampleTable
      WAITFOR DELAY '00:00:10'  
   SELECT * FROM SampleTable 
      WAITFOR DELAY '00:00:10'  
   SELECT * FROM SampleTable
COMMIT TRAN


--=====================================
-- Session #4: SERIALIZABLE
--=====================================

SELECT @@SPID

-- Transaction 4

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
   SELECT * FROM SampleTable
      WAITFOR DELAY '00:00:10'  
   SELECT * FROM SampleTable 
      WAITFOR DELAY '00:00:10'  
   SELECT * FROM SampleTable
COMMIT TRAN