CREATE TABLE [dbo].[PasswordHistory] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [UserGuid]      UNIQUEIDENTIFIER NOT NULL,
    [PasswordHash1] NVARCHAR (MAX)   CONSTRAINT [DF_password_Passwordhash1] DEFAULT (NULL) NULL,
    [PasswordHash2] NVARCHAR (MAX)   CONSTRAINT [DF_password_Passwordhash2] DEFAULT (NULL) NULL,
    [PasswordHash3] NVARCHAR (MAX)   CONSTRAINT [DF_password_Passwordhash3] DEFAULT (NULL) NULL,
    [PasswordHash4] NVARCHAR (MAX)   CONSTRAINT [DF_password_Passwordhash4] DEFAULT (NULL) NULL,
    [PasswordHash5] NVARCHAR (MAX)   CONSTRAINT [DF_password_Passwordhash5] DEFAULT (NULL) NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF_PasswordHistory_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     NVARCHAR (MAX)   CONSTRAINT [DF_password_CreatedBy] DEFAULT (suser_sname()) NULL,
    [CreatedDt]     DATETIME2 (7)    CONSTRAINT [DF_password_CreatedDt] DEFAULT (getdate()) NULL,
    [UpdatedBy]     NVARCHAR (MAX)   CONSTRAINT [DF_password_UpdatedBy] DEFAULT (suser_sname()) NULL,
    [UpdatedDt]     DATETIME2 (7)    CONSTRAINT [DF_password_UpdatedDt] DEFAULT (getdate()) NULL,
    [CreatedByName] VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_password] PRIMARY KEY CLUSTERED ([Id] ASC)
);

