SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStaging2](
	[index] [varchar](10) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[attendance_percent] [varchar](10) NULL,
	[stage] [varchar](8000) NULL
) ON [PRIMARY]

GO
