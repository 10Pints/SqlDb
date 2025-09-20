SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 06-MAR-2021
-- Description: Once the vaccinations import is complete
-- use this to see the % of people vaccinated by country
-- NOTE: the data is volatile and results >100 occur
-- =============================================
CREATE FUNCTION [dbo].[fn_total_vaccinations]() 

RETURNS 
@t TABLE 
(
    country                NVARCHAR(60)
   ,total_vaccinations     FLOAT
   ,[% total_vaccinations] FLOAT
   ,pop                    FLOAT
)
AS
BEGIN
   INSERT INTO @t (country, total_vaccinations, [% total_vaccinations], pop)
   SELECT X.country_nm, x.people_fully_vaccinated, x.people_fully_vaccinated/pop*100.0 as [% people_fully_vaccinated], c.pop
   FROM
   (SELECT country_nm, max(people_fully_vaccinated) as [people_fully_vaccinated]
   FROM owid
   WHERE total_vaccinations > 0
   GROUP BY country_nm
   ) X JOIN Country c ON(X.country_nm = C.name);

   -- order by has no effect returning a view from a fn
   RETURN;
END

GO
