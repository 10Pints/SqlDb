-- ================================================================
-- Author:      Terry Watts
-- Create date: 02-OCT-2025
-- Description: Merges the Delegate table from PropertySalesStaging
-- Returns      the merge count
-- Design:      
-- Tests:       
-- ================================================================
CREATE PROCEDURE [dbo].[sp_merge_contact_tbl] @display_tables BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
     @fn    VARCHAR(35) = 'sp_merge_contact_tbl'
    ,@cnt   INT
   ;

   EXEC sp_log 1, @fn,'000: starting';-- Declare a table variable to capture OUTPUT results
   DELETE FROM ContactStaging;

   EXEC sp_log 1, @fn,'010: merge ContactStaging table';

   DECLARE @MergeOutput TABLE
(
    Action NVARCHAR(10),
    contact_nm NVARCHAR(300) -- Adjust data type to match your delegate_nm column
);

      MERGE INTO ContactStaging AS target
      USING (
         SELECT DISTINCT TOP 1000 dbo.fnTrim(s1.value) as contact
         FROM PropertySalesStaging ps
         CROSS APPLY string_split(Contact_nm, ',') as s1
         WHERE value <> ''
         ORDER BY dbo.fnTrim(s1.value)
      ) AS source
      ON target.contact_nm = source.contact
      WHEN NOT MATCHED BY TARGET THEN
         INSERT (contact_nm)
         VALUES (source.contact)
      WHEN NOT MATCHED BY SOURCE THEN
         DELETE
      OUTPUT $action, Inserted.contact_nm INTO @MergeOutput
      ;

      SELECT @cnt = COUNT(*) FROM @MergeOutput;

      SELECT * FROM ContactStaging;
      EXEC sp_log 1, @fn,'020: UPDATING ContactStaging table: pop roles';
      UPDATE ContactStaging 
SET 
    contact_nm = CASE 
                    WHEN CHARINDEX(':', contact_nm) > 0 
                    THEN LTRIM(RTRIM(LEFT(contact_nm, CHARINDEX(':', contact_nm) - 1)))
                    ELSE contact_nm
                 END,
    [role] = CASE 
                 WHEN CHARINDEX(':', contact_nm) > 0 
                 THEN LTRIM(RTRIM(SUBSTRING(contact_nm, CHARINDEX(':', contact_nm) + 1, LEN(contact_nm))))
                 ELSE [role]
              END;

      EXEC sp_log 1, @fn,'030: UPDATED ',@@ROWCOUNT,' rows in ContactStaging';

      SELECT * FROM ContactStaging;

      EXEC sp_log 1, @fn,'999: merged ', @cnt,' rows into the ContactStaging table';
      RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_083_sp_merge_contact_tbl';
EXEC test.test_083_sp_merge_contact_tbl;
SELECT * FROM ContactStaging;
*/
