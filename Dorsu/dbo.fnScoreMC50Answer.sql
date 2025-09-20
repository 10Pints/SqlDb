SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 17-MAY-2025
--
-- Description: Scores a Multiple choice score 
--
-- Postconditions:
-- Post 01: returns: if valid inputs then scrore
-- ELSE if len act> 5                then -200
-- ELSE an invalid selectiopn char   then -100
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnScoreMC50Answer]
(
    @exp       VARCHAR(10)
   ,@act       VARCHAR(10)
   ,@penalty   FLOAT -- for act ansd not in exp
)
RETURNS FLOAT
AS
BEGIN
   DECLARE
    @score  FLOAT = 0.0
   ,@pos    INT   = 0
   ,@cntE   INT   = dbo.fnLen(@exp)
   ,@cntA   INT   = dbo.fnLen(@act)
   ,@c      CHAR
   ;

   ----------------------------------
   -- Validation
   ---------------------------------0
   IF dbo.fnLen(@exp)>5
      RETURN -300.0; -- code/read error

   IF dbo.fnLen(@act)>5
      RETURN -200.0; -- code/read error

   IF dbo.fnLen(@act)= 0
      RETURN 0.0; -- no answer

   -- Validate the exp
   WHILE(@pos< @cntE)
   BEGIN
      SET @pos = @pos + 1;
      SET @c = SUBSTRING(@exp, @pos, 1);

      IF @c< 'A' OR @c > 'E'
         RETURN -400.0; --bad selection character error
   END

   ----------------------------------
   -- No duplicates in either
   ----------------------------------
   IF(dbo.fnHasDuplicateCharacters(@exp) = 1)
      RETURN -500.0;

   IF(dbo.fnHasDuplicateCharacters(@act) = 1)
      RETURN -600.0;


   -- iterate the expect answer
   -- look for each char in act that is exp and add 1 pt for each found
   SET @pos = 0;
   WHILE(@pos< @cntA)
   BEGIN
      SET @pos = @pos + 1;
      SET @c = SUBSTRING(@act, @pos, 1);

      IF @c< 'A' OR @c > 'E'
         RETURN -100.0; --bad selection character error

      IF CHARINDEX(@c, @exp)>0
         SET @score = @score + 1.0;
   END

   -- iterate the act answer
   -- look for each char in act that is not in exp and deduct @penalty pt for each

   IF @cntA > @cntE
   BEGIN
      --SET @cnt = dbo.fnLen(@exp);
      SET @pos = 0;

      WHILE(@pos< @cntA)
      BEGIN
         SET @pos = @pos + 1;
         SET @c = SUBSTRING(@act, @pos, 1);


         IF CHARINDEX(@c, @exp) = 0
            SET @score = @score - @penalty;
      END
   END

   RETURN @score;
END
/*
SELECT dbo.fnMC50ScoreAnswer('A','A', 0.4);
EXEC test.sp__crt_tst_rtns 'dbo.fnScoreMC50Answer'
*/


GO
