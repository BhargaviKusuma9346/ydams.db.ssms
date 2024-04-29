CREATE TABLE [mapping].[CoordinatorBranches] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__Coordinato__Guid__0CE5D100] DEFAULT (newid()) NOT NULL,
    [CoordinatorId] INT              NOT NULL,
    [BranchId]      INT              NULL,
    [IsDefault]     BIT              CONSTRAINT [DF_CoordinatorBranches_IsDefault] DEFAULT ((0)) NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__Coordinat__IsDel__0DD9F539] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__Coordinat__Creat__0ECE1972] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__Coordinat__Creat__0FC23DAB] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedDt]    DATETIME         NULL,
    [CreatedByName] VARCHAR (255)    CONSTRAINT [DF__Coordinat__Creat__10B661E4] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]  VARCHAR (255)    CONSTRAINT [DF__Coordinat__Modif__11AA861D] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK__Coordina__3214EC07AE6A74DB] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Coordina__A2B5777DE832987E] UNIQUE NONCLUSTERED ([Guid] ASC)
);

