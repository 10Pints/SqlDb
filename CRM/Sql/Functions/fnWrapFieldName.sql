-- =============================================
-- Author:      Terry Watts
-- Create date: 05-SEP-2025
-- Description: 
-- Design:      
-- Tests:       
-- =============================================
CREATE FUNCTION dbo.fnWrapFieldName( @fld_nm VARCHAR(128))
RETURNS VARCHAR(128)
AS
BEGIN
   RETURN iif(dbo.fnIsReservedWord(@fld_nm)=1,CONCAT('[', @fld_nm, ']'), @fld_nm);
END
/*
EXEC tSQLt.Run 'test.test_072_fnWrapFieldName';

EXEC tSQLt.RunAll;
*/
