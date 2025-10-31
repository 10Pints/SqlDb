CREATE TABLE [dbo].[Delegate] (
    [delegate_id] INT            IDENTITY (1, 1) NOT NULL,
    [delegate_nm] NVARCHAR (510) NULL,
    [alias]       NVARCHAR (510) NULL,
    PRIMARY KEY CLUSTERED ([delegate_id] ASC)
);

