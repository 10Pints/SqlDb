SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStagingColMap](
	[ordinal] [int] NOT NULL,
	[dt] [date] NULL,
	[time24] [varchar](4) NULL,
	[schedule_id] [int] NULL
) ON [PRIMARY]

GO
