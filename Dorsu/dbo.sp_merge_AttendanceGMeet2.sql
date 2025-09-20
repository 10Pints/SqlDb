SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================
-- Author:      Terry Watts
-- Create date: 26 Apr 2025
-- Description: 
-- Design:      none
-- Tests:       indirect: sp_ImportAllGMeet2FilesInFolder
-- =======================================================
CREATE PROCEDURE [dbo].[sp_merge_AttendanceGMeet2]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn     VARCHAR(35) = 'sp_merge_AttendanceGMeet2'
   ,@cnt_1  INT
   ,@cnt_2  INT
   ,@diff   INT

   SELECT @cnt_1 = COUNT(*) FROM AttendanceGMeet2;
   EXEC sp_log 1, @fn ,'000: starting, initial count: ',@diff;

   MERGE AttendanceGMeet2 AS Target
   USING
   (
      SELECT s.student_id, s.student_nm, agms.google_alias, meet_st, joined, [stopped], duration, gmeet_id, [date], cls_st, c.course_nm, c.course_id, sec.section_nm, sec.section_id
      FROM AttendanceGMeet2Staging agms
      LEFT JOIN Student s   ON s  .student_nm = agms.student_nm
      LEFT JOIN Course  c   ON c  .course_nm  = agms.course_nm
      LEFT JOIN section sec ON sec.section_nm = agms.section_nm
   ) src
   ON Target.student_id = src.student_id
   WHEN NOT MATCHED BY Target THEN
      INSERT (    student_id,     student_nm,     google_alias, joined, [stopped], duration, cls_st, gmeet_id, [date], course_nm, course_id, section_nm, section_id)
      VALUES (src.student_id, src.student_nm, src.google_alias, joined, [stopped], duration, cls_st, gmeet_id, [date], course_nm, course_id, section_nm, section_id)
   ;

   SELECT @cnt_2 = COUNT(*) FROM AttendanceGMeet2;
   SET @diff = @cnt_2 - @cnt_1
   EXEC sp_log 1, @fn ,'999: leaving, merged', @diff,  ' files';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/

GO
