--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      15-Oct-2025
-- Rtn:              test.test_086_fnSplitQualifiedName
-- Description: main test routine for the dbo.fnSplitQualifiedName routine 
--
-- Tested rtn description:
-- splits a qualified rtn name
-- into a row containing the schema_nm and the rtn_nm
-- removes square brackets
--
-- RULES:
-- @qrn  schema   rtn
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
CREATE PROCEDURE test.test_086_fnSplitQualifiedName
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_086_fnSplitQualifiedName'

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup  ??
   EXEC test.hlpr_086_fnSplitQualifiedName '001','test.fnGetRtnNmBits','test','fnGetRtnNmBits';
   EXEC test.hlpr_086_fnSplitQualifiedName '002','a.b','a','b';
   EXEC test.hlpr_086_fnSplitQualifiedName '003','a.b.c','a','b.c';
   EXEC test.hlpr_086_fnSplitQualifiedName '004',null,null,null;
   EXEC test.hlpr_086_fnSplitQualifiedName '005','',null,null;
   EXEC test.hlpr_086_fnSplitQualifiedName '006','xyz','dbo','xyz';

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_086_fnSplitQualifiedName;
EXEC tSQLt.Run 'test.test_086_fnSplitQualifiedName';
EXEC tSQLt.RunAll;
*/