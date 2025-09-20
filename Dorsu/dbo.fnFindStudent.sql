SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Function SC: <fn_nm>
-- Description: Finds a student by likenes
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 03-MAY-2023
-- =============================================
CREATE FUNCTION [dbo].[fnFindStudent]
(
    @student_nm VARCHAR(60)
   ,@course_nm  VARCHAR(20)
   ,@section_nm VARCHAR(20)
   ,@gender     VARCHAR(20)
)
RETURNS @t TABLE
(
  srch_cls   VARCHAR(60)
 ,student_id VARCHAR(9)
 ,student_nm VARCHAR(60)
 ,gender     CHAR(1)
 ,course_nm  VARCHAR(20)
 ,section_nm VARCHAR(20)
 ,major_nm   VARCHAR(20)
 ,match_ty   INT
)
AS
BEGIN
   DECLARE
      @len     INT
     ,@count   INT
     ,@srch    VARCHAR(60)
     ,@found   BIT = 0
   ;

   SET @student_nm = dbo.fnNormalizeNm(dbo.fnTrim(@student_nm));
   SET @srch = @student_nm;

   -- First try shortening the search string from the right
   SET @len = dbo.fnLen(@student_nm);
   --WHILE @len > 4
   --BEGIN
      SET @srch = CONCAT('%', dbo.fnTrim(@student_nm), '%')

      -- Type 1 match: exact match
      INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, match_ty)
      SELECT      @student_nm, student_id, student_nm, gender, course_nm, section_nm, major_nm, 1
      FROM Enrollment_vw v
      WHERE
             (student_nm = @student_nm OR @student_nm  IS NULL)
         AND (course_nm  = @course_nm  OR @course_nm  IS NULL)
         AND (section_nm = @section_nm OR @section_nm IS NULL)
         AND (gender     = @gender     OR @gender     IS NULL)
      ORDER BY student_nm
      ;

      -- Type 2 match: substring
      INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, match_ty)
      SELECT      @student_nm, student_id, student_nm, gender, course_nm, section_nm, major_nm, 2
      FROM Enrollment_vw v
      WHERE
         v.student_nm LIKE CONCAT('%',@student_nm,'%')
         AND (course_nm  = @course_nm  OR @course_nm  IS NULL)
         AND (section_nm = @section_nm OR @section_nm IS NULL)
         AND (gender     = @gender     OR @gender     IS NULL)
         AND v.student_id NOt IN  (SELECT student_id FROM @t)
      ORDER BY student_nm
      ;

      -- Type 3 match: surname match
      IF CHARINDEX(',',@student_nm) > 0
      BEGIN
         DECLARE @surname VARCHAR(20);
         SET @surname = SUBSTRING(@student_nm, 1, CHARINDEX(',', @student_nm)-1);

         INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, match_ty)
         SELECT @student_nm, student_id, student_nm, gender, course_nm, section_nm, major_nm, 3
         FROM Enrollment_vw v
         WHERE
            SUBSTRING(v.student_nm, 1, CHARINDEX(',', v.student_nm)-1) LIKE CONCAT('%',@surname,'%')
            AND (course_nm  = @course_nm  OR @course_nm  IS NULL)
            AND (section_nm = @section_nm OR @section_nm IS NULL)
            AND (gender     = @gender     OR @gender     IS NULL)
            AND v.student_id NOt IN  (SELECT student_id FROM @t)
         ORDER BY student_nm
         ;
/*
         -- Try searching on the first 3 chars of the first word in the student name
         -- and the first 3 chars of the last word in the student name
         -- and also the first 3 letters of the LAST name if course or section is specified
         -- when we have 3 or more chars in the name
         IF (@course_nm IS NOT NULL OR @section_nm IS NOT NULL) AND @len >2
         BEGIN
            INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, match_ty)
            SELECT @student_nm, student_id, student_nm, gender, course_nm, section_nm, major_nm, 3
            FROM Enrollment_vw v
            WHERE
              (
                 student_nm LIKE CONCAT(SUBSTRING(@student_nm,1,3),'%')
              OR student_nm LIKE CONCAT(SUBSTRING(@student_nm, dbo.fnLastIndexOf(' ',@student_nm)+1,3),'%')
              )
              AND (course_nm = @course_nm  OR (@course_nm  IS NULL AND @section_nm IS NOT NULL))
              AND (section_nm= @section_nm OR (@section_nm IS NULL AND @course_nm  IS NOT NULL))
            ;
         END
*/
      END
   RETURN;
END
/*
EXEC sp_FindStudent NULL;
SELECT * FROM dbo.fnFindStudent('Mangubat, Jezryne Kaeser Duane B.', NULL, NULL, NULL );
SELECT * FROM dbo.fnFindStudent('Mangubat', NULL, NULL, NULL );
SELECT * FROM dbo.fnFindStudent('Gubalane');
SELECT * FROM dbo.fnFindStudent('Ganggangan');
SELECT * FROM dbo.fnFindStudent('John Jefferson Mondia');
SELECT * FROM dbo.fnFindStudent('Kaeser Mangubat');
SELECT * FROM dbo.fnFindStudent('Kissy Gubalane');
SELECT * FROM dbo.fnFindStudent('Kristana Ceralde Ganggangan');
SELECT * FROM dbo.fnFindStudent('Labajo, Rashelle M. - Present');
SELECT * FROM dbo.fnFindStudent('Labajo, Sunshine C. - Present');
SELECT * FROM dbo.fnFindStudent('Lagbas, Cleo Camille M.');
*/

GO
