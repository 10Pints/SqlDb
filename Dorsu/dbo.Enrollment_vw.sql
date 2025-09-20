SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 23-FEB-2025
-- Description: lists the students and their courses
-- =============================================================
CREATE VIEW [dbo].[Enrollment_vw]
AS
SELECT 
    enrollment_id
   ,e.student_id
   ,s.student_nm
   ,gender
   ,course_nm
   ,section_nm
   ,major_nm
   ,c.course_id
   ,e.section_id
   ,m.major_id
FROM Student s 
LEFT JOIN Enrollment e ON s  .student_id = e.student_id
LEFT JOIN Course  c   ON c  .course_id  = e.course_id
LEFT JOIN Section sec ON sec.section_id = e.section_id
LEFT JOIN Major m     ON m.major_id     = e.major_id
;
/*
SELECT * FROM Enrollment_vw
ORDER BY student_id, course_nm, section_nm
;
*/

GO
