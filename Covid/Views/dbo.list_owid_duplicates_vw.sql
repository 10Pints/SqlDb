SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 24-APR-2020
-- Description: list duplicates in OWID data
-- =============================================
CREATE VIEW [dbo].[list_owid_duplicates_vw]
AS
    SELECT TOP 400 c.id as ctry_id, c.iso, ow1.*
    FROM OWID ow1 JOIN
    (
    SELECT country_id, [import_date], count(*) as cnt 
    FROM Owid ow2
    GROUP BY country_id, [import_date]
    HAVING count(*) > 1
    ) X ON ow1.country_id = X.country_id AND ow1.[import_date] = X.[import_date]
    JOIN Country c on c.id = ow1.country_id
    ORDER BY c.name, ow1.[import_date];


GO
