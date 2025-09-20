SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE FUNCTION [dbo].[fn_total_vaccinations_2]()
RETURNS @t TABLE
(
   country        NVARCHAR(60),
   [date]         date,
   [vaccinated%]  float
)
AS
BEGIN
   INSERT INTO @t(country, [date], [vaccinated%])
      SELECT country_nm, import_date, Round(people_fully_vaccinated/c.pop * 100, 0)
      FROM owid ow join country c ON ow.country_nm = c.name
      WHERE people_fully_vaccinated IS NOT null AND Round(people_fully_vaccinated/c.pop * 100, 0) >=1 AND country_nm in ('United Kingdom', 'Philippines', 'Ireland', 'United States')
      ORDER BY country_nm, import_date;

   RETURN;
END

GO
