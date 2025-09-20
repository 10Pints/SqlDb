SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2021
-- Type:        Table Valued function
--
-- Description: returns Table:
-- [country, popM, conf_st, conf_end, kaput_st, kaput_end, delta_conf, delta_kaput]*
-- for a given country filter (wildcards ok) over the given interval 
-- specified by @start_date, @end_date
-- Order is country (name)
--
-- Parameters:
--   @country:    country (name) can unclude wildcards
--   @start_date: start date
--   @end_date:   start date
--
--    Defaults:
--    Country    = '%' -- all countries
--    end_date   = latest import_date in COVID -- latest data
--    start_date = 10 day interval
--
-- RETURNS: table: (country, popM, conf, kaput, dconf_pp, dconf, dkaput)
--    country
--    popM     : population in millions
--    area             country area in sq km
--    pop_density      pop/area
--    cv_density       confirmed/pop as a %
--    import_date_st   
--    import_date_end  
--    popM             pop in Millions
--    pop              
--    conf_st          total confirmed covid at the start of the period
--    conf_end         total confirmed covid at the end   of the period
--    delta_conf_st    daily delta new cases at the start of the period
--    delta_conf_end   daily delta new cases at the start of the period
--    kaput_st         
--    kaput_end        
--    delta_conf       delta over the period
--    delta_kaput      delta over the period
--    recovered        
--    sr_ratio         

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
CREATE FUNCTION [dbo].[fnDeltaStats] (@country NVARCHAR(60), @start_date DATE, @end_date DATE)
RETURNS 
@T TABLE 
(
    country          NVARCHAR(60)
   ,area             FLOAT
   ,pop_density      FLOAT
   ,cv_density       FLOAT
   ,import_date_st   DATE
   ,import_date_end  DATE
   ,popM             FLOAT
   ,pop              FLOAT
   ,conf_st          FLOAT
   ,conf_end         FLOAT
   ,delta_conf_st    FLOAT
   ,delta_conf_end   FLOAT
   ,kaput_st         FLOAT
   ,kaput_end        FLOAT
   ,delta_conf       FLOAT
   ,delta_kaput      FLOAT
   ,recovered        INT
   ,sr_ratio         FLOAT
)
AS
BEGIN
   -- Defaults
   IF @country IS NULL
      SET @country = '%' -- all countries

   IF @end_date IS NULL
      SELECT @end_date = MAX(import_date) FROM COVID; -- latest data

   IF @start_date IS NULL
      SELECT @start_date = DateAdd(DAY, -10, @end_date); -- 10 day interval

INSERT INTO @T(country, area, pop_density, cv_density, import_date_st, import_date_end, popM, pop
,conf_st, conf_end, delta_conf_st, delta_conf_end, kaput_st, kaput_end, delta_conf, delta_kaput
,recovered, sr_ratio)
   SELECT A.country, area, pop_density, cv_density, A.import_date, B.import_date, A.popM, pop
    , A.conf as conf_st, B.conf as conf_end, delta_conf_st, delta_conf_end, A.kaput as kaput_st, B.kaput as kaput_end
    , B.conf- A.conf  as delta_conf, B.kaput- A.kaput as delta_kaput, recovered, sr_ratio
FROM
   (
   SELECT
       c.name                          AS country
      ,c.area                          AS area
      ,pop_density
      ,import_date                     AS import_date
      ,ROUND(c.pop/1000000.0, 7)       AS popM
      ,c.pop                           AS pop
      ,cv.confirmed                    AS conf
      ,cv.delta_conf                   AS delta_conf_st
      ,ROUND(cv.confirmed/pop * 100,4) AS cv_density     -- as a %
      ,cv.deaths                       AS kaput
   FROM Country c JOIN Covid cv ON c.id = cv.country_id
   WHERE
   cv.import_date = @start_date
   ) A
   FULL JOIN
   (
   SELECT 
       c.name                       AS country_nm
      ,import_date                  AS import_date
      ,cv.confirmed                 AS conf
      ,cv.delta_conf                AS delta_conf_end
      ,cv.deaths                    AS kaput
      ,cv.recovered
      ,sr_ratio
   FROM Country c JOIN Covid cv ON c.id = cv.country_id
   WHERE
   cv.import_date = @end_date
   ) B
   ON A.country = B.country_nm
   WHERE country = @country;

   RETURN;
END

/*
SELECT * FROM [dbo].[fnDeltaStats]('United Kingdom', '01/01/2021', '01/10/2021');
SELECT * FROM [dbo].[fnDeltaStats]('Russia', '01/01/2021', '01/10/2021') ORDER BY country
SELECT * FROM [dbo].[fnDeltaStats]('%', '01/01/2021', '01/10/2021') WHERE AREA > 500 ORDER BY cv_density DESC
SELECT name, area, pop, conf, cv_density FROM COUNTRY WHERE area > 500 order by cv_density DESC
*/





GO
