CREATE TABLE [mapping].[PatientVitals] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [Guid]            UNIQUEIDENTIFIER CONSTRAINT [DF__PatientVit__Guid__278EDA44] DEFAULT (newid()) NOT NULL,
    [AppointmentId]   INT              NULL,
    [PatientId]       INT              NOT NULL,
    [VitalId]         INT              NOT NULL,
    [VitalName]       VARCHAR (100)    NULL,
    [VitalValue]      VARCHAR (100)    NULL,
    [LastUpdatedTime] DATETIME         CONSTRAINT [DF__PatientVi__LastU__2882FE7D] DEFAULT (getdate()) NOT NULL,
    [IsDeleted]       BIT              CONSTRAINT [DF__PatientVi__IsDel__297722B6] DEFAULT ((0)) NOT NULL,
    [CreatedDt]       DATETIME         CONSTRAINT [DF__PatientVi__Creat__2A6B46EF] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (50)     CONSTRAINT [DF__PatientVi__Creat__2B5F6B28] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedDt]      DATETIME         NULL,
    [ModifiedBy]      VARCHAR (50)     NULL,
    [CreatedByName]   VARCHAR (255)    CONSTRAINT [DF__PatientVi__Creat__6E0C4425] DEFAULT (suser_sname()) NULL,
    [ModifiedName]    VARCHAR (255)    CONSTRAINT [DF__PatientVi__Modif__6F00685E] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__PatientV__3214EC0721EDC40A] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__PatientV__A2B5777DBB260F34] UNIQUE NONCLUSTERED ([Guid] ASC)
);

