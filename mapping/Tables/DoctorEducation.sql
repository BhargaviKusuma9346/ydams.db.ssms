CREATE TABLE [mapping].[DoctorEducation] (
    [Id]             INT              IDENTITY (1, 1) NOT NULL,
    [Guid]           UNIQUEIDENTIFIER CONSTRAINT [DF__DoctorQual__Guid__39836D4D] DEFAULT (newid()) NOT NULL,
    [DoctorId]       INT              NOT NULL,
    [Qualification]  VARCHAR (500)    NULL,
    [Specialization] VARCHAR (500)    NULL,
    [IsDeleted]      BIT              CONSTRAINT [DF__DoctorQua__IsDel__3A779186] DEFAULT ((0)) NOT NULL,
    [CreatedBy]      VARCHAR (50)     CONSTRAINT [DF__DoctorQua__Creat__3B6BB5BF] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]      DATETIME         CONSTRAINT [DF__DoctorQua__Creat__3C5FD9F8] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]     VARCHAR (50)     NULL,
    [ModifiedDt]     DATETIME         NULL,
    [CreatedByName]  VARCHAR (255)    CONSTRAINT [DF__DoctorQua__Creat__3D53FE31] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]   VARCHAR (255)    CONSTRAINT [DF__DoctorQua__Modif__3E48226A] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK__DoctorQu__3214EC0716F4C61B] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__DoctorQu__A2B5777DD2CEAA8C] UNIQUE NONCLUSTERED ([Guid] ASC)
);

