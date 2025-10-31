CREATE TYPE [dbo].[ChkFldsNotNullDataType] AS TABLE (
    [ordinal] INT            NOT NULL,
    [col]     VARCHAR (120)  NOT NULL,
    [sql]     VARCHAR (4000) NOT NULL);

