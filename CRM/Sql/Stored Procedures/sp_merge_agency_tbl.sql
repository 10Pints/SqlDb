-- ================================================================
-- Author:      Terry Watts
-- Create date: 02-OCT-2025
-- Description: Merges the Agency table from PropertySalesStaging
-- Returns      the merge count
-- Design:
-- Tests:
-- ================================================================
CREATE PROCEDURE [dbo].[sp_merge_agency_tbl] @display_tables BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
     @fn    VARCHAR(35) = 'sp_merge_agency_tbl'
    ,@cnt   INT
   ;

   EXEC sp_log 1, @fn,'000: starting
@display_tables:[', @display_tables,']';

-- Declare a table variable to capture OUTPUT results
   EXEC sp_log 1, @fn,'010: calling sp_pop_AgencyStaging_tbl';

   -- Merge AgencyStaging Table
   EXEC sp_pop_AgencyStaging_tbl @display_tables;
   EXEC sp_log 1, @fn,'020: ret frm sp_pop_AgencyStaging_tbl';
   DELETE FROM AgencyMergeOutput;

   -- Merge Agency Table
   EXEC sp_log 1, @fn,'030: Merging Agency Table';
   MERGE INTO Agency AS target
   USING (
      SELECT
          agency_nm , agencyType_id ,area_id       , delegate_id, status_id
         ,first_reg , notes         ,quality       , contact_id , preferred_contact_method
         ,A.[role]  , A.phone       ,email         , A.whatsApp , A.viber
         ,A.facebook, A.messenger   ,website       , [address]  , notes_2
         ,old_notes , A.age         ,actions_08_OCT, jan_16_2025, action_by_dt
         ,replied   , history
      FROM
                   AgencyStaging A
         LEFT JOIN Delegate      D   ON A.delegate_nm       = d.delegate_nm
         LEFT JOIN AgencyType    ATY ON aty.agencyType_nm   = A.agency_type
         LEFT JOIN Area          AR  ON ar.area_nm          = A.area
         LEFT JOIN [status]      S   ON s.status_nm         = A.[status]
         LEFT JOIN contact       C   ON c.contact_nm        = A.primary_contact_nm
      ) AS source
   ON target.agency_nm = source.agency_nm
   WHEN NOT MATCHED BY TARGET THEN
      INSERT
      (
          agency_nm  ,agencyType_id,area_id        ,delegate_id         ,status_id
         ,first_reg  ,notes        ,quality        ,primary_contact_id  ,preferred_contact_method
         ,[role]     ,phone        ,email          ,whatsApp            ,viber
         ,facebook   ,messenger    ,website        ,[address]           ,notes_2
         ,old_notes  ,age          ,actions_08_OCT ,jan_16_2025         ,action_by_dt
         ,replied    ,history
      )
      VALUES
      (
          source.agency_nm ,source.agencyType_id   ,source.area_id         ,source.delegate_id  ,source.status_id
         ,source.first_reg ,source.notes           ,source.quality         ,source.contact_id   ,source.preferred_contact_method
         ,source.[role]    ,source.phone           ,source.email           ,source.whatsApp     ,source.viber
         ,source.facebook  ,source.messenger       ,source.website         ,source.[address]    ,source.notes_2
         ,source.old_notes ,source.age             ,source.actions_08_OCT  ,source.jan_16_2025  ,TRY_CAST(source.action_by_dt AS DATE)
         ,source.replied   ,source.history
)
   WHEN MATCHED THEN
      UPDATE SET
          agencyType_id             = iif(source.agencyType_id             IS NOT NULL, source.agencyType_id            , target.agencyType_id           )
         ,area_id                   = iif(source.area_id                   IS NOT NULL, source.area_id                  , target.area_id                 )
         ,delegate_id               = iif(source.delegate_id               IS NOT NULL, source.delegate_id              , target.delegate_id             )
         ,status_id                 = iif(source.status_id                 IS NOT NULL, source.status_id                , target.status_id               )
         ,first_reg                 = iif(source.first_reg                 IS NOT NULL, source.first_reg                , target.first_reg               )
         ,notes                     = iif(source.notes                     IS NOT NULL, source.notes                    , target.notes                   )
         ,quality                   = iif(source.quality                   IS NOT NULL, source.quality                  , target.quality                 )
         ,primary_contact_id        = iif(source.contact_id        IS NOT NULL, source.contact_id       , target.primary_contact_id      )
         ,preferred_contact_method  = iif(source.preferred_contact_method  IS NOT NULL, source.preferred_contact_method , target.preferred_contact_method)
         ,[role]                    = iif(source.[role]                    IS NOT NULL, source.[role]                   , target.[role]                  )
         ,phone                     = iif(source.phone                     IS NOT NULL, source.phone                    , target.phone                   )
         ,email                     = iif(source.email                     IS NOT NULL, source.email                    , target.email                   )
         ,whatsApp                  = iif(source.whatsApp                  IS NOT NULL, source.whatsApp                 , target.whatsApp                )
         ,viber                     = iif(source.viber                     IS NOT NULL, source.viber                    , target.viber                   )
         ,facebook                  = iif(source.facebook                  IS NOT NULL, source.facebook                 , target.facebook                )
         ,messenger                 = iif(source.messenger                 IS NOT NULL, source.messenger                , target.messenger               )
         ,website                   = iif(source.website                   IS NOT NULL, source.website                  , target.website                 )
         ,[address]                 = iif(source.[address]                 IS NOT NULL, source.[address]                , target.[address]               )
         ,notes_2                   = iif(source.notes_2                   IS NOT NULL, source.notes_2                  , target.notes_2                 )
         ,old_notes                 = iif(source.old_notes                 IS NOT NULL, source.old_notes                , target.old_notes               )
         ,age                       = iif(source.age                       IS NOT NULL, source.age                      , target.age                     )
         ,actions_08_OCT            = iif(source.actions_08_OCT            IS NOT NULL, source.actions_08_OCT           , target.actions_08_OCT          )
         ,jan_16_2025               = iif(source.jan_16_2025               IS NOT NULL, source.jan_16_2025              , target.jan_16_2025             )
         ,action_by_dt              = iif(source.action_by_dt              IS NOT NULL, source.action_by_dt             , target.action_by_dt            )
         ,replied                   = iif(source.replied                   IS NOT NULL, source.replied                  , target.replied                 )
         ,history                   = iif(source.history                   IS NOT NULL, source.history                  , target.history                 )
   WHEN NOT MATCHED BY SOURCE THEN
      DELETE
   OUTPUT $action, 
          COALESCE(Inserted.agency_nm                 , Deleted.agency_nm                 ) AS agency_nm
         ,COALESCE(Inserted.agencyType_id             , Deleted.agencyType_id             ) AS agencyType_id
         ,COALESCE(Inserted.delegate_id               , Deleted.delegate_id               ) AS delegate_id
         ,COALESCE(Inserted.status_id                 , Deleted.status_id                 ) AS status_id
         ,COALESCE(Inserted.first_reg                 , Deleted.first_reg                 ) AS first_reg
         ,COALESCE(Inserted.notes                     , Deleted.notes                     ) AS notes
         ,COALESCE(Inserted.quality                   , Deleted.quality                   ) AS quality
         ,COALESCE(Inserted.primary_contact_id        , Deleted.primary_contact_id        ) AS primary_contact_id
         ,COALESCE(Inserted.preferred_contact_method  , Deleted.preferred_contact_method  ) AS preferred_contact_method
         ,COALESCE(Inserted.[role]                    , Deleted.[role]                    ) AS [role]
         ,COALESCE(Inserted.phone                     , Deleted.phone                     ) AS phone
         ,COALESCE(Inserted.email                     , Deleted.email                     ) AS email
         ,COALESCE(Inserted.whatsApp                  , Deleted.whatsApp                  ) AS whatsApp
         ,COALESCE(Inserted.viber                     , Deleted.viber                     ) AS viber
         ,COALESCE(Inserted.facebook                  , Deleted.facebook                  ) AS facebook
         ,COALESCE(Inserted.messenger                 , Deleted.messenger                 ) AS messenger
         ,COALESCE(Inserted.website                   , Deleted.website                   ) AS website
         ,COALESCE(Inserted.[address]                 , Deleted.[address]                 ) AS [address]
         ,COALESCE(Inserted.[notes_2]                 , Deleted.[notes_2]                 ) AS [notes_2]
         ,COALESCE(Inserted.old_notes                 , Deleted.old_notes                 ) AS old_notes
         ,COALESCE(Inserted.age                       , Deleted.age                       ) AS age
         ,COALESCE(Inserted.actions_08_OCT            , Deleted.actions_08_OCT            ) AS actions_08_OCT
         ,COALESCE(Inserted.jan_16_2025               , Deleted.jan_16_2025               ) AS jan_16_2025
         ,COALESCE(Inserted.action_by_dt              , Deleted.action_by_dt              ) AS action_by_dt
         ,COALESCE(Inserted.replied                   , Deleted.replied                   ) AS replied
         ,COALESCE(Inserted.history                   , Deleted.history                   ) AS history
   INTO AgencyMergeOutput
   ;
   EXEC sp_log 1, @fn,'040: Merged Agency Table';

   IF @display_tables = 1
   BEGIN
      SELECT 'Agency table' as [table];
      SELECT * FROM Agency;

      SELECT 'Inserted table' as [table];
      SELECT * FROM AgencyMergeOutput;
   END

   EXEC sp_log 1, @fn,'999: rurning, merged ', @cnt,' rows into the Agency table';
   RETURN @cnt;
END
/*
EXEC test.test_084_sp_merge_agency_tbl;

SELECT Agency, a.agency_nm FROM PropertySalesStaging pss Left join AgencyStaging a ON pss.agency = a.agency_nm;
SELECT agency_nm FROM AgencyStaging;
EXEC tSQLt.Run 'test.test_084_sp_merge_agency_tbl';
EXEC tSQLt.RunAll;

SELECT *
FROM PropertySalesStaging ps JOIN AgencyStaging a ON ps.Agency = a.agency_nm
      WHERE ps.Contact_nm IS NULL
      ;

SELECT * FROM AgencyStaging;
SELECT agency FROM PropertySalesStaging;
SELECT agency_nm FROM AgencyStaging;
EXEC test.sp__crt_tst_rtns 'dbo].[sp_merge_agency_tbl', @trn=84;
*/
