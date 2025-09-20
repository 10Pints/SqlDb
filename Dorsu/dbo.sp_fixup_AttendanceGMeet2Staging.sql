SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 01-APR 2025
-- Description: fixup rtn for sp_ImportAllAttendanceGMeet2
-- Design:      EA
-- Preconditions: 
--    PRE 01: AttendanceGMeet2Staging    pop chkd
--    PRE 02: AttendanceGMeet2StagingHdr pop chkd

-- Postconditions:
--    POST 01: AttendanceGMeet2Staging
-- Tests:       test_044_sp_fixup_AttendanceGMeet2';
-- ===============================================================
CREATE PROCEDURE [dbo].[sp_fixup_AttendanceGMeet2Staging]
AS
BEGIN
   DECLARE
       @fn              VARCHAR(35)= 'sp_fixup_AttendanceGMeet2Staging'
      ,@course_nm       NVARCHAR(20)
      ,@section_nm      NVARCHAR(20)
      ,@date            DATE
      ,@cls_st          NVARCHAR(4)
      ,@class_st_time   TIME

   SET NOCOUNT ON;

   BEGIN TRY
      EXEC sp_log 1, @fn ,'000: starting';

      EXEC sp_log 1, @fn ,'010: Validating chkd preconditions';
      -- Preconditions: PRE 01: AttendanceGMeet2Staging pop chkd
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2Staging';
      -- Preconditions: PRE 02: AttendanceGMeet2StagingHdr pop chkd
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2StagingHdr';
      EXEC sp_log 1, @fn ,'020: Validated chkd preconditions';

      -- Import  the headers into a separate table called AttendanceGMeet2StagingHdr
      EXEC sp_log 1, @fn ,'030: Fixup the AttendanceGMeet2 header into';

      --SELECT * FROM AttendanceGMeet2StagingHdr;

      SELECT
          @date      = [date]
         ,@cls_st    = cls_st
         ,@course_nm = course_nm
         ,@section_nm= section_nm
      FROM AttendanceGMeet2StagingHdr;

         EXEC sp_log 1, @fn, '040: hdr info:
   date          :[',@date      ,']
   cls_st        :[',@cls_st    ,']
   course_nm     :[',@course_nm ,']
   section_nm    :[',@section_nm,']
   ';

      EXEC sp_log 1, @fn ,'050: mapping google alias to studend ID';
      UPDATE AttendanceGMeet2Staging SET student_id = dbo.fnMapGoogleAlias2StudentId(google_alias);
      EXEC sp_assert_not_equal 0, @@ROWCOUNT, 'AttendanceGMeet2StagingHdr failed to map any google aliases to student ids'

      -- ASSERTION: Got the headers
      EXEC sp_log 1, @fn ,'060: ASSERTION: Got the headers';
      EXEC sp_log 1, @fn ,'070: UPDATEing AttendanceGMeet2Staging';

      -- pop the class details
      UPDATE AttendanceGMeet2Staging
      SET
          [date]     = h.[date]
         ,cls_st     = h.cls_st
         ,course_nm  = h.course_nm
         ,section_nm = h.section_nm
   --      ,student_id = dbo.fnMapGoogleNm2StudentID(participant_nm)
         ,student_nm = s.student_nm
      FROM
         AttendanceGMeet2Staging a JOIN AttendanceGMeet2StagingHdr h ON a.id>=h.id
         LEFT JOIN Student s ON s.student_id = a.student_id
         WHERE  s.student_id IS NOT NULL
      ;
      /*
      UPDATE AttendanceGMeet2Staging
      SET student_nm = s.student_nm
      FROM
         AttendanceGMeet2Staging a 
         LEFT JOIN Student s ON s.student_id = a.student_id
      */
      EXEC sp_log 1, @fn ,'080: UPDATEed AttendanceGMeet2Staging';
      --SELECT * FROM AttendanceGMeet2Staging;
      --THROW 50000, '*** DEBUG sp_fixup_AttendanceGMeet2Staging ***', 1;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, fn, 'Caught exception'
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 1, @fn ,'999: leaving: OK';
END
/*
EXEC test.test_044_sp_fixup_AttendanceGMeet2;
EXEC tSQLt.Run 'test.test_044_sp_fixup_AttendanceGMeet2';
EXEC tSQLt.RunAll;

SELECT * FROM AttendanceGMeet2;
*/

GO
