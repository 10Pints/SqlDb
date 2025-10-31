-- ===================================================================
-- Author:      Terry Watts
-- Create date: 7-SEP-2025
-- Description: Migrates the Resort Sales staging data to ResortSales
-- merges data to various tables:
--    PropertySales, Agency, Delegate, Contact, ContactAgency
-- Preconditions:
-- PRE01: ResortSalesStaging table is populated
-- Postconditions:
-- POST01: ResortSales is populated
-- POST02: returns the number of rows migrated
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_migrate_propertySales] @display_tables BIT = 1
AS
BEGIN
   DECLARE
    @fn           VARCHAR(35)   = N'sp_migrate_PropertySales'
   ,@cmd          VARCHAR(MAX)
   ,@msg          VARCHAR(1000)
   ,@rc           INT
   ,@cnt          INT
   ;

   EXEC sp_log 1, @fn,'000: starting';

   BEGIN TRY
      -- Validating Preconditions:
      -- PRE01: PropertySalesStaging table is populated
      EXEC sp_log 1, @fn,'005: Validating preconditions';
      EXEC sp_log 1, @fn,'010: Validating  PRE01:  PropertySalesStaging table is populated';
      EXEC sp_assert_tbl_pop 'PropertySalesStaging';

      EXEC sp_log 1, @fn,'015: Processing';
      EXEC sp_log 1, @fn,'020: clearing ContactAgency, Agency, Contact,PropertySales';

      DELETE FROM PropertySales;
      DELETE FROM ContactAgency;
      DELETE FROM Agency;
      DELETE FROM Delegate;

      -- Clean up fields:
      --UPDATE PropertySalesStaging SET quality = NULL WHERE quality = 'NULL'
      EXEC sp_log 1, @fn,'025: merge PropertySales dependencies first';-- Declare a table variable to capture OUTPUT results
      DECLARE @MergeOutput TABLE (
    [Action] NVARCHAR(10),
    Delegate_nm NVARCHAR(100) -- Adjust data type to match your delegate_nm column
);

      EXEC sp_log 1, @fn,'030: merge Delegate table';
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

      EXEC sp_log 1, @fn,'035: merged ', @cnt,' rows into the Delegate table';

      -- Merge Contact Table
      EXEC sp_log 1, @fn,'040: merge Contact table';
      DELETE FROM Contact;

      MERGE INTO Contact AS target
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
         DELETE;

      SELECT * FROM Contact;

/*      INSERT INTO Contact(contact_nm)
      SELECT distinct s1.value as contact
      FROM PropertySalesStaging ps
      CROSS APPLY string_split(Contact_nm, ',') as s1
      WHERE value <> ''
      ORDER BY s1.value;*/

      EXEC sp_log 1, @fn,'045: Merge Agency table';

      -- Merge Agency Table
      MERGE INTO Agency AS target
      USING (
         SELECT DISTINCT name
         FROM PropertySalesStaging 
         WHERE name IS NOT NULL
      ) AS source
      ON target.agency_nm = source.name
      WHEN NOT MATCHED BY TARGET THEN
         INSERT (agency_nm)
         VALUES (source.name)
      WHEN NOT MATCHED BY SOURCE THEN
         DELETE;

      -- Update Agency set the default phone number to be the phone number from 
      -- PropertySalesStaging where no contacts specified
      EXEC sp_log 1, @fn,'050: update Agency default phone number where no contacts specified';
      UPDATE Agency
      SET phone = ps.phone
      FROM PropertySalesStaging ps JOIN Agency a ON ps.name = a.agency_nm
      WHERE ps.Contact_nm IS  NULL
      ;

      EXEC sp_log 1, @fn,'055: update Agency default phone number with the first contact phone';
      UPDATE Agency
      SET phone = X.default_phone
      FROM Agency
      INNER JOIN
      (
         SELECT name, MIN(dbo.fnTrim(s1.value)) AS default_phone
         FROM PropertySalesStaging ps
         CROSS APPLY string_split(phone, ',') AS s1
         WHERE s1.value <> ''
         GROUP BY name
      ) X
      ON Agency.agency_nm = X.name;

      -- update agency: address, email, delegate, facebook, messenger, viber,whatsApp
      -- treated as single fields
      EXEC sp_log 1, @fn,'060: update Agency: address, email, delegate, facebook, messenger, viber,whatsApp,website';
      UPDATE Agency
      SET
          [address]  = X.[address]
         ,email      = X.email
         ,facebook   = X.facebook
         ,messenger  = X.messenger
         ,viber      = X.viber
         ,whatsApp   = X.whatsApp
         ,website    = X.website
      FROM Agency
      INNER JOIN
      (
         SELECT name, viber, whatsApp, ps.[address], ps.delegate_nm, ps.email, ps.messenger, ps.facebook, ps.website
         FROM PropertySalesStaging ps
      ) X
      ON Agency.agency_nm = X.name;

      EXEC sp_log 1, @fn,'065: Pop PropertySales';
      INSERT INTO PropertySales
      (
 agency_id,agencyType_id,area_id,delegate_id,status_id
,notes/*,quality*/,phone,preferred_contact_method
,email, first_reg,whatsapp,viber,facebook,messenger,website
,[address],[notes_2],[old_notes]
--,[date_1]
,[actions_08_oct],[jan_16_2025]
,[action_by_dt]
,[replied],[history]
      )
      SELECT
 agency_id,t.agencyType_id,a.area_id,d.delegate_id,s.status_id
,pss.first_reg,pss.notes/*,SUBSTRING(pss.quality,1,2)*/,pss.phone,pss.preferred_contact_method
,pss.email,pss.whatsapp,pss.viber,pss.facebook,pss.messenger,pss.website
,pss.[address],pss.[notes_2],pss.old_notes
--,TRY_CAST([date_1] AS DATE)
,pss.[Actions_08_OCT],pss.[Jan_16_2025]
,TRY_CAST(pss.action_by_dt AS DATE)
,pss.[replied],pss.[history]
FROM PropertySalesStaging pss
LEFT JOIN Agency     ag ON pss.name     = ag.agency_nm
LEFT JOIN AgencyType  t ON pss.[Type]   = t.agencyType_nm
LEFT JOIN Area        a ON pss.area       = a.area_nm
LEFT JOIN Delegate    d ON pss.delegate_nm= d.alias
LEFT JOIN [Status]    s ON pss.[status]   = s.status_nm
;

      SELECT @rc = COUNT(*) FROM PropertySales;

      EXEC sp_log 1, @fn,'070: PropertySales now contains ', @rc, ' rows';
      EXEC sp_log 1, @fn,'075: PropertySales Pop Contact table';

      IF @display_tables = 1
      BEGIN
         SELECT * FROM PropertySales;
         SELECT * FROM Contact;
      END

      IF @display_tables = 1
         SELECT * FROM Agency;

      -- Merge ContactAgency Table
      EXEC sp_log 1, @fn,'080:  MERGE ContactAgency';
      DELETE FROM ContactAgency;
      EXEC sp_log 1, @fn,'081:  MERGE ContactAgency';

      MERGE INTO ContactAgency AS target
      USING
      (
         SELECT X.name, cntct_nm, agency_id, contact_id
         FROM
         (
            SELECT pss.name, dbo.fnTrim(cntct_nm.value) as cntct_nm, agency_id, role_pr.value as role_pr
            FROM PropertySalesStaging pss 
            LEFT JOIN Agency a ON pss.name=a.agency_nm
            CROSS APPLY string_split(pss.contact_nm, ',', 1) as cntct_nm
            CROSS APPLY string_split(pss.[role], ',', 1) as role_pr
            WHERE cntct_nm.value <> '' AND cntct_nm.ordinal = role_pr.ordinal
         ) X
         LEFT JOIN Contact c ON c.contact_nm = cntct_nm
         
         --CROSS APPLY dbo.fnSplitPair2(pr.value, ':') as pr2
      ) AS source
      ON target.contact_id = source.contact_id AND target.agency_id = source.agency_id
      WHEN NOT MATCHED BY TARGET THEN
         INSERT (contact_id, agency_id) --, role_nm)
         VALUES (source.contact_id, source.agency_id) --, source.contact_role)
      WHEN NOT MATCHED BY SOURCE THEN
         DELETE
      ;

      EXEC sp_log 1, @fn,'085:  MERGED ContactAgency';
      SELECT * FROM ContactAgency;

      EXEC sp_log 1, @fn,'090:  MERGE Delegate';
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
      ;

      EXEC sp_log 1, @fn,'100:  MERGED Delegate';
      -- Validating Postconditions:
      -- POST01: PropertySales table is populated
      EXEC sp_log 1, @fn,'200: Validating postconditions';
      EXEC sp_log 1, @fn,'210: Validating  POST01: PropertySales table is populated'
      EXEC sp_assert_tbl_pop 'PropertySales';
      EXEC sp_assert_tbl_pop 'Agency';
      EXEC sp_assert_tbl_pop 'Contact';
      EXEC sp_log 1, @fn,'300: postconditions validated';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn,'999: leaving, RC: ', @rc;
   RETURN @rc;
END
/*
EXEC test.test_079_sp_migrate_propertySales;
EXEC tSQLt.Run 'test_079_sp_migrate_propertySales';
*/
