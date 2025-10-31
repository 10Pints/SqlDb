--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      15-Oct-2025
-- Rtn:              test.hlpr_087_fnSplitQualifiedTableName
-- Description: test helper for the dbo.fnSplitQualifiedTableName routine tests 
--
-- Tested rtn description:
-- splits a qualified table name
-- into a row containing the schema_nm and the table_nm
-- removes square brackets
--
-- RULES:
-- @qrn  schema   table
-- a.b   a        b
-- a     dbo      a
-- NULL  null     null
-- ''    null     null
--
-- Preconditions
-- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
--          but differnt schema then raise div by zero exception

-- Postconditions:
-- Post 01: if schema is not specifed then get it from the sys rtns PROVIDED ONLY ONE rtn named the @rtn_nm
--
-- Changes:
-- 231117: handle [ ] wrappers
-- 240403: handle errors like null @qual_rtn_nm softly as per rules above
-- 241207: changed schema from test to dbo
-- 241227: default schema is now the schema found in the sys rtns for the given rtn in @qrn
--         will throw a div by zero error if PRE 02 violated
--=============================================================================================================
CREATE PROCEDURE [test].[hlpr_087_fnSplitQualifiedTableName]
    @tst_num                 VARCHAR(50)
   ,@inp_qrn                 VARCHAR(75)
   ,@exp_schema_nm           VARCHAR(50)     = NULL
   ,@exp_tbl_nm              VARCHAR(100)    = NULL

AS
BEGIN
   DECLARE
    @fn                      VARCHAR(35)    = N'hlpr_087_fnSplitQualifiedTableName'
   ,@error_msg               VARCHAR(1000)
   ,@act_row_cnt             INT
   ,@act_schema_nm           VARCHAR(50)
   ,@act_tbl_nm              VARCHAR(100)
   ,@act_ex_num              INT
   ,@act_ex_msg              VARCHAR(500)

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num           :[', @tst_num           ,']
inp_qrn           :[', @inp_qrn           ,']
exp_schema_nm     :[', @exp_schema_nm     ,']
exp_tbl_nm        :[', @exp_tbl_nm        ,']
';

      EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.fnSplitQualifiedTableName';
      SELECT
          @act_schema_nm = schema_nm
         ,@act_tbl_nm    = table_nm
      FROM dbo.fnSplitQualifiedTableName(@inp_qrn);

      EXEC sp_log 1, @fn, '020: returned from dbo.fnSplitQualifiedName:
act schema_nm:[',@act_schema_nm,']
act_tbl_nm   :[',@act_tbl_nm   ,']
';
      EXEC sp_log 1, @fn, '020: returned from dbo.fnSplitQualifiedTableName';

      -- TEST:
      EXEC sp_log 2, @fn, '080: running tests   ';
      EXEC tSQLt.AssertEquals @exp_schema_nm, @act_schema_nm,'088 schema_nm';
      EXEC tSQLt.AssertEquals @exp_tbl_nm   , @act_tbl_nm   ,'089 tbl_nm';

      ------------------------------------------------------------
      -- Passed tests
      ------------------------------------------------------------

      EXEC sp_log 1, @fn, '990: all subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC test.sp_tst_hlpr_hndl_failure;
      THROW;
   END CATCH

   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_087_fnSplitQualifiedTableName';
*/