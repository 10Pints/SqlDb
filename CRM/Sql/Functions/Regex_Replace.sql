CREATE FUNCTION [dbo].[Regex_Replace]
(@input NVARCHAR (MAX) NULL, @pattern NVARCHAR (MAX) NULL, @replacement NVARCHAR (MAX) NULL)
RETURNS NVARCHAR (MAX)
AS
 EXTERNAL NAME [RegEx].[SqlFunctions.Regex].[Regex_Replace]

