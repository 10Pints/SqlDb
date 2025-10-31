CREATE PROCEDURE dbo.sp_get_filtered_contacts
    @FilterJSON NVARCHAR(MAX)
AS
BEGIN
   DECLARE 
       @fn  VARCHAR(35)='sp_get_filtered_contacts'
      ,@cnt INT
   ;

   EXEC sp_log 1, @fn, '000: starting:
@FilterJSON:[',@FilterJSON,']
';

   SELECT
      contact_id,
      contact_nm,
      role,
      phone,
      viber,
      whatsApp,
      facebook,
      messenger,
      primary_contact_type,
      primary_contact_detail,
      last_contacted,
      is_active,
      sex,
      age
   FROM Contact 
   WHERE
   (
      age >= ISNULL(JSON_VALUE(@FilterJSON, '$.MinAge'), 0) 
      AND age <= ISNULL(JSON_VALUE(@FilterJSON, '$.MaxAge'), 100))
      AND
      (
         ISNULL(JSON_VALUE(@FilterJSON, '$.Sex'), 'Both') = 'Both' 
         OR sex = JSON_VALUE(@FilterJSON, '$.Sex'
      )
   )
   ORDER BY contact_nm;

   SET @cnt = @@ROWCOUNT;
   EXEC sp_log 1, @fn, '999: leaving, found ', @cnt, ' rows';
END