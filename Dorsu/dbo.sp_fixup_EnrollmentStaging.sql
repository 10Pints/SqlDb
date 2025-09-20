SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Description: tidies up the StudentCourseStaging table
-- names - removes double spaces
-- Part of the data load
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 04-MAR-2025
-- PRECONDITIONS: none
-- POSTCONDITONS: StudentCourseStaging.student_nm has no double spaces
-- ====================================================================
CREATE PROCEDURE [dbo].[sp_fixup_EnrollmentStaging]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @fn VARCHAR(35) = 'sp_fixup_EnrollmentStaging'

   EXEC sp_log 1, @fn, '000: starting';
   UPDATE EnrollmentStaging SET student_nm = REPLACE(student_nm, '  ', ' ');
   UPDATE EnrollmentStaging SET student_nm = REPLACE(student_nm, 'Ã±', 'ñ');

   -- Caldoza , Psyche A.
   UPDATE EnrollmentStaging SET student_nm = REPLACE(student_nm, ' , ', ', ');
   UPDATE EnrollmentStaging SET student_nm = REPLACE(student_nm, ' ,', ', ');
   EXEC sp_log 1, @fn, '999: leaving: OK';
END
/*
SELECT * FROM EnrollmentStaging ORDER BY student_nm, course_nm;
EXEC sp_fixup_EnrollmentStaging
SELECT * FROM EnrollmentStaging ORDER BY student_nm, course_nm;
*/

GO
