SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================================
-- Function SC: <fn_nm>
-- Description: lists the students enrolled on a given course and optionally section
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      EA
-- Tests:       test.test001_fnListStudentsForcourse
-- Author:      Terry Watts
-- Create date: 23-Feb-2025
-- =====================================================================================
CREATE FUNCTION [dbo].[fnListStudentsForCourse](@course_section VARCHAR(100))
RETURNS @t TABLE
(
 course_nm  VARCHAR(20)
,section_nm VARCHAR(20)
,student_id VARCHAR(9)
,student_nm VARCHAR(50)
)
AS
BEGIN
   DECLARE
    @course_nm  VARCHAR(20)
   ,@section_nm VARCHAR(20)
   ;

   SELECT
       @course_nm  = schema_nm
      ,@section_nm = rtn_nm
   FROM dbo.fnSplitQualifiedName(@course_section)
   ;

   IF @course_nm = 'dbo'
   BEGIN
      SET @course_nm = @section_nm;
      SET @section_nm = NULL;
   END

   INSERT INTO @t(course_nm, section_nm, student_id,student_nm )
   SELECT TOP 10000 course_nm, section_nm, student_id,student_nm
   FROM   Enrollment_vw e
   WHERE  (course_nm  = @course_nm OR @course_nm   IS NULL)
   AND    (section_nm = @section_nm OR @section_nm IS NULL)
   ORDER BY course_nm, section_nm, student_nm
   ;

   RETURN;
END
/*
SELECT * FROM dbo.fnListStudentsForcourse('ITMSD4');
SELECT * FROM dbo.fnListStudentsForcourse('ITMSD3');
SELECT * FROM dbo.fnListStudentsForcourse('ITC130');

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test001_fnListStudentsForcourse;
*/

GO
