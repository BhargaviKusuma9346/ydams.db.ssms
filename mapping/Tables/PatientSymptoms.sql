CREATE TABLE [mapping].[PatientSymptoms] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__PatientSym__Guid__40257DE4] DEFAULT (newid()) NOT NULL,
    [AppointmentId] INT              NULL,
    [PatientId]     INT              NOT NULL,
    [Symptoms]      VARCHAR (500)    NULL,
    [SeverityLevel] VARCHAR (500)    NULL,
    [Description]   VARCHAR (500)    NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__PatientSy__IsDel__4119A21D] DEFAULT ((0)) NOT NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__PatientSy__Creat__420DC656] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__PatientSy__Creat__4301EA8F] DEFAULT (suser_sname()) NOT NULL,
    [ModifieDt]     DATETIME         NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [CreatedByName] VARCHAR (255)    CONSTRAINT [DF__PatientSy__Creat__7B663F43] DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    CONSTRAINT [DF__PatientSy__Modif__7C5A637C] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__PatientS__3214EC07142F1E83] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__PatientS__A2B5777D440BD429] UNIQUE NONCLUSTERED ([Guid] ASC)
);

