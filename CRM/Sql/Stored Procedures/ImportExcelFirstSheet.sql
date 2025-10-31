-- ===================================================================
-- Author:      Terry Watts
-- Create date: 18-SEP-2025
-- Description: 0
--
-- Preconditions:
-- PRE01: ResortSalesStaging table is populated
-- Postconditions:
-- POST01: ResortSales is populated
-- POST02: returns the number of rows migrated
-- ===================================================================
CREATE   PROCEDURE dbo.ImportExcelFirstSheet
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
   EXEC sp_assert_file_exists @ExcelPath;

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
   -- 3. Get first sheet name into @FirstSheet
   CREATE TABLE #Sheets
   (
      TABLE_QUALIFIER NVARCHAR(255),
      TABLE_OWNER     NVARCHAR(255),
      TABLE_NAME      NVARCHAR(255),
      TABLE_TYPE      NVARCHAR(255),
      REMARKS         NVARCHAR(255)
   );

   EXEC sp_log 1, @fn, '050: INSERT INTO #Sheets EXEC sp_tables_ex ',  @ServerName;
   INSERT INTO #Sheets
      EXEC sp_tables_ex @ServerName;
  --    RETURN;

   EXEC sp_log 1, @fn, '060';
   --SELECT TOP (1) @FirstSheet = TABLE_NAME
   SELECT TABLE_NAME
   FROM #Sheets
   WHERE TABLE_TYPE = 'TABLE'
   ORDER BY TABLE_NAME;
   RETURN;

   EXEC sp_log 1, @fn, '070';
   IF @FirstSheet IS NULL
   BEGIN
      EXEC sp_log 4, @fn, '080';
      RAISERROR('No sheets found in Excel file %s',16,1,@ExcelPath);
      RETURN;
   END;

   -- 4. Build dynamic SELECT from first sheet
   SET @SQL = N'
   SELECT *
   FROM OPENQUERY(' + QUOTENAME(@ServerName) + ',
      ''SELECT * FROM [' + REPLACE(@FirstSheet,'''','''''') + ']'')';

   -- 5. Execute & return data
   EXEC sp_log 1, @fn, '090 executing @sql:
',@sql;

   EXEC(@sql);

   -- 6. Optional: clean up linked server afterwards
   EXEC sp_log 1, @fn, '100: EXEC sp_dropserver @server=@ServerNam';
   EXEC sp_dropserver @server=@ServerName, @droplogins='droplogins';
   EXEC sp_log 1, @fn, '999: leaving';
END
