SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FbNameMap](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fb_nm] [varchar](1000) NULL,
	[section_nm] [varchar](1000) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[match_ty] [int] NULL,
	[candidates] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
