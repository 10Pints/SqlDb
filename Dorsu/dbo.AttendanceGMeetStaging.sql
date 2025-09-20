SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeetStaging](
	[line] [varchar](150) NULL,
	[candidate_nm] [varchar](150) NULL,
	[student_nm] [varchar](50) NULL,
	[surname] [varchar](50) NULL,
	[student_id] [varchar](9) NULL
) ON [PRIMARY]

GO
