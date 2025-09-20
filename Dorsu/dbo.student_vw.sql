SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE VIEW [dbo].[student_vw] as
SELECT
       X.student_id
      ,X.student_nm
      ,X.gender
      ,X.google_alias
      ,X.FB_alias
      ,X.section_nm
      ,X.courses
      ,X.major_nm
      ,FORMAT(IIF(SUM(a.tot_classes) > 0, SUM(a.att)/SUM(a.tot_classes), 0), '00.00%') as attendance_pc
      ,SUM(a.tot_classes) as att_cnt
FROM
(
   SELECT
       s.student_id
      ,s.student_nm
      ,s.gender
      ,s.google_alias
      ,s.FB_alias
      ,e.section_nm
      ,string_agg(e.course_nm, ',') WITHIN GROUP (ORDER BY e.course_nm) AS courses
      ,e.major_nm
   FROM Student s
   LEFT JOIN Enrollment_vw e ON e.student_id = s.student_id
   GROUP BY s.student_id, s.student_nm, s.gender, s.google_alias, s.FB_alias, s.email
   , s.section_id, e.section_id, e.section_nm, e.major_nm
) X
LEFT JOIN AttendanceSummary_vw a ON a.student_id = X.student_id
GROUP BY X.student_id, X.student_nm, X.gender, X.google_alias, X.FB_alias, X.section_nm, X.courses, X.major_nm
;

/*
SELECT * FROM student_vw ORDER BY student_nm;
*/

GO
