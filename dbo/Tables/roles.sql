CREATE TABLE [dbo].[roles] (
    [UserId]        INT            IDENTITY (1, 1) NOT NULL,
    [Role]          NVARCHAR (100) NOT NULL,
    [claims]        NVARCHAR (MAX) NULL,
    [IsDeleted]     BIT            NOT NULL,
    [CreatedBy]     NVARCHAR (MAX) NULL,
    [CreatedDt]     DATETIME2 (7)  NULL,
    [UpdatedBy]     NVARCHAR (MAX) NULL,
    [UpdatedDt]     DATETIME2 (7)  NULL,
    [CreatedByName] VARCHAR (255)  DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)  DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_roles] PRIMARY KEY CLUSTERED ([UserId] ASC)
);

