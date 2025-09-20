SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeet2](
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[google_alias] [varchar](50) NULL,
	[meet_st] [varchar](50) NULL,
	[course_id] [int] NULL,
	[section_id] [int] NULL,
	[joined] [time](7) NULL,
	[stopped] [time](7) NULL,
	[duration] [varchar](20) NULL,
	[gmeet_id] [varchar](35) NULL,
	[date] [date] NULL,
	[cls_st] [varchar](4) NULL,
	[course_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NULL
) ON [PRIMARY]

GO
