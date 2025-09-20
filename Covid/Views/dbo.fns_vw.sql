SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[fns_vw] AS 
SELECT * FROM [sys_objs_vw] 
WHERE [ty] in('FN', 'FS', 'FT', 'IF', 'TF');


GO
