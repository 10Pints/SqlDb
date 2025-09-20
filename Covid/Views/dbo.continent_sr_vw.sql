SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE VIEW [dbo].[continent_sr_vw]
AS
SELECT top 20 sum(confirmed) as confirmed, sum(deaths) as deaths, [dbo].[fnCalcSRatio](sum(confirmed),sum(deaths)) as sr_ratio, continent_nm 
FROM BestCountriesSR_vw 
group by continent_nm
ORDER BY sr_ratio desc

GO
