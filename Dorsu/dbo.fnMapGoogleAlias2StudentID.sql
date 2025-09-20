SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 18-APR-2025
-- Description: maps the Google name to the student ID
-- Design:      EA
-- Tests:       test_010_fnMapGoogleAliasStudentID'
-- =============================================
CREATE FUNCTION [dbo].[fnMapGoogleAlias2StudentID](@google_alias VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
   DECLARE @student_id VARCHAR(9)
   ;

   SELECT @student_id = student_id
   FROM GoogleAlias
   WHERE google_alias= @google_alias
   ;

   RETURN @student_id;
END
/*
EXEC test.test_010_fnMapGoogleAliasStudentID;

EXEC tSQLt.Run 'test.test_010_fnMapGoogleAliasStudentID';
EXEC tSQLt.RunAll;
*/


GO
