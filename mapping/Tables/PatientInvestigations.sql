CREATE TABLE [mapping].[PatientInvestigations] (
    [Id]             INT              IDENTITY (1, 1) NOT NULL,
    [Guid]           UNIQUEIDENTIFIER CONSTRAINT [DF__PatientInv__Guid__0C70CFB4] DEFAULT (newid()) NOT NULL,
    [AppointmentId]  INT              NULL,
    [PatientId]      INT              NOT NULL,
    [DoctorId]       INT              NOT NULL,
    [Investigations] VARCHAR (500)    NULL,
    [Status]         VARCHAR (200)    NULL,
    [IsDeleted]      BIT              CONSTRAINT [DF__PatientIn__IsDel__0D64F3ED] DEFAULT ((0)) NOT NULL,
    [CreatedDt]      DATETIME         CONSTRAINT [DF__PatientIn__Creat__0E591826] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)     CONSTRAINT [DF__PatientIn__Creat__0F4D3C5F] DEFAULT (suser_sname()) NOT NULL,
    [ModifieDt]      DATETIME         NULL,
    [ModifiedBy]     VARCHAR (50)     NULL,
    [CreatedByName]  VARCHAR (255)    CONSTRAINT [DF__PatientIn__Creat__4F87BD05] DEFAULT (suser_sname()) NULL,
    [ModifiedName]   VARCHAR (255)    CONSTRAINT [DF__PatientIn__Modif__507BE13E] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__PatientI__3214EC0700B7DE7D] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__PatientI__A2B5777D9CB80764] UNIQUE NONCLUSTERED ([Guid] ASC)
);

