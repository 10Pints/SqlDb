SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 24-MAY-2020
-- Description: determines the JH file type from teh timestamp i the file name
   -- type  1:       Province/State	Country/Region	Last Update	Confirmed	Deaths	Recovered
   -- type  2        Province/State	Country/Region	Last Update	Confirmed	Deaths	Recovered	Latitude	Longitude
   -- type  3: FIPS	Admin2	Province_State	Country_Region	Last_Update	Lat	Long_	Confirmed	Deaths	Recovered	Active	Combined_Key
-- =============================================
CREATE FUNCTION [dbo].[fnGetJHImportType](@import_date DATE)
RETURNS INT
AS
BEGIN
   DECLARE @type INT = 0;

   SET @type = CASE
   -- type  1:       Province/State	Country/Region	Last Update	Confirmed	Deaths	Recovered
   WHEN @import_date BETWEEN '22-JAN-2020' AND '29-FEB-2020' THEN 1
   -- type  2        Province/State	Country/Region	Last Update	Confirmed	Deaths	Recovered	Latitude	Longitude
   WHEN @import_date BETWEEN '01-MAR-2020' AND '21-MAR-2020' THEN 2
   -- type  3: FIPS	Admin2	Province_State	Country_Region	Last_Update	Lat	Long_	Confirmed	Deaths	Recovered	Active	Combined_Key
   WHEN @import_date BETWEEN '22-MAR-2020' AND '31-DEC-2029' THEN 3
   ELSE 0 -- catch all for unrecognised dates
   END

   RETURN @type
END




GO
