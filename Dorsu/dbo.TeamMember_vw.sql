SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- Description: Teams and the team members 1 row per team member
-- =============================================================
CREATE VIEW [dbo].[TeamMember_vw]
AS
SELECT TOP  10000
    row_number() OVER(ORDER BY event_nm, team_nm, student_nm) as row_id
  , t.team_id
   ,t.team_nm
   ,event_nm
   ,t.section_nm
   ,tm.student_id
   ,tm.student_nm
   ,tm.is_lead
   ,iif(is_lead = 1, 'team lead','member') AS position
   ,github_project
   ,t.section_id
   ,t.team_gc
FROM
     Team_vw t
LEFT JOIN TeamMembers tm ON t.team_id = tm.team_id
ORDER BY team_nm ASC, is_lead DESC, student_nm ASC;
/*
SELECT * FROM TeamMember_vw;
SELECT * FROM Team;
SELECT * FROM Team_vw;
EXEC sp_FindStudent 'Niez';
*/

GO
