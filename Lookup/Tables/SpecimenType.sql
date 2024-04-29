CREATE TABLE [Lookup].[SpecimenType] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [SpecimenType]  VARCHAR (200)    NOT NULL,
    [IsDeleted]     BIT              DEFAULT ((0)) NOT NULL,
    [CreatedBy]     VARCHAR (50)     DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]     DATETIME         DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedDt]    DATETIME         NULL,
    [CreatedByName] VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Guid] ASC)
);

