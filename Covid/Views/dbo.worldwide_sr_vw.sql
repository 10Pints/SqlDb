SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[worldwide_sr_vw]
AS
SELECT sum(confirmed) as confirmed, sum(deaths) as deaths, [dbo].[fnCalcSRatio](sum(confirmed),sum(deaths)) as sr_ratio
FROM best_countries_sr_vw 

GO
