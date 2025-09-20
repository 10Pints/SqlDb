SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[TeamStaging](
	[team_id] [varchar](500) NOT NULL,
	[team_nm] [varchar](500) NOT NULL,
	[members] [varchar](500) NOT NULL,
	[github_project] [varchar](500) NULL,
	[section_nm] [varchar](500) NULL,
	[course_nm] [varchar](500) NULL,
	[event_nm] [varchar](500) NULL,
	[team_gc] [varchar](500) NULL,
	[team_url] [varchar](500) NULL,
	[notes] [varchar](500) NULL,
 CONSTRAINT [PK_TeamStaging] PRIMARY KEY CLUSTERED 
(
	[team_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_TeamStaging] UNIQUE NONCLUSTERED 
(
	[team_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
