SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FindStudentInfo](
	[srch_cls] [varchar](60) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](60) NULL,
	[gender] [char](1) NULL,
	[section_nm] [varchar](20) NULL,
	[course_nm] [varchar](100) NULL,
	[major_nm] [varchar](20) NULL,
	[match_ty] [int] NULL,
	[pos] [int] NULL,
	[sql] [varchar](3000) NULL
) ON [PRIMARY]

GO
