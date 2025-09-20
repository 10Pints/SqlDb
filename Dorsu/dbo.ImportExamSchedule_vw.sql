SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE VIEW [dbo].[ImportExamSchedule_vw]
AS
SELECT 
    id
	,[days]
	,st
	,[end]
	,ex_st
	,ex_end 
	,ex_date
	,ex_day
FROM ExamSchedule
;
/*
SELECT * FROM ImportExamSchedule_vw;
*/

GO
