SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  21-DEC-2023
-- Description:  adds msg to the log cache
--               sets the the was caching log context to true
-- ======================================================================================================
CREATE PROCEDURE [dbo].[sp_cache_log] @log_msg NVARCHAR(4000)
AS
BEGIN
   IF dbo.fnWasCachingLog() = 1  
   BEGIN
      DECLARE 
          @key        NVARCHAR(40)
         ,@cached_msg NVARCHAR(4000)
      ;

      -- Keeps cocatenating log to the log cache if the cache already exists
      SET @key = dbo.fnGetLogCacheKey();
      SET @log_msg = CONCAT(dbo.fnGetLogCache(), @log_msg);
      EXEC sp_set_session_context @key, @log_msg;

      -- Set the was logging flag to true
      SET @key = dbo.fnGetWasCachingLogKey();
      EXEC sp_set_session_context @key, 1;
   END
END
/*

*/

GO
