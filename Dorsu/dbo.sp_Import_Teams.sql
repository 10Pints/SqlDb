SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================================
-- Description:      Imports Team members
-- Design:           EArtyryiryikrui
-- Tests:            test_017_sp_Import_Teams
-- Author:           Terry Watts
-- Create date:      24-MAR-2025
-- Preconditions:
-- PRE 01: Event table pop

-- Postconditions:
--
--                   POST02: TeamStaging, Team, TeamMembers pop
--                   POST03: any Student is only ever a member of 0 or 1 teams
--                   POST04: Minimum/max team member count chd
--                   POST05: @min_tm_mbr_cnt > 0
--                   POST06: @max_tm_mbr_cnt > min_tm_mbr_cnt
-- ===========================================================================
CREATE PROCEDURE [dbo].[sp_Import_Teams]
    @file            NVARCHAR(600)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@min_tm_mbr_cnt  INT
   ,@max_tm_mbr_cnt  INT
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_Teams'
      ,@team_nm   VARCHAR(50)
      ,@tab       NCHAR(1)    = NCHAR(9)
      ,@row_cnt   INT         = 0
      ,@cnt       INT         = 0
      ,@event_id  INT
   ;
   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [', @file          ,']
folder:        [', @folder        ,']
clr_first:     [', @clr_first     ,']
sep:           [', @sep           ,']
codepage:      [', @codepage      ,']
min_tm_mbr_cnt:[', @min_tm_mbr_cnt,']
max_tm_mbr_cnt:[', @max_tm_mbr_cnt,']
display_tables:[', @display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------
      -- POST01: Event table pop
      EXEC sp_assert_tbl_pop 'Event';
      -- POST04: @min_tm_mbr_cnt > 0
      EXEC sp_assert_less_than 0, @min_tm_mbr_cnt, ' POST04: @min_tm_mbr_cnt > 0';
      -- POST05: @max_tm_mbr_cnt > min_tm_mbr_cnt
      EXEC sp_assert_gtr_than_or_equal @max_tm_mbr_cnt, @min_tm_mbr_cnt, 'POST05: @max_tm_mbr_cnt > min_tm_mbr_cnt';

      ----------------------------
      -- ASSERTION Validation OK
      ----------------------------

      ----------------------------
      -- Setup
      ----------------------------
      DELETE FROM TeamMembersStaging;
      DELETE FROM TeamMembers;
      DELETE FROM Team;

      ----------------------------
      -- ASSERTION: Event found, TeamMembers, Team clrd
      ----------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: calling  sp_import_txt_file ''TeamStaging'', ''', @file, ''', @codepage=65001, @display_table=1;';

      EXEC @row_cnt = sp_import_txt_file
          @table           = 'TeamStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      --EXEC @row_cnt = sp_import_txt_file  'TeamStaging', @file, @codepage=65001, @display_table=@display_tables;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '020: populating the Team table';

      -- Copy to the main table: Teams
      INSERT INTO Team(team_id, team_nm, github_project, section_id, event_id, team_gc, team_url)
      SELECT team_id, team_nm, github_project, section_id, e.event_id, team_gc, team_url
      FROM
         TeamStaging ts 
         LEFT JOIN Event   e ON e.event_nm   = ts.event_nm
         LEFT JOIN section s ON s.section_nm = ts.section_nm
--       Left JOIN Course  c ON c.course_nm =  ts.course_nm
      ;

      IF @display_tables = 1
      BEGIN
         SELECT 'Team table';
         SELECT * FROM Team;
      END

      -- Fixup the team members:
      EXEC sp_log 1, @fn, '030: populating the TeamMembers table';
      INSERT INTO TeamMembersStaging(team_id, student_nm, student_id, is_lead, section_nm)
      SELECT team_id, [value], s.student_id, IIF(ordinal=1, 1,0), section_nm
      FROM TeamStaging ts CROSS APPLY STRING_SPLIT(members, ';', 1)
      LEFT JOIN Student s ON s.student_nm = [value]
      WHERE [value]<>''
      ;

      EXEC sp_log 1, @fn, '040: processing students names not found';
      SELECT * FROM TeamMembersStaging;

      ---------------------------------------------------------
      -- Ensure all student ids found
      ---------------------------------------------------------
      EXEC sp_log 2, @fn, '055: chking all student ids found ';

      IF EXISTS
      (
         SELECT 1 
         FROM TeamMembersStaging 
         WHERE student_id IS NULL
      ) THROW 50623, 'sp_Import_Teams: Not all students found in student table', 1;

      ---------------------------------------------------------
      -- ASSERTION all student ids found
      ---------------------------------------------------------

      IF EXISTS (SELECT 1 FROM TeamMembersStaging WHERE student_id IS NULL )
         EXEC sp_raise_exception 65000, @fn, 'failed: TeamMembersStaging student_nm column has erros, was not able to match all student nms to ids';

      EXEC sp_log 1, @fn, '070: popping  TeamMembers';

      INSERT INTO TeamMembers(team_id, student_nm, student_id, is_lead)
      SELECT team_id, student_nm, student_id, is_lead
      FROM TeamMembersStaging;

      IF @display_tables = 1
         SELECT * FROM TeamMembers;

      -------------------------------------------------------
      -- Check Postconditions
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '080: Check Postconditions';
      -- POST01: TeamStaging, Team, TeamMembers pop
      EXEC sp_assert_tbl_pop 'TeamStaging';
      EXEC sp_assert_tbl_pop 'Team';

      -- POST02: Student only member of 1 team
      -- chd by UQ on the TeamMember table
      -- POST03: Minimum team member count chkd
      EXEC sp_log 1, @fn, '090: Check POST03: Minimum';

      SELECT 
          @cnt     = COUNT(*)
         ,@team_nm = team_nm
      FROM TeamMembers tm JOIN Team t ON tm.team_id = t.team_id
      GROUP BY team_nm
      HAVING COUNT(*) < @min_tm_mbr_cnt
      ;

      IF @cnt IS NOT NULL AND @cnt> 0
         EXEC sp_raise_exception 56301, 'POST03: Min team ',@team_nm,' member count chk failed exp: ',@min_tm_mbr_cnt, ',  @cnt: ', @cnt;


      -- POST03: Max team member count chkd
      EXEC sp_log 1, @fn, '100: Check POST03: Max';
      SELECT @cnt = COUNT(*), @team_nm = team_nm
            FROM TeamMembers tm JOIN Team t ON tm.team_id = t.team_id
            GROUP BY team_nm
            HAVING COUNT(*) > @max_tm_mbr_cnt
            ;

      IF @cnt IS NOT NULL AND @cnt> 0
         EXEC sp_raise_exception 56301, 'POST03: Max team ',@team_nm,' member count chk failed: shld be < ', @max_tm_mbr_cnt;

      EXEC sp_log 1, @fn, '300: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC sp_Import_Teams
 @file           ='D:\Dorsu\Data\Teams.Teams.txt'
,@min_tm_mbr_cnt = 2
,@max_tm_mbr_cnt = 5
,@display_tables = 1
;

SELECT
team_nm, course_nm, section_nm, student_id, student_nm, is_lead, position, event_nm
FROM Team_vw WHERE Section_nm IN ('2B','2D') ORDER BY Section_nm, team_nm, is_lead DESC, student_nm;;

EXEC test.test_017_sp_Import_Teams;
EXEC tSQLt.Run 'test.test_017_sp_Import_Teams';
EXEC tSQLt.RunAll;
SELECT * FROM TeamMembersStaging where student_id IS NULL;
SELECT * FROM TeamStaging order by team_id;
SELECT * FROM dbo.fnGetTeamMembers('Team Albert& Friends');

EXEC sp_FindStudent2 'Francisco, Hanney';
EXEC sp_FindStudent2 'Liza';
EXEC sp_FindStudent2 'Jay Bee';
EXEC sp_FindStudent2 'Esperanza, Kaye';
EXEC sp_FindStudent2 'Dumandan, Jhonalyn';
EXEC sp_FindStudent2 'Maynagcot, Kristine';
EXEC sp_FindStudent2 'Vidal, Francine Mae';

EXEC sp_FindStudent2 'Balucanag, John Laurence';
EXEC sp_FindStudent2 'Floren, Jhelaisy Joy';
EXEC sp_FindStudent2 'Galladora, Jan Mayen';
EXEC sp_FindStudent2 'Masinaring, Geremiah';
EXEC sp_FindStudent2 'Alaba, Jake';
EXEC sp_FindStudent2 'Nierra, Michelle';
EXEC sp_FindStudent2 'Banzawan, Jamaica';
EXEC sp_FindStudent2 'Madanlo, Romel';

EXEC sp_FindStudent2 'Burgos, Christopher Jr. A..';
EXEC sp_FindStudent2 'Abelgas, Reymund';
EXEC sp_FindStudent2 'Bungaos, Jellian';
EXEC sp_FindStudent2 'Espe, Niño';
EXEC sp_FindStudent2 'Sarda, Jemar Lhoyd';
EXEC sp_FindStudent2 'Mondia, John Jefferson';
EXEC sp_FindStudent2 'Masungcad, Jennifer';
EXEC sp_FindStudent2 'Labajo, Rashelle';
EXEC sp_FindStudent2 'Lindo, Sheryl';
EXEC sp_FindStudent2 'Cubelo, Nicimel Grace';

EXEC sp_FindStudent2 'Pilapil, April';
EXEC sp_FindStudent2 'Labaco, Del Junry';
EXEC sp_FindStudent2 'Candia, Yzalyn';
EXEC sp_FindStudent2 'Jay, Bee';
EXEC sp_FindStudent2 'Labajo, Sunshine';
EXEC sp_FindStudent2 'Bentayao, Jezabel';

EXEC sp_FindStudent2 'Filtro, Rosheille';
EXEC sp_FindStudent2 'Gomez, Irene';
EXEC sp_FindStudent2 'Bongcaron, Lei heart';
EXEC sp_FindStudent2 'Bello, Glydel Jade';
EXEC sp_FindStudent2 'Sandayan, Stefhamel';
EXEC sp_FindStudent2 'Estopito, April';


EXEC sp_FindStudent2 'John Kenneth Gade'
EXEC sp_FindStudent2 'Ivan Vasay'
EXEC sp_FindStudent2 'Kissy Faith M. Candia'
EXEC sp_FindStudent2 'Leopoldo Dumadangon'
EXEC sp_FindStudent2 'Christian Jay Barbas'
EXEC sp_FindStudent2 'James Bernard Verdeflor'
EXEC sp_FindStudent2 'Richard Fuertes'
EXEC sp_FindStudent2 'Jomari Gamao'
EXEC sp_FindStudent2 'Rudelito Dongiapon'
EXEC sp_FindStudent2 'Jhon Ryan Pagantian'
EXEC sp_FindStudent2 'Sitti Monera F. Martin'
EXEC sp_FindStudent2 'Honey Jane P. Pangasate'
EXEC sp_FindStudent2 'Kyle Alonzo'
EXEC sp_FindStudent2 'Jemar Carlos'
EXEC sp_FindStudent2 'ALonzo'
EXEC sp_FindStudent2 'Rudelito Dongiapon'
SELECT * FROM TeamMembersStaging where student_id IS NULL;
*/

GO
