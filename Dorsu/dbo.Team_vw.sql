SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- Description: Teams and the team members
-- =============================================================
CREATE VIEW [dbo].[Team_vw]
AS
WITH CTE AS
(
   SELECT
   t.team_id
  ,team_nm
  ,section_nm
  ,string_agg(tm.student_nm, ', ') as members
  ,github_project
  ,team_gc
  ,s.section_id
  ,event_nm

FROM TeamMembers tm
LEFT JOIN Team t on t.team_id = tm.team_id
LEFT JOIN section s ON s.section_id = t.section_id
LEFT JOIN [Event] e ON e.event_id = t.event_id
GROUP BY t.team_id, team_nm, section_nm, s.section_id, github_project, team_gc,event_nm
)
SELECT TOP 1000
  row_number() OVER(ORDER BY team_nm) as row_id
, *
FROM cte
ORDER BY team_nm

/*
SELECT * FROM Team_vw;
EXEC sp_FindStudent 'Niez';
*/

GO
