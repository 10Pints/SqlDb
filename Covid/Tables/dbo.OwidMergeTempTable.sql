SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[OwidMergeTempTable](
	[action] [nvarchar](20) NULL,
	[inserted_nm] [nvarchar](1000) NULL,
	[deleted_nm] [nvarchar](1000) NULL
) ON [PRIMARY]

GO
