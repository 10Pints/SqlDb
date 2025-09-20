SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE View [dbo].[FindStudentInfo_vw]
AS
SELECT TOP 10000 
   fsi.srch_cls, s.student_id, s.student_nm, s.gender, google_alias, course_nm, section_nm, major_nm, match_ty
FROM FindStudentInfo fsi 
LEFT JOIN  Student s on fsi.student_id = s.student_id
ORDER BY fsi.student_nm, course_nm, section_nm
;
/*
SELECT * FROM FindStudentInfo_vw;
*/

GO
