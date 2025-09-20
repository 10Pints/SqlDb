SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE View [dbo].[fk_vw]
AS
SELECT
    name                              AS fk_nm
   ,SCHEMA_NAME(schema_id)            AS schema_nm
   ,OBJECT_NAME(parent_object_id)     AS f_table_nm
   ,OBJECT_NAME(referenced_object_id) AS p_table_nm
   ,is_disabled
FROM sys.foreign_keys
;
/*
SELECT * FROM fk_vw
*/


GO
