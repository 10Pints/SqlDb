CREATE TABLE [dbo].[Status] (
    [status_id] INT            IDENTITY (1, 1) NOT NULL,
    [status_nm] NVARCHAR (510) NULL,
    PRIMARY KEY CLUSTERED ([status_id] ASC)
);

