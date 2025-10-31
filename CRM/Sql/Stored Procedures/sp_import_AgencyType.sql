-- =============================================================================
-- Author:      Terry Watts
-- Create date: 03-OCT-2025
-- Description: Imports the AgencyType table from an XL sheet
-- Design:      EA:
-- called by:   sp_import_PropertySales
-- Tests:       
--
-- Preconditions:
-- Postconditions:
-- POST01: following tables are populated:
--    PropertySalesStaging
--    PropertySales
--    Agency         merge
--    Contacts       merge
--    Delegate       merge
--    Status         merge ??
--
-- POST02: returns the imported row count
-- =============================================================================
CREATE PROCEDURE dbo.sp_import_AgencyType
    @file            VARCHAR(100)
   ,@worksheet       VARCHAR(64)  --= 'Resort Sale'
   ,@range           VARCHAR(255) --= 'A1:Z93'
   ,@display_tables  BIT         = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           VARCHAR(35)   = N'sp_import_AgencyType'
      ,@sql          NVARCHAR(4000)
      ,@schema       VARCHAR(40)
      ,@table_nm     VARCHAR(60)
      ,@fld_ty       VARCHAR(25)
      ,@fld_id       INT
      ,@fld_nm       VARCHAR(50)
      ,@len          INT
      ,@row_cnt      INT
  ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
 @file:          [',@file          ,']
,@worksheet:     [',@worksheet     ,']
,@range:         [',@range         ,']
,@display_tables:[',@display_tables,']
';

      -- Preconditions: PRE01: table must exist or exception 60001 'Table '<@q_table_nm> does not exist
   DELETE FROM AgencyType;

   SET @sql = CONCAT('
INSERT INTO AgencyType(agencyType_id,agencyType_nm)
SELECT id,name 
FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
         ''Excel 12.0;Database=', @file, ';HDR=YES'',
         ''SELECT * FROM [', @worksheet, '$', @range, ']'')
WHERE id IS NOT NULL AND name IS NOT NULL;');

      EXEC sp_log 1, @fn, '010: import sql:
', @sql;

      EXEC(@sql);

      DELETE FROM AgencyType WHERE agencyType_id IS NULL AND agencyType_nm IS NULL;

      IF @display_tables = 1
         SELECT * FROM AgencyType ORDER BY agencyType_id;

      SELECT @row_cnt = COUNT(*) FROM AgencyType;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving ok imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC test.test_078_sp_import_propertySales;
EXEC sp_import_propertySalesStaging;
SELECT * FROM PropertySalesStaging;
EXEC test.sp__crt_tst_rtns 'dbo.sp_import_AgencyType';
*/

