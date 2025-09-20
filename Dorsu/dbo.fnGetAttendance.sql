SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================
-- Description: Returns the attendance record for the suppied parameters
-- Design: EA
-- Tests:  test_016_fnGetAttendance
-- Author: Terry Watts
-- Create date: 23-Mar-2025
-- ======================================================================
CREATE FUNCTION [dbo].[fnGetAttendance]
(
    @student_id  VARCHAR(9)
   ,@course_nm   VARCHAR(20)
   ,@section_nm  VARCHAR(20)
)
RETURNS @t TABLE
(
    [index]             INT
   ,student_id          VARCHAR(9)
   ,student_nm          VARCHAR(50)
   ,course_nm           VARCHAR(20)
   ,section_nm          VARCHAR(20)
   ,attendance_percent  VARCHAR(5)
   ,ordinal             INT
   ,[date]              DATE
   ,present             BIT
)
AS
BEGIN
   INSERT INTO @t
   (
--    [index]
   student_id
   ,student_nm
   ,course_nm
   ,section_nm
--   ,attendance_percent
--   ,ordinal
   ,[date]
   ,present
   )
   SELECT
--      [index]
       student_id
      ,student_nm
      ,course_nm
      ,section_nm
--      ,attendance_pc
--      ,ordinal
      ,[date]
      ,present
   FROM Attendance_vw
   WHERE
         (student_id = @student_id OR @student_id IS NULL)
     AND (course_nm  = @course_nm  OR @course_nm  IS NULL)
     AND (section_nm = @section_nm OR @section_nm IS NULL)
   ;

   RETURN;
END
/*
SELECT * FROM Attendance_vw WHERE student_id = '2023-1772'; -- Alcoser, Reallene R.

SELECT * FROM dbo.fnGetAttendance('2023-1772', 'GEC E2', NULL);
SELECT * FROM dbo.fnGetAttendance('2023-1772', 'GEC E3', NULL); -- no recs
SELECT * FROM dbo.fnGetAttendance('2018-0429', 'GEC E2', '2D');


EXEC test.hlpr_016_fnGetAttendance
    @tst_num                = '002'
   ,@display_tables         = 1
   ,@inp_student_id         = '2023-1772' -- Alcoser, Reallene R.
   ,@inp_course_nm          = NULL
   ,@inp_section_nm         = NULL
   ,@exp_row_cnt            = NULL
;
EXEC test.hlpr_016_fnGetAttendance
    @tst_num                = '001'
   ,@display_tables         = 1
   ,@inp_student_id         = NULL
   ,@inp_course_nm          = NULL
   ,@inp_section_nm         = NULL
   ,@exp_row_cnt            = NULL
;
EXEC test.hlpr_016_fnGetAttendance
    @tst_num                = '003'
   ,@display_tables         = 1
   ,@inp_student_id         = NULL
   ,@inp_course_nm          = NULL
   ,@inp_section_nm         = NULL
   ,@exp_row_cnt            = NULL
;

EXEC tSQLt.Run 'test.test_016_fnGetAttendance';
SELECT * FROM dbo.fnGetAttendance( NULL, NULL,NULL, NULL);
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
