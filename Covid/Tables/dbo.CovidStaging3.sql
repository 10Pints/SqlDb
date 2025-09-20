SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CovidStaging3](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rgn_cnt] [int] NULL,
	[import_date] [date] NOT NULL,
	[last_update] [date] NULL,
	[country_id] [int] NOT NULL,
	[country_nm] [nvarchar](28) NOT NULL,
	[confirmed] [int] NULL,
	[deaths] [int] NULL,
	[recovered] [int] NULL,
	[active] [int] NULL,
	[sr_ratio] [float] NULL,
	[incident_rate] [float] NULL,
	[case_fatality_ratio] [float] NULL,
	[staging] [nvarchar](max) NULL,
 CONSTRAINT [PK_CovidStaging3] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_CovidStaging3] UNIQUE NONCLUSTERED 
(
	[country_id] ASC,
	[import_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CovidStaging3]  WITH CHECK ADD  CONSTRAINT [FK_CovidStaging3_Country] FOREIGN KEY([country_id])
REFERENCES [dbo].[Country] ([id])

ALTER TABLE [dbo].[CovidStaging3] CHECK CONSTRAINT [FK_CovidStaging3_Country]

ALTER TABLE [dbo].[CovidStaging3]  WITH CHECK ADD  CONSTRAINT [FK_CovidStaging3_Country1] FOREIGN KEY([country_nm])
REFERENCES [dbo].[Country] ([name])

ALTER TABLE [dbo].[CovidStaging3] CHECK CONSTRAINT [FK_CovidStaging3_Country1]

GO
