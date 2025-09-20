SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Description: returns 1 row containing the
--              FK main details (not columns)
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 07-MAR-2025
-- =============================================
CREATE FUNCTION [dbo].[fnGetFk]( @fk_nm VARCHAR(60))
RETURNS @t TABLE
(
    fk_nm         VARCHAR(60)
   ,schema_nm     VARCHAR(60)
   ,f_table_nm    VARCHAR(60)
   ,p_table_nm    VARCHAR(60)
   ,is_disabled   BIT
)
AS
BEGIN
   INSERT INTO @t(fk_nm,schema_nm,f_table_nm,p_table_nm, is_disabled)
   SELECT fk_nm,schema_nm,f_table_nm,p_table_nm, is_disabled
   FROM fk_vw
   WHERE fk_nm LIKE @fk_nm OR @fk_nm IS NULL;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetFk('')

*/


GO
