SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 28-APR-2020
-- Description: reports the countries that have the lowest 5 day average
-- ====================================================================
CREATE FUNCTION [dbo].[fnGetBestCountries]
(
    @date                   DATE
   ,@delta                  INT  -- interval between the 2 probes
   ,@conf_sig               INT  -- minimum confirmed 
   ,@min_pop_M              INT
   ,@max_pop_M              INT
)
RETURNS 
@T TABLE 
(
    -- Add the column definitions for the TABLE variable here
     country_nm     NVARCHAR(60)
    ,confirmed      INT
    ,deaths         INT
    ,recovered      INT
    ,d_now          FLOAT
    ,d_previous     FLOAT
    ,change         FLOAT
)
AS
BEGIN
   DECLARE 
    @min_pop       FLOAT = @min_pop_M * 1000000
   ,@max_pop       FLOAT = @max_pop_M * 1000000


   IF @date IS NULL 
      SET @date = GETDATE();

   IF @min_pop_M IS NULL
      set @min_pop_M = 20

   IF @max_pop_M IS NULL
      set @max_pop_M = 2000

INSERT INTO @T ( country_nm, confirmed, deaths, recovered, d_now, d_previous, change)
SELECT 
     X.country_nm
    ,X.confirmed
    ,X.deaths
    ,X.recovered
    ,X.d_now
    ,Y.d_previous
    ,ROUND(100*(X.d_now -Y.d_previous)/(iif(Y.d_previous = 0, iif(X.d_now=0, 1, X.d_now), Y.d_previous)),0) AS change
FROM
(
    SELECT
         country_nm
        ,ROUND(CONVERT(float, AVG(dbo.fnPerCapita (delta_conf, pop, 2))),1) AS d_now
        ,max(confirmed) as confirmed
        ,max(deaths) as deaths
        ,max(recovered) as recovered
    FROM Covid cv JOIN Country  c ON cv.country_id = c.id 
    WHERE
        cv.country_id in
        (
            SELECT c2.id 
            FROM Country c2 JOIN Covid cv2 ON c2.id = cv2.country_id
            GROUP BY c2.id
            HAVING MAX(confirmed) > @conf_sig -- minimum significance
        )
        AND delta_conf IS NOT NULL
        AND import_date BETWEEN DATEADD(DAY,-@delta, @date) AND @date
        AND pop BETWEEN @min_pop AND @max_pop
        GROUP BY country_nm
) X JOIN
(
    SELECT
         country_nm 
        ,ROUND(CONVERT(float, AVG(dbo.fnPerCapita (delta_conf, pop, 2))),1) AS d_previous
    FROM Covid cv JOIN Country  c ON cv.country_id = c.id 
    WHERE
        cv.country_id in
        (
            SELECT c2.id 
            FROM Country c2 JOIN Covid cv2 ON c2.id = cv2.country_id
            GROUP BY c2.id
            HAVING MAX(confirmed) > @conf_sig -- minimum significance
        )
        AND delta_conf IS NOT NULL
        AND import_date BETWEEN DATEADD(DAY,-(2*@delta), @date) AND DATEADD(DAY,-@delta, @date)
        AND pop BETWEEN @min_pop AND @max_pop
        GROUP BY country_nm
) Y ON X.country_nm = y.country_nm;

    RETURN;
END




GO
