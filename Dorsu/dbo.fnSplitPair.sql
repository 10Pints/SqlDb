SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 11-APR-2025
--
-- Description: splits a composite string of 2 parts separated by a '.' 
-- into a row containing the first part (a), and the second part (b)
--
-- Postconditions:
-- Post 01: if schema is not specifed then get it from the sys rtns PROVIDED ONLY ONE rtn named the @rtn_nm
-- 
-- Changes:
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitPair]
(
    @composit VARCHAR(150) -- qualified routine name
)
RETURNS @t TABLE
(
    a  VARCHAR(1000)
   ,b  VARCHAR(1000)
)
AS
BEGIN
   INSERT INTO @t SELECT * FROM dbo.fnSplitPair2(@composit, '.');
   RETURN;
END
/*
SELECT * FROM fnSplitQualifiedName('test.fnGetRtnNmBits')
SELECT * FROM fnSplitQualifiedName('a.b')
SELECT * FROM fnSplitQualifiedName('a.b.c')
SELECT * FROM fnSplitQualifiedName('a')
SELECT * FROM fnSplitQualifiedName(null)
SELECT * FROM fnSplitQualifiedName('')
EXEC test.sp__crt_tst_rtns '[dbo].[fnSplitQualifiedName]';
*/


GO
