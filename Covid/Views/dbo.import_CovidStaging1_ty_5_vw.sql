SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE view [dbo].[import_CovidStaging1_ty_5_vw]
AS
SELECT
    import_date
   ,country_nm
   ,delta_conf
   ,confirmed
   ,delta_deaths
   ,deaths
FROM covidstaging1;
/*
SELECT top 200 * FROM import_CovidStaging1_ty_5_vw
*/

GO
