SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[rel_pop_stats_vw]
AS
SELECT 
     cv.import_date
   , cv.country_nm AS country
   , ROUND( c.pop / 1000000, 1) AS [Pop (M)]
   , c.area
   , ROUND(CAST(cv.delta_conf AS float) * 1000000 / c.pop, 0) AS d_conf_pp
   , ROUND(CAST(cv.delta_dead      AS float) * 1000000 / c.pop, 0) AS d_dead_pp
   , ROUND(CAST(cv.delta_recovered AS float) * 1000000 / c.pop, 0) AS d_rec_pp
   , ROUND(CAST(cv.confirmed       AS float) * 1000000 / c.pop, 0) AS conf_pp
   , ROUND(CAST(cv.deaths          AS float) * 1000000 / c.pop, 0) AS dead_pp
   , ROUND(CAST(cv.recovered       AS float) * 1000000 / c.pop, 0) AS rec_pp
   , cv.sr_ratio
   , cv.delta_conf
   , cv.delta_dead
   , cv.delta_recovered
   , cv.confirmed
   , cv.deaths
   , cv.recovered

   FROM dbo.Covid cv JOIN dbo.Country c ON cv.country_id = c.id;


GO
