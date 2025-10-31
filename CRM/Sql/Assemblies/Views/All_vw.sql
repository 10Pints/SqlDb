



CREATE VIEW [dbo].[All_vw]
AS
SELECT
       ag.agency_nm
      ,t.agencyType_nm
      ,a.area_nm
      ,d.[delegate_nm]
      ,s.[status_nm]
      ,c.[contact_nm]
      ,ps.[notes]
      ,ps.[quality]
      ,ps.[phone]
      ,ps.[preferred_contact_method]
      ,ps.[email]
      ,ps.[whatsapp]
      ,ps.[viber]
      ,ps.[facebook]
      ,ps.[messenger]
      ,ps.[website]
      ,ps.[address]
      ,ps.[notes_2]
      ,ps.[old_notes]
      ,ps.[date_1]
      ,ps.[actions_08_oct]
      ,ps.first_reg
      ,ps.[jan_16_2025]
      ,ps.[action_by_dt]
      ,ps.[replied]
      ,ps.[history]
FROM PropertySales ps 
LEFT JOIN Agency   ag ON ps.agency_id = ag.agency_id
LEFT JOIN AgencyType   t ON ps.agencyType_id = t.agencyType_id
LEFT JOIN Area     a ON ps.area_id   = a.area_id
LEFT JOIN Delegate d ON ps.delegate_id = d.delegate_id
LEFT JOIN [Status] s ON ps.status_id = s.status_id
LEFT JOIN ContactAgency ca ON ps.agency_id = ca.agency_id
LEFT JOIN Contact  c ON ca.contact_id = c.contact_id
;
/*
SELECT * FROM PropertySales_vw;
*/
