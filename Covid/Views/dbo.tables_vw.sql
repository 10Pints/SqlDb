SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[tables_vw] AS 
SELECT * FROM [sys_objs_vw] 
WHERE [ty] in('ET', 'IT','S', 'T', 'U');


GO
