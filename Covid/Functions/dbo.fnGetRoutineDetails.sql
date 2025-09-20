SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 28-DEC-2019
-- Description: List routine details of all the functions
-- =============================================
CREATE FUNCTION [dbo].[fnGetRoutineDetails]
(
    @type      NVARCHAR(30)   = '%'
   ,@rtn_nm    NVARCHAR(50)   = '%'
   ,@not_like  NVARCHAR(50)   = NULL
   ,@schema    NVARCHAR(30)   = 'dbo'
)
RETURNS @t TABLE
(
  ROUTINE_SCHEMA  NVARCHAR(256)
, ROUTINE_NAME    NVARCHAR(256)
, ROUTINE_TYPE    NVARCHAR(40)
, CREATED         DATETIME
, LAST_ALTERED    DATETIME
)
AS
BEGIN
   IF @not_like IS NOT NULL
   BEGIN
      INSERT INTO @t (ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, CREATED, LAST_ALTERED)
         SELECT TOP 2000 ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, ut.dbo.fnFormatDate(CREATED) AS CREATED, ut.dbo.fnFormatDate(LAST_ALTERED) AS LAST_ALTERED
         FROM INFORMATION_SCHEMA.ROUTINES s
         WHERE
                 ROUTINE_TYPE     LIKE @type
             AND ROUTINE_SCHEMA   LIKE @schema
             AND ROUTINE_NAME     LIKE @rtn_nm
             AND ROUTINE_NAME NOT LIKE @not_like
         ORDER BY ROUTINE_NAME;
   END
   ELSE
   BEGIN
      INSERT INTO @t (ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, CREATED, LAST_ALTERED)
         SELECT TOP 2000 ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, ut.dbo.fnFormatDate(CREATED) AS CREATED, ut.dbo.fnFormatDate(LAST_ALTERED) AS LAST_ALTERED
         FROM INFORMATION_SCHEMA.ROUTINES s
         WHERE
                 ROUTINE_TYPE     LIKE @type
             AND ROUTINE_SCHEMA   LIKE @schema
             AND ROUTINE_NAME     LIKE @rtn_nm
         ORDER BY ROUTINE_TYPE, ROUTINE_SCHEMA, ROUTINE_NAME;
   END

   RETURN
END





GO
