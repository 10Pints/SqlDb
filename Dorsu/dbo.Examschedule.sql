SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Examschedule](
	[id] [int] NOT NULL,
	[days] [varchar](1000) NOT NULL,
	[st] [varchar](1000) NOT NULL,
	[end] [varchar](1000) NOT NULL,
	[ex_st] [varchar](1000) NOT NULL,
	[ex_end] [varchar](1000) NOT NULL,
	[ex_date] [varchar](1000) NOT NULL,
	[ex_day] [varchar](1000) NOT NULL,
 CONSTRAINT [PK_Examschedule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
