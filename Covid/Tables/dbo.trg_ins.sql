SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[trg_ins](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[country_nm] [nvarchar](50) NOT NULL,
	[import_date] [date] NOT NULL,
	[confirmed] [int] NOT NULL,
	[deaths] [int] NOT NULL,
	[recovered] [int] NULL,
	[delta_conf] [int] NULL,
	[delta_dead] [int] NULL,
	[delta_recovered] [int] NULL,
	[sr_ratio] [float] NULL,
	[last_update] [datetime] NULL,
	[country_id] [int] NOT NULL
) ON [PRIMARY]

GO
