SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Description: returns the team members for the parameters
-- Design:      EA
-- Tests:       test_018_fnGetTeamMembers
-- Author:      Terry Watts
-- Create date: 25-MAR-2025
-- ==========================================================
CREATE FUNCTION [dbo].[fnGetTeamMembers]
(
    @team_nm     VARCHAR(40)
   ,@section_nm  VARCHAR(20)
   ,@course_nm   VARCHAR(20)
   ,@student_id  VARCHAR(9)
   ,@student_nm  VARCHAR(50)
)
RETURNS @t TABLE
(
    team_nm       VARCHAR(40)
   ,section_nm    VARCHAR(20)
   ,student_id    VARCHAR(9)
   ,student_nm    VARCHAR(50)
   ,is_lead       BIT
)
AS
BEGIN
   INSERT INTO @t(team_nm,section_nm,student_id,student_nm, is_lead)
      SELECT team_nm, section_nm, student_id, student_nm, is_lead
      FROM   Team_vw
      WHERE
          (team_nm    LIKE CONCAT('%', @team_nm   , '%') OR @team_nm    IS NULL)
      AND (section_nm LIKE CONCAT('%', @section_nm, '%') OR @section_nm IS NULL)
      AND (course_nm  LIKE CONCAT('%', @course_nm , '%') OR @course_nm  IS NULL)
      AND (student_id LIKE CONCAT('%', @student_id, '%') OR @student_id IS NULL)
      AND (student_nm LIKE CONCAT('%', @student_nm, '%') OR @student_nm IS NULL)
      ORDER BY team_nm, student_nm
   ;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetTeamMembers(NULL, NULL, NULL, NULL, NULL);
SELECT * FROM dbo.fnGetTeamMembers(NULL, NULL, NULL, NULL, 'Albert')
EXEC test.test_018_fnGetTeamMembers;
EXEC tSQLt.Run 'test.test_018_fnGetTeamMembers;';
*/

GO
