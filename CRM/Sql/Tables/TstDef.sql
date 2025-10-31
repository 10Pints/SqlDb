CREATE TABLE [test].[TstDef] (
    [id]   INT            IDENTITY (1, 1) NOT NULL,
    [line] VARCHAR (4000) NULL,
    CONSTRAINT [PK_test.rtnDefTable] PRIMARY KEY CLUSTERED ([id] ASC)
);

