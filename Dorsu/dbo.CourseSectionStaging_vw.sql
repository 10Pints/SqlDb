SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Description: Displays the Course section info
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 01-MAR-2025
-- =============================================
CREATE view .[dbo].[CourseSectionStaging_vw] as
SELECT TOP 1000 c.course_nm, s.section_nm, c.course_id as course_id, s.section_id
FROM CourseSection cs 
JOIN course c ON cs.course_id = c.course_id 
JOIN section s ON s.section_id = cs.section_id
ORDER BY c.course_nm, s.section_nm;
/*
SELECT * FROM CourseSectionStaging_vw;
*/


GO
