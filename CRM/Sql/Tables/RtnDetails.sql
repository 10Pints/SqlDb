CREATE TABLE [test].[RtnDetails] (
    [qrn]            VARCHAR (90) NULL,
    [schema_nm]      VARCHAR (60) NULL,
    [rtn_nm]         VARCHAR (60) NULL,
    [trn]            INT          NULL,
    [cora]           NCHAR (1)    NULL,
    [ad_stp]         BIT          NULL,
    [rtn_ty]         VARCHAR (2)  NULL,
    [rtn_ty_code]    VARCHAR (2)  NULL,
    [is_clr]         BIT          NULL,
    [tst_rtn_nm]     VARCHAR (50) NULL,
    [hlpr_rtn_nm]    VARCHAR (50) NULL,
    [max_prm_len]    INT          NULL,
    [sc_fn_ret_ty]   VARCHAR (20) NULL,
    [prm_cnt]        INT          NULL,
    [display_tables] BIT          NULL
);

