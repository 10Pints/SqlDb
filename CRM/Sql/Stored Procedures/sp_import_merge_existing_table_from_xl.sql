-- ======================================================================================
-- Author:      Terry Watts (adapted by Grok)
-- Create date: 18-SEP-2025
-- Description: Dynamically imports/merges data from Excel into an *existing* table.
-- Uses common column names for matching (order irrelevant). Supports append, replace, or true MERGE.
--
-- Params:
-- @file: Full path to Excel.
-- @worksheet: Sheet name (default: 'Sheet1').
-- @range: Cell range (default: entire sheet).
-- @table: Existing table name (required; schema-qualified OK).
-- @key_column: Single key column for MERGE (NULL = append-only INSERT).
-- @delete_first: If 1, DELETE all rows first (replace mode).
-- @display_tables: If 1, SELECT * after.
--
-- Example Execution:
-- EXEC dbo.sp_import_merge_existing_table_from_xl
--    'D:\Dev\Property\Data\PropertySales.xlsx', 'Resort', NULL, 'dbo.ResortSales', NULL, 1, 1;
-- -- (Replaces all in ResortSales, displays result)
--
-- EXEC dbo.sp_import_merge_existing_table_from_xl
--    'D:\Dev\Property\Data\PropertySales.xlsx', 'Resort', NULL, 'dbo.ResortSales', 'ID', 0, 1;
-- -- (MERGEs on ID, displays result)
-- ======================================================================================
CREATE PROCEDURE [dbo].[sp_import_merge_existing_table_from_xl]
    @file            VARCHAR(1000)        -- no default
   ,@worksheet       VARCHAR(31)    = NULL
   ,@range           VARCHAR(255)   = NULL
   ,@table           VARCHAR(128)   -- Required; no default
   ,@key_column      VARCHAR(128)   = NULL
   ,@delete_first    BIT            = 0
   ,@display_tables  BIT            = 0
AS
BEGIN
   DECLARE
      @fn            VARCHAR(45)    = N'sp_import_merge_existing_table_from_xl'
     ,@sql           NVARCHAR(4000)
     ,@commonColumns NVARCHAR(MAX) = ''
     ,@insertColumns NVARCHAR(MAX) = ''
     ,@updateSets    NVARCHAR(MAX) = ''
     ,@firstCol      VARCHAR(30)
     ,@worksheetFull VARCHAR(31)   = ISNULL(@worksheet, 'Sheet1')
     ,@rangeFull     VARCHAR(255)  = @range  -- Will build sheet/range string below
     ,@cnt           INT
   ;

   EXEC sp_log 1, @fn, '000: starting:
@file:        [',@file,']
@worksheet:   [',@worksheetFull,']
@range:       [',@range,']
@table:       [',@table,']
@key_column:  [',@key_column,']
@delete_first:[',@delete_first,']
';

   -- Set Defaults
   DROP TABLE IF EXISTS TempExcelData;

   -- Validate required params
   EXEC sp_log 1, @fn, '005: validating params';

   IF @file IS NULL OR LTRIM(RTRIM(@file)) = ''
      EXEC sp_raise_exception 65001, '@file is required.', @fn = @fn;--RAISERROR('@file is required.', 16, 1);

   IF @table IS NULL OR LTRIM(RTRIM(@table)) = ''
      RAISERROR('@table is required and must exist.', 16, 1);

   BEGIN TRY
      -- 0. Check target table exists
      EXEC sp_log 1, @fn, '010: checking if table ', @table, ' exists';
      IF OBJECT_ID(@table, 'U') IS NULL
      BEGIN
         RAISERROR('Target table [%s] does not exist.', 16, 1, @table);
         RETURN;
      END

      -- 0. Drop staging if exists
      EXEC sp_log 1, @fn, '020: dropping TempExcelData if exists';
      IF OBJECT_ID('TempExcelData', 'U') IS NOT NULL
         DROP TABLE TempExcelData;

      -- 1. Build range string and import to staging
      SET @rangeFull = CASE WHEN @range IS NULL THEN '' ELSE @range END;
      SET @sql = CONCAT('
         SELECT *
         INTO TempExcelData
         FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=', @file, ';HDR=YES'',
            ''SELECT * FROM [', @worksheetFull, '$', @rangeFull, ']'')
      ');

      EXEC sp_log 1, @fn, '030: executing', @sql;
      EXEC sp_executesql @sql;
      select @cnt = count(*) from TempExcelData;
      EXEC sp_log 1, @fn, '040: executed sql, loaded ', @cnt , ' rows';

      -- Check for empty import
      IF NOT EXISTS (SELECT 1 FROM TempExcelData)
      BEGIN
         EXEC sp_log 4, @fn, '050: No data found in Excel range. Cannot proceed.';
         RAISERROR('No data found in Excel range. Cannot proceed.', 16, 1);
         RETURN;
      END

      SELECT * FROM TempExcelData;
      --SELECT MAX(dbo.fnLen(gender)) as len_gen from TempExcelData;
      DECLARE @CommonCols TABLE( col_nm VARCHAR(50));

      INSERT INTO @CommonCols (col_nm)
      SELECT c.name
      FROM sys.columns c
         WHERE c.object_id = OBJECT_ID('TempExcelData')
         INTERSECT
         SELECT c.name AS col_name
         FROM sys.columns c
         WHERE c.object_id = OBJECT_ID(@table)
      ;
      SELECT * FROM @CommonCols;
      --THROW 50000, 'DEBUG ', 1;

      -- 2. Build common columns (matching names between temp and target)
      /*;WITH CommonCols AS (
         SELECT c.name AS col_name
         FROM sys.columns c
         WHERE c.object_id = OBJECT_ID('TempExcelData')
         INTERSECT
         SELECT c.name AS col_name
         FROM sys.columns c
         WHERE c.object_id = OBJECT_ID(@table)
      )*/
      SELECT 
         @commonColumns = @commonColumns + QUOTENAME(col_nm) + ',',
         @insertColumns = @insertColumns + QUOTENAME(col_nm) + ','
      FROM @CommonCols;

      IF LEN(@commonColumns) = 0
      BEGIN
         RAISERROR('No matching columns between Excel and target table. Cannot proceed.', 16, 1);
         RETURN;
      END

      -- Trim trailing commas
      SET @commonColumns = LEFT(@commonColumns, LEN(@commonColumns) - 1);
      SET @insertColumns = LEFT(@insertColumns, LEN(@insertColumns) - 1);
      EXEC sp_log 1, @fn, '070';

      -- Build UPDATE SET clause (all commons except key)
      IF @key_column IS NOT NULL
      BEGIN
         SELECT @updateSets = @updateSets + QUOTENAME(col_nm) + ' = s.' + QUOTENAME(col_nm) + ','
         FROM @CommonCols
         WHERE col_nm <> @key_column;
         SET @updateSets = LEFT(@updateSets, LEN(@updateSets) - 1);
      END

      -- Get first common col for null cleanup
      SELECT TOP 1 @firstCol = col_nm FROM @CommonCols ORDER BY col_nm;
      EXEC sp_log 1, @fn, '080: @commonColumns: ', @commonColumns;

      -- 3. Optional: Delete all rows first
      IF @delete_first = 1
      BEGIN
         SET @sql = CONCAT('DELETE FROM [', @table, '];');
         EXEC sp_log 1, @fn, '090: delete_first mode: ', @sql;
         EXEC (@sql);
         EXEC sp_log 1, @fn, '100: Deleted ', @@ROWCOUNT, ' rows from ', @table;
      END

      -- 4. Populate: MERGE if key provided (and not delete_first), else INSERT
      EXEC sp_log 1, @fn, '110: Populate: MERGE if key provided (and not delete_first), else INSERT';

      IF @key_column IS NOT NULL AND @delete_first = 0
      BEGIN
         -- True MERGE
         EXEC sp_log 1, @fn, '120: TRUE: so merge';
/*         SET @sql = CONCAT('
            MERGE [', @table, '] AS t
            USING TempExcelData AS s ON t.[', @key_column, '] = s.[', @key_column, ']
            WHEN MATCHED THEN
               UPDATE SET ', @updateSets, '
            WHEN NOT MATCHED THEN
               INSERT (', @insertColumns, ')
               VALUES (', REPLACE(@insertColumns, '[', 's.[') , ')
            OUTPUT $action, INSERTED.name
            INTO MergeResults
            ;'
         );*/
         DROP TABLE IF EXISTS GlobalMergeResults;
         CREATE TABLE GlobalMergeResults
         (
             ActionType NVARCHAR(10),
             Name NVARCHAR(255)
         );

SET @sql = CONCAT('
    MERGE [', @table, '] AS t
    USING TempExcelData AS s ON t.[', @key_column, '] = s.[', @key_column, ']
    WHEN MATCHED THEN
       UPDATE SET ', @updateSets, '
    WHEN NOT MATCHED THEN
       INSERT (', @insertColumns, ')
       VALUES (', REPLACE(@insertColumns, '[', 's.[') , ')
    OUTPUT $action, INSERTED.', @key_column, '
    INTO GlobalMergeResults
    ;'
);
         EXEC sp_log 1, @fn, '130: MERGE mode: ', @sql;

  --       DROP TABLE IF EXISTS MergeResults;
         EXEC sp_log 1, @fn, '131';

         EXEC sp_executesql @sql;
         EXEC sp_log 1, @fn, '135: MERGE mode: ', @sql
         -- Count the actions
         DECLARE @InsertCount INT = 0, 
                 @UpdateCount INT = 0,
                 @TotalCount  INT = 0;

         -- Display the statistics
SELECT 
    COUNT(*) AS TotalActions,
    SUM(CASE WHEN ActionType = 'INSERT' THEN 1 ELSE 0 END) AS RowsInserted,
    SUM(CASE WHEN ActionType = 'UPDATE' THEN 1 ELSE 0 END) AS RowsUpdated
FROM GlobalMergeResults;

         -- Cleanup
         --DROP TABLE #MergeResults;
         EXEC sp_log 1, @fn, '140: MERGE completed. Updated/Inserted rows processed. inserted ', @InsertCount, ' rows updated ',@UpdateCount;
      END
      ELSE
      BEGIN
         -- Simple INSERT (append or post-delete)
         EXEC sp_log 1, @fn, '150: FALSE so Simple INSERT';
         SET @sql = CONCAT('
            INSERT INTO [', @table, '] (', @insertColumns, ')
            SELECT ', REPLACE(@insertColumns, '[', ''), '
            FROM TempExcelData;
         ');
         EXEC sp_log 1, @fn, '150: INSERT sql: ', @sql;
         EXEC sp_executesql @sql;
         EXEC sp_log 1, @fn, '160: Inserted ', @@ROWCOUNT, ' rows into ', @table;
      END

      -- 5. Clean null rows (based on first common col)
      SET @sql = CONCAT('DELETE FROM [', @table, '] WHERE [', @firstCol, '] IS NULL;');
      EXEC sp_log 1, @fn, '170: cleaning null rows: ', @sql;
      EXEC (@sql);
      EXEC sp_log 1, @fn, '180: Deleted ', @@ROWCOUNT, ' null rows from ', @table;

      EXEC sp_log 1, @fn, '190: Successfully merged/imported into [', @table, '].';

      IF @display_tables = 1
      BEGIN
         SET @sql = CONCAT('SELECT * FROM [', @table, '];');
         EXEC sp_log 1, @fn, '200: displaying: ', @sql;
         EXEC (@sql);
      END

      -- Cleanup
      --DROP TABLE IF EXISTS TempExcelData;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '500: caught Exception, cleaning up.';
      --IF OBJECT_ID('TempExcelData', 'U') IS NOT NULL DROP TABLE IF EXISTS TempExcelData;
      THROW;
   END CATCH;

   EXEC sp_log 1, @fn, '999: completed processing loaded ', @cnt,  ' rows';
   RETURN @cnt;
END
/*
exec test.test_080_sp_import_merge_existing_table_from_xl;

exec tSQLt.Run 'test.test_080_sp_import_merge_existing_table_from_xl'
*/