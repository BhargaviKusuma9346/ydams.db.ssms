CREATE TYPE [dbo].[PastHistoryAnswersUDT] AS TABLE (
    [QuestionTypeGuid] UNIQUEIDENTIFIER NOT NULL,
    [Answer]           VARCHAR (200)    NULL);

