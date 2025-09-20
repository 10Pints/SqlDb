SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[TeamMembersStaging](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[is_lead] [bit] NULL,
	[team_id] [int] NULL,
	[section_nm] [varchar](20) NULL
) ON [PRIMARY]

GO
