CREATE TABLE [mapping].[PatientPhysicalExaminations] (
    [Id]                      INT              IDENTITY (1, 1) NOT NULL,
    [Guid]                    UNIQUEIDENTIFIER CONSTRAINT [DF__PatientPhy__Guid__26509D48] DEFAULT (newid()) NOT NULL,
    [AppointmentId]           INT              NULL,
    [PatientId]               INT              NOT NULL,
    [PhysicalExaminationName] VARCHAR (500)    NULL,
    [IsDeleted]               BIT              CONSTRAINT [DF_PatientPhysicalExaminations_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]               VARCHAR (50)     CONSTRAINT [DF__PatientPh__Creat__2744C181] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]               DATETIME         CONSTRAINT [DF__PatientPh__Creat__2838E5BA] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]              VARCHAR (50)     NULL,
    [ModifiedDt]              DATETIME         NULL,
    [CreatedByName]           VARCHAR (255)    CONSTRAINT [DF__PatientPh__Creat__292D09F3] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]            VARCHAR (255)    CONSTRAINT [DF__PatientPh__Modif__2A212E2C] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK__PatientP__3214EC07A022273D] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__PatientP__A2B5777D44427B3D] UNIQUE NONCLUSTERED ([Guid] ASC)
);

