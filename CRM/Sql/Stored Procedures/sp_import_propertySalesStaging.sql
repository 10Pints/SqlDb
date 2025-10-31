-- =============================================================================
-- Author:      Terry Watts
-- Create date: 12-SEP-2025
-- Description: Clean imports a spreadsheet into the PropertySalesStaging table
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
CREATE PROCEDURE [dbo].[sp_import_propertySalesStaging]
    @file            VARCHAR(100)
   ,@worksheet       VARCHAR(64)  --= 'Resort Sale'
   ,@range           VARCHAR(255) --= 'A1:Z93'
   ,@display_tables  BIT         = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           VARCHAR(35)   = N'sp_import_propertySalesStaging'
      ,@sql          NVARCHAR(4000)
      ,@schema       VARCHAR(40)
      ,@table_nm     VARCHAR(60)
      ,@fld_ty       VARCHAR(25)
      ,@fld_id       INT
      ,@fld_nm       VARCHAR(50)
      ,@len          INT
      ,@rc           INT
  ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
   @file:          [', @file         ,']
   @worksheet:     [', @worksheet    ,']
   @range:         [',@range         ,']
   @display_tables:[',@display_tables,']
   ';
      -- Preconditions: PRE01: table must exist or exception 60001 'Table '<@q_table_nm> does not exist
      DELETE FROM PropertySalesStaging;
      SET @sql = CONCAT('
INSERT INTO PropertySalesStaging
(
[name],[type],area,delegate_nm,status,first_reg
,[notes],[quality],[contact_nm],[role],[phone],[facebook],[messenger]
,[preferred_contact_method],[email],[whatsapp]
,[viber],[website],[address]
,[notes_2],[old_notes],[age],[actions_08_oct],[jan_16_2025]
,[action_by_dt],[replied],[history])
      select 
[agency],[type],[area],[delegate],[status],first_reg
,[notes],[quality],[contact nm],[role],[phone],[facebook],[messenger]
,[preferred contact method],[email],[whatsapp]
,[viber],[website],[address]
,[notes_2],[old notes],[age],[actions 08-oct],[jan_16_2025]
,[action by dt],[replied],[history]
FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
         ''Excel 12.0;Database=', @file, ';HDR=YES'',
         ''SELECT * FROM [', @worksheet, '$', @range, ']'')
 WHERE [agency] IS NOT NULL;
   ');

      EXEC sp_log 1, @fn, '010: import sql:
', @sql;

      EXEC(@sql);

      DELETE FROM PropertySalesStaging WHERE [name] IS NULL AND Type  IS NULL AND area IS NULL;

      IF @display_tables = 1
         SELECT * FROM PropertySalesStaging;

      SELECT @rc = COUNT(*) FROM PropertySalesStaging;
      EXEC sp_log 1, @fn, '900: completed import, imported ',@rc, ' rows';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';

      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving ok imported ',@rc, ' rows';
   RETURN @rc;
END
/*
EXEC test.test_082_sp_import_propertySalesStaging;
EXEC test.test_078_sp_import_propertySales;
EXEC sp_import_propertySalesStaging;
SELECT * FROM PropertySalesStaging;

INSERT INTO PropertySalesStaging
(
[agency_nm],agencyType_nm,area_nm,delegate_nm,status_nm,first_reg
,[Notes],[Quality],[Contact_nm],[role],[phone],[facebook],[messenger]
,[preferred_contact_method],[email],[WhatsApp]
,[viber],[website],[Address]
,[Notes_2],[Old_Notes],[age],[Actions_08_OCT],[Jan_16_2025]
,[Action_By_dt],[Replied],[History])
      SELECT 
[agency],[Type],[Area],[Delegate],[Status],first_reg
,[Notes],[Quality],[Contact nm],[role],[phone],[facebook],[messenger]
,[preferred contact method],[email],[WhatsApp]
,[viber],[website],[Address]
,[Notes_2],[Old Notes],[age],[Actions 08-OCT],[Jan_16_2025]
,[Action By dt],[Replied],[History]
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
         'Excel 12.0;Database=D:\Dev\CRM\SQL\Tests\078_sp_import_property_sales\Property Sales 251002-1200.xlsx;HDR=YES',
         'SELECT * FROM [Resort Sale$A1:AC1000]')

*/

