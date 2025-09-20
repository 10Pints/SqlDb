SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Covid](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[country_nm] [nvarchar](28) NOT NULL,
	[import_date] [date] NOT NULL,
	[confirmed] [int] NULL,
	[deaths] [int] NULL,
	[recovered] [int] NULL,
	[delta_conf] [int] NULL,
	[delta_deaths] [int] NULL,
	[delta_recovered] [int] NULL,
	[last_update] [date] NULL,
	[country_id] [int] NOT NULL,
	[last_import_file] [nvarchar](500) NULL,
	[sr_ratio] [float] NULL,
	[confirmed-17 days] [int] NULL,
	[notes] [nvarchar](max) NULL,
 CONSTRAINT [PK_Covid] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Covid] UNIQUE NONCLUSTERED 
(
	[country_id] ASC,
	[import_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_Covid] ON [dbo].[Covid]
(
	[country_id] ASC,
	[import_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

ALTER TABLE [dbo].[Covid]  WITH CHECK ADD  CONSTRAINT [FK_Covid_Country] FOREIGN KEY([country_id])
REFERENCES [dbo].[Country] ([id])

ALTER TABLE [dbo].[Covid] CHECK CONSTRAINT [FK_Covid_Country]

ALTER TABLE [dbo].[Covid]  WITH CHECK ADD  CONSTRAINT [FK_Covid_Country1] FOREIGN KEY([country_nm])
REFERENCES [dbo].[Country] ([name])

ALTER TABLE [dbo].[Covid] CHECK CONSTRAINT [FK_Covid_Country1]

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[COVID_TRIGGER_DELETE_AFTER] ON [dbo].[Covid] AFTER DELETE
AS BEGIN
   DECLARE 
      @cnt_ins INT

   SELECT @cnt_ins = COUNT(*) FROM DELETED;

   PRINT CONCAT('DELETED after trigger called, count:', @cnt_ins);

   IF EXISTS(SELECT 1 FROM DELETED)
   BEGIN
      INSERT INTO [Audit]([action], id, country_id,country_nm,import_date,last_update,confirmed,delta_conf,deaths,delta_dead,recovered,delta_recovered)
      SELECT 'DELETE', id, country_id,country_nm,import_date,last_update,confirmed,delta_conf,deaths,delta_dead,recovered,delta_recovered
      FROM DELETED;

      -- update deltas after deleting data
      EXEC [dbo].[sp_prcs_update_deltas]
   END
END;

ALTER TABLE [dbo].[Covid] ENABLE TRIGGER [COVID_TRIGGER_DELETE_AFTER]

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:        Terry watts
-- Create date:   24-JAN-2020
-- Description:   
-- =============================================
CREATE TRIGGER [dbo].[COVID_TRIGGER_INSERT_AFTER] ON [dbo].[Covid] AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   DECLARE 
      @cnt_ins INT

   SELECT @cnt_ins = COUNT(*) FROM INSERTED;

   PRINT CONCAT('INSERT after trigger called, count:', @cnt_ins);
   SELECT  i.import_date,  'INSERT' as [ACTION: INSERT], i.country_nm
         , i.confirmed,    i.delta_conf,  i.deaths
         , i.delta_dead,   i.recovered,   i.delta_recovered
--         , i.sr_ratio,     i.country_id,  i.last_update
         , i.last_import_file
   FROM INSERTED i 

   INSERT INTO [Audit]
   (
        [action], country_id
      , country_nm,  import_date,   last_update
      , confirmed,   delta_conf,    deaths
      , delta_dead,  recovered,     delta_recovered
--      , sr_ratio
      ,last_import_file
      )
   SELECT
        --cv.id,          
         'INSERT',      i.country_id
      , i.country_nm,   i.import_date, i.last_update
      , i.confirmed,    i.delta_conf,  i.deaths
      , i.delta_dead,   i.recovered,   i.delta_recovered
--      , i.sr_ratio
         , i.last_import_file
   FROM INSERTED i 
END

ALTER TABLE [dbo].[Covid] ENABLE TRIGGER [COVID_TRIGGER_INSERT_AFTER]

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:        Terry watts
-- Create date:   24-JAN-2021
-- Description:   
-- =============================================
CREATE TRIGGER [dbo].[COVID_TRIGGER_UPDATE_AFTER] ON [dbo].[Covid] AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   DECLARE 
        @id INT
       ,@cnt_ins INT
       ,@cnt_del INT
       ,@cnt_covid INT

   SELECT @cnt_covid = COUNT(*) FROM Covid;
   SELECT @cnt_ins   = COUNT(*) FROM INSERTED;
   SELECT @cnt_del   = COUNT(*) FROM DELETED;

   PRINT CONCAT('UPDATE after trigger called, counts: INS: ', @cnt_ins, ' DEL: ', @cnt_del);

   IF @cnt_ins < @cnt_covid
   BEGIN
      PRINT 'UPDATE after trigger updating audit'; 

SELECT 
     i.import_date, 'UPDATE'  AS [ACTION: UPDATE]
     , iif(i.confirmed  <> d.confirmed, 'confirmed', iif(i.deaths  <> d.deaths, 'deaths', iif(i.recovered  <> d.recovered, 'recovered', 'other field'))) as changed_field
   , i.country_nm       AS country_nm  --    , d.country_nm          AS country_nm_old
   , i.confirmed        AS confirmed         , d.confirmed           AS confirmed_old
   , i.deaths           AS deaths            , d.deaths              AS deaths_old
   , i.recovered        AS recovered         , d.recovered           AS recovered_old
   , i.delta_conf       AS delta             , d.delta_conf          AS delta_conf_old
   , i.delta_dead       AS delta_dead        , d.delta_dead          AS delta_dead_old
   , i.delta_recovered  AS delta_recovered   , d.delta_recovered     AS delta_recovered_old
   , d.import_date      AS import_date_old   
   , i.last_update      AS last_update       , d.last_update         AS last_update_old
   , i.id               AS id                , d.id                  AS id_old
   , i.last_import_file AS last_import_file  , d.last_import_file    AS last_import_file_old
   , GetDate()          AS updated
FROM INSERTED I FULL JOIN DELETED D ON i.country_nm = d.country_nm AND i .import_date =d.import_date
WHERE 
      i.confirmed       <> d.confirmed
   OR i.deaths          <> d.deaths
   OR i.recovered       <> d.recovered
   OR i.delta_conf      <> d.delta_conf
   OR i.delta_dead      <> d.delta_dead
   OR i.delta_recovered <> d.delta_recovered
--   OR i.sr_ratio        <> d.sr_ratio
   OR i.last_update     <> d.last_update

INSERT INTO dbo.[AUDIT]
(
   [action], country_id, country_nm, import_date
   , confirmed       , confirmed_old
   , deaths          , deaths_old
   , recovered       , recovered_old
   , delta_conf      , delta_conf_old
   , delta_dead      , delta_dead_old
   , delta_recovered , delta_recovered_old
   , last_update     , last_update_old
   , id
   , changed_field
   , last_import_file
   , last_import_file_old
)
SELECT 'UPDATE'
   , i.country_id       AS i_country_id
   , i.country_nm       AS i_country_nm
   , i.import_date
   , i.confirmed        AS i_confirmed      , d.confirmed       AS d_confirmed
   , i.deaths           AS i_deaths         , d.deaths          AS d_deaths         
   , i.recovered        AS i_recovered      , d.recovered       AS d_recovered      
   , i.delta_conf       AS i_delta_conf     , d.delta_conf      AS d_delta_conf     
   , i.delta_dead       AS i_delta_dead     , d.delta_dead      AS d_delta_dead     
   , i.delta_recovered  AS i_delta_recovered, d.delta_recovered AS d_delta_recovered
   , i.last_update      AS i_last_update    , d.last_update     AS d_last_update    
   , i.id               AS i_id
   , iif(i.confirmed  <> d.confirmed, 'confirmed', iif(i.deaths  <> d.deaths, 'deaths', iif(i.recovered  <> d.recovered, 'recovered', 'other field'))) AS changed_field
   , i.last_import_file AS last_import_file  , d.last_import_file    AS last_import_file_old
FROM INSERTED I FULL JOIN DELETED D ON i.country_nm = d.country_nm AND i.import_date = d.import_date
WHERE 
      i.confirmed       <> d.confirmed
   OR i.deaths          <> d.deaths
   OR i.recovered       <> d.recovered
   OR i.delta_conf      <> d.delta_conf
   OR i.delta_dead      <> d.delta_dead
   OR i.delta_recovered <> d.delta_recovered
   OR i.last_update     <> d.last_update
;
   END
END

/*
*/

ALTER TABLE [dbo].[Covid] ENABLE TRIGGER [COVID_TRIGGER_UPDATE_AFTER]

GO
