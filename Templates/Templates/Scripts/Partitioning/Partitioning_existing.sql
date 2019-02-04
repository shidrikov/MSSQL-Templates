
-- Optional: Create a filegroup and explicity create a set of files
ALTER DATABASE [WideWorldImportersDW]
ADD FILEGROUP [Sale];
GO

ALTER DATABASE [WideWorldImportersDW]
ADD FILE (NAME = WideWorldImportersDW_Sale2013, FILENAME = 'E:\DB\WWI\WideWorldImportersDW_Sale2013.ndf', SIZE = 5MB, MAXSIZE = 1000MB, FILEGROWTH = 5MB)
TO FILEGROUP [Sale];
GO
ALTER DATABASE [WideWorldImportersDW]
ADD FILE (NAME = WideWorldImportersDW_Sale2014, FILENAME = 'E:\DB\WWI\WideWorldImportersDW_Sale2014.ndf', SIZE = 5MB, MAXSIZE = 1000MB, FILEGROWTH = 5MB)
TO FILEGROUP [Sale];
GO
ALTER DATABASE [WideWorldImportersDW]
ADD FILE (NAME = WideWorldImportersDW_Sale2015, FILENAME = 'E:\DB\WWI\WideWorldImportersDW_Sale2015.ndf', SIZE = 5MB, MAXSIZE = 1000MB, FILEGROWTH = 5MB)
TO FILEGROUP [Sale];
GO
ALTER DATABASE [WideWorldImportersDW]
ADD FILE (NAME = WideWorldImportersDW_Sale2016, FILENAME = 'E:\DB\WWI\WideWorldImportersDW_Sale2016.ndf', SIZE = 5MB, MAXSIZE = 1000MB, FILEGROWTH = 5MB)
TO FILEGROUP [Sale];
GO 

-- Create partition function
CREATE PARTITION FUNCTION PF_Year (date)
AS RANGE RIGHT FOR VALUES ('20130101', '20140101', '20150101')
GO

-- Create partition scheme
CREATE PARTITION SCHEME PS_Year
AS PARTITION PF_Year ALL TO ([Sale])
GO

-- If index is a primary key, it is not allowed to drop it via DROP INDEX, use DROP CONSTRAINT instead
ALTER TABLE [Fact].[Sale_Partitioned] DROP CONSTRAINT [PK_Fact_Sale_Partitioned]
GO

-- Create new index on PS_Year partition scheme
CREATE CLUSTERED INDEX PK_Fact_Sale_Partitioned 
ON Fact.Sale_Partitioned 
(
	[Sale Key] ASC, 
	[Invoice Date Key] ASC
) ON PS_Year ([Invoice Date Key])
GO