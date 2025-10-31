--=================================================================
-- Author:           Terry Watts
-- Create date:      13-Jun-2025
-- Rtn:              test.test_069_fnCrtTblSql
-- Description: main test routine for the dbo.fnCrtTblSql routine 
--
-- Tested rtn description:
-- creates the SQL to create a table
--              based on the input string
--              All fields are VARCHAR(MAX)
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    returns creat table SQL
--
-- Tests:
--=================================================================
CREATE PROCEDURE [test].[test_069_fnCrtTblSql]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_069_fnCrtTblSql'

   EXEC test.sp_tst_mn_st @fn;
   EXEC test.hlpr_069_fnCrtTblSql
       @tst_num      = '002'
      ,@inp_tbl_nm   = 'TestTable'
      ,@inp_fields   = ' Name 	 Type 	Area 	Delegate 	Status 	Quality 	Contact_nm 	Agnt_Comm_split 	Jan_20_2025 	Jan_16_2025 	Dec_09_2024 	preferred_contact_method 	phone 	Alt_phone 	Whatsapp 	Facebook 	messenger 	website 	email 	Address 	Notes 	Old_Notes 	date 	Actions_08-OCT 	date_2 	Actions_12-sep 	date_3 	date_4 	Actions_18-Aug 	Old_Status 	Action_By_dt 	Replied 	Visit 	 History '
      ,@exp_sql      = 'CREATE TABLE TestTable
(
    [Name] VARCHAR(8000)
   ,[Type] VARCHAR(8000)
   ,Area VARCHAR(8000)
   ,Delegate VARCHAR(8000)
   ,[Status] VARCHAR(8000)
   ,Quality VARCHAR(8000)
   ,Contact_nm VARCHAR(8000)
   ,Agnt_Comm_split VARCHAR(8000)
   ,Jan_20_2025 VARCHAR(8000)
   ,Jan_16_2025 VARCHAR(8000)
   ,Dec_09_2024 VARCHAR(8000)
   ,preferred_contact_method VARCHAR(8000)
   ,phone VARCHAR(8000)
   ,Alt_phone VARCHAR(8000)
   ,Whatsapp VARCHAR(8000)
   ,Facebook VARCHAR(8000)
   ,messenger VARCHAR(8000)
   ,website VARCHAR(8000)
   ,email VARCHAR(8000)
   ,[Address] VARCHAR(8000)
   ,Notes VARCHAR(8000)
   ,Old_Notes VARCHAR(8000)
   ,[date] VARCHAR(8000)
   ,Actions_08_OCT VARCHAR(8000)
   ,date_2 VARCHAR(8000)
   ,Actions_12_sep VARCHAR(8000)
   ,date_3 VARCHAR(8000)
   ,date_4 VARCHAR(8000)
   ,Actions_18_Aug VARCHAR(8000)
   ,Old_Status VARCHAR(8000)
   ,Action_By_dt VARCHAR(8000)
   ,Replied VARCHAR(8000)
   ,Visit VARCHAR(8000)
   ,History VARCHAR(8000)
);'
;


   EXEC test.hlpr_069_fnCrtTblSql
       @tst_num      = '001'
      ,@inp_tbl_nm   = 'TestTable'
      ,@inp_fields   = 'id, name,description, location'
      ,@exp_sql      = 'CREATE TABLE TestTable
(
    id VARCHAR(8000)
   ,[name] VARCHAR(8000)
   ,[description] VARCHAR(8000)
   ,[location] VARCHAR(8000)
);'
;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*

EXEC test.test_069_fnCrtTblSql;
EXEC tSQLt.RunAll;
*/