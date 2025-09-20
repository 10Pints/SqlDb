SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Description: returns the teams registered for the event
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 04-APR-2025
-- ==========================================================
CREATE FUNCTION [dbo].[fnGetEventTeams]( @event_nm VARCHAR(40))
RETURNS @t TABLE
(
    event_nm      VARCHAR(100)
   ,team_nm       VARCHAR(40)
   ,section_nm    VARCHAR(20)
   ,[date]        date
   ,student_id    VARCHAR(9)
   ,student_nm    VARCHAR(50)
   ,is_lead       BIT
)
AS
BEGIN
   INSERT INTO @t(team_nm, section_nm, [date], student_id, student_nm, is_lead)
      SELECT      team_nm, section_nm, [date], student_id, student_nm, is_lead
      FROM   Team_vw
      WHERE (event_nm LIKE CONCAT('%', @event_nm, '%') OR @event_nm IS NULL)
      ORDER BY team_nm, student_nm
   ;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetEventTeams(NULL)
SELECT * FROM dbo.fnGetEventTeams('Albert')
*/

GO
