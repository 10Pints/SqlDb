CREATE TYPE [test].[CompareStringsTbl] AS TABLE (
    [A]          VARCHAR (MAX) NULL,
    [B]          VARCHAR (MAX) NULL,
    [SA]         VARCHAR (MAX) NULL,
    [SB]         VARCHAR (MAX) NULL,
    [CA]         VARCHAR (MAX) NULL,
    [CB]         VARCHAR (MAX) NULL,
    [msg]        VARCHAR (MAX) NULL,
    [match]      BIT           NULL,
    [status_msg] VARCHAR (120) NULL,
    [code]       INT           NULL,
    [ndx]        INT           NULL,
    [log]        VARCHAR (MAX) NULL);

