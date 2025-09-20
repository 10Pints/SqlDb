SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE view [dbo].[import_CovidStaging1_ty_1_vw]
AS
SELECT Province_State, country_region, last_update, confirmed, deaths, recovered
FROM covidstaging1;


GO
