CREATE TABLE [dbo].[EventLogStaging] (
    [TimeCreated]  VARCHAR (8000) NULL,
    [event_id]     VARCHAR (8000) NULL,
    [event_type]   VARCHAR (8000) NULL,
    [LogName]      VARCHAR (8000) NULL,
    [ProviderName] VARCHAR (8000) NOT NULL,
    [MachineName]  VARCHAR (8000) NULL,
    [UserId]       VARCHAR (8000) NULL,
    [Message]      VARCHAR (8000) NULL
);

