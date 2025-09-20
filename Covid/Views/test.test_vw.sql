SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [test].[test_vw] AS 
SELECT * FROM [sys_objs_vw] 
WHERE [ty] in('FN') AND is_system_object = 0;


GO
