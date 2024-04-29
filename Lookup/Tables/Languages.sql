CREATE TABLE [Lookup].[Languages] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__Languages__Guid__038683F8] DEFAULT (newid()) NOT NULL,
    [Languages]     VARCHAR (500)    NOT NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__Languages__IsDel__047AA831] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__Languages__Creat__056ECC6A] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__Languages__Creat__0662F0A3] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedDt]    DATETIME         NULL,
    [CreatedByName] VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Language__3214EC07CE28E563] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Language__A2B5777DFC5628D1] UNIQUE NONCLUSTERED ([Guid] ASC)
);

