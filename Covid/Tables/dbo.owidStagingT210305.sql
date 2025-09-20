SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[owidStagingT210305](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[iso_code] [nvarchar](200) NULL,
	[continent] [nvarchar](200) NULL,
	[location] [nvarchar](200) NULL,
	[date] [nvarchar](200) NULL,
	[total_cases] [nvarchar](200) NULL,
	[new_cases] [nvarchar](200) NULL,
	[new_cases_smoothed] [nvarchar](200) NULL,
	[total_deaths] [nvarchar](200) NULL,
	[new_deaths] [nvarchar](200) NULL,
	[new_deaths_smoothed] [nvarchar](200) NULL,
	[total_cases_per_million] [nvarchar](200) NULL,
	[new_cases_per_million] [nvarchar](200) NULL,
	[new_cases_smoothed_per_million] [nvarchar](200) NULL,
	[total_deaths_per_million] [nvarchar](200) NULL,
	[new_deaths_per_million] [nvarchar](200) NULL,
	[new_deaths_smoothed_per_million] [nvarchar](200) NULL,
	[reproduction_rate] [nvarchar](200) NULL,
	[icu_patients] [nvarchar](200) NULL,
	[icu_patients_per_million] [nvarchar](200) NULL,
	[hosp_patients] [nvarchar](200) NULL,
	[hosp_patients_per_million] [nvarchar](200) NULL,
	[weekly_icu_admissions] [nvarchar](200) NULL,
	[weekly_icu_admissions_per_million] [nvarchar](200) NULL,
	[weekly_hosp_admissions] [nvarchar](200) NULL,
	[weekly_hosp_admissions_per_million] [nvarchar](200) NULL,
	[new_tests] [nvarchar](200) NULL,
	[total_tests] [nvarchar](200) NULL,
	[total_tests_per_thousand] [nvarchar](200) NULL,
	[new_tests_per_thousand] [nvarchar](200) NULL,
	[new_tests_smoothed] [nvarchar](200) NULL,
	[new_tests_smoothed_per_thousand] [nvarchar](200) NULL,
	[positive_rate] [nvarchar](200) NULL,
	[tests_per_case] [nvarchar](200) NULL,
	[tests_units] [nvarchar](200) NULL,
	[total_vaccinations] [nvarchar](200) NULL,
	[people_vaccinated] [nvarchar](200) NULL,
	[people_fully_vaccinated] [nvarchar](200) NULL,
	[new_vaccinations] [nvarchar](200) NULL,
	[new_vaccinations_smoothed] [nvarchar](200) NULL,
	[total_vaccinations_per_hundred] [nvarchar](200) NULL,
	[people_vaccinated_per_hundred] [nvarchar](200) NULL,
	[people_fully_vaccinated_per_hundred] [nvarchar](200) NULL,
	[new_vaccinations_smoothed_per_million] [nvarchar](200) NULL,
	[stringency_index] [nvarchar](200) NULL,
	[population] [nvarchar](200) NULL,
	[population_density] [nvarchar](200) NULL,
	[median_age] [nvarchar](200) NULL,
	[aged_65_older] [nvarchar](200) NULL,
	[aged_70_older] [nvarchar](200) NULL,
	[gdp_per_capita] [nvarchar](200) NULL,
	[extreme_poverty] [nvarchar](200) NULL,
	[cardiovasc_death_rate] [nvarchar](200) NULL,
	[diabetes_prevalence] [nvarchar](200) NULL,
	[female_smokers] [nvarchar](200) NULL,
	[male_smokers] [nvarchar](200) NULL,
	[handwashing_facilities] [nvarchar](200) NULL,
	[hospital_beds_per_thousand] [nvarchar](200) NULL,
	[life_expectancy] [nvarchar](200) NULL,
	[human_development_index] [nvarchar](200) NULL,
 CONSTRAINT [PK_owidStagingT210305] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
