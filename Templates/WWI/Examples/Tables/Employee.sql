CREATE TABLE [Examples].[Employee] (
    [EmployeeId]     INT      NOT NULL,
    [EmployeeNumber] CHAR (8) NOT NULL,
    [ManagerId]      INT      NULL,
    CONSTRAINT [PKEmployee] PRIMARY KEY CLUSTERED ([EmployeeId] ASC),
    CONSTRAINT [FKEmployee_Ref_ExamplesEmployee] FOREIGN KEY ([ManagerId]) REFERENCES [Examples].[Employee] ([EmployeeId])
);

