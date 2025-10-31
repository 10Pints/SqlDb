-- ===============================================================
-- Author:      Terry Watts
-- Create date: 17-JUN-2025
-- Description: generates the sql to check if every value 
--    in field @fld_nm of the table @q_table_nm
--    can be cast to the type @ty
-- Tests      : test_075_fnCrtFldNotNullSql
--
-- Postconditions: returns the check SQL for the given parameters
-- ===============================================================
CREATE FUNCTION [dbo].[fnCrtFldNotNullSql]
(
    @q_table_nm VARCHAR(60)
   ,@fld_nm     VARCHAR(40)
   ,@ty         VARCHAR(25)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE 
    @sql       NVARCHAR(4000)
   ,@schema_nm VARCHAR(50)
   ,@tbl_nm    VARCHAR(100)
   ;

   SELECT
       @schema_nm = schema_nm
      ,@tbl_nm    = rtn_nm
   FROM dbo.fnSplitQualifiedName(@q_table_nm);

   SET @sql = 
   CONCAT
   (
'IF NOT EXISTS
(
   SELECT 1 FROM [',@schema_nm,'].[',@tbl_nm,']
   WHERE TRY_CAST([',@fld_nm,'] AS ',@ty,') IS NULL
)
   SET @fld_ty = ''',@ty,'''
ELSE
   SET @fld_ty = NULL
;'
   );

   RETURN @sql;
END
/*
EXEC test.test_076_fnCrtFldNotNullSql;
*/
