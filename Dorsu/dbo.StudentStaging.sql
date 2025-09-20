SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[StudentStaging](
	[student_id] [varchar](9) NOT NULL,
	[student_nm] [varchar](50) NULL,
	[gender] [char](1) NULL,
	[google_alias] [varchar](30) NULL,
	[FB_alias] [varchar](30) NULL,
	[email] [varchar](30) NULL
) ON [PRIMARY]

GO
