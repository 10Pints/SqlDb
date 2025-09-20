SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================
-- Author:      Terry Watts
-- Create date: 20-MAY-2020
-- Type:        Table Valued function
-- Description: returns the average delta_confirmed 
-- for countries over an interval
-- No order is specified
--
-- Parameters:
--   start     : end - interval
--
-- RETURNS: table: (country, popM, conf, kaput, dconf_pp, dconf, dkaput)
--   popM = population in millions
--   conf      : total confirmed covid at the end of the period (MAX)
--   kaput     : total dead            at the end of the period (MAX)
--   dconf_pp  : average of the daily new cases per pop
--   dconf     : worst case daily new cases over the period
--   dkaput    : worst case daily new kaput over the period
--
-- Algorithm:
--   Take the average of the block of records between date = (@end-@interval) and @end
--   If end is not specified use current date
--   popM = population in millions
--   conf      : total confirmed covid at the end of the period (MAX)
--   kaput     : total dead            at the end of the period (MAX)
--   dconf_pp  : average of the daily new cases per pop
--   dconf     : worst case daily new cases over the period
--   dkaput    : worst case daily new kaput over the period
-- =================================================
CREATE FUNCTION [dbo].[fnGetAvgDeltaConfpp]
(
    @end             DATE
   ,@interval        INT   = 5
   ,@min_confirmed   INT   = 200
   ,@min_pop_M       INT   = 4      -- Millions
   ,@max_pop_M       INT   = 2000   -- Millions
)
RETURNS 
@T TABLE 
(
    country    NVARCHAR(60)
   ,popM       FLOAT
   ,conf       INT
   ,conf_pp    FLOAT
   ,kaput      INT
   ,dconf_pp   FLOAT
   ,dconf      INT
   ,dkaput     INT
)
AS
BEGIN
DECLARE
    @start           DATE
   ,@min_pop         FLOAT
   ,@max_pop         FLOAT

   SET @min_pop = CONVERT(FLOAT, @min_pop_M) * 1000000.0
   SET @max_pop = CONVERT(FLOAT, @max_pop_M) * 1000000.0

   IF @end IS NULL 
      SET @end = GETDATE();

   SET @start = DATEADD(DAY, -@interval, @end)

   INSERT INTO @T(country, popM, conf, conf_pp, kaput, dconf_pp, dconf, dkaput)
   SELECT 
       c.name
      ,ROUND(c.pop/1000000, 1)   AS popM
      ,MAX(cv.confirmed)         AS conf
      ,dbo.fnPerCentOfPop2(MAX(cv.confirmed), pop, 4) AS conf_pp
      ,MAX(cv.deaths)            AS kaput
      ,ROUND(AVG(dbo.fnPerCentOfPop2(cv.delta_conf, pop, 8)),4) AS avg_d_conf_pp
      ,MAX(cv.delta_conf)   AS dconf
      ,MAX(cv.delta_dead)        AS dkaput
   FROM Country c JOIN Covid cv ON c.id = cv.country_id
   WHERE 
   pop BETWEEN @min_pop AND @max_pop                          -- filter by pop
   AND cv.import_date BETWEEN @start AND @end
   GROUP BY c.name, c.pop
   ORDER BY c.name;

   RETURN;
END

/*
SELECT * FROM [dbo].[fnGetAvgDeltaConfpp]( NULL, 10, 200, 4, 2000)
SELECT COUNT(*) FROM Country
SELECT COUNT(*) FROM Covid

DECLARE @start DATE, @end DATE
DECLARE @interval INT = 10
SET @end = GETDATE()
SET @start = DATEADD(DAY, -@interval, @end)
PRINT(@start)
PRINT(@end)

SELECT TOP 10 * FROM Covid WHERE import_date BETWEEN @start AND @end
*/





GO
