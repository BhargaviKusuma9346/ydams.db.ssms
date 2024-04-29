CREATE TABLE [Coordinator].[Coordinator] (
    [Id]                   INT              IDENTITY (1, 1) NOT NULL,
    [Guid]                 UNIQUEIDENTIFIER CONSTRAINT [DF__Coordinato__Guid__10E07F16] DEFAULT (newid()) NOT NULL,
    [UserId]               INT              NULL,
    [FirstName]            VARCHAR (200)    NULL,
    [LastName]             VARCHAR (200)    NULL,
    [ContactNumber]        VARCHAR (200)    NULL,
    [AlternateNumber]      VARCHAR (200)    NULL,
    [EmailId]              NVARCHAR (256)   NULL,
    [Gender]               VARCHAR (200)    NULL,
    [DateOfBirth]          DATETIME         NULL,
    [Branches]             VARCHAR (MAX)    NULL,
    [WorkDays]             INT              NULL,
    [WorkHours]            INT              NULL,
    [PreferredContactType] VARCHAR (MAX)    NULL,
    [Languages]            VARCHAR (MAX)    NULL,
    [CoordinatorPhotoURL]  VARCHAR (200)    NULL,
    [IsDeleted]            BIT              CONSTRAINT [DF__Coordinat__IsDel__11D4A34F] DEFAULT ((0)) NOT NULL,
    [CreatedBy]            VARCHAR (50)     CONSTRAINT [DF__Coordinat__Creat__12C8C788] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]            DATETIME         CONSTRAINT [DF__Coordinat__Creat__13BCEBC1] DEFAULT (getdate()) NOT NULL,
    [CreatedByName]        VARCHAR (500)    CONSTRAINT [DF_Coordinator_CreatedByName] DEFAULT (suser_sname()) NULL,
    [ModifiedBy]           VARCHAR (50)     NULL,
    [ModifiedDt]           DATETIME         NULL,
    [ModifiedName]         VARCHAR (500)    CONSTRAINT [DF_Coordinator_ModifiedName] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Coordina__3214EC070EEB4CA4] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Coordina__A2B5777D5BAE20FD] UNIQUE NONCLUSTERED ([Guid] ASC)
);
GO

