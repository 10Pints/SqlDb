SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  21-DEC-2023
-- Description:  clears the held log cache
--               call when previously holding or in the event of an exception
-- ======================================================================================================
CREATE PROCEDURE [dbo].[sp_clr_log_cache]
AS
BEGIN
   IF dbo.fnWasCachingLog() = 1  
   BEGIN
      DECLARE @key NVARCHAR(40);
      SET @key = dbo.fnGetLogCacheKey();
      EXEC sp_set_session_context @key, NULL;
      SET @key = dbo.fnGetLogCacheKey();
      EXEC sp_set_session_context @key, NULL;
   END
END
/*

*/

GO
