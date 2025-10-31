-- ===================================================================
-- Author:      Terry Watts, CHAP GPT
-- Create date: 18-SEP-2025
-- Description: gets the list of sheet names in an excel Workbook
--
-- Preconditions:
-- None
-- Postconditions:
-- POST01: @ExcelPath exists OR EXCEPTION 53000 'file does not exist'
-- POST02: 
-- ===================================================================
CREATE PROCEDURE [dbo].[get_excel_sheet_names]
    @ExcelPath NVARCHAR(4000)       -- full path to workbook
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @fn NVARCHAR(35) = 'ImportExcelFirstSheet'
   EXEC sp_log 1, @fn, '000: starting, @ExcelPath:[', @ExcelPath,'\';
   DECLARE @ServerName SYSNAME = N'ExcelImport';
   DECLARE @FirstSheet NVARCHAR(255);
   DECLARE @SQL NVARCHAR(MAX);

   -- Validate inputs
   EXEC sp_log 1, @fn, '005: Validate inputs: @ExcelPath: [',@ExcelPath, '] exists';
   EXEC sp_assert_file_exists @ExcelPath, @ex_num = 53000;

   -- 1. Drop any existing linked server
   IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @ServerName)
   BEGIN
      EXEC sp_log 1, @fn, '010: EXEC sp_dropserver';
      EXEC sp_dropserver @server=@ServerName, @droplogins='droplogins';
   END;

   -- 2. Create linked server pointing to this Excel file
   EXEC sp_log 1, @fn, '020: sp_addlinkedserver';
   EXEC sp_addlinkedserver
      @server     = @ServerName,
      @srvproduct = N'ACE 12.0',
      @provider   = N'Microsoft.ACE.OLEDB.16.0',  -- or 16.0 if installed
      @datasrc    = @ExcelPath,
      @provstr    = N'Excel 12.0;HDR=YES;IMEX=1;';

   EXEC sp_log 1, @fn, '030: EXEC sp_serveroption ', @ServerName, 'DATA ACCESS', 'TRUE';
   EXEC sp_serveroption @ServerName, 'DATA ACCESS', 'TRUE';
   EXEC sp_log 1, @fn, '040: creating table #Sheets';

   IF dbo.fnTableExists('dbo.XL_sheets') = 1
      DELETE FROM XL_sheets;
   ELSE
      CREATE TABLE XL_sheets
      (
         TABLE_QUALIFIER NVARCHAR(255),
         TABLE_OWNER     NVARCHAR(255),
         TABLE_NAME      NVARCHAR(255),
         TABLE_TYPE      NVARCHAR(255),
         REMARKS         NVARCHAR(255)
      );

   EXEC sp_log 1, @fn, '050: INSERT INTO #Sheets EXEC sp_tables_ex ',  @ServerName;
   INSERT INTO XL_sheets
      EXEC sp_tables_ex @ServerName;

   EXEC sp_log 1, @fn, '060';

   select * from XL_sheets;

      -- 6. Optional: clean up linked server afterwards
   EXEC sp_log 1, @fn, '100: EXEC sp_dropserver @server=@ServerNam';
   EXEC sp_dropserver @server=@ServerName, @droplogins='droplogins';
   EXEC sp_log 1, @fn, '999: leaving';

   RETURN;
END
