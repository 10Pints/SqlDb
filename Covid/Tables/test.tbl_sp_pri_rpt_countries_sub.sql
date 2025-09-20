SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [test].[tbl_sp_pri_rpt_countries_sub](
	[country] [nvarchar](60) NULL,
	[improvement%] [float] NULL,
	[improvement] [int] NULL,
	[delta_conf_pp_1] [int] NULL,
	[delta_conf_pp_2] [int] NULL,
	[cv_density] [float] NULL,
	[dlta_cnf_blk1_st] [int] NULL,
	[dlta_cnf_blk1_end] [int] NULL,
	[dlta_cnf_blk2_st] [int] NULL,
	[dlta_cnf_blk2_end] [float] NULL,
	[delta_conf_1] [nvarchar](60) NULL,
	[delta_conf_2] [nvarchar](60) NULL,
	[delta_conf_1/day] [nvarchar](60) NULL,
	[delta_conf_2/day] [nvarchar](60) NULL,
	[blok1_st] [date] NULL,
	[blok1_end] [date] NULL,
	[blok2_st] [date] NULL,
	[blok2_end] [date] NULL,
	[conf_blok1_st] [int] NULL,
	[conf_blok1_end] [int] NULL,
	[conf_blok2_st] [int] NULL,
	[conf_blok2_end] [int] NULL,
	[kaput_st] [int] NULL,
	[kaput_mid] [int] NULL,
	[kaput_end] [int] NULL,
	[delta_kaput_1] [int] NULL,
	[delta_kaput_2] [int] NULL,
	[kaput/conf%] [float] NULL,
	[kaput/pop%] [float] NULL,
	[area] [int] NULL,
	[pop] [int] NULL,
	[pop_density] [float] NULL,
	[conf%] [float] NULL,
	[sr_ratio] [float] NULL
) ON [PRIMARY]

GO
