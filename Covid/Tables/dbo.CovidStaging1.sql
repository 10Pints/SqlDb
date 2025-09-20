SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CovidStaging1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[import_date] [nvarchar](4000) NULL,
	[country_nm] [nvarchar](4000) NULL,
	[country_region] [nvarchar](4000) NULL,
	[province_state] [nvarchar](4000) NULL,
	[country_id] [int] NULL,
	[FIPS] [nvarchar](4000) NULL,
	[Admin2] [nvarchar](4000) NULL,
	[last_update] [nvarchar](4000) NULL,
	[lat] [nvarchar](4000) NULL,
	[long_] [nvarchar](4000) NULL,
	[confirmed] [nvarchar](4000) NULL,
	[deaths] [nvarchar](4000) NULL,
	[recovered] [nvarchar](4000) NULL,
	[delta_conf] [int] NULL,
	[delta_deaths] [int] NULL,
	[active] [nvarchar](4000) NULL,
	[combined_key] [nvarchar](4000) NULL,
	[incident_rate] [nvarchar](4000) NULL,
	[case_fatality_ratio] [nvarchar](4000) NULL,
	[staging] [nvarchar](4000) NULL,
 CONSTRAINT [PK_CovidStaging1] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
