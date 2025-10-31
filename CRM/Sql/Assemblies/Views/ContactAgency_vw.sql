CREATE VIEW [dbo].[ContactAgency_vw]
AS
SELECT
       a.agency_nm
      ,c.contact_nm
      ,a.agency_id
      ,c.contact_id
FROM      Agency a
LEFT JOIN ContactAgency ca ON a.agency_id  = ca.agency_id
LEFT JOIN Contact        c ON ca.contact_id = c.contact_id
;
/*
SELECT * FROM ContactAgency_vw;
SELECT * FROM Contact;
SELECT * FROM Agency;
SELECT * FROM ContactAgency;
*/
