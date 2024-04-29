CREATE TABLE [dbo].[DeleteRequests] (
    [Id]                 INT              IDENTITY (1, 1) NOT NULL,
    [Guid]               UNIQUEIDENTIFIER CONSTRAINT [DF__DeleteRequ__Guid__4F1DA8B1] DEFAULT (newid()) NOT NULL,
    [UserTypeId]         INT              NOT NULL,
    [RequestedForUserId] INT              NULL,
    [PatientId]          INT              NULL,
    [RequestedFor]       VARCHAR (500)    NOT NULL,
    [RequestedBy]        VARCHAR (500)    NOT NULL,
    [BranchName]         VARCHAR (500)    NULL,
    [Comments]           VARCHAR (1000)   NULL,
    [IsAccepted]         BIT              CONSTRAINT [DF__DeleteReq__IsAcc__5011CCEA] DEFAULT ((0)) NOT NULL,
    [IsRequested]        BIT              CONSTRAINT [DF_DeleteRequests_IsRequested] DEFAULT ((0)) NULL,
    [IsDeleted]          BIT              CONSTRAINT [DF__DeleteReq__IsDel__5105F123] DEFAULT ((0)) NOT NULL,
    [CreatedBy]          VARCHAR (50)     CONSTRAINT [DF__DeleteReq__Creat__51FA155C] DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]          DATETIME         CONSTRAINT [DF__DeleteReq__Creat__52EE3995] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]         VARCHAR (50)     NULL,
    [ModifiedDt]         DATETIME         NULL,
    [CreatedByName]      VARCHAR (255)    CONSTRAINT [DF__DeleteReq__Creat__53E25DCE] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]       VARCHAR (255)    CONSTRAINT [DF__DeleteReq__Modif__54D68207] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK__DeleteRe__3214EC07FFDE6F00] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__DeleteRe__A2B5777D123F606A] UNIQUE NONCLUSTERED ([Guid] ASC)
);
GO

