CREATE TABLE [mapping].[CoordinatorPreferredContactType] (
    [Id]                   INT              IDENTITY (1, 1) NOT NULL,
    [Guid]                 UNIQUEIDENTIFIER CONSTRAINT [DF__Coordinato__Guid__24E777C3] DEFAULT (newid()) NOT NULL,
    [CoordinatorId]        INT              NOT NULL,
    [PreferredContactType] VARCHAR (MAX)    NULL,
    [IsDeleted]            BIT              CONSTRAINT [DF__Coordinat__IsDel__25DB9BFC] DEFAULT ((0)) NOT NULL,
    [CreatedBy]            VARCHAR (50)     CONSTRAINT [DF__Coordinat__Creat__26CFC035] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]            DATETIME         CONSTRAINT [DF__Coordinat__Creat__27C3E46E] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           VARCHAR (50)     NULL,
    [ModifiedDt]           DATETIME         NULL,
    [CreatedByName]        VARCHAR (255)    CONSTRAINT [DF__Coordinat__Creat__06D7F1EF] DEFAULT (suser_sname()) NULL,
    [ModifiedName]         VARCHAR (255)    CONSTRAINT [DF__Coordinat__Modif__07CC1628] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Coordina__3214EC07DC6C2EB0] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Coordina__A2B5777D4AA6583A] UNIQUE NONCLUSTERED ([Guid] ASC)
);
GO

