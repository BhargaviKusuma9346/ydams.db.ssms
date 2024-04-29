CREATE TABLE [Lookup].[Investigations] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [Guid]            UNIQUEIDENTIFIER CONSTRAINT [DF_Investigations_Guid] DEFAULT (newid()) NULL,
    [TestCode]        VARCHAR (100)    NULL,
    [TestName]        VARCHAR (200)    NULL,
    [TestCategory]    VARCHAR (200)    NULL,
    [SpecimenType]    VARCHAR (200)    NULL,
    [SpecimenVolume]  VARCHAR (200)    NULL,
    [Instructions]    VARCHAR (500)    NULL,
    [CreatedByUserId] INT              NULL,
    [IsDeleted]       BIT              CONSTRAINT [DF__Investiga__IsDel__6E2152BE] DEFAULT ((0)) NOT NULL,
    [CreatedDt]       DATETIME         CONSTRAINT [DF__Investiga__Creat__6F1576F7] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (50)     CONSTRAINT [DF__Investiga__Creat__70099B30] DEFAULT (suser_sname()) NOT NULL,
    [CreatedByName]   VARCHAR (500)    CONSTRAINT [DF_Investigations_CreatedByName] DEFAULT (suser_sname()) NULL,
    [ModifiedDt]      DATETIME         NULL,
    [ModifiedBy]      VARCHAR (50)     NULL,
    [ModifiedName]    VARCHAR (500)    CONSTRAINT [DF_Investigations_ModifiedName] DEFAULT (suser_sname()) NULL
);
GO

