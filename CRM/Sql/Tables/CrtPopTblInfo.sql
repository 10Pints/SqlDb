CREATE TABLE [dbo].[CrtPopTblInfo] (
    [file_path]          VARCHAR (500)  NULL,
    [q_tbl_nm]           VARCHAR (100)  NULL,
    [stage]              VARCHAR (20)   NULL,
    [sep]                VARCHAR (6)    NULL,
    [format_file]        VARCHAR (500)  NULL,
    [codepage]           INT            NULL,
    [display_tables]     BIT            NULL,
    [schema_nm]          VARCHAR (25)   NULL,
    [table_nm]           VARCHAR (60)   NULL,
    [folder]             VARCHAR (500)  NULL,
    [stg_table_nm]       VARCHAR (60)   NULL,
    [crt_stg_tbl_sql]    VARCHAR (8000) NULL,
    [sql]                VARCHAR (8000) NULL,
    [crt_fmt_sql]        VARCHAR (8000) NULL,
    [crt_tbl_sql]        VARCHAR (8000) NULL,
    [copy_to_mn_tbl_sql] VARCHAR (8000) NULL,
    [len]                INT            NULL,
    [ndx]                INT            NULL,
    [fields]             VARCHAR (8000) NULL,
    [file]               VARCHAR (500)  NULL
);

