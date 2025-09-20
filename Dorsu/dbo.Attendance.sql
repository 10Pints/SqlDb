SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Attendance](
	[classSchedule_id] [int] NOT NULL,
	[student_id] [varchar](9) NOT NULL,
	[date] [date] NOT NULL,
	[present] [bit] NULL,
	[updated]  AS (getdate()),
 CONSTRAINT [PK_Attendance] PRIMARY KEY CLUSTERED 
(
	[classSchedule_id] ASC,
	[student_id] ASC,
	[date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_Attendance_ClassSchedule] FOREIGN KEY([classSchedule_id])
REFERENCES [dbo].[ClassSchedule] ([classSchedule_id])

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_Attendance_ClassSchedule]

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_Attendance_Student] FOREIGN KEY([student_id])
REFERENCES [dbo].[Student] ([student_id])

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_Attendance_Student]

GO
