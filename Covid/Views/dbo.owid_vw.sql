SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE View [dbo].[owid_vw]
AS 
SELECT 
     id
   , [import_date]
   , country_nm                           AS country
   , Round([population]/1000000, 1)       AS [pop (M)]
   , population_density                   AS [pop_density (per pskm)]
   , total_cases                          AS confirmed
   , total_cases_per_million              AS confirmed_pMp
   , new_cases                            AS new
   , new_cases_per_million                AS new_pMp
   , total_deaths                         AS dead
   , total_deaths_per_million             AS dead_pMp
   , new_deaths                           AS dead_today
   , new_deaths_per_million               AS dead_today_pMp
   , total_tests                          AS total_tests
   , new_tests                            AS new_tests
   , ROUND(total_tests_per_thousand/10,1) AS [tests % pop]
   , new_tests_per_thousand               AS new_tests_pTp
   , new_tests_smoothed                   AS new_tests_smthd
   , new_tests_smoothed_per_thousand      AS new_tests_smthd_pTp
   , tests_units                          AS tests_units
   , stringency_index                     AS stringency_index
   , median_age                           AS median_age
   , aged_65_older                        AS aged_65_older
   , aged_70_older                        AS aged_70_older
   , gdp_per_capita                       AS gdp_pCap
   , extreme_poverty                      AS poverty
   , diabetes_prevalence                  AS diabetes
   , female_smokers                       AS smoke_f
   , male_smokers                         AS smoke_b
   , handwashing_facilities               AS wash_fac
   , hospital_beds_per_thousand           AS hosp_beds_pk

FROM Owid;


GO
