SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry Watts
-- Create date: 05-MAR-2025
-- Description: returns the students for a section
--
-- PRECONDITIONS:
-- PRE 01: 
--
-- POSTCONDITIONS:
-- POST01: 
--
-- CHANGES:
--
-- ===============================================================
CREATE FUNCTION [dbo].[fnGetGetStudentsForSection](@section_nm VARCHAR(20))
RETURNS @t TABLE
(
    section_nm VARCHAR(20)
   ,student_id VARCHAR(9)
   ,student_nm VARCHAR(50)
   ,gender     CHAR(1)
)
AS
BEGIN
   DECLARE
    @fn VARCHAR(35) = 'fnGetGetStudentsForSection'
   ,@desc_st_row     INT = NULL
   ,@desc_end_row    INT = NULL
   ,@schema_nm       VARCHAR(50)
   ,@ad_stp          BIT            = 0
   ,@tstd_rtn        VARCHAR(100)
   ,@qrn             VARCHAR(100)
   ;

   INSERT INTO @t(section_nm, student_id, student_nm, gender)
   SELECT section_nm, student_id, student_nm, gender
   FROM StudentSection_vw
   WHERE section_nm=@section_nm OR @section_nm IS NULL
   ORDER BY section_nm, student_nm;
   RETURN;
END
/*
SELECT * from dbo.fnGetGetStudentsForSection(NULL)
SELECT * from dbo.fnGetGetStudentsForSection('IT 3C')
*/



GO
