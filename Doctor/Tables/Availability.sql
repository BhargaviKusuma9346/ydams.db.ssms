CREATE TABLE [Doctor].[Availability] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__Availabili__Guid__3A4CA8FD] DEFAULT (newid()) NULL,
    [DoctorId]      INT              NULL,
    [WeekDayId]     INT              NULL,
    [SlotName]      VARCHAR (500)    NULL,
    [StartTime]     TIME (7)         NULL,
    [EndTime]       TIME (7)         NULL,
    [NumberOfSlots] INT              NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__Availabil__IsDel__3B40CD36] DEFAULT ((0)) NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__Availabil__Creat__3C34F16F] DEFAULT (getdate()) NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__Availabil__Creat__3D2915A8] DEFAULT (suser_sname()) NULL,
    [CreatedById]   INT              NULL,
    [ModifiedDt]    DATETIME         NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedById]  INT              NULL,
    [CreatedByName] VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Availabi__3214EC07602163E9] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Availabi__A2B5777DEABADADE] UNIQUE NONCLUSTERED ([Guid] ASC)
);

