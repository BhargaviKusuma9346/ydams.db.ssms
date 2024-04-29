CREATE TABLE [mapping].[CoordinatorLanguages] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__Coordinato__Guid__1E3A7A34] DEFAULT (newid()) NOT NULL,
    [CoordinatorId] INT              NOT NULL,
    [Languages]     VARCHAR (MAX)    NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__Coordinat__IsDel__1F2E9E6D] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__Coordinat__Creat__2022C2A6] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__Coordinat__Creat__2116E6DF] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedDt]    DATETIME         NULL,
    [CreatedByName] VARCHAR (255)    CONSTRAINT [DF__Coordinat__Creat__7F36D027] DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    CONSTRAINT [DF__Coordinat__Modif__002AF460] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Coordina__3214EC074D953F7C] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Coordina__A2B5777DBED296EE] UNIQUE NONCLUSTERED ([Guid] ASC)
);
GO

