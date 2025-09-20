SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- Description: Finds a student by likeness
-- Design:      Uses the enrollment view
-- Tests:       test_024_sp_FindStudent2
-- =============================================
CREATE FUNCTION [dbo].[fnFindStudent2]
(
    @student_nm VARCHAR(60)
   ,@gender     VARCHAR(20)
   ,@course_nm  VARCHAR(20)
   ,@section_nm VARCHAR(20)
   ,@match_ty   INT         -- =NULL for all matches
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
 ,pos        INT
 ,cls1       VARCHAR(60)
 ,cls2       VARCHAR(60)
)
AS
BEGIN
   DECLARE
      @len     INT
     ,@pos     INT = 0
     ,@count   INT
     ,@srch_cls VARCHAR(60)
     ,@found   BIT = 0
     ,@cls1    VARCHAR(60)
     ,@cls2    VARCHAR(60)
   ;

   --@match_ty
   IF @match_ty IS NULL SET @match_ty = 4
   SET @srch_cls = dbo.fnTrim(@student_nm);

   -- First try shortening the search string from the right
   SET @len = dbo.fnLen(@student_nm);
   --WHILE @len > 4
   --BEGIN

   IF @srch_cls IS NOT NULL
   BEGIN
      SET @pos = CHARINDEX(' ', @srch_cls);
      IF @pos = 0 SET @pos = CHARINDEX(',', @srch_cls);
   END

   -- May be just single word no sep
   IF (@pos = 0 AND @student_nm IS NOT NULL)-- AND @match_ty >= 4
      BEGIN
      INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, pos, match_ty, cls1, cls2)--, course_nm, section_nm, major_nm, match_ty)
      SELECT         @srch_cls,student_id, student_nm, gender, course_nm, section_nm, major_nm, @pos, 4,      @cls1,@cls2
      FROM Enrollment_vw s
      WHERE
          (student_nm LIKE CONCAT( '%', @srch_cls, '%')  OR (@student_nm IS NULL))
      AND ((gender     = @gender    )                    OR (@gender     IS NULL))
      AND ((course_nm  = @course_nm )                    OR (@course_nm  IS NULL))
      AND ((section_nm = @section_nm)                    OR (@section_nm IS NULL))
      ;
      INSERT INTO @t(match_ty) VALUES (4);
      RETURN;
   END

   ---------------------------------------------------------------------------------
   --   ASSERTION: we have a multi part name with commas OR @student_nm IS NOT NULL
   ---------------------------------------------------------------------------------

   SET @cls1 = SUBSTRING(@srch_cls, 1, @pos-1);
   SET @cls2 = SUBSTRING(@srch_cls, @pos+1, 99);

   -- INSERT INTO @t(srch_cls, pos,cls1,cls2, student_nm)    VALUES(@srch_cls, @pos, @cls1, @cls2, @student_nm)   ;

   -- Type 1 match: match on both cls1 and cls2
   -- Always run this
   INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, pos, match_ty, cls1, cls2)--, course_nm, section_nm, major_nm, match_ty)
   SELECT         @srch_cls,student_id, student_nm, gender, course_nm, section_nm, major_nm, @pos, 1,      @cls1,@cls2
   FROM Enrollment_vw s
   WHERE
      ((student_nm LIKE CONCAT( '%', @cls1, '%') AND student_nm LIKE CONCAT( '%', @cls2, '%')) OR (@student_nm IS NULL))
      AND ((gender     = @gender    ) OR (@gender     IS NULL))
      AND ((course_nm  = @course_nm ) OR (@course_nm  IS NULL))
      AND ((section_nm = @section_nm) OR (@section_nm IS NULL))
      ;

   --  if found and match type = 1 EXACT
   IF (@match_ty = 1)
   BEGIN
      IF (@@ROWCOUNT  = 0)
      BEGIN
         INSERT INTO @t(match_ty) VALUES (1);
         RETURN;
      END
   END

   ---------------------------------------------------------------
   -- ASSERTION: not found an exact match
   ---------------------------------------------------------------

   -- Type 2 match on either cls1 or cls2
   INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm,  pos, match_ty, cls1, cls2)--, course_nm, section_nm, major_nm, match_ty)
   SELECT        @srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, @pos, 2,       @cls1, @cls2
   FROM Enrollment_vw s
   WHERE
       (
          (
             student_nm LIKE CONCAT( '%', @cls1, '%') OR (@student_nm IS NULL)
          )
          OR 
          (
             student_nm LIKE CONCAT( '%', @cls2, '%')
          )
       )
      AND ((gender     = @gender    ) OR (@gender     IS NULL))
      AND ((course_nm  = @course_nm ) OR (@course_nm  IS NULL))
      AND ((section_nm = @section_nm) OR (@section_nm IS NULL))
      ;

   IF (@match_ty = 2)
   BEGIN
      IF (@@ROWCOUNT  = 0)
         INSERT INTO @t(match_ty) VALUES (2);

      RETURN;
   END

   ---------------------------------------------------------------
   -- ASSERTION: not found a type 1 or 2 match
   ---------------------------------------------------------------

   INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, pos, match_ty, cls1, cls2)
   SELECT        @srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm,@pos, 3,       @cls1,@cls2
   FROM Enrollment_vw s
   WHERE
       (
             student_nm LIKE CONCAT( '%', @cls1, '%')
          OR student_nm LIKE CONCAT( '%', @cls2, '%')
          OR @student_nm IS NULL
       )
      AND ((gender     = @gender    ) OR (@gender     IS NULL))
      AND ((course_nm  = @course_nm ) OR (@course_nm  IS NULL))
      AND ((section_nm = @section_nm) OR (@section_nm IS NULL))
      ;

   SELECT @count = COUNT(*) FROM @t;

   IF (@match_ty = 3)
   BEGIN
      IF (@@ROWCOUNT  = 0)
         INSERT INTO @t(match_ty) VALUES (3);

      RETURN;
   END

   ---------------------------------------------------------------
   -- ASSERTION: not found an type 1,2,3 match
   ---------------------------------------------------------------

   -- if all else fails try the student id
   IF @count = 0 
      INSERT INTO @t(
        srch_cls
       ,student_id
       ,student_nm
       ,gender
       ,course_nm
       ,section_nm
       ,major_nm
       ,match_ty
      )
      SELECT
        @srch_cls
       ,student_id
       ,student_nm
       ,gender
       ,course_nm
       ,section_nm
       ,major_nm
       ,5
    FROM Enrollment_vw s
    WHERE s.student_id = @srch_cls

   IF (@@ROWCOUNT  = 0)
      INSERT INTO @t(match_ty) VALUES (5);

   RETURN;
END
/*
SELECT * FROM dbo.fnFindStudent2('John', NULL, NULL, NULL, NULL);
SELECT * FROM dbo.fnFindStudent2(NULL, NULL, NULL, NULL, NULL);
SELECT * FROM Student;
SELECT * FROM Enrollment_vw;
*/

GO
