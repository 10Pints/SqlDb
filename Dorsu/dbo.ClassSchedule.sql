SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ClassSchedule](
	[classSchedule_id] [int] IDENTITY(1,1) NOT NULL,
	[course_id] [int] NOT NULL,
	[major_id] [int] NOT NULL,
	[section_id] [int] NOT NULL,
	[day] [varchar](3) NOT NULL,
	[st_time] [varchar](4) NOT NULL,
	[end_time] [varchar](4) NULL,
	[dow] [int] NULL,
	[description] [varchar](100) NULL,
	[room_id] [int] NULL,
 CONSTRAINT [PK_ClassSchedule_1] PRIMARY KEY CLUSTERED 
(
	[classSchedule_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[ClassSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ClassSchedule_Course] FOREIGN KEY([course_id])
REFERENCES [dbo].[Course] ([course_id])

ALTER TABLE [dbo].[ClassSchedule] CHECK CONSTRAINT [FK_ClassSchedule_Course]

ALTER TABLE [dbo].[ClassSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ClassSchedule_Major] FOREIGN KEY([major_id])
REFERENCES [dbo].[Major] ([major_id])

ALTER TABLE [dbo].[ClassSchedule] CHECK CONSTRAINT [FK_ClassSchedule_Major]

ALTER TABLE [dbo].[ClassSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ClassSchedule_Room] FOREIGN KEY([room_id])
REFERENCES [dbo].[Room] ([room_id])

ALTER TABLE [dbo].[ClassSchedule] CHECK CONSTRAINT [FK_ClassSchedule_Room]

ALTER TABLE [dbo].[ClassSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ClassSchedule_Section] FOREIGN KEY([section_id])
REFERENCES [dbo].[Section] ([section_id])

ALTER TABLE [dbo].[ClassSchedule] CHECK CONSTRAINT [FK_ClassSchedule_Section]

GO
