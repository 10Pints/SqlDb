SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE View [dbo].[tests_per_thou_vw]
AS
Select
[country_nm]
,MAX(total_tests_per_thousand) as tests_per_thou
from owid
--WHERE total_tests IS NOT NULL 
GROUP BY [country_nm]


GO
