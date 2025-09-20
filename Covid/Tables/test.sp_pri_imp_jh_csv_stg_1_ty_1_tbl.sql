SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [test].[sp_pri_imp_jh_csv_stg_1_ty_1_tbl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[import_date] [nvarchar](60) NULL,
	[staging] [nvarchar](4000) NULL,
	[province_state] [nvarchar](60) NULL,
	[country_nm] [nvarchar](50) NULL,
	[last_update] [nvarchar](60) NULL,
	[confirmed] [int] NULL,
	[deaths] [int] NULL,
	[recovered] [int] NULL,
	[existing] [int] NULL
) ON [PRIMARY]

GO
