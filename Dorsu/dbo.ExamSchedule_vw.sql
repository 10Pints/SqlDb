SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[ExamSchedule_vw]
AS
SELECT 
	 [days]
	,st
	,[end]
	,ex_st
	,ex_end 
	,ex_date
	,ex_day
FROM ExamSchedule
;


GO
