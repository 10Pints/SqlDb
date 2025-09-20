SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeet](
	[student_id] [varchar](150) NULL,
	[student_nm] [varchar](50) NOT NULL,
	[date] [date] NOT NULL,
	[class_start] [varchar](4) NOT NULL,
	[course_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NULL,
 CONSTRAINT [PK_AttendanceGMeet_1] PRIMARY KEY CLUSTERED 
(
	[student_nm] ASC,
	[date] ASC,
	[class_start] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_AttendanceGMeet_name] ON [dbo].[AttendanceGMeet]
(
	[student_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
