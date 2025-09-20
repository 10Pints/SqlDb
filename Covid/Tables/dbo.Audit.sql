SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Audit](
	[id_] [int] IDENTITY(1,1) NOT NULL,
	[updated] [datetime] NULL,
	[action] [nvarchar](15) NULL,
	[changed_field] [nvarchar](22) NULL,
	[id] [int] NULL,
	[country_id] [int] NULL,
	[country_nm] [nvarchar](50) NULL,
	[import_date] [date] NULL,
	[last_update] [datetime] NULL,
	[last_update_old] [datetime] NULL,
	[confirmed] [int] NULL,
	[confirmed_old] [int] NULL,
	[delta_conf] [int] NULL,
	[delta_conf_old] [int] NULL,
	[deaths] [int] NULL,
	[deaths_old] [int] NULL,
	[delta_dead] [int] NULL,
	[delta_dead_old] [int] NULL,
	[recovered] [int] NULL,
	[recovered_old] [int] NULL,
	[delta_recovered] [int] NULL,
	[delta_recovered_old] [int] NULL,
	[modified_time] [datetime] NULL,
	[modified_time_old] [datetime] NULL,
	[last_import_file] [nvarchar](500) NULL,
	[last_import_file_old] [nvarchar](500) NULL,
 CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED 
(
	[id_] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Audit] ADD  CONSTRAINT [DF_Audit_updated]  DEFAULT (getdate()) FOR [updated]

ALTER TABLE [dbo].[Audit] ADD  CONSTRAINT [DF_Audit_modified_date]  DEFAULT (getdate()) FOR [modified_time]

GO
