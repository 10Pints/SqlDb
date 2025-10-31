-- =============================================
-- Author:      Terry Watts
-- Create date: 9-SEP-2025
-- Description: 
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- =============================================
CREATE PROCEDURE [sp_crt_pop_ResortSalesRefData]
   @display_tables  BIT         = 1
AS
BEGIN
   SET NOCOUNT ON;
   EXEC sp_import_new_table_from_xl 'D:\Dev\Property\Data\PropertySales.xlsx', 'Lists', 'A2:A27', 'Country',  @display_tables;
   EXEC sp_import_new_table_from_xl 'D:\Dev\Property\Data\PropertySales.xlsx', 'Lists', 'B2:C10', 'Delegate', @display_tables;
   EXEC sp_import_new_table_from_xl 'D:\Dev\Property\Data\PropertySales.xlsx', 'Lists', 'D2:D50', 'Status',   @display_tables;
   EXEC sp_import_new_table_from_xl 'D:\Dev\Property\Data\PropertySales.xlsx', 'Lists', 'E2:E10', 'Area',     @display_tables;
   EXEC sp_import_new_table_from_xl 'D:\Dev\Property\Data\PropertySales.xlsx', 'Lists', 'F2:F15', 'Type',     @display_tables;
   EXEC sp_import_new_table_from_xl 'D:\Dev\Property\Data\PropertySales.xlsx', 'Lists', 'G2:G32', 'Action',   @display_tables;
END
/*
EXEC sp_Pop_ResortSalesRefData;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/
