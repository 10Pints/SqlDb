SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:        Terry Watts
-- Create date:   28-Apr-2025
-- Description:   associate pics with students
--
-- Algorithm:
-- 1. user starts a db proc that gets the all the picture file names for a given folder
-- 2. system loads the picture file names from the folder into a staging table
-- 3. system then try to map the file name to the student
-- 4. this will not always be successful if the Find student algorithm cannot find it
--
-- Design:        EA Associate Photos with students
-- Tests:         test_052_sp_associate_student_pics
--
-- PRECONDITIONS: 
-- PRE01: folder exists (chkd)
-- POSTCONDITIONS:
-- POST 01:if error throws exception ELSE returns the count of files in the folder
-- POST 02 
-- POST 03 
-- POST 04 
-- POST 05 
-- =============================================
CREATE PROCEDURE [dbo].[sp_associate_student_pics]
    @folder    VARCHAR(500)
   ,@clr_first       BIT = 1
   ,@display_tables  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @fn           VARCHAR(35) = 'sp_associate_student_pics'
   ,@sql          VARCHAR(MAX)
   ,@url          VARCHAR(500)
   ,@filename     VARCHAR(100)
   ,@student_id   VARCHAR(9)
   ,@student_nm   VARCHAR(50)
   ,@srch_cls     VARCHAR(50) -- could be FB name, google alias, dorsu stud nm or id
   ,@ret          INT
   ,@file_cnt     INT
   ,@match_cnt    INT
   ,@i            INT         = 0 -- loop index
   ,@n            INT         = 0 -- loop index
   ,@delta        INT
   ,@status       INT
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000 sarting:
folder :       [', @folder        ,']
clr_first:     [', @clr_first     ,']
display_tables:[', @display_tables,']
';
   ------------------------------------------------
   -- Validate inputs
   ------------------------------------------------
      -- PRE01: folder exists (chkd)
      EXEC sp_assert_folder_exists @folder;

      ------------------------------------------------
      -- Process
      ------------------------------------------------
      IF @clr_first = 1
      BEGIN
         EXEC sp_log 1, @fn, '020 truncating the StudentPic table';
         TRUNCATE TABLE StudentPic;
      END

      -- 1. user starts a db proc that gets the all the picture file names for a given folder
      -- 2. system loads the picture file names from the folder into a staging table
      -- list all the files picture files -m the folder dir *.jp*,*.png, *.bmp
      EXEC sp_log 1, @fn, '030 getting the list of picture files in folder: ', @folder;
      EXEC @file_cnt = sp_getFilesInFolder @folder, '*.jp*', 0, 1; -- disp tbls, clr first
      EXEC @delta    = sp_getFilesInFolder @folder, '*.png', 1, 0; -- disp tbls, not clr first
      SET  @file_cnt = @file_cnt + @delta;
      EXEC sp_getFilesInFolder @folder, '*.bmp', 0, 0; -- disp tbls, not clr first
      SET  @file_cnt = @file_cnt + @delta;
      EXEC sp_log 1, @fn, '040 found ',@file_cnt,' picture files in ', @folder;
      SELECT *  FROM Filenames;

      --cursor loop
      DECLARE c1 CURSOR FOR
         SELECT [file]
         FROM Filenames
--         WHERE [file] like '%.txt'
         ORDER BY [file]
      ;

      OPEN c1;
      FETCH NEXT FROM c1 INTO @filename;
      SET @status =  @@fetch_status

      EXEC sp_log 1, @fn ,'050: B4 mn process loop, @status: ',@status;
      WHILE @@fetch_status <> -1
      BEGIN
         SET @i = @i + 1;
         -- pop the staging table
         SET @url = CONCAT(@folder, CHAR(92), @filename);
         SET @srch_cls = @filename;
         EXEC sp_log 1, @fn ,'060: top of mn process loop, file [', @i,']: [', @filename, '], @url:[',@url,']';

         -- extract student alais  
         -- examples: Albert Velasco 2.jpeg, Gella Marie Elayde Loguinsa.jpeg
         SET @n =  CHARINDEX('.', @filename);
         SET @srch_cls = SUBSTRING(@filename, 1, @n-1);
         EXEC sp_log 1, @fn ,'070: @srch_cls: [',@srch_cls, '], @n: ',@n;
         EXEC sp_assert_not_equal 0, @n, ' 075 error @n = 0';

         -- remove any numbers
         SET @srch_cls = dbo.Regex_Replace(@srch_cls, '[0-9]', '')
         EXEC sp_log 1, @fn ,'071: @srch_cls: [',@srch_cls, ']';

         -- 3. try to map each file name to the student
         EXEC @match_cnt =sp_FindStudent @srch_cls;
         EXEC sp_log 1, @fn ,'072: @match_cnt: [', @match_cnt, ']';
         --throw 50000, 'DEBUG', 1

         -- 4. this will not always be successful if the Find student algorithm cannot find it
         IF @match_cnt = 0
         BEGIN
            EXEC sp_log 1, @fn ,'080: failed to match [', @srch_cls, '] to a student';
         END

         IF @match_cnt = 1
         BEGIN
            SELECT
                @student_id = student_id
               ,@student_nm = student_nm
            FROM FindStudentInfo

            EXEC sp_log 1, @fn ,'090: found student: [', @srch_cls, ']-> ', @student_id, ' ', @student_nm;
            INSERT INTO StudentPic(student_id, student_nm, url)
            VALUES( @student_id, @student_nm, @url);

            --THROW 50000, 'DEBUG', 1;
         END

         IF @match_cnt > 1
         BEGIN
            EXEC sp_log 1, @fn ,'080: found multiple matches match [', @srch_cls, '] to a student';
         END

         FETCH NEXT FROM c1 INTO @filename;
      END -- while files loop

      EXEC sp_log 1, @fn ,'050:done mn loop';
      CLOSE c1;
      DEALLOCATE c1;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      CLOSE c1;
      DEALLOCATE c1;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, processed ', @file_cnt, ' files';
   RETURN @file_cnt;
END
/*
EXEC tSQLt.Run 'test.test_052_sp_associate_student_pics';
EXEC tSQLt.RunAll;
*/


GO
