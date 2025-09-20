SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- Author: Terry Watts
-- Date:   25-Apr-2025
-- Description: returns teh sekected row from the FindStudentInfo_vw
-- 
-- 
CREATE FUNCTION [dbo].[fnFindStudentInfo](@student_id varchar(9))
RETURNS @t TABLE
(
	student_id     VARCHAR(9) NOT NULL,
	student_nm     VARCHAR(50) NULL,
	gender         CHAR(1) NULL,
	google_alias   VARCHAR(50) NULL,
	fb_alias       VARCHAR(50) NULL,
	email          VARCHAR(30) NULL,
	photo_url      VARCHAR(150) NULL,
	srch_cls       VARCHAR(60) NULL,
	section_nm     VARCHAR(20) NULL,
	course_nm      VARCHAR(20) NULL,
	major_nm       VARCHAR(20) NULL,
	match_ty       INT NULL
)
AS
BEGIN
INSERT INTO @t(student_id, student_nm, gender, google_alias, srch_cls,section_nm, course_nm, major_nm, match_ty)
   SELECT      student_id, student_nm, gender, google_alias, srch_cls,section_nm, course_nm, major_nm, match_ty
   FROM FindStudentInfo_vw
   WHERE student_id LIKE CONCAT('%', @student_id, '%');
   RETURN;
END
/*
SELECT * FROM dbo.fnFindStudentInfo(NULL)
*/

GO
