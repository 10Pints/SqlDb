SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 04-MAR-2025
-- Description: 
-- PRECONDITIONS:
-- 
--
-- POSTCONDITIONS:
--  POST 01: List the student det2ils
--
-- CHANGES:
-- 
-- ============================================================================================================================
CREATE FUNCTION [dbo].[fnGetStudentById](@student_id VARCHAR(8))
RETURNS
@t TABLE
(
	student_id VARCHAR(9)  NOT NULL,
	student_nm VARCHAR(50) NULL,
	gender     CHAR(1)     NULL
)

AS
BEGIN
   INSERT INTO @t SELECT * FROM Student
   WHERE student_id LIKE @student_id OR @student_id Is NULL
   ;

   RETURN;
END
/*
   SELECT * FROM dbo.fnGetStudentById('2020%');
   EXEC test.sp__crt_tst_rtns 'dbo.fnGetStudentById', 3;
*/



GO
