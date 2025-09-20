SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================================================================================================
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- Description: Finds a student by likeness 
--              and populates the FindStudentInfo 
-- Design:      EA: Model.Use Case Model.Find student.Find student_ActivityGraph.Find student_ActivityGraph, Model.Conceptual Model.Findstudent
-- Tests:       test_039_spFindStudent
-- Postconditions:
-- POST 01:     Poplated FindStudentInfo with 0,1 or more rows: [student id student nm,gender, section, course, match ty]
-- =============================================================================================================================================
CREATE PROCEDURE [dbo].[sp_FindStudent]
--(
    @student_nm         VARCHAR(60)   = NULL  -- NULL for all students
   ,@gender             VARCHAR(20)   = NULL  -- NULL for all genders
   ,@section_nm         VARCHAR(20)   = NULL  -- NULL for all sections
   ,@course_nm          VARCHAR(60)   = NULL  -- NULL for all courses
   ,@major_nm           VARCHAR(10)   = NULL  -- NULL for all majors
   ,@match_ty           INT           = NULL  -- NULL for all match types
   ,@display_rows       BIT           = 1
--)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn               VARCHAR(35) = 'sp_FindStudent'
     ,@len              INT
     ,@pos              INT         = 0
     ,@cnt              INT
     ,@found            BIT         = 0
     ,@sep_ty           BIT         -- = 0: spc, 1: comma
     ,@cls1             VARCHAR(60)
     ,@cls2             VARCHAR(60)
     ,@nm_part_sql      VARCHAR(1000)
     ,@insert_cls       VARCHAR(1000)
     ,@from_cls         VARCHAR(20) = 'FROM Student_vw s'
     ,@where_cls        VARCHAR(1000)
     ,@filter_cls       VARCHAR(1000)
     ,@main_sql         VARCHAR(4000)
     ,@Line             VARCHAR(100)= REPLICATE('-', 100)
     ,@NL               CHAR(2)     = CHAR(13) + CHAR(10)
     ,@need_where_cls   BIT =1
     ,@sep_chr          CHAR(1)
   ;

   EXEC sp_log 1, @fn, '000 starting
    @student_nm :[',@student_nm,']
   ,@course_nm  :[',@course_nm ,']
   ,@section_nm :[',@section_nm,']
   ,@gender     :[',@gender    ,']
   ,@match_ty   :[',@match_ty  ,']
';

   SET @need_where_cls = 
   iif(@student_nm IS NULL AND @major_nm IS NULL AND @course_nm IS NULL AND @section_nm IS NULL AND @gender IS NULL, 0, 1);

   TRUNCATE TABLE FindStudentInfo;

   -- If no criteria

   IF @match_ty IS NULL SET @match_ty = 4;

   -- Trim the search clause
   SET @student_nm = dbo.fnTrim(@student_nm);

   IF @student_nm IS NOT NULL
   BEGIN
      SET @pos = CHARINDEX(',', @student_nm);
      IF @pos > 0
      BEGIN
         SET @pos = CHARINDEX(',', @student_nm);
         SET @sep_ty = 1; -- 1: comma
         SET @sep_chr= ',';
      END
      ELSE
         SET @sep_ty = 0; -- 0: spc
         SET @sep_chr= ' ';
   END

      ------------------------
   -- Assertion @sep_ty known
   ---------------------------
   WHILE 1=1
   BEGIN
      SET @insert_cls = CONCAT('INSERT INTO FindStudentInfo
      (        srch_cls    ,student_id ,student_nm ,gender, section_nm ,course_nm, major_nm, match_ty)
   SELECT ''', @student_nm,''',student_id, student_nm, gender, section_nm, courses, major_nm,' --, '    1  '
   );

      -- ASSERTION: @pre_cls needs the match_ty appending later

      -- Build the where clause
      SET @where_cls = iif(@student_nm IS NOT NULL, CONCAT( 'student_nm =''',@student_nm, '''', @NL), NULL);

      SET @filter_cls = 
      CONCAT
      (
       iif( @gender     IS NULL, '', CONCAT( iif(@student_nm IS NOT NULL,'AND ',''),' gender     LIKE ''%', @gender    , '%''', @NL))
      ,iif( @section_nm IS NULL, '', CONCAT( iif(@student_nm IS NOT NULL OR @gender IS NOT NULL,'AND ',''),' section_nm LIKE ''%', @section_nm, '%''', @NL))
      ,iif( @course_nm  IS NULL, '', CONCAT( iif(@student_nm IS NOT NULL OR @gender IS NOT NULL OR @section_nm IS NOT NULL,'AND ',''),' courses    LIKE ''%', @course_nm , '%''', @NL))
      ,iif( @major_nm   IS NULL, '', CONCAT( iif(@student_nm IS NOT NULL OR @gender IS NOT NULL OR @section_nm IS NOT NULL OR @course_nm IS NOT NULL,'AND ',''),' major_nm   LIKE ''%', @major_nm  , '%''', @NL))
      );

      --IF dbo.fnLen(@filter_cls)>0 SET @filter_cls = CONCAT('AND ',@filter_cls);
      --------------------------------------------------------------
      -- Do a type 1 search: exact match on student_nm and criteria
      --------------------------------------------------------------

      -- if no criteria
      exec sp_log 1, @fn, 15, ' @where_cls: [', @where_cls, '], @filter_cls:[',@filter_cls,']';

      SET @main_sql = 
      CONCAT
      (
          @insert_cls
         ,iif(@need_where_cls=1, '1', '0'), @NL
         ,@from_cls, @NL
         ,iif(@need_where_cls=1, CONCAT('WHERE', @NL, @where_cls, @filter_cls), '')
       );

      PRINT CONCAT(@NL,@Line, @NL);
      EXEC sp_log 1, @fn, '020: doing a type 1 search, @sql:', @NL
      , @main_sql, @NL;

      PRINT CONCAT(@Line, @NL);

      EXEC(@main_sql);
      UPDATE FindStudentInfo SET [sql] = @main_sql;

      IF @@ROWCOUNT > 0
      BEGIN
         EXEC sp_log 1, @fn, '030: found type 1: exact match, returning';
         BREAK;
      END

      -------------------------------------------
      -- Assertion type 1 search yielded no rows
      -------------------------------------------
      EXEC sp_log 1, @fn, '035: did not find an exact match';

      -------------------------------------------------
      -- Do a type 2 search:
      -------------------------------------------------
      -- do a search based on splitting the words in the name and doing an AND( a=b or a IS NULL) CNF connective
      SELECT @cnt = COUNT(*) FROM string_split(@student_nm, ',');

      ------------------------------------------------------------------------------
      -- Do a type 2 search: based on comma or spc sep if the search cls has parts
      ------------------------------------------------------------------------------

      IF @cnt > 0
      BEGIN
         -- Get the comma separated name parts and do a CNF filter on them
         ;WITH cte AS
         (
            SELECT CONCAT('%', dbo.fnTrim(value), '%') as cls
            FROM string_split(@student_nm, @sep_chr) AS cls
         )
         SELECT @nm_part_sql = 
         CONCAT
         (
            ' (student_nm LIKE ''', string_agg(cls, ''' AND student_nm LIKE '''), ''')', @NL
         )
         FROM cte
         ;
      END

      --SET @where_cls = iif(@student_nm IS NOT NULL, CONCAT( 'student_nm =''',@student_nm, '''', @NL), NULL);
      --SET @main_sql = CONCAT ( @insert_cls, '2', @NL, @from_cls, @NL, iif(@need_where_cls=1, CONCAT('WHERE', @NL), ''), @filter_cls, @nm_part_sql, @NL,  @filter_cls);
      SET @where_cls = iif(@student_nm IS NOT NULL, @nm_part_sql, '')
      SET @main_sql =
      CONCAT
      (
          @insert_cls
         ,iif(@need_where_cls=1, '2', '2'), @NL
         ,@from_cls, @NL
         ,iif(@need_where_cls=1, CONCAT('WHERE', @NL, @where_cls, @filter_cls), '')
       );

      PRINT CONCAT(@NL,@Line, @NL) ;

      EXEC sp_log 1, @fn, '040: doing a ty 2 search, @sql:', @NL, @main_sql, @NL;
      PRINT CONCAT(@NL,@Line);

      -----------------------------------------------
      EXEC(@main_sql);
      UPDATE FindStudentInfo SET [sql] = @main_sql;

      SET @cnt =  @@ROWCOUNT;
      EXEC sp_log 1, @fn, '050: found ',@cnt, ' rows using ty 2 search';

      IF @cnt> 0
      BEGIN
         EXEC sp_log 1, @fn, '060: found type 2 match';
         BREAK;
      END

      --------------------------------------------------
      -- Do a type 3 search: search based on student id
      --------------------------------------------------

      EXEC sp_log 1, @fn, '070: doing a type 3 search based on student id';
      SET @main_sql = CONCAT (@insert_cls, '3', @NL, @from_cls, @NL, ' WHERE', @NL,'student_id LIKE ''%',@student_nm,'%''');
      PRINT CONCAT(@NL,@Line, @NL);
      EXEC sp_log 1, @fn, '080: doing a ty 3 search, @sql:', @NL, @main_sql, @NL;
      PRINT CONCAT(@NL,@Line);

      -----------------------------------------------
      EXEC(@main_sql);

      UPDATE FindStudentInfo SET [sql] = @main_sql;

      SET @cnt =  @@ROWCOUNT;
      EXEC sp_log 1, @fn, '090: found ',@cnt, ' rows using ty 3 search';

      IF @cnt> 0
      BEGIN
         EXEC sp_log 1, @fn, '100: found type 3 match';
         BREAK;
      END

      ------------------------------------------------------------------------------------
      -- Do a type 4 search: based on first and last parts of the name igmnring initials.
      -- currently no other criteria used
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '110: doing a ty 4 search based on first AND last parts of the name ignoring initials';
      DECLARE
          @first_nm VARCHAR(500)
          ,@last_nm VARCHAR(500)
      ;

      SELECT
         @first_nm = first_nm
        ,@last_nm  = last_nm 
      FROM dbo.fnGetFirstLastWords(@student_nm, ' ');

      SET @main_sql = CONCAT
      (
'INSERT INTO FindStudentInfo
      (srch_cls   ,student_id, student_nm, gender, section_nm, course_nm, major_nm, match_ty)
SELECT student_nm, student_id, student_nm, gender, section_nm, courses  , major_nm, 4
FROM Student_vw
WHERE student_nm LIKE ''%',@first_nm,'%''
AND   student_nm LIKE ''%',@last_nm ,'%''
;'
      );
      PRINT CONCAT(@NL,@Line, @NL);
      EXEC sp_log 1, @fn, '120: doing a ty 4 search, @sql:', @NL, @main_sql, @NL;
      PRINT CONCAT(@NL,@Line);
      --DELETE FROM FindStudentInfo;
      EXEC(@main_sql);
      SET @cnt = @@ROWCOUNT;
      EXEC sp_log 1, @fn, '121: found ',@cnt, ' rows using ty 4 search';
      SELECT @cnt = COUNT(*) FROM FindStudentInfo;
      EXEC sp_log 1, @fn, '122: *** found ',@cnt, ' rows using ty 4 search';

      IF @cnt> 0
      BEGIN
         EXEC sp_log 1, @fn, '140: found type 4 match';
         BREAK;
      END

      ------------------------------------------------------------------------------------
      -- Do a type 5 search: based on first OR last parts of the name igmnring initials.
      -- currently no other criteria used
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '150: doing a ty 5 search based on first OR last parts of the name ignoring initials';

      SET @main_sql = CONCAT
      (
'INSERT INTO FindStudentInfo
      (srch_cls   ,student_id, student_nm, gender, section_nm, course_nm, major_nm, match_ty)
SELECT student_nm, student_id, student_nm, gender, section_nm, courses  , major_nm, 4
FROM Student_vw
WHERE student_nm LIKE ''%',@first_nm,'%''
OR   student_nm LIKE ''%',@last_nm ,'%''
;'
      );

      PRINT CONCAT(@NL,@Line, @NL);
      EXEC sp_log 1, @fn, '120: doing a ty 5 search, @sql:', @NL, @main_sql, @NL;
      PRINT CONCAT(@NL,@Line);
      EXEC(@main_sql);

      SET @cnt = @@ROWCOUNT;
      EXEC sp_log 1, @fn, '050: found ',@cnt, ' rows using ty 5 search';
      SELECT @cnt = COUNT(*) FROM FindStudentInfo;
      EXEC sp_log 1, @fn, '051: *** found ',@cnt, ' rows using ty 5 search';

      IF @cnt> 0
      BEGIN
         EXEC sp_log 1, @fn, '060: found type 5 match';
         BREAK;
      END

      ------------------------------------------------------------------------------------
      -- Not found
      ------------------------------------------------------------------------------------

      EXEC sp_log 3, @fn, '200: ', @student_nm, ' not found';
      INSERT INTO FindStudentInfo
             (srch_cls   ,  gender,  section_nm,  course_nm,  major_nm, match_ty)
      VALUES (@student_nm, @gender, @section_nm, @course_nm, @major_nm, -1)
      ;

      BREAK;
      END -- While 1=1

   /*
   SELECT s.student_id, s.student_nm, s.gender, google_alias, course_nm, section_nm, @major_nm, match_ty
   FROM FindStudentInfo fsi 
   JOIN Student s ON fsi.student_id = s.student_id 
   ORDER BY fsi.student_nm, course_nm, section_nm;
   */

   SELECT @cnt = COUNT(*) FROM FindStudentInfo;

   if @display_rows = 1
      SELECT * FROM FindStudentInfo

   EXEC sp_log 1, @fn, '999 leaving, found ',@cnt , ' rows';
   RETURN @cnt;
END
/*
Martin, Sitti Monera F.
EXEC sp_FindStudent 'Sitti Fernando Martin'
EXEC sp_FindStudent 'Sitti'
EXEC test.test_039_sp_FindStudent;
EXEC tSQLt.Run 'test.test_039_spFindStudent';
EXEC spFindStudent 'Estrera, Jeros Kent A.', NULL, NULL, NULL, NULL;
Pangasate, Honey Jane P.

*/

GO
