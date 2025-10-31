



CREATE VIEW [dbo].[Agency_vw]
AS
SELECT
    ag.agency_id             --AS agency_id
   ,ag.agency_nm             --AS agency_nm
   ,ag.agencyType_id         --AS agency_type_if
   ,aty.agencyType_nm        AS agencyType_nm
   ,ar.area_id
   ,ar.area_nm
   ,d.delegate_id
   ,d.delegate_nm
   ,s.status_id
   ,s.status_nm
   ,ag.first_reg             --AS ag_first_reg
   ,ag.notes                 --AS ag_notes
   ,ag.quality               --AS ag_quality
   ,ag.primary_contact_id
   ,c.contact_nm              AS primary_contact_nm
   ,c.primary_contact_detail  --AS prmry_cntct_primary_contact_detail
   ,c.primary_contact_type    --AS prmry_cntct_primary_contact_type
   ,ag.preferred_contact_method
   ,c.[role]                  --AS prmry_cntct_role
   ,ag.phone                 --AS ag_phone
   ,ag.email                 --AS ag_email
   ,ag.whatsApp              --AS ag_whatsApp
   ,ag.viber                 --AS ag_viber
   ,ag.facebook              --AS ag_facebook
   ,ag.messenger             --AS ag_messenger
   ,ag.website               --AS ag_website
   ,ag.[address]              --AS ag_address
   ,notes_2
   ,old_notes
   ,c.age                     --AS prmry_cntct_age
   ,actions_08_OCT
   ,jan_16_2025
   ,action_by_dt
   ,replied
   ,history
   ,c.is_active               --AS prmry_cntct_is_active
   ,c.last_contacted          --AS prmry_cntct_last_contacted
   ,c.sex                     --AS prmry_cntct_sex
FROM      Agency ag
left join AgencyType ATY   ON ATY.agencyType_id = ag.agencyType_id
LEFT JOIN ContactAgency ca ON CA .agency_id     = ag.agency_id
LEFT JOIN Contact        c ON c  .contact_id    = ag.primary_contact_id
LEFT JOIN Delegate       d ON d  .delegate_id   = ag.delegate_id
LEFT JOIN Area          ar ON ar .area_id       = ag.area_id
LEFT JOIN Status         s ON s  .status_id     = ag.status_id
;
/*
SELECT * FROM Agency_vw;
SELECT * FROM Contact;
SELECT * FROM Agency;
SELECT * FROM ContactAgency;
*/
