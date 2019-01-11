

/* PRIMARY KEY */

CREATE TABLE [dbo].[Cities](
	[CityID] INT NOT NULL PRIMARY KEY,
	[CityName] NVARCHAR(50) NOT NULL
);

GO

CREATE TABLE [dbo].[Cities](
	[CityID] INT NOT NULL,
	[CityName] NVARCHAR(50) NOT NULL, 
CONSTRAINT [PK_Cities] PRIMARY KEY ([CityID])
);

GO

CREATE TABLE [dbo].[Cities](
	[CityID] INT NOT NULL,
	[CityName] NVARCHAR(50) NOT NULL, 
CONSTRAINT [PK_Cities] PRIMARY KEY ([CityID], [CityName])
);

GO

/* DEFAULT */

CREATE TABLE [Sales].[Orders](
	[OrderID] [int] NOT NULL PRIMARY KEY,
	[LastEditedWhen] [datetime2](7) NOT NULL DEFAULT (sysdatetime())
);

GO

CREATE TABLE [Sales].[Orders](
	[OrderID] [int] NOT NULL PRIMARY KEY,
	[LastEditedWhen] [datetime2](7) NOT NULL
);

GO

ALTER TABLE [Sales].[Orders] 
ADD CONSTRAINT [DF_Sales_Orders_LastEditedWhen] 
DEFAULT (sysdatetime()) FOR [LastEditedWhen]

GO

CREATE SEQUENCE [Sequences].[CityID] AS INT 
  START WITH 38187
  INCREMENT BY 1

GO

ALTER TABLE [Application].[Cities] 
ADD CONSTRAINT [DF_Application_Cities_CityID] 
DEFAULT (NEXT VALUE FOR [Sequences].[CityID]) FOR [CityID]

GO

CREATE TABLE Examples.Gadget
(
  GadgetId INT NOT NULL CONSTRAINT PKGadget PRIMARY KEY,
  GadgetNumber CHAR(8) NOT NULL CONSTRAINT AKGadget UNIQUE,
  GadgetType VARCHAR(10) NOT NULL
);

GO

ALTER TABLE Examples.Widget 
ADD RowLastModifiedTime DATETIME2 NULL 
DEFAULT (sysdatetime()) WITH VALUES

GO

INSERT INTO [Sales].[Orders] ([OrderID])
VALUES (1),(2); 

INSERT INTO [Sales].[Orders] ([OrderID], [LastEditedWhen])
VALUES (3, DEFAULT), (4, DEFAULT);

UPDATE Examples.Widget 
SET RowLastModifiedTime = DEFAULT;

GO


/* UNIQUE */

ALTER TABLE Examples.Gadget
ADD CONSTRAINT AKGadget UNIQUE (GadgetCode);

GO


/* CHECK */

CREATE TABLE Examples.GroceryItem
(
	ItemCost SMALLMONEY NULL,
	CONSTRAINT CHKGroceryItem_ItemCostRange 
		CHECK (ItemCost > 0 AND ItemCost < 1000)
);

GO

CREATE TABLE Examples.Message
(
	MessageTag CHAR(5) NOT NULL,
	Comment NVARCHAR(MAX) NULL
);

ALTER TABLE Examples.Message
	ADD CONSTRAINT CHKMessage_MessageTagFormat
	CHECK (MessageTag LIKE '[A-Z]-[0-9][0-9][0-9]');

ALTER TABLE Examples.Message
	ADD CONSTRAINT CHKMessage_CommentNotEmpty
	CHECK (LEN(Comment) > 0);

GO

CREATE TABLE Examples.Customer
(
  ForcedDisabledFlag BIT NOT NULL,
  ForcedEnabledFlag  BIT NOT NULL,
  CONSTRAINT CHKCustomer_ForcedStatusFlagCheck
    CHECK (NOT (ForcedDisabledFlag = 1 AND ForcedEnabledFlag = 1))
);

GO


/* FOREIGN KEY */

ALTER TABLE [Application].[Cities] 
ADD CONSTRAINT [FK_Cities_StateProvinces] 
FOREIGN KEY ([StateProvinceID])
REFERENCES [Application].[StateProvinces] ([StateProvinceID])

GO

ALTER TABLE [Application].[Cities] WITH CHECK
ADD CONSTRAINT [FK_Cities_StateProvinces] FOREIGN KEY ([StateProvinceID])
REFERENCES [Application].[StateProvinces] ([StateProvinceID])

ALTER TABLE [Application].[Cities] WITH NOCHECK
ADD CONSTRAINT [FK_Cities_StateProvinces] FOREIGN KEY ([StateProvinceID])
REFERENCES [Application].[StateProvinces] ([StateProvinceID])

ALTER TABLE [Application].[Cities] WITH CHECK CHECK CONSTRAINT [FK_Cities_StateProvinces] 

ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [FK_OrderLines_People] 
FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
ON DELETE NO ACTION 
ON UPDATE NO ACTION

ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [FK_OrderLines_People] 
FOREIGN KEY([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
ON DELETE CASCADE
ON UPDATE CASCADE 

ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [FK_OrderLines_People] 
FOREIGN KEY([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
ON DELETE SET NULL
ON UPDATE SET NULL

ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [FK_OrderLines_People] 
FOREIGN KEY([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
ON DELETE SET DEFAULT
ON UPDATE SET DEFAULT

GO

CREATE TABLE Examples.Employee
(
  EmployeeId INT NOT NULL CONSTRAINT PK_Employee PRIMARY KEY,
  EmployeeNumber CHAR(8) NOT NULL,
  ManagerId INT NULL CONSTRAINT FK_Employee_Employee 
    REFERENCES Examples.Employee (EmployeeId)
);

GO

CREATE TABLE Examples.Color
(
  ColorId INT NOT NULL CONSTRAINT PKColor PRIMARY KEY,
  ColorName VARCHAR(30) NOT NULL CONSTRAINT AKColor UNIQUE
);

CREATE TABLE Examples.Product
(
  ProductId INT NOT NULL CONSTRAINT PKProduct PRIMARY KEY,
  ColorName VARCHAR(30) NOT NULL 
    CONSTRAINT FKProduct_Ref_ExamplesColor REFERENCES Examples.Color (ColorName)
); 
