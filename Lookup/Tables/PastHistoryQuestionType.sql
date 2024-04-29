CREATE TABLE [Lookup].[PastHistoryQuestionType] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [QuestionType]  VARCHAR (500)    NULL,
    [Description]   VARCHAR (500)    NULL,
    [OptionCount]   INT              NULL,
    [IsDeleted]     BIT              DEFAULT ((0)) NOT NULL,
    [CreatedBy]     VARCHAR (50)     DEFAULT (suser_sname()) NOT NULL,
    [CreatedDt]     DATETIME         DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    VARCHAR (50)     NULL,
    [ModifiedDt]    DATETIME         NULL,
    [CreatedByName] VARCHAR (255)    DEFAULT (suser_sname()) NOT NULL,
    [ModifiedName]  VARCHAR (255)    DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Guid] ASC)
);

