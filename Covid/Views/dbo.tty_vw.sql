SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[tty_vw] AS 
SELECT * FROM [sys_objs_vw] 
WHERE [ty] in('TT');


GO
