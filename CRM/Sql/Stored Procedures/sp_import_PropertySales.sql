-- =============================================
-- Author:      Terry Watts
-- Create date: 12-SEP-2025
-- Description:
-- Design:      EA:
-- Tests:
--
-- Preconditions:
-- Postconditions: POST01: following tables are populated:
--    PropertySalesStaging
--    PropertySales
--    Agency         merge
--    Contacts       merge
--    Delegate       merge
--    Status         merge ??
-- =============================================
CREATE PROCEDURE [dbo].[sp_import_PropertySales]
    @file            VARCHAR(100)
   ,@worksheet       VARCHAR(64)
   ,@range           VARCHAR(255)
   ,@display_tables  BIT         = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           VARCHAR(35)   = N'sp_import_property_sales'
      ,@sql          NVARCHAR(4000)
      ,@schema       VARCHAR(40)
      ,@table_nm     VARCHAR(60)
      ,@fld_ty       VARCHAR(25)
      ,@fld_id       INT
      ,@fld_nm       VARCHAR(50)
      ,@len          INT
  ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
   @file:          [', @file         ,']
   @worksheet:     [', @worksheet    ,']
   @range:         [',@range         ,']
   @display_tables:[',@display_tables,']
   ';
      EXEC sp_import_propertySalesStaging
          @file            = @file
         ,@worksheet       = @worksheet
         ,@range           = @range
         ,@display_tables  = @display_tables

      EXEC sp_log 1, @fn, '010: calling sp_migrate_PropertySales';

      EXEC sp_migrate_PropertySales @display_tables;
      EXEC sp_log 1, @fn, '900: completed processing loop';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';

      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving ok';
END
/*
EXEC test.test_078_sp_import_property_sales;
EXEC tSQLt.Run 'test.test_078_sp_import_property_sales';
*/

