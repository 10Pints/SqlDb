SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================
-- Description: Displays the student section info
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 03-MAR-2025
-- ===============================================
CREATE view .[dbo].[StudentSectionStaging_vw] as
SELECT s.student_nm, s.student_id, c.course_nm, c.course_id, sec.section_nm, sec.section_id
FROM StudentCourseStaging scs
JOIN Student s   ON s.student_id = scs.student_id
JOIN Course  c   ON c.course_nm   =  scs.course_nm
JOIN Section sec ON sec.section_nm = scs.section_nm
/*
SELECT * FROM StudentSectionStaging_vw ORDER BY student_nm, course_nm, section_nm;
*/


GO
