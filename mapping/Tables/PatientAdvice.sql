CREATE TABLE [mapping].[PatientAdvice] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__PatientAdv__Guid__6E96540A] DEFAULT (newid()) NOT NULL,
    [AppointmentId] INT              NOT NULL,
    [Advice]        VARCHAR (MAX)    NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__PatientAd__IsDel__6F8A7843] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__PatientAd__Creat__707E9C7C] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__PatientAd__Creat__7172C0B5] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedDt]    DATETIME         NULL,
    [CreatedByName] VARCHAR (255)    CONSTRAINT [DF__PatientAd__Creat__7266E4EE] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]  VARCHAR (255)    CONSTRAINT [DF__PatientAd__Modif__735B0927] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK__PatientA__3214EC0785C0476B] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__PatientA__A2B5777DB6443174] UNIQUE NONCLUSTERED ([Guid] ASC)
);
GO

