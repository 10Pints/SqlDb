SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the Event table from a tsv
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 24-Mar-2025
-- Preconditions: 
-- Postconditions: TeamMembers, Team tables will be clrd
--                 Event will be populated
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Event]
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
       @fn        VARCHAR(35) = 'sp_Import_Event'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0


   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      --Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      --setup
      ----------------------------------------------------------------
      IF dbo.fnFkExists('FK_TeamMembers_Team') = 1 ALTER TABLE TeamMembers DROP CONSTRAINT FK_TeamMembers_Team;
      IF dbo.fnFkExists('FK_Team_Event')       = 1 ALTER TABLE Team        DROP CONSTRAINT FK_Team_Event;

      TRUNCATE TABLE TeamMembers;
      TRUNCATE TABLE Team;
      TRUNCATE TABLE [Event];

      ----------------------------------------------------------------
      --Import text file
      ----------------------------------------------------------------

      EXEC @row_cnt = sp_import_txt_file
          @table           = 'Event'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
            ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      ALTER TABLE TeamMembers WITH CHECK ADD CONSTRAINT FK_TeamMembers_Team FOREIGN KEY(team_id) REFERENCES Team (team_id);
      ALTER TABLE TeamMembers CHECK CONSTRAINT FK_TeamMembers_Team;
      ALTER TABLE Team WITH CHECK ADD CONSTRAINT FK_Team_Event FOREIGN KEY(event_id)REFERENCES Event (event_id)
      ALTER TABLE Team CHECK CONSTRAINT FK_Team_Event;

      EXEC sp_log 1, @fn, '399: finished importing file: ',@file,'';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      ALTER TABLE TeamMembers WITH CHECK ADD CONSTRAINT FK_TeamMembers_Team FOREIGN KEY(team_id) REFERENCES Team (team_id);
      ALTER TABLE TeamMembers CHECK CONSTRAINT FK_TeamMembers_Team;
      ALTER TABLE Team WITH CHECK ADD CONSTRAINT FK_Team_Event FOREIGN KEY(event_id)REFERENCES Event (event_id)
      ALTER TABLE Team CHECK CONSTRAINT FK_Team_Event;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from',@file;
END
/*
EXEC sp_Import_Event 'D:\Dorsu\Data\Events.Events.txt', 1;
SELECT * FROM Event;
*/


GO
