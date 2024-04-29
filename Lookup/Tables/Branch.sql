CREATE TABLE [Lookup].[Branch] (
    [Id]             INT               IDENTITY (1, 1) NOT NULL,
    [Guid]           UNIQUEIDENTIFIER  CONSTRAINT [DF__Branch__Guid__7CD98669] DEFAULT (newid()) NOT NULL,
    [BranchName]     VARCHAR (200)     NULL,
    [Address]        VARCHAR (200)     NULL,
    [City]           VARCHAR (200)     NULL,
    [State]          VARCHAR (200)     NULL,
    [Latitude]       FLOAT (53)        NULL,
    [Longitude]      FLOAT (53)        NULL,
    [ContactName]    VARCHAR (200)     NULL,
    [ContactEmail]   VARCHAR (200)     NULL,
    [ContactPhone]   VARCHAR (200)     NULL,
    [Location_cords] [sys].[geography] NULL,
    [IsDeleted]      BIT               CONSTRAINT [DF__Branch__IsDelete__7DCDAAA2] DEFAULT ((0)) NOT NULL,
    [CreatedBy]      VARCHAR (50)      CONSTRAINT [DF__Branch__CreatedB__7EC1CEDB] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]      DATETIME          CONSTRAINT [DF__Branch__CreatedD__7FB5F314] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]     VARCHAR (50)      NULL,
    [ModifiedDt]     DATETIME          NULL,
    [CreatedByName]  VARCHAR (255)     DEFAULT (suser_sname()) NULL,
    [ModifiedName]   VARCHAR (255)     DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Branch__3214EC076D50B73F] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__Branch__A2B5777DC34FD35B] UNIQUE NONCLUSTERED ([Guid] ASC)
);

