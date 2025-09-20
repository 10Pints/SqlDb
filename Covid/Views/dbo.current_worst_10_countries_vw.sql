SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[current_worst_10_countries_vw]
AS
SELECT TOP 10 country, MAX(d_conf_pp) AS d_conf_pp_max
FROM rel_pop_stats_vw
   WHERE IMPORT_DATE BETWEEN DATEADD(DAY, -10, GetDate()) AND GetDate()
   GROUP BY country
   ORDER BY MAX(d_conf_pp) DESC


GO
