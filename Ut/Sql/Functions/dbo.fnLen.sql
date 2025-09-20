SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: fnLen deals with the trailing spaces bug in Len
-- ===============================================================
CREATE FUNCTION [dbo].[fnLen]( @v VARCHAR(8000))
RETURNS INT
AS
BEGIN
   RETURN Len(@v+'x')-1;
END
GO

