SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[most_infected_ctry_sr_vw]
AS
SELECT TOP 300 
    country_nm
   ,RIGHT(FORMAT(ROUND(confirmed/fpop * 100, 4),'##0.0000'), 15) AS [infection%pop]
   ,confirmed
   ,sr_ratio AS survival_rate
   ,pop
   ,area
   ,RIGHT(ut.dbo.fnPadLeft(FORMAT(ROUND(pop_density, 2), '####0.00'), 12),12) as pop_density
   ,deaths
   ,import_date
   ,ROUND(confirmed/fpop * 100, 4) AS [finfection%pop]
FROM best_countries_sr_vw
WHERE country_nm <> 'Others'
ORDER BY [infection%pop] DESC;

GO
