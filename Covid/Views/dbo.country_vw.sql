SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[country_vw]
AS
SELECT
    id
   ,[name]
   ,iso 
   ,iso2 
   ,un_code 
   ,ROUND(pop/1000000,2) AS [pop (M)]
   ,median_age
   ,area
   ,Round(pop/area, 1) as pop_den
   ,lock_date
   ,unlock_date
FROM Country


GO
