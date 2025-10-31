CREATE TABLE [dbo].[EventLog] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [TimeCreated]  DATETIME2 (7)  NULL,
    [event_id]     INT            NULL,
    [event_type]   VARCHAR (15)   NULL,
    [LogName]      VARCHAR (25)   NULL,
    [ProviderName] VARCHAR (75)   NULL,
    [MachineName]  VARCHAR (15)   NULL,
    [UserId]       VARCHAR (150)  NULL,
    [Message]      VARCHAR (8000) NULL,
    CONSTRAINT [PK_EventLog] PRIMARY KEY CLUSTERED ([id] ASC)
);

