CREATE TABLE [mapping].[PatientAttachments] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [Guid]            UNIQUEIDENTIFIER CONSTRAINT [DF__PatientAtt__Guid__2FDA0782] DEFAULT (newid()) NOT NULL,
    [AppointmentId]   INT              NULL,
    [PatientId]       INT              NOT NULL,
    [AttachmentTitle] VARCHAR (500)    NULL,
    [AttachmentUrl]   VARCHAR (500)    NULL,
    [IsDeleted]       BIT              CONSTRAINT [DF__PatientAt__IsDel__30CE2BBB] DEFAULT ((0)) NOT NULL,
    [CreatedBy]       VARCHAR (50)     CONSTRAINT [DF__PatientAt__Creat__31C24FF4] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]       DATETIME         CONSTRAINT [DF__PatientAt__Creat__32B6742D] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]      VARCHAR (50)     NULL,
    [ModifiedDt]      DATETIME         NULL,
    [CreatedByName]   VARCHAR (255)    CONSTRAINT [DF__PatientAt__Creat__33AA9866] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]    VARCHAR (255)    CONSTRAINT [DF__PatientAt__Modif__349EBC9F] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK__PatientA__3214EC07D004431F] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__PatientA__A2B5777DF3CC9AA2] UNIQUE NONCLUSTERED ([Guid] ASC)
);

