SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================
-- Description: Performs the fixup for the AttendanceGMeetStagingimport
-- Design:      EA
-- Tests:       test_011_sp_ImportGMeetAttendance
-- Author:      Terry Watts
-- Create date: 14-Mar-2025
-- =====================================================================
CREATE PROCEDURE [dbo].[sp_fixup_AttendanceGMeetStaging]
    @course_nm     NVARCHAR(20)
   ,@section_nm    NVARCHAR(20)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_fixup_AttendanceGMeetStaging';

   EXEC sp_log 1, @fn, '000: starting
course_nm:    [',@course_nm    ,']
section_nm:   [',@section_nm   ,']
';

   BEGIN TRY
      -- Copy to the line to  candidate_nm column
      UPDATE AttendanceGMeetStaging SET candidate_nm = line;
      --------------------------------------------------
      -- Removing lines with no characters
      --------------------------------------------------
      EXEC sp_log 1, @fn, '010: removing timestamps';
      DELETE FROM AttendanceGMeetStaging
      WHERE dbo.Regex_IsMatch(candidate_nm,'[a-zA-Z]') = 0
      ;

      EXEC sp_log 1, @fn, '020: removed ', @@ROWCOUNT, ' timestamps';

      --------------------------------------------------
      -- Removing double quotes
      --------------------------------------------------
      EXEC sp_log 1, @fn, '030: removing double quotes';
      UPDATE AttendanceGMeetStaging SET candidate_nm = REPLACE(candidate_nm, '"', '') WHERE CHARINDEX('"', candidate_nm) > 0;
      EXEC sp_log 1, @fn, '040: removed ', @@ROWCOUNT, ' double quotes';

      --------------------------------------------------
      -- Removing lines without the word present
      --------------------------------------------------
      EXEC sp_log 1, @fn, '050: Removing lines withut the word present';
      DELETE FROM AttendanceGMeetStaging WHERE candidate_nm NOT LIKE '%present%'
      EXEC sp_log 1, @fn, '060: removed ', @@ROWCOUNT, ' lines without the word present';

      --------------------------------------------------
      -- Removing null lines
      --------------------------------------------------
      EXEC sp_log 1, @fn, '050: Removing lines withuut the word present';
      DELETE FROM AttendanceGMeetStaging WHERE candidate_nm IS NULL
      EXEC sp_log 1, @fn, '060: removed ', @@ROWCOUNT, ' NULL lines';

      --------------------------------------------------
      -- Removing present
      --------------------------------------------------
      EXEC sp_log 1, @fn, '070: Removing Removing the word present';
      UPDATE AttendanceGMeetStaging SET candidate_nm = REPLACE(candidate_nm, 'present', '') WHERE CHARINDEX('present', candidate_nm) > 0;
      EXEC sp_log 1, @fn, '080: removed ', @@ROWCOUNT, ' double quotes';

      --------------------------------------------------
      -- Removing combinations of endings like '-'
      --------------------------------------------------
      EXEC sp_log 1, @fn, '090: trimming combinations of [, -] present';
      UPDATE AttendanceGMeetStaging SET candidate_nm = TRIM(' -' FROM candidate_nm);
      EXEC sp_log 1, @fn, '100: removed ', @@ROWCOUNT, ' double quotes';

      ----------------------------------------------------------------
      -- Make sure the last character of the full name is not a comma
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '105: replacing end comma with . if it exists';
      UPDATE AttendanceGMeetStaging SET candidate_nm = CONCAT(TRIM(',' FROM candidate_nm), '.')
      WHERE RIGHT(candidate_nm, 1) = ',';
      EXEC sp_log 1, @fn, '100: update ', @@ROWCOUNT, ' ending commas';

      --------------------------------------------------
      -- Make sure the surname is followed by a comma
      -- First word is followed by
      --------------------------------------------------
       UPDATE AttendanceGMeetStaging 
       SET candidate_nm = dbo.Regex_Replace(candidate_nm, '^(\w+)([-,\s]+)(.*)', '$1, $3')
       FROM AttendanceGMeetStaging;

      ----------------------------------------------------------------
      -- fnCamelCase candidate_nm
      ----------------------------------------------------------------
       UPDATE AttendanceGMeetStaging 
       SET candidate_nm = dbo.fnCamelCase(candidate_nm)

       -- PRINT dbo.fnCamelCase('abGd Eefg');

      -- Matching name against the registered student List
      -- stage 1 : do a direct comparison
      EXEC sp_log 1, @fn, '110: Matching name against the registered student List';
      EXEC sp_log 1, @fn, '120: Matching name stage 1';

      UPDATE a
      SET 
          student_id = s.student_id
         ,student_nm = s.student_nm
         ,surname    = IIF(CHARINDEX(',', a.candidate_nm)>0, SUBSTRING(a.candidate_nm, 1, CHARINDEX(',', a.candidate_nm)-1), '????')
      FROM AttendanceGMeetStaging a
      LEFT JOIN Student s ON s.student_nm = a.candidate_nm;

      EXEC sp_log 1, @fn, '130: Matching name stage 2';
      SELECT * FROM AttendanceGMeet a;

   /*   SELECT * FROM AttendanceGMeetStaging a 
      JoIn Enrollment_vw e
      ON a.candidate_nm = e.student_nm
      */

      -- stage2: compare against surname and enrollment if of unique
      EXEC sp_log 1, @fn, '499: Completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '510: rethrowing exception';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving';
END
/*
EXEC test.test_011_sp_ImportGMeetAttendance;

EXEC tSQLt.Run 'test.test_011_sp_ImportGMeetAttendance';
EXEC tSQLt.RunAll;

EXEC sp_ImportGMeetAttendance 'D:\Dorsu\Data\Attendance 250314.txt';
SELECT * FROM AttendanceGMeet;
SELECT * FROM AttendanceGMeetStaging;
EXEC sp_fixup_AttendanceGMeetStaging;
SELECT * FROM AttendanceGMeetStaging;
*/
--Salminang, Irizgle C. - --

GO
