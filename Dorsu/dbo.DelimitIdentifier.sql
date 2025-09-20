SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: adds [] brackets to an identifier as necessary
--    Example table names like 'User' or 'Autorized actions'
--
-- Design:      EA: Dorsu Model.Conceptual Model.Delimit Identifier
-- Tests:       
-- ==================================================================
CREATE FUNCTION [dbo].[DelimitIdentifier]
(
   @id VARCHAR(120) -- identifier
)
RETURNS VARCHAR(120)
AS
BEGIN
   DECLARE @nb BIT = 0;

   WHILE 1=1
   BEGIN
      IF CHARINDEX(' ', @id) > 0
      BEGIN
         SET @nb = 1;
         BREAK;
      END

      BREAK;
   END -- while 1=1

   RETURN @nb;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
