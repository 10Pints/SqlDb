SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: 
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- =============================================
CREATE FUNCTION [dbo].[fnFindStudentsNotInTeams]
(
    @event_nm     VARCHAR(25)
   ,@course_nm    VARCHAR(20)
   ,@section_nm   VARCHAR(20)
)
RETURNS @t TABLE
(
    student_id   VARCHAR(9)
   ,student_nm   VARCHAR(50)
)
AS
BEGIN
   DECLARE @n INT

   INSERT INTO @t (student_id, student_nm)
   SELECT e.student_id, e.student_nm
   FROM Enrollment_vw e
   JOIN Student s ON e.student_id = s.student_id
   WHERE
       e.course_nm = @course_nm
   AND e.section_nm= @section_nm
   AND e.student_id NOT IN
   (
      SELECT student_id
      FROM Team_vw
      WHERE
          event_nm   = @event_nm
      AND course_nm  = @course_nm
      AND section_nm = @section_nm
   );

   RETURN;
END
/*
SELECT * FROM dbo.fnFindStudentsNotInTeams('GEC E2 Mini Presentation', 'GEC E2','2B');
SELECT * FROM dbo.fnFindStudentsNotInTeams('GEC E2 Mini Presentation', 'GEC E2','2D');

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
SELECT * FROM Team_vw;
*/

GO
