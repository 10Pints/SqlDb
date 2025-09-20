SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================
-- Description: returns the team details for the parameters
-- Design:      EA
-- Tests:       test_030_sp_GetTeams
-- Author:      Terry Watts
-- Create date: 5-APR-2025
-- ==========================================================
CREATE PROC [dbo].[sp_GetTeams]
    @section_nm   VARCHAR(20)  = NULL
   ,@event_nm     VARCHAR(100) = NULL
   ,@team_nm      VARCHAR(40)  = NULL
   ,@student_nm   VARCHAR(50)  = NULL
   ,@student_id   VARCHAR(9)   = NULL
   ,@is_lead      BIT          = NULL
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)   = N'SP_GetTeams'
   ,@s_section_nm   VARCHAR(20)  = iif(@section_nm IS NULL ,'<NULL>', @section_nm)
   ,@s_event_nm     VARCHAR(100) = iif(@event_nm   IS NULL ,'<NULL>', @event_nm  )
   ,@s_team_nm      VARCHAR(40)  = iif(@team_nm    IS NULL ,'<NULL>', @team_nm   )
   ,@s_student_nm   VARCHAR(50)  = iif(@student_nm IS NULL ,'<NULL>', @student_nm)
   ,@s_student_id   VARCHAR(9)   = iif(@student_id IS NULL ,'<NULL>', @student_id)
   ,@s_is_lead      VARCHAR(9)   = iif(@is_lead    IS NULL ,'<NULL>', CONVERT(VARCHAR(9), @is_lead))
--      ,@row_cnt   INT
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn,'000: starting, params:
section_nm:[',@s_section_nm,']
event_nm  :[',@s_event_nm  ,']
team_nm   :[',@s_team_nm   ,']
student_nm:[',@s_student_nm,']
student_id:[',@s_student_id,']
is_lead   :[',@s_is_lead   ,']
';

      EXEC sp_log 1, @fn,'010: calling dbo.fnGetTeams(',@s_section_nm,',',@s_team_nm,',',@s_team_nm,',',@s_student_nm,',',@s_student_id,',',@s_is_lead,')';

      SELECT * FROM dbo.fnGetTeams
      (
          @section_nm
         ,@event_nm
         ,@team_nm
         ,@student_nm
         ,@student_id
         ,@is_lead
      );

      EXEC sp_log 1, @fn,'019';
--      SET @row_cnt = @@ROWCOUNT;
      EXEC sp_log 1, @fn,'020';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

  EXEC sp_log 1, @fn,'999: leaving';--, selected ', @row_cnt, ' rows';
END
/*
EXEC dbo.sp_GetTeams @student_nm ='Misoles, Mike A.';
SELECT * FROM team_vw;
EXEC test.test_030_sp_GetTeams;

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_030_sp_GetTeams';
EXEC dbo.sp_GetTeams @event_nm = 'Project X Requirements Presentation IT 3C';
EXEC dbo.sp_GetTeams @event_nm = 'Requ';

Team Powerpuff	GEC E2	2B	2023-2602	Duray, Cristian Dave	NULL
*/


GO
