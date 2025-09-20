SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 18-MAY-2025
-- Description: displays MC50 scores
-- =============================================================
CREATE VIEW [dbo].[MC50_StudentAnswer_vw]
AS
   SELECT
       sa.id
      ,sa.student_id
      ,sa.ordinal
      ,sa.answer AS act_answer
      ,e.answer AS exp_answer
      ,score
   FROM MC50_StudentAnswer sa JOIN MC50_Answers e
      ON sa.ordinal=e.ordinal;

/*
SELECT * FROM MC50_StudentAnswer_vw WHERE act_answer <> '';
*/

GO
