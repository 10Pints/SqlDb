SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeet2Staging](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[s_no] [varchar](50) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[google_alias] [varchar](50) NULL,
	[meet_st] [varchar](50) NULL,
	[Joined] [varchar](50) NULL,
	[stopped] [varchar](50) NULL,
	[duration] [varchar](50) NULL,
	[gmeet_id] [varchar](50) NULL,
	[date] [varchar](20) NULL,
	[cls_st] [varchar](4) NULL,
	[course_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NULL,
 CONSTRAINT [PK_AttendanceGMeet2Staging] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
