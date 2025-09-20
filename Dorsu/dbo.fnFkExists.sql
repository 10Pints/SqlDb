SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =====================================================================
-- Author:      Terry Watts
-- Create date: 08 MAR 2025
-- Description: returns true if the foreign key exists, false otherwise
-- Design:      
-- Tests:       
-- =====================================================================
CREATE FUNCTION [dbo].[fnFkExists](@fk VARCHAR(128))
RETURNS BIT
AS
BEGIN
   RETURN iif(EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = @fk), 1, 0);
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_000_FkExists';
*/


GO
