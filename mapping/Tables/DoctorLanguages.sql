CREATE TABLE [mapping].[DoctorLanguages] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__DoctorLang__Guid__4EDDB18F] DEFAULT (newid()) NOT NULL,
    [DoctorId]      INT              NOT NULL,
    [Languages]     VARCHAR (MAX)    NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__DoctorLan__IsDel__4FD1D5C8] DEFAULT ((0)) NOT NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__DoctorLan__Creat__50C5FA01] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__DoctorLan__Creat__51BA1E3A] DEFAULT (suser_sname()) NOT NULL,
    [ModifieDt]     DATETIME         NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [CreatedByName] VARCHAR (255)    CONSTRAINT [DF__DoctorLan__Creat__7D4E87B5] DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    CONSTRAINT [DF__DoctorLan__Modif__7E42ABEE] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__DoctorLa__3214EC07B5E850C7] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__DoctorLa__A2B5777DBCB4A804] UNIQUE NONCLUSTERED ([Guid] ASC)
);
GO

