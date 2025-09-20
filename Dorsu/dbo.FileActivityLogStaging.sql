SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FileActivityLogStaging](
	[FilePath] [varchar](8000) NULL,
	[Created] [varchar](8000) NULL,
	[LastModified] [varchar](8000) NULL,
	[LastAccessed] [varchar](8000) NULL
) ON [PRIMARY]

GO
