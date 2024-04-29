CREATE TABLE [Lookup].[Symptom] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__Symptom__Guid__0B91BA14] DEFAULT (newid()) NULL,
    [SymptomCode]   VARCHAR (50)     NULL,
    [SymptomName]   VARCHAR (50)     NULL,
    [SymptomType]   VARCHAR (200)    NULL,
    [Description]   VARCHAR (500)    NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__Symptom__IsDelet__0C85DE4D] DEFAULT ((0)) NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__Symptom__Created__0D7A0286] DEFAULT (getdate()) NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__Symptom__Created__0E6E26BF] DEFAULT (suser_sname()) NULL,
    [CreatedById]   INT              NULL,
    [ModifieDt]     DATETIME         NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedById]  INT              NULL,
    [CreatedByName] VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Symptom__3214EC075D739BA2] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Symptom__A2B5777DA1F2763B] UNIQUE NONCLUSTERED ([Guid] ASC)
);

