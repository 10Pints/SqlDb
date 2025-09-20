SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CountriesData](
	[Rnk] [int] NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[Pop] [float] NOT NULL,
	[Yearly_Change] [nvarchar](50) NOT NULL,
	[Net_Change] [float] NOT NULL,
	[Density] [float] NOT NULL,
	[Area] [float] NOT NULL,
	[Migrants] [float] NULL,
	[Fert_Rate] [nvarchar](50) NOT NULL,
	[Med__Age] [nvarchar](50) NOT NULL,
	[Urban_Pop] [nvarchar](50) NOT NULL,
	[World_Share] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CountriesData] PRIMARY KEY CLUSTERED 
(
	[Rnk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
