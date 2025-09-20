SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 02-MAR-2025
-- Description: lists the students and their courses, sections
-- =============================================================
CREATE VIEW [dbo].[StudentSectionCourse_vw]
AS
SELECT s.student_id, student_nm, sec.section_nm, course_nm
FROM
             Enrollment     e
   LEFT JOIN Student        s   on s.  student_id = e.student_id
   LEFT JOIN Course         c   on c  .course_id  = e . course_id
   LEFT JOIN Section        sec on sec.section_id = e .section_id
   LEFT JOIN CourseSection  cs  on cs .section_id = sec.section_id
;
/*
SE
SELECT * FROM Student;
*/

GO
