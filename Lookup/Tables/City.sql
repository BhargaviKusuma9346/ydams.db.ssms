CREATE TABLE [Lookup].[City] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER CONSTRAINT [DF__City__Guid__45F365D3] DEFAULT (newid()) NULL,
    [StateId]       INT              NULL,
    [CityName]      VARCHAR (200)    NULL,
    [IsDeleted]     BIT              CONSTRAINT [DF__City__IsDeleted__46E78A0C] DEFAULT ((0)) NULL,
    [CreatedDt]     DATETIME         CONSTRAINT [DF__City__CreatedDt__47DBAE45] DEFAULT (getdate()) NULL,
    [CreatedBy]     VARCHAR (50)     CONSTRAINT [DF__City__CreatedBy__48CFD27E] DEFAULT (suser_sname()) NULL,
    [CreatedById]   INT              CONSTRAINT [DF__City__CreatedByI__49C3F6B7] DEFAULT ((0)) NULL,
    [ModifieDt]     DATETIME         NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedById]  INT              CONSTRAINT [DF__City__ModifiedBy__4AB81AF0] DEFAULT ((0)) NULL,
    [CreatedByName] VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    [ModifiedName]  VARCHAR (255)    DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__City__3214EC07385A5A47] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ__City__A2B5777D7102ED81] UNIQUE NONCLUSTERED ([Guid] ASC)
);

