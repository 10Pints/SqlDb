-- ================================================================
-- Author:      Terry Watts
-- Create date: 02-OCT-2025
-- Description: Populates the AgencyStaging table from PropertySalesStaging
-- Returns      the merge count
-- Design:
-- Tests:      test_088_sp_pop_AgencyStaging_tbl
-- Preconditions:
--    PRE01: PropertySalesStaging popd
--
-- Postconditions:
--    POST01: AgencyStaging popd
--    POST02: Returns the merge count
-- ================================================================
CREATE PROCEDURE [dbo].[sp_pop_AgencyStaging_tbl]
   @display_tables BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
     @fn    VARCHAR(35) = 'sp_pop_AgencyStaging_tbl'
    ,@cnt   INT
   ;
   --  PRE01: PropertySalesStaging popd
   EXEC sp_log 1, @fn,'000: starting';-- Declare a table variable to capture OUTPUT results
   EXEC sp_log 1, @fn,'010: Merge Agency Table';
   DELETE FROM AgencyStaging;

   -- Merge AgencyStaging Table
   MERGE INTO AgencyStaging AS target
   USING (
      SELECT DISTINCT [name]
      FROM PropertySalesStaging
      WHERE [name] IS NOT NULL
   ) AS source
   ON target.agency_nm = source.[name]
   WHEN NOT MATCHED BY TARGET THEN
      INSERT (agency_nm)
      VALUES (source.[name])
   WHEN NOT MATCHED BY SOURCE THEN
      DELETE
   ;

   EXEC sp_log 1, @fn,'020: populated AgencyStaging with ', @@rowcount, ' rows';

   -- Update Agency set the default phone number to be the phone number from
   -- PropertySalesStaging where no contacts specified
   EXEC sp_log 1, @fn,'020: update AgencyStaging set  default phone number where no contacts specified';
   UPDATE AgencyStaging
   SET phone = ps.phone
   FROM PropertySalesStaging ps JOIN AgencyStaging a ON ps.[name] = a.agency_nm
   WHERE ps.Contact_nm IS NULL
   ;

   SELECT @cnt = COUNT(*) FROM AgencyStaging;

   EXEC sp_log 1, @fn,'030: update Agency default phone number with the first contact phone';
   UPDATE AgencyStaging
   SET phone = X.default_phone
   FROM AgencyStaging
   INNER JOIN
   (
      SELECT [name], MIN(dbo.fnTrim(s1.value)) AS default_phone
      FROM PropertySalesStaging ps
      CROSS APPLY string_split(phone, ',') AS s1
      WHERE s1.value <> ''
      GROUP BY [name]
   ) X
   ON AgencyStaging.agency_nm = X.[name];
   --SELECT * FROM AgencyStaging;

   -- update agency: address, email, delegate, facebook, messenger, viber,whatsApp
   -- treated as single fields
   EXEC sp_log 1, @fn,'040: update Agency: address, email, delegate, facebook, messenger, viber,whatsApp,website';
   UPDATE AgencyStaging
   SET
       agency_nm           = X.[name]
      ,agency_type         = X.[type]
      ,area                = X.area
      ,delegate_nm         = X.delegate_nm
      ,[status]            = X.[status]
      ,first_reg           = X.first_reg
      ,notes               = X.notes
      ,quality             = X.quality
      ,primary_contact_nm  = X.contact_nm
      ,[role]              = X.[role]
      ,phone               = X.phone
      ,preferred_contact_method = X.preferred_contact_method
      ,email               = X.email
      ,whatsApp            = X.whatsApp
      ,viber               = X.viber
      ,facebook            = X.facebook
      ,messenger           = X.messenger
      ,website             = X.website
      ,[address]           = X.[address]
      ,notes_2             = X.notes_2
      ,old_notes           = X.old_notes
      ,age                 = X.age
      ,actions_08_OCT      = X.actions_08_OCT
      ,jan_16_2025         = X.jan_16_2025
      ,action_by_dt        = X.action_by_dt
      ,replied             = X.replied
      ,history             = X.history

   FROM AgencyStaging
   INNER JOIN
   (
      SELECT
          [name],[type], area, ps.delegate_nm, [status],first_reg, notes, quality
         ,contact_nm,[role], phone, preferred_contact_method
         , viber, whatsApp, ps.[address], ps.email, ps.messenger, ps.facebook
         , ps.website, notes_2, Old_Notes, age, actions_08_OCT, jan_16_2025
         , action_by_dt, replied, history
      FROM PropertySalesStaging ps
   ) X
   ON AgencyStaging.agency_nm = X.[name];

   IF @display_tables = 1
   BEGIN
      SELECT 'AgencyStaging table' as [table];
      SELECT * FROM AgencyStaging;
   END

   -- Postconditions:
   -- POST01: AgencyStaging populated
   EXEC sp_assert_tbl_pop 'AgencyStaging';

   EXEC sp_log 1, @fn,'999: merged ', @cnt,' rows into the Agency table';
   RETURN @cnt;
END
/*
EXEC test.test_088_sp_pop_AgencyStaging_tbl;


SELECT * FROM PropertySalesStaging
*/
