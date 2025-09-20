SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================================================
-- Author:      Terry Watts
-- Create date: 20-MAY-2020
-- Description: creates the sql for the
-- sp_report_countries_best, worst sps
-- It samples 2 bloks of data, defined by @start and @end import dates 
-- and takes the deltas for a set of key fields over the @sample_period number days for each blok
-- So blok 1 is from @start - @sample_period  to @start
--    blok 2 is from @end   - @sample_period  to @end
--
-- improvement is defined as (delta 1 - delta 2) which is raw data 
-- and therefore is not directly comparable beteween countries of different populations
--
-- improvement% is directly comparable beteween countries as defined thus:
-- 
--    improvement% = (delta_1 - delta_2)/delta_1 * 100 
--
-- Parameters:
-- @end              end date of the poll
-- @interval         period in days petween start and end dates
-- @sample_period    width in days of each block
-- @start            
-- @sig              dconf_pp minimum threshold
-- @top              number of rows in the returned list
-- @min_pop_M        minimum pop threshold in millions
-- @max_pop_M        maximum pop threshold in millions
-- @order_by         order by field
-- @dir              list order: ASC or DESC
--
-- PRECONDITIONS:
--    sp_prcs_update_delats run after import
--
-- Algorithm:
--    Get 2 bloks A, B
--    A is the first, B is the second
--    each blok is interval long
--    B goes from End-interval to end
--    A goes from End-2*interval to End-interval
--    calc the average performance of both by taking the average (AvgA,Avg B ) 
--    of the start value and the end value for each block
--    Compare these (AvgB-AvgA)/AvgA as % so:
--
-- Dependencies:
--    sp_prcs_crt_sql_for_trnd_rpt
--    sp_rpt_countries_int_wrst
--    sp_pri_rpt_countries_sub -> sp_rpt_countries_int_bst -> sp_rpt_countries_bst_wrst]
--    
-- test: [test].[test 008_sp_pri_rpt_countries_sub NOTRAN]
-- ============================================================================================================
CREATE FUNCTION [dbo].[fnCreateTrendSql]
(
    @tgt_date           DATE
   ,@interval           INT         = NULL      -- days
   ,@sample_width       INT         = NULL
   ,@min_confirmed      INT         = 200
   ,@top                INT         = 20
   ,@min_pop_M          FLOAT       = 5         -- Millions
   ,@max_pop_M          FLOAT       = 2000      -- Millions
   ,@order_by           NVARCHAR(25)= NULL
   ,@country_filter     NVARCHAR(60)= NULL
   ,@dir                NVARCHAR(4) = NULL      -- ASC or DESC def: ASC
)
RETURNS NVARCHAR (4000)
AS
BEGIN
   DECLARE
    @sql                NVARCHAR(4000)
   ,@start              DATE        = NULL
   ,@end                DATE
   ,@blok1_st           DATE
   ,@blok1_end          DATE
   ,@blok2_st           DATE
   ,@blok2_end          DATE
   ,@NL                 NVARCHAR(2) = NCHAR(13)+NCHAR(10)

     
   -- Set Defaults:
   IF @interval         IS NULL SET @interval      = 10        -- days
   
   IF @order_by         IS NULL SET @order_by      = 'conf_end';
   IF @country_filter   IS NULL SET @country_filter= '%';
   IF @dir              IS NULL SET @dir           = 'ASC';
   IF @start            IS NULL SET @start         = DATEADD(DAY, -2*@interval, @end)
   ;

   SET @sample_width = @sample_width/2;
   SET @interval     = @interval/2;


   SET @blok1_st    = DATEADD(DAY, -@interval-@sample_width, @tgt_date);
   SET @blok1_end   = DATEADD(DAY, -@interval+@sample_width , @tgt_date);
   SET @blok2_st    = DATEADD(DAY,  @interval-@sample_width , @tgt_date);
   SET @blok2_end   = DATEADD(DAY,  @interval+@sample_width , @tgt_date);

   --SET @blok1_st_str  = FORMAT(@blok1_st,  'yyyy-MMM-dd');
   --SET @blok2_st_str  = FORMAT(@blok2_st,  'yyyy-MMM-dd');
   --SET @blok1_end_str = FORMAT(@blok1_end, 'yyyy-MMM-dd');
   --SET @blok2_end_str = FORMAT(@blok2_end, 'yyyy-MMM-dd');

   RETURN CONCAT(
 'SELECT TOP ',@top, 
  '  country'                                                        , @NL
 ,' ,ROUND((delta_conf_1- delta_conf_2)*100.0/'                      , @NL
 ,'iif(delta_conf_1=0, 1, delta_conf_1), 2)     AS [improvement%]'   , @NL
 ,', (delta_conf_1- delta_conf_2)               AS [improvement]'    , @NL
 ,', ROUND(delta_conf_1/ pop * 1000000, 2)      AS delta_conf_pp_1'  , @NL
 ,', ROUND(delta_conf_2/ pop * 1000000, 2)      AS delta_conf_pp_2'  , @NL
 ,', cv_density'                                                     , @NL
 ,', dlta_cnf_blk1_st, dlta_cnf_blk1_end, dlta_cnf_blk2_st, dlta_cnf_blk2_end', @NL -- 3 daily deltas - st, mid, end
 ,', delta_conf_1'                                                   , @NL -- 2 period deltas blok 1, blok 2
 ,', delta_conf_2'                                                   , @NL -- 2 period deltas
 ,', delta_conf_1/' ,@sample_width * 2, '           AS [delta_conf_1/day]', @NL
 ,', delta_conf_2/' ,@sample_width * 2, '           AS [delta_conf_2/day]', @NL
 ,', blok1_st, blok1_end, blok2_st, blok2_end'                       , @NL
 ,', conf_blok1_st, conf_blok1_end, conf_blok2_st, conf_blok2_end'   , @NL
 ,', kaput_st, kaput_mid, kaput_end'                                 , @NL
 ,', delta_kaput_1, delta_kaput_2, [kaput/conf%], [kaput/pop%]'      , @NL
 ,', area'                                                           , @NL
 ,', pop'                                                            , @NL
 ,', pop_density'                                                    , @NL
 ,', [conf%]'                                                        , @NL
 ,', sr_ratio'                                                       , @NL
 ,' FROM '                                                           , @NL
,'('                                                                 , @NL
,'SELECT'                                                            , @NL
,' country'                                                          , @NL
,',area'                                                             , @NL
,',pop'                                                              , @NL
,',pop_density'                                                      , @NL
,',import_date_st                               AS blok1_st'         , @NL
,',import_date_end                              AS blok1_end'        , @NL
,',conf_st                                      AS conf_blok1_st'    , @NL
,',conf_end                                     AS conf_blok1_end'   , @NL
,',delta_conf                                   AS delta_conf_1'     , @NL
,',delta_conf_st                                AS dlta_cnf_blk1_st' , @NL
,',delta_conf_end                               AS dlta_cnf_blk1_end', @NL
,',kaput_st                                     AS kaput_st'         , @NL
,',kaput_end                                    AS kaput_mid'        , @NL
,',delta_kaput                                  AS delta_kaput_1'    , @NL
,'FROM dbo.fnDeltaStats(''',@country_filter,''',','''', @blok1_st,''',',''''   ,@blok1_end,'''', ') '                      , @NL
,'WHERE popM between '     ,@min_pop_M, ' AND ', @max_pop_M          , @NL
,') A JOIN '                                                         , @NL
,'('                                                                 , @NL
,'SELECT '                                                           , @NL
,' country as country2'                                              , @NL
,',import_date_st                               AS blok2_st'         , @NL
,',import_date_end                              AS blok2_end'        , @NL
,',cv_density'                                                       , @NL
,',conf_st                                      AS conf_blok2_st'    , @NL
,',conf_end                                     AS conf_blok2_end'   , @NL
,',delta_conf                                   AS delta_conf_2'     , @NL
,',delta_conf_st                                AS dlta_cnf_blk2_st' , @NL
,',delta_conf_end                               AS dlta_cnf_blk2_end', @NL
,',delta_conf_end'                                                   , @NL
,',dbo.fnPerCentOfPop2(conf_end, pop, 4)        AS [conf%]'          , @NL
,',kaput_end'                                                        , @NL
,',delta_kaput AS delta_kaput_2'                                     , @NL
,',delta_conf_end                               AS delta_conf'       , @NL
,',sr_ratio                                     AS sr_ratio'         , @NL
,',dbo.fnPerCentOfPop2(kaput_end, pop, 4)       AS [kaput/pop%]'     , @NL
,',dbo.fnPerCentOfPop2(kaput_end, conf_end, 4)  AS [kaput/conf%]'    , @NL
,'FROM dbo.fnDeltaStats(''',@country_filter,''',','''',@blok2_st,''',',''''   ,@blok2_end,'''', ') '                    , @NL
,'WHERE conf_end >= '      ,@min_confirmed                           , @NL
,' AND  popM between '     ,@min_pop_M, ' AND ', @max_pop_M          , @NL
,') B ON A.country = B.country2'                                     , @NL
, @NL
,'ORDER BY [',@order_by,'] ',@dir, ';'                               , @NL);
END
/*
*/

GO
