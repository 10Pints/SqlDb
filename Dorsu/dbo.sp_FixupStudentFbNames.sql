SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:         Terry Watts
-- Create date:    27 April
-- Description:    
-- Design:         EA: Model.Use Case Model.FixupStudentFbNames
-- Preconditions:  
-- Postconditions: 
-- Tests:       
-- ============================================================
CREATE PROCEDURE [dbo].[sp_FixupStudentFbNames]
    @file            VARCHAR(MAX)
   ,@clr_first       BIT = 1
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35)    = N'sp_FixupStudentFbNames'
      ,@id           INT
      ,@row_cnt      INT
      ,@fb_nm        VARCHAR(50)
      ,@section_nm   VARCHAR(20)
   ;

   SET NOCOUNT ON;
   EXEC sp_log 1, @fn, '000:  starting:
file     :[', @file     ,']
clr_first:[',@clr_first ,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '010:  Validate initial state';
      EXEC sp_assert_file_exists @file;

      --------------------------------------
      -- Assertion: good to go
      --------------------------------------
      if @clr_first = 1
      BEGIN
         EXEC sp_log 1, @fn, '020:  clearing the FbNameMap table';
         DELETE FROM FbNameMap;
      END

      -- Import the fb name file to the FbMapStaging table
      EXEC sp_log 1, @fn, '030:  Import the fb name file to the FbMapStaging table';
      EXEC sp_Import_FbMapStaging @file;

      -- Iterate this table trying to find the student name based solely on the fb name and section
      EXEC sp_log 1, @fn, '040:  Iterate this table trying to find the student name based solely on the fb name and section';
      DECLARE my_cursor CURSOR FAST_FORWARD FOR 
         SELECT id, fb_nm, section_nm 
         FROM FBMapStaging;

      OPEN my_cursor;

      -- Fetch the first row
      FETCH NEXT FROM my_cursor INTO @id, @fb_nm, @section_nm;

      -- Loop through the rows
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Process the row
         DELETE FROM FindStudentInfo;

         EXEC sp_log 1, @fn, '050: Process the row: id: ',@id, ' fb_nm:[',@fb_nm,'] section_nm:[', @section_nm, ']';
         EXEC @row_cnt = sp_FindStudent @student_nm = @fb_nm, @section_nm=@section_nm, @display_rows=0;

         EXEC sp_log 1, @fn, '060: found ', @row_cnt, ' rows';

         EXEC sp_log 1, @fn, '070: If 0 rows found skip';

         WHILE 1=1
         BEGIN
            -- If 0 result pop empty found cols
            IF @row_cnt = 0
            BEGIN
               EXEC sp_log 1, @fn, '080: 0 row found pop empty found cols';
               THROW 5000, 'DEBUG', 1;
               INSERT INTO FbNameMap(fb_nm, section_nm)
               SELECT               @fb_nm, @section_nm
               BREAK;
            END

            -- If 1 result use it
            IF @row_cnt = 1
            BEGIN
               EXEC sp_log 1, @fn, '090: 1 row found pop it';
               --SELECT * FROM FindStudentInfo_vw;

               INSERT INTO FbNameMap(fb_nm, section_nm, student_id, student_nm, match_ty)
               SELECT               @fb_nm, section_nm, student_id, student_nm, match_ty
               FROM FindStudentInfo_vw;
               --THROW 5000, 'DEBUG', 1;
               BREAK;
            END

/*
            -- Else concat the found rows separating with a line feed character
             EXEC sp_log 1, @fn, '100: Else concat the found rows separating with a line feed character';
               INSERT INTO FbNameMap(fb_nm, candidates)
               SELECT               @fb_nm, string_agg(student_nm, ';')
               FROM FindStudentInfo_vw;
*/
             BREAK;
         END -- while 1=1

         -- When completed the iteration loop
         EXEC sp_log 1, @fn, '110: Finished fb name iteration loop';

         -- Display the list (FBNamemap table)
         EXEC sp_log 1, @fn, '120: Add these rows to the FBNameMap Table';

         -- Fetch the next row
         FETCH NEXT FROM my_cursor INTO @id, @fb_nm, @section_nm;
      END

      --------------------------------------
      -- Completed processing
      --------------------------------------
      -- Clean up
      CLOSE my_cursor;
      DEALLOCATE my_cursor;

      -- Display the map
      EXEC sp_log 1, @fn, '130: Display the FBNameMap Table'
      SELECT * FROM FbNameMap;
      EXEC sp_log 1, @fn, '900: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      -- Clean up
      CLOSE my_cursor;
      DEALLOCATE my_cursor;

      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999 leaving';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns 'sp_FixupStudentFbNames'
*/

GO
