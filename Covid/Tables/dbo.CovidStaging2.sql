SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CovidStaging2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_2] [int] NULL,
	[import_date] [date] NOT NULL,
	[last_update] [date] NULL,
	[province_state] [nvarchar](60) NULL,
	[country_id] [int] NOT NULL,
	[orig_country_nm] [nvarchar](50) NULL,
	[country_nm] [nvarchar](50) NOT NULL,
	[confirmed] [float] NULL,
	[deaths] [float] NULL,
	[recovered] [float] NULL,
	[active] [float] NULL,
	[incident_rate] [float] NULL,
	[case_fatality_ratio] [float] NULL,
	[staging] [nvarchar](4000) NULL,
 CONSTRAINT [PK_CovidStaging2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
