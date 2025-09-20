SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FileExists](
	[file_exists] [bit] NULL,
	[folder_exists] [bit] NULL,
	[parent_folder_exists] [bit] NULL
) ON [PRIMARY]

GO
