CREATE TABLE [dbo].[EmailTemplates] (
    [Id]                   INT              IDENTITY (1, 1) NOT NULL,
    [Guid]                 UNIQUEIDENTIFIER CONSTRAINT [DF__EmailTempl__Guid__2E5BD364] DEFAULT (newid()) NOT NULL,
    [Name]                 VARCHAR (500)    NOT NULL,
    [TemplateHtml]         VARCHAR (MAX)    NOT NULL,
    [ReplaceableVariables] VARCHAR (MAX)    NULL,
    [IsDeleted]            BIT              CONSTRAINT [DF__EmailTemp__IsDel__2F4FF79D] DEFAULT ((0)) NOT NULL,
    [CreatedDt]            DATETIME         CONSTRAINT [DF__EmailTemp__Creat__30441BD6] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            VARCHAR (50)     CONSTRAINT [DF__EmailTemp__Creat__3138400F] DEFAULT (suser_sname()) NOT NULL,
    [ModifieDt]            DATETIME         NULL,
    [ModifiedBy]           VARCHAR (50)     NULL,
    [CreatedByName]        VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]         VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__EmailTem__3214EC07CDB70B4E] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__EmailTem__A2B5777D70A60585] UNIQUE NONCLUSTERED ([Guid] ASC)
);

