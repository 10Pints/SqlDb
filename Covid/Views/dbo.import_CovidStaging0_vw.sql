SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE view [dbo].[import_CovidStaging0_vw]
AS
SELECT [staging]--, Province_State, country_nm, last_update, confirmed, deaths,recovered
FROM covidstaging0;


GO
