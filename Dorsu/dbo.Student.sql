SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 05-Mar-2025
-- Description: debug
-- =============================================
CREATE TRIGGER [dbo].[sp_student_insert_trigger]
   ON [dbo].[Student]
   AFTER DELETE
AS 
BEGIN
   SET NOCOUNT ON;
   THROW 65525, 'student_insert_trigger alert', 1;

END

ALTER TABLE [dbo].[Student] DISABLE TRIGGER [sp_student_insert_trigger]

ALTER TABLE [dbo].[Student] DISABLE TRIGGER [sp_student_insert_trigger]

GO
