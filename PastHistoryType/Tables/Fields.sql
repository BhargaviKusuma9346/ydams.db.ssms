﻿CREATE TABLE [PastHistoryType].[Fields] (
    [Id]                INT              IDENTITY (1, 1) NOT NULL,
    [Guid]              UNIQUEIDENTIFIER DEFAULT (newid()) NULL,
    [PastHistoryTypeId] INT              NULL,
    [FieldName]         VARCHAR (200)    NULL,
    [FieldType]         VARCHAR (200)    NULL,
    [RowOrder]          INT              NULL,
    [Units]             VARCHAR (200)    NULL,
    [Option1]           VARCHAR (200)    NULL,
    [Option2]           VARCHAR (200)    NULL,
    [Option3]           VARCHAR (200)    NULL,
    [Option4]           VARCHAR (200)    NULL,
    [Option5]           VARCHAR (200)    NULL,
    [Option6]           VARCHAR (200)    NULL,
    [Option7]           VARCHAR (200)    NULL,
    [Option8]           VARCHAR (200)    NULL,
    [Option9]           VARCHAR (200)    NULL,
    [Option10]          VARCHAR (200)    NULL,
    [SqlQuery]          VARCHAR (MAX)    NULL,
    [IsDeleted]         BIT              DEFAULT ((0)) NULL,
    [CreatedDt]         DATETIME         DEFAULT (getdate()) NULL,
    [CreatedBy]         VARCHAR (50)     DEFAULT (suser_sname()) NULL,
    [CreatedById]       INT              NULL,
    [ModifieDt]         DATETIME         NULL,
    [ModifiedBy]        VARCHAR (50)     NULL,
    [ModifiedById]      INT              NULL,
    [CreatedByName]     VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]      VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Guid] ASC)
);

