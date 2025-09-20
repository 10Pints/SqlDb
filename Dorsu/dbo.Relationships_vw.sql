SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--=====================================================================
-- Author:      Terry Watts
-- Create date: 12-Apr-2025
-- Description: Displays the dbo table relationships
--=====================================================================
CREATE VIEW [dbo].[Relationships_vw]
AS
   SELECT TOP 1000
   CONSTRAINT_NAME
   FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
   WHERE CONSTRAINT_SCHEMA='dbo'
   ORDER BY CONSTRAINT_NAME;
;
/*
   SELECT * FROM Relationships_vw;
*/

GO
