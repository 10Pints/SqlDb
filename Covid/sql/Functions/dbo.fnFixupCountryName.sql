SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 24-MAY-2020
-- Description: make country names consistent
-- =============================================
CREATE FUNCTION [dbo].[fnFixupCountryName] (@old_name      NVARCHAR(60))
RETURNS NVARCHAR(60)
BEGIN
    DECLARE 
       @new_name  NVARCHAR(60)

   SET @new_name = CASE
   WHEN @old_name LIKE '%Akrotiri%'                                THEN 'Akrotiri'
   WHEN @old_name LIKE '%Åland Islands%'                           THEN 'Aland Islands'
   WHEN @old_name LIKE '%Antigua%'                                 THEN 'Antigua'
   WHEN @old_name LIKE '%Bahamas%'                                 THEN 'Bahamas'
   WHEN @old_name LIKE '%Bonaire%Sint%'                            THEN 'Bonaire'
   WHEN @old_name LIKE '%Bolivia%'                                 THEN 'Bolivia'
   WHEN @old_name LIKE '%Bosnia%'                                  THEN 'Bosnia'
   WHEN @old_name LIKE '%British Indian Ocean Territory%'          THEN 'British Indian Ocean Territory'
   WHEN @old_name LIKE '%Brunei%'                                  THEN 'Brunei'
   WHEN @old_name LIKE '%Burma%'                                   THEN 'Myanmar'
   WHEN @old_name LIKE '%Caribbean Netherlands%'                   THEN 'Bonaire'
   WHEN @old_name LIKE '%Cabo Verde%'                              THEN 'Cabo Verde'
   WHEN @old_name LIKE '%Cape Verde%'                              THEN 'Cabo Verde'
   WHEN @old_name LIKE '%Cayman Islands%'                          THEN 'Cayman Islands'
   WHEN @old_name LIKE '%Central African Republic%'                THEN 'Central African Republic'
   WHEN @old_name LIKE '%Channel Island%'                          THEN 'United Kingdom'
   WHEN @old_name LIKE '%China%'                                   THEN 'China'
   WHEN @old_name LIKE '%Cocos'                                    THEN 'Cocos'
   WHEN @old_name LIKE '%Comoros%'                                 THEN 'Comoros'
   WHEN @old_name LIKE '%Congo (the Democratic Republic of the)%'  THEN 'Congo (Democratic Republic)'
   WHEN @old_name LIKE '%Congo (the)%'                             THEN 'Congo'
   WHEN @old_name LIKE '%Congo%Brazzaville%'                       THEN 'Congo'
   WHEN @old_name LIKE '%Congo%Kinshasa%'                          THEN 'Congo (Democratic Republic)'
   WHEN @old_name LIKE '%C[oô]t[e] d%'                             THEN 'Ivory Coast'
   WHEN @old_name LIKE '%C[oô]te d''Ivoire%'                       THEN 'Ivory Coast'
   WHEN @old_name LIKE '%Cook Islands%'                            THEN 'Cook Islands'
   WHEN @old_name LIKE '%Cruise Ship%'                             THEN 'Others'
   WHEN @old_name LIKE '%Curaçao%'                                 THEN 'Curacao'
   WHEN @old_name LIKE '%Cz%'                                      THEN 'Czechia'
   WHEN @old_name LIKE '%Democratic People%'                       THEN 'North Korea'
   WHEN @old_name LIKE '%Democratic Republic of Congo%'            THEN 'Congo (Democratic Republic)'
   WHEN @old_name LIKE '%Diamond Princess%'                        THEN 'Others'
   WHEN @old_name LIKE '%Dominican Republic%'                      THEN 'Dominican Republic'
   WHEN @old_name LIKE '%DR Congo%'                                THEN 'Congo (Democratic Republic)'
   WHEN @old_name LIKE '%East Timor%'                              THEN 'Timor'
   WHEN @old_name LIKE '%Eire%'                                    THEN 'Ireland'
   WHEN @old_name LIKE '%Ireland%'                                 THEN 'Ireland'
   WHEN @old_name LIKE '%Falkland Islands%'                        THEN 'Falkland Islands'
   WHEN @old_name LIKE '%Faroe Islands%'                           THEN 'Faroe Islands'
   WHEN @old_name LIKE '%Faeroe Islands%'                          THEN 'Faroe Islands'
   WHEN @old_name LIKE '%French Guiana%'                           THEN 'Guiana'
   WHEN @old_name LIKE '%French Southern Territories%'             THEN 'French Southern Territories'
   WHEN @old_name LIKE '%Gaza Strip%'                              THEN 'Palestine'
   WHEN @old_name LIKE '%Gambia%'                                  THEN 'Gambia'
   WHEN @old_name LIKE 'Guernsey%'                                 THEN 'United Kingdom'
   WHEN @old_name LIKE '%Heard Island%'                            THEN 'Heard Island'
   WHEN @old_name LIKE '%Holy See%'                                THEN 'Holy See'
   WHEN @old_name LIKE '%Hong Kong%'                               THEN 'Hong Kong'
   WHEN @old_name LIKE '%Iran%'                                    THEN 'Iran'
   WHEN @old_name LIKE '%Ivory Coast%'                             THEN 'Ivory Coast'
   WHEN @old_name LIKE 'Jersey%'                                   THEN 'United Kingdom'
   WHEN @old_name LIKE '%Korea%Republic of%'                       THEN 'South Korea'
   WHEN @old_name LIKE '%Korea%South%'                             THEN 'South Korea'
   WHEN @old_name LIKE '%Korea (the Democratic People%'            THEN 'North Korea'
   WHEN @old_name LIKE '%Korea%North%'                             THEN 'North Korea'
   WHEN @old_name LIKE '%Lao%'                                     THEN 'Laos'
   WHEN @old_name LIKE '%Macao%'                                   THEN 'Macao'
   WHEN @old_name LIKE '%Macau%'                                   THEN 'Macao'
   WHEN @old_name LIKE '%Macedonia%'                               THEN 'Macedonia'
   WHEN @old_name LIKE '%Marshall Islands%'                        THEN 'Marshall Islands'
   WHEN @old_name LIKE '%Micronesia%'                              THEN 'Micronesia'
   WHEN @old_name LIKE '%Moldova%'                                 THEN 'Moldova'
   WHEN @old_name LIKE '%MS Zaandam%'                              THEN 'Others'
   WHEN @old_name LIKE '%Myanmar%'                                 THEN 'Myanmar'
   WHEN @old_name LIKE '%Netherlands%'                             THEN 'Netherlands'
   WHEN @old_name LIKE '%Niger %'                                  THEN 'Niger'
   WHEN @old_name LIKE '%Nigeria%'                                 THEN 'Nigeria'
   WHEN @old_name LIKE '%North%Ireland'                            THEN 'United Kingdom'
   WHEN @old_name LIKE '%Northern Mariana Islands%'                THEN 'Northern Mariana Islands'
   WHEN @old_name LIKE '%Palestin%'                                THEN 'Palestine'
   WHEN @old_name LIKE '%Philipp%'                                 THEN 'Philippines'
   WHEN @old_name LIKE 'Republic of the Congo%'                    THEN 'Congo'
   WHEN @old_name LIKE '%Republic of Korea%'                       THEN 'South Korea'
   WHEN @old_name LIKE '%Russia%'                                  THEN 'Russia'
   WHEN @old_name LIKE '%R_union%'                                 THEN 'Reunion'
   WHEN @old_name LIKE '%Sahara%'                                  THEN 'Sahara'
   WHEN @old_name LIKE '%S% Barth_lemy%'                           THEN 'Saint Barthelemy'
   WHEN @old_name LIKE '%S% Helena%'                               THEN 'Saint Helena'
   WHEN @old_name LIKE '%S% Kitts%'                                THEN 'Saint Kitts'
   WHEN @old_name LIKE '%S% Christopher Island%'                   THEN 'Saint Kitts'
   WHEN @old_name LIKE '%S% Martin%'                               THEN 'Saint Martin'
   WHEN @old_name LIKE '%S% Pierre%'                               THEN 'Saint Pierre'
   WHEN @old_name LIKE '%S% Vincent%'                              THEN 'Saint Vincent'
   WHEN @old_name LIKE '%S[aã]o Tom[eé]%'                          THEN 'Sao Tome'
   WHEN @old_name LIKE '%Sint Maarten%'                            THEN 'Saint Martin'
   WHEN @old_name LIKE '%South Georgia%'                           THEN 'South Georgia'
   WHEN @old_name LIKE '%Sudan%'                                   THEN 'Sudan'
   WHEN @old_name LIKE '%Svalbard%'                                THEN 'Svalbard'
   WHEN @old_name LIKE '%Swaziland%'                               THEN 'Eswatini'
   WHEN @old_name LIKE '%Syria%'                                   THEN 'Syria'
   WHEN @old_name LIKE '%Taipei%'                                  THEN 'China'
   WHEN @old_name LIKE '%Taiwan%'                                  THEN 'China'
   WHEN @old_name LIKE '%Tanzania%'                                THEN 'Tanzania'
   WHEN @old_name LIKE '%Timor-Leste%'                             THEN 'Timor'
   WHEN @old_name LIKE '%Trinidad%'                                THEN 'Trinidad'
   WHEN @old_name LIKE '%Turks%Caicos%'                            THEN 'Turks and Caicos Islands'
   WHEN @old_name LIKE '%United Arab Emirates%'                    THEN 'UAE'
   WHEN @old_name LIKE '%Ukraine%'                                 THEN 'Ukraine'
   WHEN @old_name LIKE '%UK%'                                      THEN 'United Kingdom'
   WHEN @old_name LIKE '%United States%'                           THEN 'United States'
   WHEN @old_name LIKE '%U%S%Virgin Islands'                       THEN 'US Virgin Islands'
   WHEN @old_name LIKE 'US'                                        THEN 'United States'
   WHEN @old_name LIKE 'USA'                                       THEN 'United States'
   WHEN @old_name LIKE '%Vatican%'                                 THEN 'Holy See'
   WHEN @old_name LIKE '%Venezuela%'                               THEN 'Venezuela'
   WHEN @old_name LIKE '%Viet nam%'                                THEN 'Vietnam'
   WHEN @old_name LIKE '%Vietnam%'                                 THEN 'Vietnam'
   WHEN @old_name LIKE '%Virgin Islands%British%'                  THEN 'British Virgin Islands'
   WHEN @old_name LIKE '%Virgin Islands%U%S%'                      THEN 'US Virgin Islands'
   WHEN @old_name LIKE '%Wallis%'                                  THEN 'Wallis'
   WHEN @old_name LIKE '%West Bank % Gaza%'                        THEN 'Palestine'
   WHEN @old_name LIKE '%Zaire%'                                   THEN 'Congo (Democratic Republic)'

   ELSE @old_name  -- CATCH ALL
   END -- CASE

   RETURN @new_name;
END

/*
EXEC sp_fixup_country_name 'country', 'name';
*/





GO
