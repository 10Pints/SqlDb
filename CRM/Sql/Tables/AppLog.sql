CREATE TABLE [dbo].[AppLog] (
    [id]        INT            IDENTITY (1, 1) NOT NULL,
    [timestamp] VARCHAR (30)   CONSTRAINT [DF_AppLog_timestamp] DEFAULT (getdate()) NOT NULL,
    [schema_nm] VARBINARY (20) NULL,
    [rtn]       VARCHAR (60)   NULL,
    [hit]       INT            NULL,
    [log]       VARCHAR (MAX)  NULL,
    [msg]       VARCHAR (MAX)  NULL,
    [level]     INT            NULL,
    [row_count] INT            NULL,
    [logger]    VARCHAR (80)   NULL,
    [exception] VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_AppLog] PRIMARY KEY CLUSTERED ([id] ASC)
);

