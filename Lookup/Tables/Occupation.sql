﻿CREATE TABLE [Lookup].[Occupation] (
    [Id]             INT              IDENTITY (1, 1) NOT NULL,
    [Guid]           UNIQUEIDENTIFIER DEFAULT (newid()) NULL,
    [OccupationName] VARCHAR (200)    NULL,
    [IsDeleted]      BIT              DEFAULT ((0)) NULL,
    [CreatedDt]      DATETIME         DEFAULT (getdate()) NULL,
    [CreatedBy]      VARCHAR (50)     DEFAULT (suser_sname()) NULL,
    [ModifieDt]      DATETIME         NULL,
    [ModifiedBy]     VARCHAR (50)     NULL,
    [CreatedByName]  VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]   VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Guid] ASC)
);

