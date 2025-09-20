SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ClassScheduleStaging](
	[id] [int] NOT NULL,
	[course_nm] [nvarchar](50) NULL,
	[major_nm] [nvarchar](50) NULL,
	[section_nm] [nvarchar](50) NULL,
	[day] [nvarchar](50) NULL,
	[dow] [int] NULL,
	[times] [nvarchar](50) NULL,
	[room_nm] [nvarchar](50) NULL,
 CONSTRAINT [PK_ClassSchedule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
