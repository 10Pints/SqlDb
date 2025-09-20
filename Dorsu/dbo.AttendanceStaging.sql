SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStaging](
	[index] [varchar](10) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[attendance_percent] [varchar](10) NULL,
	[stage] [varchar](8000) NULL,
	[course_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NULL,
	[course_id] [int] NULL,
	[section_id] [int] NULL
) ON [PRIMARY]

GO
