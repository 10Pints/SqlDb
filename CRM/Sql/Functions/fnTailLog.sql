-- =============================================
-- Author:      Terry Watts
-- Create date: 02-OCT-2025
-- Description: Displays the tail of the AppLog
-- Design:      
-- Tests:       
-- =============================================
CREATE FUNCTION dbo.fnTailLog(@cnt INT)
RETURNS @t TABLE
(
   id          INT            NOT NULL,
   timestamp   VARCHAR(30)    NOT NULL,
   schema_nm   VARBINARY(20)  NULL,
   rtn         VARCHAR(60)    NULL,
   hit         INT            NULL,
   [log]       VARCHAR(MAx)   NULL,
   msg         VARCHAR(MAx)   NULL,
   [level]     INT            NULL,
   row_count   INT            NULL,
   logger      VARCHAR(50)    NULL,
   exception   VARCHAR(MAx)   NULL
)
AS
BEGIN
   DECLARE @max_id INT;
   SELECT @max_id = MAX(id) FROM AppLog;

   INSERT INTO @t(    id,[timestamp],rtn,[log],msg,[level],row_count,logger,exception)
      SELECT TOP 1000 id,[timestamp],rtn,[log],msg,[level],row_count,logger,exception
      FROM (
          SELECT TOP 1000 id,[timestamp],rtn,[log],msg,[level],row_count,logger,exception
          FROM AppLog
          WHERE id > @max_id-@cnt
          ORDER BY id DESC
      ) AS t
      ORDER BY id ASC;  -- restores ascending order

   RETURN;
END
/*
SELECT * FROM dbo.fnTailLog(50);
Select * FROM dbo.AppLog
--DELETE FROM AppLog;
*/
