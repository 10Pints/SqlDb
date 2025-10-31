CREATE VIEW Agent_vw
AS
SELECT
    ag.agency_id             AS ag_agency_id         
   ,ag.agency_nm             AS ag_agency_nm         
   ,ag.agencyType_id         AS ag_agency_type_if    
   ,ag.agencyType_nm         AS ag_agency_type_nm    
   ,ar.area_nm               --   AS ag_area              
   ,d.delegate_nm            AS ag_delegate          
   ,d.delegate_nm            --AS delegate_nm          
   ,ag.delegate_id           --AS ag_delegate_id       
   ,s.status_nm             --AS ag_status            
   ,ag.first_reg             AS ag_first_reg         
   ,ag.quality               AS ag_quality           
   ,ag.notes                 AS ag_notes             
   ,ag.phone                 AS ag_phone             
   ,ag.viber                 AS ag_viber             
   ,ag.whatsApp              AS ag_whatsApp          
   ,ag.facebook              AS ag_facebook          
   ,ag.messenger             AS ag_messenger         
   ,ag.website               AS ag_website           
   ,ag.email                 AS ag_email             
   ,ag.primary_contact_id    AS ag_primary_contact_id
   ,ag.address               AS ag_address           
   ,ca.agency_id as ca_agency_id, ca.contact_id as ca_contact_id
   ,c.contact_id
   ,c.contact_nm
   ,c.facebook
   ,c.is_active
   ,c.last_contacted
   ,c.messenger
   ,c.phone
   ,c.primary_contact_detail
   ,c.primary_contact_type
   ,c.[role]
   ,c.sex
   ,c.age
   ,c.viber
   ,c.whatsApp
FROM      Agency ag
LEFT JOIN ContactAgency ca ON CA.agency_id  = AG.agency_id
LEFT JOIN Contact        c ON ca.contact_id = c.contact_id
LEFT JOIN Delegate       d ON d.delegate_id = ag.delegate_id
LEFT JOIN Area          ar ON ar.area_id    = ag.area_id
LEFT JOIN Status         s ON s.status_id     = ag.status_id
;
/*
SELECT * FROM Agent_vw;
SELECT * FROM Contact;
SELECT * FROM Agency;
SELECT * FROM ContactAgency;
*/
