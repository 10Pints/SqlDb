-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
--
-- Description: splits a qualified table name
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
-- TESTS:  test_086_fnSplitQualifiedName
--
-- Changes:
-- 231117: handle [ ] wrappers
-- 240403: handle errors like null @qual_rtn_nm softly as per rules above
-- 241207: changed schema from test to dbo
-- 241227: default schema is now the schema found in the sys rtns for the given rtn in @qrn
--         will throw a div by zero error if PRE 02 violated
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitQualifiedTableName]
(
   @qrn VARCHAR(150) -- qualified routine name
)
RETURNS @t TABLE
(
    schema_nm  VARCHAR(50)
   ,table_nm     VARCHAR(100)
)
AS
BEGIN
   INSERT INTO @t(schema_nm, table_nm)
   SELECT schema_nm, rtn_nm
   FROM dbo.fnSplitQualifiedName(@qrn);

   RETURN;
END
/*
SELECT * FROM dbo.fnSplitQualifiedTableName('test.abc');
test_086_fnSplitQualifiedName
*/
