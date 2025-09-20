SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================================================
-- Author:      Terry Watts
-- Create date: 27-APR-2020
-- Description: Updates the delta figures for Covid
-- Changes:
-- 210410: sr_ratio is computed by sp_prcs_update_deltas as
--    (culm confirmed 17 days ago - culm deaths today)/culm confirmed 17 days ago or 0 if no confirmed
-- Test sht: 
-- https://docs.google.com/spreadsheets/d/1LHWKOG5FxGE3vnHc0UarRR4EShuT0a01hbxW6bsVJiA/edit#gid=0
-- =================================================================================================
CREATE PROCEDURE [dbo].[sp_prcs_update_deltas]
AS
BEGIN
   DECLARE 
       @fn     NVARCHAR(20)   = N'UPDT DELTAS';

   EXEC sp_log 1, @fn, '000: starting';

   EXEC sp_log 1, @fn, '010: creating the sr data, sr_ratio from confirmed-17 days ago and current deaths';
   WITH Deltas (id,import_date,country_nm, delta_conf, delta_dead, delta_rec, sr_ratio, [confirmed-17 days])
   AS
   (
      SELECT    id,import_date,country_nm, delta_conf, delta_dead, delta_rec, iif([confirmed-17 days]> 0, ROUND(([confirmed-17 days]-deaths)/[confirmed-17 days] * 100.0, 2), NULL) AS sr_ratio, [confirmed-17 days] 
      FROM
      (SELECT 
          id
         ,import_date AS import_date 
         ,country_nm
         ,(confirmed - Lag(confirmed, 1,  0) OVER (PARTITION BY country_nm ORDER BY country_nm, import_date))               AS delta_conf
         ,(deaths    - Lag(deaths   , 1,  0) OVER (PARTITION BY country_nm ORDER BY country_nm, import_date))               AS delta_dead
         ,(recovered - Lag(recovered, 1,  0) OVER (PARTITION BY country_nm ORDER BY country_nm, import_date))               AS delta_rec
         ,CAST((       Lag(confirmed, 17, 0) OVER (PARTITION BY country_nm ORDER BY country_nm, import_date)) AS FLOAT)     AS [confirmed-17 days]--/Lag(confirmed, 17, 1)*100.0 AS sr_ratio
         , deaths
          FROM Covid
      ) X
   )
   UPDATE Covid 
   SET
       delta_conf          = ds.delta_conf
      ,delta_dead          = ds.delta_dead
      ,delta_recovered     = ds.delta_rec
      ,sr_ratio            = ds.sr_ratio
      ,[confirmed-17 days] = ds.[confirmed-17 days]
   FROM covid c 
       JOIN Deltas ds ON c.import_date = ds.import_date AND c.country_nm = ds.country_nm;

   EXEC sp_log 1, @fn, '020: come countries do not repot recovered consistently, this throws our stats reporting - so calc recovered from sr_ratio and confirmed-17 days ago if possible';
   UPDATE Covid 
   SET 
       recovered = [confirmed-17 days] * sr_ratio/100
      ,notes = CONCAT( notes, ' * calc recovery from sr and conf-17 day')
      WHERE recovered IS NULL and sr_ratio is not NULL AND confirmed IS NOT NULL;

   EXEC sp_log 1, @fn, '999: leavting';
END

GO
