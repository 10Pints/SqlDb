SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 17-MAY-2025
--
-- Description: splits a MC50 row into its component parts
--
-- Postconditions:
-- Post 01: 
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitMC50Row]
(
    @row VARCHAR(500) -- qualified routine name
)
RETURNS @t TABLE
(
    student_id    VARCHAR(1000)
   ,student_name  VARCHAR(1000)
   ,gender        CHAR(1)
   ,section_nm    VARCHAR(20)
   ,ordinal       INT
   ,answer        VARCHAR(10)
)
AS
BEGIN
   DECLARE
    @pos          INT
   ,@tab          CHAR = CHAR(9)
   ,@student_id   VARCHAR(9)
   ,@student_name VARCHAR(50)
   ,@gender       CHAR
   ,@section_nm   VARCHAR(20)
   ;
   SELECT 
       @student_id     = [1]
      ,@student_name   = [2]
      ,@gender         = [3]
      ,@section_nm     = [4]
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num,
         TRIM(value) as value
    FROM
     STRING_SPLIT(@row, CHAR(9))
) AS src
PIVOT (
    MAX(value) FOR row_num IN ([1], [2], [3], [4])
) AS pvt;

   SET @pos = dbo.fnFindNthOccurrence(@row, @tab, 4)+1;

   SET @row = SUBSTRING(@row, @pos, dbo.fnLen(@row)-@pos);
   INSERT INTO @t (student_id, student_name, gender, section_nm, ordinal, answer)
   SELECT         @student_id,@student_name,@gender,@section_nm, ordinal, value
   FROM string_split(@row, @tab, 1)
   ;

   RETURN;
END
/*
SELECT * FROM fnSplitMC50Row('2023-2326	Caldoza, Psyche A.	F	2D	C	AC	BCE	BCE	AC	CDE	BD	ADE	CE	AD	ADE	CE	AE	E	CE	ACE	D	ACDE	A	DE	DE	ABC	AC	C	CDE	C	BCE	E	BCD	DE	AD	BDE	ACD	ABCD	A	BCD	A	BCE	ABD	BCE	A	D	ACE	BDE	BCD	BCE	AD	BCD	AE	BC	')
*/


GO
