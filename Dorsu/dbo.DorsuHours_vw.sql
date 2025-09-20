SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE VIEW [dbo].[DorsuHours_vw]
AS
SELECT TOP 100000 DATE_BUCKET (day, 1, Created) AS Created, COUNT(*) as cnt
FROM
(
SELECT Created
FROM
(
SELECT
  DATE_BUCKET (hour, 1, Cast(Created as DateTime)) as Created
  FROM [Dorsu_Dev].[dbo].[tsvStaging]
  WHERE Cast(Created as DateTime) > '2025-02-17 07:45:00.000'
  GROUP BY DATE_BUCKET (hour, 1, Cast(Created as DateTime))
  UNION 
SELECT
  DATE_BUCKET (hour, 1, Cast(LastModified as DateTime)) as Created
  FROM [Dorsu_Dev].[dbo].[tsvStaging]
  WHERE Cast(LastModified as DateTime) > '2025-02-17 07:45:00.000'
  GROUP BY DATE_BUCKET (hour, 1, Cast(LastModified as DateTime))
  UNION
SELECT
  DATE_BUCKET (hour, 1, Cast(LastAccessed as DateTime)) as Created
  FROM [Dorsu_Dev].[dbo].[tsvStaging]
  WHERE Cast(LastAccessed as DateTime) > '2025-02-17 07:45:00.000'
  GROUP BY DATE_BUCKET (hour, 1, Cast(LastAccessed as DateTime))
) X
GROUP BY Created
) Y
GROUP BY DATE_BUCKET (day, 1, Created)
ORDER BY Created
;
/*
SELECT * FROM DorsuHours_vw
*/

GO
