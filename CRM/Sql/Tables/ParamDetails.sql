CREATE TABLE [test].[ParamDetails] (
    [ordinal]        INT          IDENTITY (1, 1) NOT NULL,
    [param_nm]       VARCHAR (50) NULL,
    [type_nm]        VARCHAR (32) NULL,
    [parameter_mode] VARCHAR (10) NULL,
    [is_chr_ty]      BIT          NULL,
    [is_result]      BIT          NULL,
    [is_output]      BIT          NULL,
    [is_nullable]    BIT          NULL,
    [tst_ty]         NCHAR (3)    NULL,
    [is_exception]   BIT          NULL,
    CONSTRAINT [PK_ParamDetails] PRIMARY KEY CLUSTERED ([ordinal] ASC)
);

