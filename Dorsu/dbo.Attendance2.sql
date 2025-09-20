SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Attendance2](
	[id] [int] NOT NULL,
	[classSchedule_id] [int] NOT NULL,
	[student_id] [varchar](9) NOT NULL,
 CONSTRAINT [PK_Attendanc2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Attendance2]  WITH CHECK ADD  CONSTRAINT [FK_Attendance2_ClassSchedule] FOREIGN KEY([classSchedule_id])
REFERENCES [dbo].[ClassSchedule] ([classSchedule_id])

ALTER TABLE [dbo].[Attendance2] CHECK CONSTRAINT [FK_Attendance2_ClassSchedule]

ALTER TABLE [dbo].[Attendance2]  WITH CHECK ADD  CONSTRAINT [FK_Attendance2_Student] FOREIGN KEY([student_id])
REFERENCES [dbo].[Student] ([student_id])

ALTER TABLE [dbo].[Attendance2] CHECK CONSTRAINT [FK_Attendance2_Student]

GO
