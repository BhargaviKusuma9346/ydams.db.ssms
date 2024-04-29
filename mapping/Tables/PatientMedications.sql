CREATE TABLE [mapping].[PatientMedications] (
    [Id]             INT              IDENTITY (1, 1) NOT NULL,
    [Guid]           UNIQUEIDENTIFIER CONSTRAINT [DF__PatientMed__Guid__131DCD43] DEFAULT (newid()) NOT NULL,
    [AppointmentId]  INT              NULL,
    [PatientId]      INT              NOT NULL,
    [DoctorId]       INT              NOT NULL,
    [MedicationName] VARCHAR (MAX)    NOT NULL,
    [NoOfDays]       VARCHAR (500)    NULL,
    [Strength]       VARCHAR (500)    NULL,
    [StartDate]      DATETIME         NULL,
    [EndDate]        DATETIME         NULL,
    [WhenToTake]     VARCHAR (500)    NULL,
    [Frequency]      VARCHAR (500)    NULL,
    [Notes]          VARCHAR (1000)   NULL,
    [IsDeleted]      BIT              CONSTRAINT [DF__PatientMe__IsDel__1411F17C] DEFAULT ((0)) NOT NULL,
    [CreatedDt]      DATETIME         CONSTRAINT [DF__PatientMe__Creat__150615B5] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)     CONSTRAINT [DF__PatientMe__Creat__15FA39EE] DEFAULT (suser_sname()) NOT NULL,
    [ModifieDt]      DATETIME         NULL,
    [ModifiedBy]     VARCHAR (50)     NULL,
    [CreatedByName]  VARCHAR (255)    CONSTRAINT [DF__PatientMe__Creat__5911273F] DEFAULT (suser_sname()) NULL,
    [ModifiedName]   VARCHAR (255)    CONSTRAINT [DF__PatientMe__Modif__5A054B78] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__PatientM__3214EC0726F98EC6] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__PatientM__A2B5777D617CB801] UNIQUE NONCLUSTERED ([Guid] ASC)
);
GO

