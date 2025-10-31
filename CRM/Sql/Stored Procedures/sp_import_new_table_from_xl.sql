-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 03-APR-2020
-- Description: This stored procedure dynamically imports data from a specified Excel
-- file, creates a new table, and adds an auto-incrementing ID column as the first field.
--
-- Tests: test_074_sp_crt_pop_property_sales
--
-- Example Execution:
/*
EXEC sp_import_new_table_from_xl
'D:\Dev\Property\Data\PropertySales.xlsx'
,'Resort'
,'A1:C10'
,'ResortSales'
,1;

SELECT * FROM ResortSales;
*/
-- ======================================================================================
CREATE PROCEDURE [dbo].[sp_import_new_table_from_xl]
    @file            VARCHAR(1000)
   ,@worksheet       VARCHAR(31)    = NULL
   ,@range           VARCHAR(255)   = NULL
   ,@table           VARCHAR(128)   = NULL
   ,@display_tables  BIT            = 1
AS
BEGIN
   DECLARE
      @fn            VARCHAR(35)    = N'sp_import_new_table_from_xl'
     ,@sql           NVARCHAR(4000)
     ,@columnList    NVARCHAR(MAX) = ''
     ,@field         VARCHAR(30)
   ;

   EXEC sp_log 1, @fn, '000: starting:
@file:     [',@file,']
@worksheet:[',@worksheet,']
@range:    [',@range,']
@table:    [',@table,']
';

BEGIN TRY
   -- 0. Drop the target table if it already exists
   EXEC sp_log 1, @fn, '010: dropping table ', @table, ' If it exists';

   IF OBJECT_ID(@table, 'U') IS NOT NULL
   BEGIN
      SET @sql = CONCAT('DROP TABLE [', @table, '];');
      EXEC sp_log 1, @fn, '020:',@sql;
      EXEC (@sql);
   END

   -- 0. Drop the staging table if it exists
   EXEC sp_log 1, @fn, '030: dropping the temporary table TempExcelData If it exists';
   IF OBJECT_ID('TempExcelData', 'U') IS NOT NULL
      DROP TABLE TempExcelData;

   -- 1. Create a regular table to hold the raw data from the Excel file
   -- This uses the OPENROWSET method.
   SET @sql = CONCAT('
      SELECT *
      INTO TempExcelData
      FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
         ''Excel 12.0;Database=', @file, ';HDR=YES'',
         ''SELECT * FROM [', @worksheet, '$', @range, ']'')
   ');

   EXEC sp_log 1, @fn, '040:',@sql;
   EXEC sp_executesql @sql;

   -- 2. Get the column names from the staging table
   -- We'll use these to build the schema for the final table.
   SELECT @columnList = @columnList + QUOTENAME(c.name) + ' ' + t.name +
                   CASE WHEN t.name IN ('varchar', 'nvarchar', 'char', 'nchar') THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR) END + ')' ELSE '' END + ','
   FROM sys.columns AS c
   JOIN sys.types AS t ON c.user_type_id = t.user_type_id
   WHERE c.object_id = OBJECT_ID('TempExcelData')
   ORDER BY c.column_id;

   -- Check for and handle empty column list
   IF LEN(@columnList) > 0
   BEGIN
      SET @columnList = LEFT(@columnList, LEN(@columnList) - 1);
   END
   ELSE
   BEGIN
      RAISERROR('No columns found in Excel data. Cannot proceed.', 16, 1);
      EXEC sp_log_exception @fn, '50: No columns found in Excel data. Cannot proceed.';
      RETURN;
   END

   -- 3. Dynamically create the final table with the new ID column first
   SET @sql = CONCAT('
      CREATE TABLE [', @table, '] (
         ID INT IDENTITY(1,1) PRIMARY KEY,
         ', @columnList, '
      );'
   );
   
   EXEC sp_log 1, @fn, '060: create the main table with id',@sql;
   EXEC sp_executesql @sql;

   -- 4. Insert the data from the temporary table into the new table
   -- The ID column will be auto-populated.
   -- We need to generate the column list for the INSERT statement, excluding the ID.
   DECLARE @insertColumns NVARCHAR(MAX) = '';
   SELECT @insertColumns = @insertColumns + QUOTENAME(c.name) + ','
   FROM sys.columns AS c
   WHERE c.object_id = OBJECT_ID('TempExcelData')
   ORDER BY c.column_id;
   SET @insertColumns = LEFT(@insertColumns, LEN(@insertColumns) - 1);

   SET @sql = CONCAT('
      INSERT INTO [', @table, '] (', @insertColumns, ')
      SELECT ', @insertColumns, '
      FROM TempExcelData;
   ');
   EXEC sp_log 1, @fn, '070: poplate the main table',@sql;
   EXEC sp_executesql @sql;

   EXEC sp_log 1, @fn, '080: table [', @table, '] was successfully created from the Excel file.';
   EXEC sp_log 1, @fn, '090: the new ID column has been added as the first field.';

   -- 6 Delete any rows where the first column is null
   SELECT @field = name FROM sys.columns
   WHERE [object_id] = OBJECT_ID('TempExcelData')
   AND column_id = 1;

   SET @sql = CONCAT('DELETE FROM [',@table,'] WHERE [',@field,'] IS NULL;');
   EXEC sp_log 1, @fn, '100: cleaning null trailing rows from ',@table,' @sql:
   ', @sql;

   EXEC(@sql);
   EXEC sp_log 1, @fn, '110: cleaning null trailing rows from ',@table,' where '
      ,@field, ' IS NULL, deleted ', @@ROWCOUNT, ' rows.';

   IF @display_tables = 1
   BEGIN
      SET @sql = CONCAT('SELECT ''',@table, ''' as [table];');
      EXEC sp_log 1, @fn, '120: ',@sql;
      EXEC(@sql);
      SET @sql = CONCAT('SELECT * FROM [',@table,']');
      EXEC(@sql);
   END

   -- 5. Clean up the staging table
   DROP TABLE IF EXISTS TempExcelData;
END TRY
BEGIN CATCH
   -- Log the exception
   EXEC sp_log_exception @fn, 'Exception caught. Cleaning up tables.';

   -- Clean up both tables if an error occurs
   IF OBJECT_ID('TempExcelData', 'U') IS NOT NULL
      DROP TABLE IF EXISTS TempExcelData;

   IF OBJECT_ID(@table, 'U') IS NOT NULL
   BEGIN
      SET @sql = CONCAT('DROP TABLE [', @table, ']');
      EXEC(@sql);
   END

   ;THROW; -- Re-throw the error
END CATCH;

   EXEC sp_log 1, @fn, '999: completed processing';
END
/*
EXEC tSQLt.Run 'test.test_074_sp_crt_pop_property_sales'; -- the main test
EXEC sp_import_new_table_from_xl 
'D:\Dev\Property\Data\PropertySales.xlsx'
,'Resort'
,'A1:C10'
,'ResortSales'
;
SELECT * FROM ResortSales;
*/
