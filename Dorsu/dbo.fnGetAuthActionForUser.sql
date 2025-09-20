SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE FUNCTION [dbo].[fnGetAuthActionForUser](@user_id INT)
RETURNS @t TABLE
(
    user_id     INT
   ,user_nm     VARCHAR(20)
   ,action_id   INT
   ,action_nm   VARCHAR(20)
)
AS
BEGIN
   INSERT INTO @t(user_id, user_nm, action_id, action_nm)
   SELECT user_id, user_nm, action_id, action_nm
   FROM AuthorizedActions_vw
   WHERE @user_id = user_id
   ;

   RETURN;
END



GO
