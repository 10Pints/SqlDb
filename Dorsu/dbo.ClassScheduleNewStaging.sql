SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ClassScheduleNewStaging](
	[course_id] [varchar](20) NOT NULL,
	[description] [nvarchar](150) NULL,
	[major_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NOT NULL,
	[days] [varchar](20) NOT NULL,
	[times] [varchar](50) NOT NULL,
	[rooms] [varchar](20) NULL,
 CONSTRAINT [PK_ClassScheduleNewStaging] PRIMARY KEY CLUSTERED 
(
	[course_id] ASC,
	[section_nm] ASC,
	[days] ASC,
	[times] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
