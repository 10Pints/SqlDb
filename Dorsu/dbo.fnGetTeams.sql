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
CREATE FUNCTION [dbo].[fnGetTeams]
(
    @section_nm   VARCHAR(20)
   ,@event_nm     VARCHAR(100)
   ,@team_nm      VARCHAR(40)
   ,@student_nm   VARCHAR(50)
   ,@student_id   VARCHAR(9)
   ,@is_lead      BIT
)
RETURNS @t TABLE
(
    row_id           INT
   ,section_nm       VARCHAR(20)
   ,event_nm         VARCHAR(100)
   ,team_nm          VARCHAR(60)
   ,team_gc          VARCHAR(150) NULL
   ,github_project   VARCHAR(8000) NULL
   ,student_id       VARCHAR(9)
   ,student_nm       VARCHAR(50)
   ,is_lead          BIT
   ,position         VARCHAR(20)
   ,team_id          INT
)
AS
BEGIN
   INSERT INTO @t
(
    row_id
   ,section_nm
   ,event_nm
   ,team_nm
   ,team_gc
   ,github_project
   ,student_id
   ,student_nm
   ,is_lead
   ,position
   ,team_id
)
   SELECT row_number() OVER(ORDER BY event_nm,team_nm, student_nm) as row_id
   ,section_nm
   ,event_nm
   ,team_nm
   ,team_gc
   ,SUBSTRING(github_project, 1, 200)
   ,student_id
   ,student_nm
   ,is_lead
   ,position
   ,team_id

   FROM TeamMember_vw
   WHERE
       (event_nm   LIKE CONCAT('%', @event_nm  , '%') OR @event_nm   IS NULL)
   AND (team_nm    LIKE CONCAT('%', @team_nm   , '%') OR @team_nm    IS NULL)
   AND (student_nm LIKE CONCAT('%', @student_nm, '%') OR @student_nm IS NULL)
   AND (section_nm LIKE CONCAT('%', @section_nm, '%') OR @section_nm IS NULL)
   AND (student_id = @student_id                      OR @student_id IS NULL)
   AND (is_lead    = @is_lead                         OR @is_lead    IS NULL)
   ORDER BY event_nm, team_nm, student_nm
   ;

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_030_sp_GetTeams';
EXEC test.test_030_sp_GetTeams;

SELECT * FROM dbo.fnGetTeams(NULL,NULL,NULL,NULL,NULL,NULL);
SELECT * FROM dbo.fnGetTeams('3B',NULL,NULL,NULL,NULL,NULL);
SELECT * FROM dbo.fnGetTeams(NULL,NULL,NULL,NULL,'2023-1531',NULL);
EXEC sp_GetTeams ;

EXEC dbo.sp_GetTeams @student_nm ='Misoles';
EXEC dbo.sp_GetTeams @student_nm ='Misoles';
EXEC dbo.sp_GetTeams @event_nm = 'Project X Requirements Presentation IT 3C';

*/


GO
