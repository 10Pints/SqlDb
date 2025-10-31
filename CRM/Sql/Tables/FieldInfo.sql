CREATE TABLE [dbo].[FieldInfo] (
    [id]  INT          IDENTITY (1, 1) NOT NULL,
    [nm]  VARCHAR (50) NULL,
    [ty]  VARCHAR (15) NULL,
    [len] INT          CONSTRAINT [DF_FieldInfo_len] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

