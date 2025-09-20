SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- See also: fnIsTxtInt
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsInt]( @v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @s VARCHAR(1000) = TRY_CONVERT( VARCHAR(1000), @v);

   IF dbo.fnLen(@s) = 0 -- returns 0 if null or MT
      RETURN 0;

   RETURN iif(TRY_CONVERT(INT, @v) IS NULL, 0, 1);
END
/*
EXEC tSQLt.Run 'test.test_022_fnIsInt';
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[fnIsInt]', @trn=22, @ad_stp=1;
*/

GO
