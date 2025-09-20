SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EnrollmentStaging](
	[impid] [varchar](50) NOT NULL,
	[student_id] [varchar](50) NOT NULL,
	[student_nm] [varchar](50) NULL,
	[gender] [varchar](50) NULL,
	[course_nm] [varchar](50) NOT NULL,
	[section_nm] [varchar](50) NOT NULL,
	[major_nm] [varchar](50) NULL,
	[year] [varchar](50) NULL
) ON [PRIMARY]

GO
