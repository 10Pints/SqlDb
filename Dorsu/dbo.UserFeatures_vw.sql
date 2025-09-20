SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE View [dbo].[UserFeatures_vw]
AS
SELECT distinct u.[user_id], r.role_id, r.role_nm, u.user_nm, r2f.feature_id, f.feature_nm
FROM [User] u
LEFT JOIN UserRole    u2r ON u.[user_id]  = u2r.[user_id]
LEFT JOIN [Role]      r   ON r.role_id    = u2r.role_id
LEFT JOIN RoleFeature r2f ON r2f.role_id  = r.role_id
LEFT JOIN Feature     f   ON f.feature_id = r2f.feature_id
;
/*
SELECT * FROM UserFeatures_vw
SELECT * FROM Feature;
*/

GO
