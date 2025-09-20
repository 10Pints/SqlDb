SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================
-- Procedure:     sp_crt_attendance_col_map
-- Description:   populates the AttendanceDates table
-- Design:        EA: Model.Use Case Model.Attendance
-- Preconditions  Attendance table pop
-- Postconditions Post 01: AttendanceDates pop
-- Tests:         test_013_sp_pop_AttendanceDates
-- Author:        ME!
-- Create date:   18-MAR-2025
-- ================================================
CREATE PROCEDURE [dbo].[sp_pop_AttendanceDates]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn VARCHAR(35) = 'sp_pop_AttendanceDates'
   ;
   EXEC sp_log 1, @fn, '000: starting';

   --------------------------------------------------
   -- Setup
   --------------------------------------------------
   EXEC sp_log 1, @fn, '010: Setup';
   DELETE FROM AttendanceDates;

   --------------------------------------------------
   -- Process
   --------------------------------------------------
   EXEC sp_log 1, @fn, '020: process';

   -- Extract dates from the attendeance register header
   INSERT INTO AttendanceDates(ordinal, value)
   SELECT ordinal, value
   FROM AttendanceStagingHdr CROSS APPLY string_split(hdr, NCHAR(9), 1);

   SELECT  * FROM AttendanceDates;
   --------------------------------------------------
   -- Chk postconditions
   --------------------------------------------------
   EXEC sp_log 1, @fn, '030: Chk postconditions';

   -- Postconditions Post 01: AttendanceDates pop
   EXEC sp_assert_tbl_pop 'AttendanceDates';

   --------------------------------------------------
   -- Process complete
   --------------------------------------------------
   EXEC sp_log 1, @fn, '999: leaving OK';
END
/*
EXEC test.test_013_sp_pop_AttendanceDates;
EXEC tSQLt.Run 'test.test_013_sp_pop_AttendanceDates';


--EXEC test.sp__crt_tst_rtns 'dbo.sp_pop_AttendanceDates'
EXEC tSQLt.RunAll;EXEC tSQLt.Run 'test.test_013_sp_pop_AttendanceDates';
*/

GO
