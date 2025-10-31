CREATE FUNCTION [dbo].[ListExcelSheets]
(@FilePath NVARCHAR (4000) NULL)
RETURNS 
     TABLE (
        [SheetName] NVARCHAR (4000) NULL)
AS
 EXTERNAL NAME [RegEx].[RegEx.ExcelSheetLister].[ListSheetsInWorkbook]

