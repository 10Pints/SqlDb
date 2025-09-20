SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 28-DEC-2019
-- Description: List Procedure details
-- =============================================
CREATE FUNCTION [dbo].[fnGetProcedureDetails]
(
       @like      NVARCHAR(50)   = '%'
      ,@not_like  NVARCHAR(50)   = NULL
      ,@schema    NVARCHAR(30)   = 'dbo'
)
RETURNS TABLE 
AS
RETURN 
   SELECT TOP 1000 gpd.* 
   FROM dbo.fnGetRoutineDetails('P%', @like, @not_like, @schema) gpd JOIN
   (select * FROM dbo.procs_vw 
   WHERE
       is_system_object = 0
   AND [schema] = 'dbo'
   ) vw
   ON gpd.ROUTINE_NAME =  vw.name
   order by name ASC






GO
