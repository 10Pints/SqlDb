SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ExamScheduleStaging](
	[id] [varchar](1000) NULL,
	[days] [varchar](1000) NULL,
	[st] [varchar](1000) NULL,
	[end] [varchar](1000) NULL,
	[ex_st] [varchar](1000) NULL,
	[ex_end] [varchar](1000) NULL,
	[ex_date] [varchar](1000) NULL,
	[ex_day] [varchar](1000) NULL
) ON [PRIMARY]

GO
