SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2021
-- Description: Once the vaccinations import is complete
-- use this to see the % of people vaccinated by country
-- NOTE: the data is volatile and results >100 occur
-- =============================================
CREATE FUNCTION [dbo].[fn_total_vaccinations2](@country NVARCHAR(60))
RETURNS 
@t TABLE 
(
    country             NVARCHAR(60)
   ,[date]              DATE
   ,total_vaccinations  FLOAT
   ,[% vaccinated]      FLOAT
)
AS
BEGIN
   INSERT INTO @t (country,.[date], total_vaccinations, [% vaccinated])
SELECT TOP 2000
country_nm as country, import_date, sum(people_fully_vaccinated) as vaccinated, ROUND(people_fully_vaccinated/pop*100, 3) as [% vaccinated]
   FROM Owid ow JOIN Country c ON ow.country_nm = c.name
   WHERE people_fully_vaccinated > 0
   AND country_nm = @country
   AND total_cases IS NOT NULL
   GROUP BY import_date, country_nm, pop, people_fully_vaccinated
   ORDER BY import_date DESC;
   RETURN;
END

/*
SELECT * FROM [dbo].[fn_total_vaccinations2]('Philippines');
SELECT * FROM [dbo].[fn_total_vaccinations2]('United States');
SELECT * FROM [dbo].[fn_total_vaccinations2]('United Kingdom');
SELECT * FROM [dbo].[fn_total_vaccinations2]('Israel');

SELECT country_nm, max(people_fully_vaccinated) as people_fully_vaccinated
   FROM Owid 
   WHERE people_fully_vaccinated > 0
   GROUP BY country_nm;

SELECT *
   FROM Owid 
   WHERE country_nm = 'United Kingdom'
   AND people_fully_vaccinated > 0
   ORDER BY import_date DESC

SELECT *
   FROM Owid 
   WHERE country_nm = 'United States'
   AND people_fully_vaccinated > 0
   ORDER BY import_date DESC
*/



GO
