SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE VIEW [dbo].[best_countries_sr_vw]
AS
SELECT top 300 country_nm, Right(FORMAT([dbo].[fnCalcSRatio](confirmed,deaths), '###.00'),6) AS sr_ratio, Right(ut.dbo.fnPadLeft(FORMAT(pop, '#,###,###,###'), 13), 14) as pop, confirmed, deaths, import_date, pop as fpop, [dbo].[fnCalcSRatio](confirmed,deaths) as sr, area, continent_nm, pop_density
FROM Covid cv JOIN country c ON cv.country_nm = c.name
JOIN (select max(import_date) as max_date FROM covid) x ON cv.import_date = x.max_date;

GO
