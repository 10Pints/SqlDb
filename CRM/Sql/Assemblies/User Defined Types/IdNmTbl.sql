CREATE TYPE [dbo].[IdNmTbl] AS TABLE (
    [id]  INT            IDENTITY (1, 1) NOT NULL,
    [val] VARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC));

