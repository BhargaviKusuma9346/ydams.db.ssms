﻿CREATE TABLE [mapping].[PatientDiagnosis] (
    [Id]             INT              IDENTITY (1, 1) NOT NULL,
    [Guid]           UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [AppointmentId]  INT              NOT NULL,
    [Diagnosis]      VARCHAR (500)    NULL,
    [DiagnosisType]  VARCHAR (500)    NULL,
    [DiagnosisGroup] VARCHAR (500)    NULL,
    [DiseaseType]    VARCHAR (500)    NULL,
    [Comments]       VARCHAR (500)    NULL,
    [IsDeleted]      BIT              DEFAULT ((0)) NOT NULL,
    [CreatedBy]      VARCHAR (50)     DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]      DATETIME         DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]     VARCHAR (50)     NULL,
    [ModifiedDt]     DATETIME         NULL,
    [CreatedByName]  VARCHAR (255)    DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]   VARCHAR (255)    DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Guid] ASC)
);

