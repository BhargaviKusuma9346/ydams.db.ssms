﻿CREATE TABLE [Doctor].[Doctor] (
    [Id]                       INT              IDENTITY (1, 1) NOT NULL,
    [Guid]                     UNIQUEIDENTIFIER CONSTRAINT [DF__Doctor__Guid__1F98B2C1] DEFAULT (newid()) NULL,
    [UserId]                   INT              NULL,
    [FirstName]                VARCHAR (200)    NULL,
    [LastName]                 VARCHAR (200)    NULL,
    [Gender]                   VARCHAR (200)    NULL,
    [DateOfBirth]              DATETIME         NULL,
    [ProfileURL]               VARCHAR (225)    NULL,
    [SignUrl]                  VARCHAR (225)    NULL,
    [QualificationName]        VARCHAR (MAX)    NULL,
    [SpecializationName]       VARCHAR (MAX)    NULL,
    [Languages]                VARCHAR (MAX)    NULL,
    [ContactNumber]            VARCHAR (200)    NULL,
    [EmailId]                  NVARCHAR (256)   NULL,
    [City]                     VARCHAR (200)    NULL,
    [State]                    VARCHAR (200)    NULL,
    [Pincode]                  INT              NULL,
    [Address]                  VARCHAR (200)    NULL,
    [RegistrationNumber]       VARCHAR (200)    NULL,
    [StateOfRegistration]      VARCHAR (200)    NULL,
    [YearOfRegistration]       VARCHAR (200)    NULL,
    [RegistrationDate]         DATETIME         NULL,
    [RegistrationValidity]     DATETIME         NULL,
    [AlternateNumber]          VARCHAR (200)    NULL,
    [PracticeStartDate]        DATETIME         NULL,
    [ConsultationFee]          VARCHAR (50)     NULL,
    [IsMonday]                 BIT              CONSTRAINT [DF_Doctor_IsMonday] DEFAULT ((0)) NULL,
    [IsTuesday]                BIT              CONSTRAINT [DF_Doctor_IsTuesday] DEFAULT ((0)) NULL,
    [IsWednesday]              BIT              CONSTRAINT [DF_Doctor_IsWednesday] DEFAULT ((0)) NULL,
    [IsThursday]               BIT              CONSTRAINT [DF_Doctor_IsThursday] DEFAULT ((0)) NULL,
    [IsFriday]                 BIT              CONSTRAINT [DF_Doctor_IsFriday] DEFAULT ((0)) NULL,
    [IsSaturday]               BIT              CONSTRAINT [DF_Doctor_IsSaturday] DEFAULT ((0)) NULL,
    [IsSunday]                 BIT              CONSTRAINT [DF_Doctor_IsSunday] DEFAULT ((0)) NULL,
    [AppointmentDurationInMin] INT              CONSTRAINT [DF_Doctor_AppointmentDurationInMin] DEFAULT ((0)) NULL,
    [IsAvailable]              BIT              CONSTRAINT [DF_Doctor_IsAvailable] DEFAULT ((1)) NULL,
    [IsDeleted]                BIT              CONSTRAINT [DF__Doctor__IsDelete__208CD6FA] DEFAULT ((0)) NULL,
    [CreatedDt]                DATETIME         CONSTRAINT [DF__Doctor__CreatedD__2180FB33] DEFAULT (getdate()) NULL,
    [CreatedBy]                VARCHAR (50)     CONSTRAINT [DF__Doctor__CreatedB__22751F6C] DEFAULT (suser_sname()) NULL,
    [CreatedById]              INT              NULL,
    [ModifieDt]                DATETIME         NULL,
    [ModifiedBy]               VARCHAR (50)     NULL,
    [ModifiedById]             INT              NULL,
    [CreatedByName]            VARCHAR (255)    CONSTRAINT [DF__Doctor__CreatedB__666B225D] DEFAULT (suser_sname()) NULL,
    [ModifiedName]             VARCHAR (255)    CONSTRAINT [DF__Doctor__Modified__675F4696] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Doctor__3214EC070AB0E0A6] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Doctor__A2B5777D7D6D3129] UNIQUE NONCLUSTERED ([Guid] ASC)
);
GO

