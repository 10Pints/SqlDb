SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE view [dbo].[import_CovidStaging1_ty_2_vw]
AS
SELECT Province_State, country_region, last_update, confirmed, deaths,recovered, Lat, Long_
FROM covidstaging1;


GO
