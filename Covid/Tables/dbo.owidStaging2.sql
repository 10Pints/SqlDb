SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[owidStaging2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[iso_code] [nvarchar](50) NULL,
	[continent] [nvarchar](50) NULL,
	[country_nm] [nvarchar](50) NULL,
	[country_id] [int] NULL,
	[date] [date] NULL,
	[total_cases] [float] NULL,
	[new_cases] [float] NULL,
	[total_deaths] [float] NULL,
	[new_deaths] [float] NULL,
	[total_cases_per_million] [float] NULL,
	[new_cases_per_million] [float] NULL,
	[total_deaths_per_million] [float] NULL,
	[new_deaths_per_million] [float] NULL,
	[total_tests] [float] NULL,
	[new_tests] [float] NULL,
	[total_tests_per_thousand] [float] NULL,
	[new_tests_per_thousand] [float] NULL,
	[new_tests_smoothed] [float] NULL,
	[new_tests_smoothed_per_thousand] [float] NULL,
	[tests_units] [nvarchar](50) NULL,
	[stringency_index] [float] NULL,
	[population] [float] NULL,
	[population_density] [float] NULL,
	[median_age] [float] NULL,
	[aged_65_older] [float] NULL,
	[aged_70_older] [float] NULL,
	[gdp_per_capita] [float] NULL,
	[extreme_poverty] [float] NULL,
	[cvd_death_rate] [float] NULL,
	[diabetes_prevalence] [float] NULL,
	[female_smokers] [float] NULL,
	[male_smokers] [float] NULL,
	[handwashing_facilities] [float] NULL,
	[hospital_beds_per_thousand] [float] NULL,
	[life_expectancy] [float] NULL,
 CONSTRAINT [PK_owid_Staging2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
