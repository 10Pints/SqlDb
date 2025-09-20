SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE view [dbo].[import_CovidStaging1_ty_4_vw]
AS
SELECT
    FIPS
   ,admin2
   ,province_State
   ,country_region
   ,last_update
   ,lat
   ,long_
   ,confirmed
   ,deaths
   ,recovered
   ,active
   ,combined_key
   ,incident_rate
   ,case_fatality_ratio
FROM covidstaging1;


GO
