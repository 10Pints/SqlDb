SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStagingDetail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NULL,
	[ordinal] [int] NULL,
	[present] [bit] NULL,
	[date] [date] NULL,
	[schedule_id] [int] NULL,
 CONSTRAINT [PK_AttendanceStagingDetail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
