CREATE TABLE [Lookup].[Medications] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [Guid]            UNIQUEIDENTIFIER CONSTRAINT [DF_Medications_Guid] DEFAULT (newid()) NULL,
    [MedicationCode]  VARCHAR (100)    NULL,
    [MedicationName]  VARCHAR (200)    NULL,
    [MedicationClass] VARCHAR (200)    NULL,
    [Dosage]          VARCHAR (200)    NULL,
    [Type]            VARCHAR (200)    NULL,
    [Manufacturer]    VARCHAR (500)    NULL,
    [Usage]           VARCHAR (500)    NULL,
    [IsDeleted]       BIT              CONSTRAINT [DF__Medicatio__IsDel__71F1E3A2] DEFAULT ((0)) NOT NULL,
    [CreatedByUserId] INT              NULL,
    [CreatedDt]       DATETIME         CONSTRAINT [DF__Medicatio__Creat__72E607DB] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (50)     CONSTRAINT [DF__Medicatio__Creat__73DA2C14] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedDt]      DATETIME         NULL,
    [ModifiedBy]      VARCHAR (50)     NULL,
    [CreatedByName]   VARCHAR (255)    CONSTRAINT [DF__Medicatio__Creat__51700577] DEFAULT (suser_sname()) NULL,
    [ModifiedName]    VARCHAR (255)    CONSTRAINT [DF__Medicatio__Modif__526429B0] DEFAULT (suser_sname()) NULL
);
GO

