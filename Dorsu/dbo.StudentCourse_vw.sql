SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 23-FEB-2025
-- Description: lists the students and their courses
-- =============================================================
CREATE VIEW [dbo].[StudentCourse_vw]
AS
SELECT TOP 10000 s.student_id, s.student_nm, s.gender, e.course_nm, section_nm
FROM Student s
LEFT JOIN Enrollment_vw e  ON s.student_id   = e .student_id
--LEFT JOIN Section        sec ON sec.section_id = ss .section_id
--LEFT JOIN CourseSection  cs  ON cs.section_id  = sec.section_id
--LEFT JOIN Course         c   ON c.course_id    = cs .course_id
ORDER BY s.student_nm,course_nm
;
/*
SELECT * FROM StudentCourse_vw;
SELECT * FROM section
SELECT * FROM StudentSection
*/


GO
