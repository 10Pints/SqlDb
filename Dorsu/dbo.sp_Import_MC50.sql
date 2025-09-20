SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Author:       Tewrry Watts
-- Create date:  17-May-2025
-- Description:  Imports the Classschedule table from a tsv
-- Design:       EA
-- Tests:        test_062_sp_Import_MC50
-- Preconditions: 
-- Postconditions: 
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_MC50]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn           VARCHAR(35) = 'sp_Import_MC50'
      ,@tab          NCHAR(1)=NCHAR(9)
      ,@nl           NCHAR(1)=NCHAR(13)
      ,@row_cnt      INT = 0
      ,@sql          VARCHAR(8000)
      ,@answer_str   VARCHAR(8000)
      ,@max_score    FLOAT
   ;

   EXEC sp_log 1, @fn, '000: starting
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY

      IF @folder IS NOT NULL
         SET @file = CONCAT(@folder, '\', @file);

      IF @clr_first = 1
         TRUNCATE TABLE MC50_staging;

      -----------------------------------------------
      -- Load the staging table
      -----------------------------------------------

      SELECT @sql = CONCAT('BULK INSERT MC50_staging
FROM ''', @file, '''
WITH (
    FORMATFILE = ''D:\Dorsu\Data\MC50.fmt''
);'
);

      EXEC sp_log 1, @fn, '010: SQL ', @nl, @sql;
      EXEC (@sql);
      SELECT @row_cnt = COUNT(*) FROM MC50_staging;
      EXEC sp_log 1, @fn, '020: imported ', @row_cnt,  ' rows';

      If @display_tables = 1
         SELECT * FROM MC50_staging;

      -----------------------------------------------
      -- Pop the answer table
      -----------------------------------------------
      EXEC sp_log 1, @fn, '030: pop answer table ';
      SELECT @answer_str = SUBSTRING(staging, CHARINDEX('Answer', staging)+7, 8000)
      FROM MC50_staging
      WHERE id = 2;

      EXEC sp_log 1, @fn, '040: @answer_str ', @answer_str;
      SELECT @answer_str as answers;
      TRUNCATE TABLE MC50_answers;

      INSERT INTO MC50_answers(ordinal, answer)
      SELECT ordinal, TRIM(value)
      FROM string_split(@answer_str, @tab, 1);

      UPDATE MC50_answers
      SET answer = dbo.fnTrim(answer);

      If @display_tables = 1
         SELECT * FROM MC50_answers;

      -----------------------------------------------
      -- Pop the student answers
      -----------------------------------------------
      EXEC sp_log 1, @fn, '050: populating MC50_StudentAnswer table';
      TRUNCATE TABLE MC50_StudentAnswer;

      INSERT INTO MC50_StudentAnswer(student_id, ordinal, answer)
      SELECT     student_id, b.ordinal,TRIM(b.answer)
      FROM MC50_staging a CROSS APPLY dbo.fnSplitMC50Row(a.staging) b
      WHERE a.id>4;

      If @display_tables = 1
         SELECT * FROM MC50_studentAnswer;

      -----------------------------------------------
      -- Score the answers
      -----------------------------------------------
      EXEC sp_log 1, @fn, '060: Score the answers';

      -- Get the max score
      SELECT @max_score = SUM(dbo.fnScoreMC50Answer(answer, answer, 0.2))
      FROM MC50_Answers;

      UPDATE MC50_StudentAnswer
      SET score = dbo.fnScoreMC50Answer(e.answer, a.answer, 0.2)
      FROM MC50_StudentAnswer a JOIN MC50_Answers e ON a.ordinal = e.ordinal
      ;

      IF @display_tables = 1
         SELECT * FROM MC50_StudentAnswer_vw;

      IF EXISTS
      (
         SELECT 1
         FROM MC50_StudentAnswer
         WHERE score < -10.0 OR score > 10.0
      )
      BEGIN
         --EXEC sp_log 4, @fn, '070: ERROR bad character in question or answer @max_score: ',@max_score;
         SELECT * FROM MC50_StudentAnswer_vw
         WHERE score <-10.0 OR score > 10.0;
         THROW 51005, '080: ERROR bad character in score', 1;
      END

      -----------------------------------------------
      -- Total the scores for each student
      -----------------------------------------------
      EXEC sp_log 1, @fn, '090: Total the scores for each student, @max_score= ',@max_score;
      TRUNCATE TABLE MC50_scores;

      INSERT INTO MC50_scores(student_id, score)
      SELECT student_id, ROUND(SUM(score) / @max_score * 100.0, 2)
      FROM MC50_studentAnswer
      GROUP BY student_id;

      --EXEC sp_log 1, @fn, '060: Score the answers';

      If @display_tables = 1
         SELECT * FROM MC50_scores_vw ORDER BY score DESC;

      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
END
/*
EXEC test.test_062_sp_Import_MC50;
   Answer C AC BCE CE AC DE BCD DE ABCE CE AE CE AE E BCE AC D ABCDE A C ABC BC ACD C BCE C BCE E BCDE BCE ACD BDE ACD BC A BCD A BCE BCD BCE BE C AC BCE BCD BCE ACE BDE ABD BC 
EXEC tSQLt.Run 'test.test_062_sp_Import_MC50';
EXEC sp_importAllStudentCourses;
 C AC BCE CE AC DE BCD DE ABCE CE AE CE AE E BCE AC D ABCDE A C ABC BC ACD C BCE C BCE E BCDE BCE ACD BDE ACD BC A BCD A BCE BCD BCE BE C AC BCE BCD BCE ACE BDE ABD BC 
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_Import_MC50]';
BC --
BC --
*/

GO
