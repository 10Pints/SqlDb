SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FileActivityLog](
	[filepath] [varchar](289) NULL,
	[created] [varchar](21) NULL,
	[lastmodified] [varchar](22) NULL,
	[lastaccessed] [varchar](21) NULL
) ON [PRIMARY]

GO
