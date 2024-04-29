CREATE TABLE [Lookup].[Vital] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER DEFAULT (newid()) NULL,
    [VitalName]     VARCHAR (200)    NULL,
    [VitalUnit]     VARCHAR (200)    NULL,
    [Description]   VARCHAR (MAX)    NULL,
    [IsDeleted]     BIT              DEFAULT ((0)) NULL,
    [CreatedDt]     DATETIME         DEFAULT (getdate()) NULL,
    [CreatedBy]     VARCHAR (50)     DEFAULT (suser_sname()) NULL,
    [CreatedById]   INT              NULL,
    [ModifiedDt]    DATETIME         NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedById]  INT              NULL,
    [CreatedByName] VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Guid] ASC)
);

