SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[best_ctry_sr_vw]
AS
SELECT TOP 300 country_nm, sr_ratio AS survival_rate, pop, confirmed, deaths, import_date
FROM best_countries_sr_vw 
ORDER BY sr desc

GO
