CREATE TABLE [mapping].[PatientPastHistory] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__PatientPas__Guid__1308BEAA] DEFAULT (newid()) NOT NULL,
    [AppointmentId] INT              NULL,
    [PatientId]     INT              NOT NULL,
    [QuestionId]    INT              NOT NULL,
    [Answer]        VARCHAR (500)    NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__PatientPa__IsDel__13FCE2E3] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__PatientPa__Creat__14F1071C] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__PatientPa__Creat__15E52B55] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedDt]    DATETIME         NULL,
    [CreatedByName] VARCHAR (255)    CONSTRAINT [DF__PatientPa__Creat__16D94F8E] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]  VARCHAR (255)    CONSTRAINT [DF__PatientPa__Modif__17CD73C7] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK__PatientP__3214EC0727127D94] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__PatientP__A2B5777D35953DE1] UNIQUE NONCLUSTERED ([Guid] ASC)
);

