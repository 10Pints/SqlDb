SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 31-MAR-2025
-- Description: Gets the authorized fetures for a given user
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
--  POST 01: returns a list of features the user is authorized to perform
--
-- CHANGES:
--
-- ============================================================================================================================
CREATE FUNCTION [dbo].[fnGetAuthorizedUserFeatures](@user_id VARCHAR(8))
RETURNS
@t TABLE
(
	[feature_id] INT          NULL,
	feature_nm   VARCHAR(50)  NULL,
	[user_id]    CHAR(1)      NULL
)

AS
BEGIN
   INSERT INTO @t SELECT feature_id, feature_nm, [user_id]
   FROM UserFeatures_vw
   WHERE ([user_id] = @user_id) OR (@user_id IS NULL)
   ;

   RETURN;
END
/*
   SELECT * FROM dbo.fnGetAuthorizedUserFeatures(1);
*/

GO
