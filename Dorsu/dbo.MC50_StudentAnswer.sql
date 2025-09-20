SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[MC50_StudentAnswer](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NOT NULL,
	[ordinal] [int] NULL,
	[answer] [varchar](8) NULL,
	[score] [float] NULL
) ON [PRIMARY]

GO
