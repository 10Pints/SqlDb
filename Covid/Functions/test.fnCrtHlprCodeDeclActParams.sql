SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 03-MAY-2024
-- Description: 
-- Creates the helper decl bloc for the act params output by teh teted rtn like:
--   ,@act_row_cnt     INT
--   ,@act_file_path   NVARCHAR(4000)            -- comma separated
--   ,@act_range       NVARCHAR(4000)            -- comma separated
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions: return table with the CoreParams
--
-- Called by: test.fnCrtHlprCodeDecl
-- ==================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeDeclActParams]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1)
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1           NCHAR(3) = '   '
   ,@tab2           NCHAR(6) = '      '
   ,@rtn_ty_code    NVARCHAR(2)
   ,@sc_fn_ret_ty   NVARCHAR(20)
   ,@ad_stp         BIT
   ,@max_prm_len    INT

    SELECT
       @rtn_ty_code  = rtn_ty_code
      ,@ad_stp       = ad_stp
      ,@sc_fn_ret_ty = sc_fn_ret_ty
      ,@max_prm_len  = max_prm_len
   FROM test.RtnDetails;

   IF @ad_stp = 1
      INSERT INTO @t (line) VALUES
      (CONCAT(@tab2, '-- fnCrtHlprCodeDeclActParams'))

  -- Create an ACT variable for both EXP and out params
   INSERT INTO @t (line)
   SELECT
       CONCAT
       (
          @tab2, ',@act_'
         ,dbo.fnPadRight(param_nm, @max_prm_len)
         ,' ', UPPER(type_nm)
         ,iif(is_out_prm_related = 1, CONCAT('= @inp_', param_nm), '') -- if out param then need to set the act to input value to supply to the teted rtn
       )
   FROM test.ParamDetails
   WHERE tst_ty='EXP';

   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeDeclActParams();
SELECT * FROM test.ParamDetails;
EXEC tSQLt.RunAll;
*/

GO
