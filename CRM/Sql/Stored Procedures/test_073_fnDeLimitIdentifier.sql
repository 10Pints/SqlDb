--=========================================================================
-- Author:           Terry Watts
-- Create date:      16-Jun-2025
-- Rtn:              test.test_073_fnDeLimitIdentifier
-- Description: main test routine for the dbo.fnDeLimitIdentifier routine 
--
-- Tested rtn description:
-- delimits identifier  if necessary
-- Design:
-- Tests:
--=========================================================================
CREATE PROCEDURE [test].[test_073_fnDeLimitIdentifier]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_073_fnDeLimitIdentifier'

   EXEC test.sp_tst_mn_st @fn;

   EXEC test.hlpr_073_fnDeLimitIdentifier
       @tst_num            = '001'
      ,@inp_q_id           = NULL
      ,@exp_out_val        = NULL
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC test.hlpr_073_fnDeLimitIdentifier
       @tst_num            = '002'
      ,@inp_q_id           = ''
      ,@exp_out_val        = ''
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC test.hlpr_073_fnDeLimitIdentifier
       @tst_num            = '003'
      ,@inp_q_id           = 'User'
      ,@exp_out_val        = '[User]'
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC test.hlpr_073_fnDeLimitIdentifier
       @tst_num            = '004'
      ,@inp_q_id           = 'int.User'
      ,@exp_out_val        = '[int].[User]'
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC test.hlpr_073_fnDeLimitIdentifier
       @tst_num            = '005'
      ,@inp_q_id           = 'db.int.User'
      ,@exp_out_val        = 'db.[int].[User]'
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC test.hlpr_073_fnDeLimitIdentifier
       @tst_num            = '006'
      ,@inp_q_id           = 'db.dbo.Enrollment Staging'
      ,@exp_out_val        = 'db.dbo.[Enrollment Staging]'
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC test.hlpr_073_fnDeLimitIdentifier
       @tst_num            = '007'
      ,@inp_q_id           = 'db.dbo.[Enrollment Staging]'
      ,@exp_out_val        = 'db.dbo.[Enrollment Staging]'
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;


   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_073_fnDeLimitIdentifier';
*/