SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27 APR 2025
-- Description: gets the  first and last words 
--   from a clause excluding Initials with trailing dot
--   used for Dorsu Student Names
-- Design:      none
-- Tests:       test_050_fnGetFirstLastWords
-- =============================================
CREATE FUNCTION [dbo].[fnGetFirstLastWords]
(
    @clause VARCHAR(4000)
   ,@sep    VARCHAR(1))
RETURNS @t TABLE
(
    first_nm VARCHAR(1000)
   ,last_nm VARCHAR(1000)
)
AS
BEGIN
INSERT INTO  @t (first_nm, last_nm)
SELECT
    TRIM(',' FROM X.cls) AS first_nm
   ,TRIM(',' FROM Y.cls) AS last_nm
FROM
(
   SELECT TOP 1
   TRIM(',' FROM value) AS cls
   FROM string_split(@clause, @sep, 1) AS cls
   WHERE value NOT LIKE '%.%'
) X
,
(
   SELECT TOP 1
   TRIM(', ' FROM value) as cls
   FROM string_split(@clause, @sep, 1) AS cls
   WHERE value NOT LIKE '%.%'
   ORDER BY ordinal DESC
) Y;

   RETURN;
END
/*
EXEC test.test_050_fnGetFirstLastWords;
EXEC tSQLt.Run'test.test_050_fnGetFirstLastWords';
EXEC tSQLt.RunAll;

SELECT * FROM dbo.fnGetFirstLastWords('Sitti Monera F. Martin', ' ');
SELECT * FROM dbo.fnGetFirstLastWords('Zaragoza, Princess Ann D.', ' ');
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns 'dbo.fnGetFirstLastWords'
SELECT * FROM student

*/

GO
