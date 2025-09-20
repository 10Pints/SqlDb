SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 18-MAY-2025
-- Description: displays MC50 scores
-- =============================================================
CREATE VIEW [dbo].[MC50_scores_vw]
AS
   SELECT s.student_id, student_nm, score
   FROM MC50_scores m JOIN Student s
      ON m.student_id = s.student_id;

/*
SELECT * FROM MC50_scores_vw;
*/

GO
