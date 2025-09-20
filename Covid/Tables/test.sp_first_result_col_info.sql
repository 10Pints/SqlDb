SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [test].[sp_first_result_col_info](
	[name] [nvarchar](50) NULL,
	[column_ordinal] [int] NULL,
	[is_nullable] [bit] NULL,
	[system_type_name] [nvarchar](50) NULL,
	[error_message] [nvarchar](300) NULL
) ON [PRIMARY]

GO
