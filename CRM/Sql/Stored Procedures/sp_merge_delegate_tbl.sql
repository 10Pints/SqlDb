-- ================================================================
-- Author:      Terry Watts
-- Create date: 02-OCT-2025
-- Description: Merges the Delegate table from PropertySalesStaging
-- Returns      the merge count
-- Design:      
-- Tests:       
-- ================================================================
CREATE PROCEDURE [dbo].[sp_merge_delegate_tbl] @display_tables BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
     @fn    VARCHAR(35) = 'sp_merge_delegate_tbl'
    ,@cnt   INT
   ;

   EXEC sp_log 1, @fn,'000: starting';-- Declare a table variable to capture OUTPUT results
   DECLARE @MergeOutput TABLE
   (
       Action NVARCHAR(10),
       Delegate_nm NVARCHAR(100) -- Adjust data type to match your delegate_nm column
   );

      EXEC sp_log 1, @fn,'010: merge Delegate table';
      -- Merge Delegate Table
      MERGE INTO Delegate AS target
      USING (
         SELECT DISTINCT delegate_nm 
         FROM PropertySalesStaging 
         WHERE delegate_nm IS NOT NULL
      ) AS source
      ON target.delegate_nm = source.delegate_nm
      WHEN NOT MATCHED BY TARGET THEN
         INSERT (delegate_nm)
         VALUES (source.delegate_nm)
      WHEN NOT MATCHED BY SOURCE THEN
         DELETE
      OUTPUT $action, Inserted.delegate_nm INTO @MergeOutput
      ;

      SELECT @cnt = COUNT(*) FROM @MergeOutput;

      IF @display_tables = 1 SELECT * FROM Delegate;

      EXEC sp_log 1, @fn,'999: merged ', @cnt,' rows into the Delegate table';
      RETURN @cnt;
END
/*
EXEC test.test_081_sp_merge_delegate_tbl;
SELECT * FROM Delegate;
EXEC tSQLt.Run 'test.test_081_sp_merge_delegate_tbl';
*/
