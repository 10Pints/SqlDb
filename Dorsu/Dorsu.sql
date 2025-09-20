/*
Parameters:

--------------------------------------------------------------------------------
 Type            : Params
--------------------------------------------------------------------------------
 CreateMode      : Create
 Database        : Dorsu_dev
 DisplayLog      : True
 DisplayScript   : True
 FilePath        : C:\bin\DbScripter\Dorsu_dev_crt.2.cfg.json
 IndividualFiles : False
 Instance        : 
 IsExprtngData   : False
 LogFile         : D:\Logs\Dorsu.log
 LogLevel        : Info
 Name            : DbScripter-DORSU config
 RequiredSchemas : System.Collections.Generic.List`1[System.String]
 RequiredTypes   : System.Collections.Generic.List`1[DbScripterLibNS.SqlTypeEnum]
 Script Dir      : D:\Dorsu\Scripts\sql
 Script File     : D:\Dorsu\Scripts\sql\Dorsu.sql
 ScriptUseDb     : True
 Server          : DEVI9
 AddTimestamp    : False
 Timestamp       : 250622-1116

 RequiredSchemas : 1
	dbo

 RequiredTypes : 8
	Schema
	Assembly
	Table
	Trigger
	Procedure
	Function
	View
	UserDefinedDataType
*/

USE [Dorsu_dev]
GO

CREATE SCHEMA [dbo]

GO
GO

CREATE TYPE [dbo].[ChkFldsNotNullDataType] AS TABLE(
	[ordinal] [int] NOT NULL,
	[col] [varchar](120) NOT NULL,
	[sql] [varchar](4000) NOT NULL
)

GO
GO

CREATE TYPE [dbo].[IdNmTbl] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[val] [varchar](4000) NULL,
	PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: adds [] brackets to an identifier as necessary
--    Example table names like 'User' or 'Autorized actions'
--
-- Design:      EA: Dorsu Model.Conceptual Model.Delimit Identifier
-- Tests:       
-- ==================================================================
CREATE FUNCTION [dbo].[DelimitIdentifier]
(
   @id VARCHAR(120) -- identifier
)
RETURNS VARCHAR(120)
AS
BEGIN
   DECLARE @nb BIT = 0;

   WHILE 1=1
   BEGIN
      IF CHARINDEX(' ', @id) > 0
      BEGIN
         SET @nb = 1;
         BREAK;
      END

      BREAK;
   END -- while 1=1

   RETURN @nb;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ===============================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: fnLen deals with the trailing spaces bug in Len
-- ===============================================================
CREATE  FUNCTION [dbo].[fnLen]( @v VARCHAR(8000))
RETURNS INT
AS
BEGIN
   RETURN CASE
            WHEN @v IS NULL THEN 0
            ELSE Len(@v+'x')-1
            END;
END
/*
EXEC test.sp__crt_tst_rtns 'dbo].[fnLen]', 43;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ==========================================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: Removes specific characters from the right end of a string
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ==========================================================================
CREATE FUNCTION [dbo].[fnRTrim]
(
   @s VARCHAR(MAX)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   DECLARE  
       @tcs    VARCHAR(20)

   IF (@s IS NULL ) OR (LEN(@s) = 0)
      RETURN @s;

   SET @tcs = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))

   WHILE CHARINDEX(Right(@s, 1) , @tcs) > 0 AND dbo.fnLen(@s) > 0 -- SUBSTRING(@s,  dbo.fnLen(@s)-1, 1) or Right(@s, 1)
      SET @s = SUBSTRING(@s, 1, dbo.fnLen(@s)-1); -- SUBSTRING(@s, 1, dbo.fnLen(@s)-1) or Left(@s, dbo.fnLen(@s)-1)

   RETURN @s;
END




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ================================================================
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Removes specific characters from 
--              the beginning of a string
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ==================================================================
CREATE FUNCTION [dbo].[fnLTrim]
(
    @s VARCHAR(MAX)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   DECLARE  
       @tcs    VARCHAR(20)

   IF (@s IS NULL ) OR (dbo.fnLen(@s) = 0)
      RETURN @s;

   SET @tcs = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))

   WHILE CHARINDEX(SUBSTRING(@s, 1, 1), @tcs) > 0 AND dbo.fnLen(@s) > 0
      SET @s = SUBSTRING(@s, 2, dbo.fnLen(@s)-1);

   RETURN @s;
END
/*
PRINT CONCAT('[', fnTrim(' '), ']')
PRINT CONCAT('[', fnLTrim(' '), ']')
PRINT CONCAT('[', fnLTrim2(' ', ' '), ']')
PRINT CONCAT('[', fnLTrim(CONCAT(0x20, 0x09, 0x0a, 0x0d, 0x20,'a', 0x20, 0x09, 0x0a, 0x0d, 0x20,' #cd# ')), ']');
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================
-- Author:      Terry Watts
-- Create date: 10-OCT-2019
-- Description: Trims leading and trailing whitesace including the 
--                normally untrimmable CHAR(160)
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ================================================================
CREATE FUNCTION [dbo].[fnTrim]( @s VARCHAR(4000)
)
RETURNS VARCHAR(4000)
AS
BEGIN
  RETURN dbo.fnRTrim( dbo.fnLTrim(@s));
END
/*
PRINT CONCAT('[', dbo.fnTrim(CONCAT(0x20, 0x09, 0x0a, 0x0d, 0xA0, '  a  #cd# ', 0x20, 0x09, 0x0a, 0x0d, 0x0d,0xA0)), ']');
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 24-OCT-2019
-- Description: CamelCase seps = {<spc>, ' -}
--=============================================
CREATE FUNCTION [dbo].[fnCamelCase](@str NVARCHAR(200))
RETURNS NVARCHAR(4000) AS
BEGIN
   DECLARE
    @res       NVARCHAR(200)
   ,@tmp       NVARCHAR(2000)
   ,@n         INT
   ,@FirstLen  INT
   ,@SEP       NVARCHAR(1)
   ,@len       INT
   ,@ndx       INT = 1
   ,@c         NVARCHAR(1)
   ,@seps      NVARCHAR(10) = ' -'''
   -- Init Set flag to true
   ,@flag      BIT     = 1
   ;

   IF @str IS NULL OR Len(@str) = 0
      RETURN @str;

   -- Make all charactesrs lower case
   SET @str = LOWER(dbo.fnTrim(@str));
   SET @len = dbo.fnLen(@str);

   -- For each character in string
   WHILE @ndx <= @len
   BEGIN
      SET @c = SUBSTRING(@str, @ndx, 1);
      SET @ndx = @ndx + 1;

      -- Is character a separator?
      IF CharIndex(@c, @seps, 1) >0
      BEGIN
         -- Set the flag true
         SET @flag = 1;
      END
      ELSE
      BEGIN
         -- ASSERTION: if here then we have a non seperator character

         -- Is flag set?
         IF @flag = 1
         BEGIN
         -- make uppercase
         SET @c = UPPER(@c);
         -- Set the flag false
         SET @flag = 0;
         END
      END -- end if else

      SET @res = CONCAT(@res, @c);
   END  -- WHILE

   RETURN @res;
END
/*
PRINT dbo.fnCamelCase('abGd Eefg');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-DEC-2019
-- Description: case sensitive compare helper function
-- Returns:     1 if match false 0
-- =============================================
CREATE FUNCTION [dbo].[fnCaseSensistiveCompare]
(
    @exp        VARCHAR(MAX)
   ,@act        VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
   IF @exp IS NULL AND @act IS NULL
      RETURN 1;

   IF (@exp IS NULL     AND @act IS NOT NULL) OR
      (@exp IS NOT NULL AND @act IS NULL)
      RETURN 0;

   RETURN IIF( @exp COLLATE Latin1_General_CS_AS  = @act COLLATE Latin1_General_CS_AS
   , 1, 0);
END
/*
   
   IF (@expected IS NULL)
      SET @exp_is_null = 1;

   IF (@actual IS NULL)
      SET @act_is_null = 1;

   IF (@exp_is_null = 1) AND (@act_is_null = 1)
      RETURN 1;

   IF (@exp_is_null = 1) AND (@act_is_null = 1)
      RETURN 1;

   IF ( dbo.fnLEN(@expected) = 0) AND ( dbo.fnLEN(@actual) = 0)
      RETURN 1;

   SET @exp = CONVERT(VARBINARY(8000), @expected);
   SET @act = CONVERT(VARBINARY(8000), @actual);

   IF (@exp = 0x) AND (@act = 0x)
   BEGIN
      SET @res = 1;
   END
   ELSE
   BEGIN
      IF @exp = @act
         SET @res = 1;
      ELSE
         SET @res = 0;
   END

   -- ASSERTION @res is never NULL
   RETURN @res;
END
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =====================================================================
-- Author:      Terry Watts
-- Create date: 31-OCT-2024
-- Description: determines if @ty is a text datatype
-- e.g. 'VARCHAR' is a text type
-- 
-- PRECONDITIONS: @ty is just the datatype without ()
-- e.g. 'VARCHAR' is OK but 'VARCHAR(20)' the output is undefined
-- =====================================================================
CREATE FUNCTION [dbo].[fnIsTextType](@ty   VARCHAR(500))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('char','nchar','varchar','nvarchar'), 1, 0);
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_097_fnIsTextType';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: Returns true if a time type
--              Handles single and array types like INT and VARCHAR(MAX)
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsTimeType](@ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('date','datetime','datetime2','datetimeoffset','smalldatetime','TIME'), 1, 0);
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsIntType]( @ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('BIT','INT','SMALLINT','TINYINT','BIGINT','MONEY','SMALLMONEY'), 1, 0);
END
/*
SELECT dbo.fnIsInt('0',0) as [fnIsInt('0', 0)], dbo.fnIsInt('05',0) as [fnIsInt(05,0)]
SELECT dbo.fnIsInt('0',1) as [fnIsInt('0',1)], dbo.fnIsInt('05',1) as [dbo.fnIsInt('05',1)]
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if a sql_variant is an
-- approximate type: {float, real or numeric}
-- test: [test].[t 025 fnIsFloat]
-- ================================================
CREATE FUNCTION [dbo].[fnIsFloatType](@ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('float','real','numeric'), 1, 0);
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type GUID
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsGuidType](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   RETURN iif(CONVERT(VARCHAR(500), SQL_VARIANT_PROPERTY(@v, 'BaseType')) = 'uniqueidentifier', 1, 0);
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: Gets the type category for a Sql Uerver datatype
-- e.g. Exact types : INT, MONEY 
-- Floating point types: float real
--
-- TESTS:
-- ===================================================================
CREATE FUNCTION [dbo].[fnGetTypeCat](@ty VARCHAR(25))
RETURNS VARCHAR(25)
AS
BEGIN
   DECLARE @type SQL_VARIANT
   ;

   RETURN
      CASE
         WHEN dbo.fnIsIntType (@ty)     = 1 THEN 'Int'
         WHEN dbo.fnIsTextType(@ty)     = 1 THEN 'Text'
         WHEN dbo.fnIsTimeType(@ty) = 1 THEN 'Time'
         WHEN dbo.fnIsFloatType(@ty)    = 1 THEN 'Float'
         WHEN dbo.fnIsGuidType(@ty)     = 1 THEN 'GUID'
         END;
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[fnGetTypeCat]';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type BIT
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsBoolType](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   RETURN iif( @v = 'bit', 1,0);
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: function to compare values - includes an
--              approx equal check for floating point types
-- Returns 1 if equal, 0 otherwise
-- =========================================================
CREATE FUNCTION [dbo].[fnChkEquals]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE
    @fn     VARCHAR(35)   = N'sp_fnChkEquals'
   ,@res    BIT
   ,@a_str  VARCHAR(4000) = CONVERT(VARCHAR(400), @a)
   ,@b_str  VARCHAR(4000) = CONVERT(VARCHAR(400), @b)
   ,@a_ty   VARCHAR(25)   = CONVERT(VARCHAR(25), SQL_VARIANT_PROPERTY(@a, 'BaseType'))
   ,@b_ty   VARCHAR(25)   = CONVERT(VARCHAR(25), SQL_VARIANT_PROPERTY(@b, 'BaseType'))
   ;

   -- NULL check
   IF @a IS NULL AND @b IS NULL
   BEGIN
      RETURN 1;
   END

   IF @a IS NULL AND @b IS NOT NULL
   BEGIN
      RETURN 0;
   END

   IF @a IS NOT NULL AND @b IS NULL
   BEGIN
      RETURN 0;
   END

   -- if both are floating point types, fnCompareFloats evaluates  fb comparison to accuracy +- epsilon
   -- any differnce less that epsilon is consider insignifacant so considers and b to =
   -- fnCompareFloats returns 1 if a>b, 0 if a==b, -1 if a<b
   IF (dbo.[fnIsFloatType](@a_ty) = 1) AND (dbo.[fnIsFloatType](@b_ty) = 1)
   BEGIN
      RETURN iif(dbo.[fnCompareFloats](CONVERT(FLOAT(24), @a), CONVERT(FLOAT(24), @b)) = 0, 1, 0);
   END

   -- if both are int types
   IF (dbo.fnIsIntType(@a_ty) = 1) AND (dbo.fnIsIntType(@b_ty) = 1)
      RETURN iif(CONVERT(BIGINT, @a) = CONVERT(BIGINT, @b), 1, 0);

   -- if both are string types
   IF (dbo.fnIsTextType(@a_ty) = 1) AND (dbo.fnIsTextType(@b_ty) = 1)
      RETURN iif(@a_str = @b_str, 1, 0);

   -- if both are boolean types
   IF (dbo.fnIsBoolType(@a_ty) = 1) AND (dbo.fnIsBoolType(@b_ty) = 1)
      RETURN iif(CONVERT(BIT, @a) = CONVERT(BIT, @b), 1, 0);

   -- if both are datetime types
   IF (dbo.fnIsTimeType(@a_ty) = 1) AND (dbo.fnIsTimeType(@b_ty) = 1)
      RETURN iif( CONVERT(DATETIME, @a) = CONVERT(DATETIME, @b), 1, 0);

   -- if both are guid types
   IF (dbo.fnIsGuidType(@a_ty) = 1) AND (dbo.fnIsGuidType(@b_ty) = 1)
      RETURN iif(CONVERT(UNIQUEIDENTIFIER, @a) = CONVERT(UNIQUEIDENTIFIER, @b), 1, 0);

   ----------------------------------------------------
   -- Compare by type cat
   ----------------------------------------------------

   DECLARE
    @a_cat  VARCHAR(25)
   ,@b_cat  VARCHAR(25)

   SET @a_cat = [dbo].[fnGetTypeCat](@a_ty);
   SET @b_cat = [dbo].[fnGetTypeCat](@b_ty);

   if(@a_cat = @b_cat)
   BEGIN
      IF @a_cat = 'Int'
      BEGIN
         SET @res = iif(CONVERT(BIGINT, @a) = CONVERT(BIGINT, @b), 1, 0);
      END
      ELSE IF @a_cat = 'Float'
      BEGIN
         SET @res = iif(CONVERT(FLOAT(24), @a) = CONVERT(FLOAT(24), @b), 1, 0);
      END
      ELSE IF @a_cat = 'Text'
      BEGIN
         SET @res = iif(CONVERT(VARCHAR(8000), @a) = CONVERT(VARCHAR(8000), @b), 1, 0);
      END
      ELSE IF @a_cat = 'Time'
      BEGIN
         SET @res = iif(CONVERT(DATETIME2, @a) = CONVERT(DATETIME2, @b), 1, 0);
      END
      ELSE IF @a_cat = 'GUID'
      BEGIN
         SET @res = iif(CONVERT(UNIQUEIDENTIFIER, @a) = CONVERT(UNIQUEIDENTIFIER, @b), 1, 0);
      END

      RETURN @res;
   END

   ----------------------------------------------------------------------
   -- Can compare Floats with integral types -> convert both to big float
   ----------------------------------------------------------------------
   IF (@a_cat='Int' AND @b_cat='Float') OR (@a_cat='Float' AND @b_cat='Int')
   BEGIN
      RETURN iif(CONVERT(FLOAT(24), @a) = CONVERT(FLOAT(24), @b), 1, 0);
   END

   ----------------------------------------------------
   -- Final option: compare by converting to text
   ----------------------------------------------------
   SET @res = iif(@a_str = @b_str, 1, 0)
   RETURN @res;
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: determines if a character is whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if is whitspace, 0 otherwise
-- ===============================================================================================
CREATE FUNCTION [dbo].[fnIsWhitespace]( @t NCHAR) 
RETURNS BIT
AS
BEGIN
   RETURN CASE WHEN  @t IN (NCHAR(9) , NCHAR(10), NCHAR(11), NCHAR(12)
                           ,NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160)) THEN 1 
              ELSE 0 END
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: determines if the string contains whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if string contains whitspace, 0 otherwise
-- ==========================================================================================
CREATE FUNCTION [dbo].[fnContainsWhitespace]( @s VARCHAR(4000))
RETURNS BIT
AS
BEGIN
   DECLARE
       @res       BIT = 0
      ,@i         INT = 1
      ,@len       INT = dbo.fnLen(@s)

   WHILE @i <= @len
   BEGIN
      IF dbo.fnIswhitespace(SUBSTRING(@s, @i, 1))=1
      BEGIN
         SET @res = 1;
         break;
      END

      SET @i = @i + 1;
   END

   RETURN @res;
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================
-- Description: Convers a date like 23-Feb to a DATE
-- Design:      
-- Tests:       
-- Author:      
-- Create date: 
-- ==================================================
CREATE FUNCTION [dbo].[fnCovertStringToDate]( @StringDate VARCHAR(20))
RETURNS DATE
AS
BEGIN

-- Extract components (assuming consistent format)
DECLARE 
    @Day           VARCHAR(2) = PARSENAME(REPLACE(@StringDate, '-', '.'), 2) -- '21'
   ,@Month         VARCHAR(3) = PARSENAME(REPLACE(@StringDate, '-', '.'), 1) -- 'Feb'
   ,@Year          VARCHAR(4) = Year(GetDate())
   ,@FormattedDate VARCHAR(20);

   -- Combine into a standard format and convert to date
   SET @FormattedDate = CONCAT(@Day, '-', @Month, '-', @Year);

   RETURN CONVERT(DATE, @FormattedDate, 106);
END
/*
EXEC tSQLt.Run 'test.test_015_fnCovertStringToDate';

EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 17-JUN-2025
-- Description: generates the sql to check if every value 
--    in field @fld_nm of the table @q_table_nm
--    can be cast to the type @ty
-- Tests      : test_075_fnCrtFldNotNullSql
--
-- Postconditions: returns the check SQL for the given parameters
-- ===============================================================
CREATE FUNCTION [dbo].[fnCrtFldNotNullSql]
(
    @q_table_nm VARCHAR(60)
   ,@fld_nm     VARCHAR(40)
   ,@ty         VARCHAR(25)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
     DECLARE @sql NVARCHAR(4000)
     ;

     SET @sql =
     CONCAT
     (
'IF NOT EXISTS
(
   SELECT 1 FROM ',@q_table_nm,'
   WHERE TRY_CAST([',@fld_nm,'] AS ',@ty,') IS NULL
)
   SET @fld_ty = ''',@ty,'''
ELSE
   SET @fld_ty = NULL
;'
     );

     RETURN @sql;
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[fnCrtFldNotNullSql]'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author     : Terry Watts
-- Create date: 12-APR-2025
-- Description: removes double quotes an Line feeds from data
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:     EA
-- Tests:      test_018_fnCrtRemoveDoubleQuotesSql
--             test_037_sp_import_txt_file
-- ============================================================
CREATE FUNCTION [dbo].[fnCrtRemoveDoubleQuotesSql]
(
    @table              VARCHAR(60)
   ,@max_len_fld        INT
)
RETURNS VARCHAR(8000)

AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)       = N'sp_import_txt_file'
   ,@table_no_brkts     VARCHAR(60)
   ,@nl                 CHAR(2)           = CHAR(13)+CHAR(10)
   ,@sql                VARCHAR(8000)
   ,@empty_str          VARCHAR(2)=''''
   ,@double_quote       VARCHAR(5)='"'
   ;

   SET @table_no_brkts = REPLACE(REPLACE(@table, '[',''),  ']','');

   --    SELECT dbo.fnPadRight(CONCAT(''['', column_name, '']''), ', @max_len_fld+2, ') AS column_name

SET @sql = CONCAT
(
'DECLARE
    @nl             CHAR(2) = CHAR(13)+CHAR(10)
   ,@Lf             CHAR(1) = CHAR(10)
   ,@empty_str      VARCHAR(1)=''''
   ,@double_quote   VARCHAR(1)=''"''
   ,@sql            VARCHAR(8000)
;

WITH cte AS
(
   SELECT CONCAT(''['', column_name, '']'') AS column_name
      ,ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) AS row_num
      ,ordinal_position
      ,DATA_TYPE
      ,is_txt
   FROM list_table_columns_vw
   WHERE table_name = ''',@table_no_brkts, ''' AND is_txt = 1
)
,cte2 AS
(
   SELECT ''UPDATE ',@table,' SET '' AS sql
   UNION ALL
   SELECT
      CONCAT
      (  iif(row_num=1, '' '','','')
        ,column_name, '' = 
        TRIM(REPLACE(REPLACE('',column_name',','',CHAR(34),''',@empty_str,''''')
        ,CHAR(10),''',@empty_str,'''''
            )
         )''
      )
   FROM cte
   UNION ALL
   SELECT ''FROM ',@table,';''
)
SELECT @sql = 
string_agg(sql, ''', @NL, ''')
FROM cte2;'
);

   RETURN @sql;
END
/*
EXEC tSQLt.Run 'test.test_018_fnCrtRemoveDoubleQuotesSql';
EXEC tSQLt.Run 'test.test_037_sp_import_txt_file';
------------------------------------------------
DECLARE @sql VARCHAR(8000)
SELECT @sql = dbo.fnCrtRemoveDoubleQuotesSql('[User]', 12);
PRINT @sql
------------------------------------------------
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: checks if a word is a reserved word
--
-- Design:      Deepseek
-- Tests:       test.test_071_IsReservedWord
-- ==================================================================
CREATE FUNCTION [dbo].[IsReservedWord](@word NVARCHAR(128))
RETURNS BIT
AS
BEGIN
    DECLARE @isReserved BIT = 0;
    -- We do UPPER incase we're working in a SQL 
    SET @word = UPPER(LTRIM(RTRIM(@word)));

    SET @isReserved = 
      CASE 
         WHEN @word IN
(
  'ABS', 'ADD', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'AUTHORIZATION'
, 'BACKUP', 'BEGIN', 'BETWEEN', 'BIY', 'BREAK', 'BROWSE', 'BULK', 'BY'
, 'CASCADE', 'CASE', 'CAST', 'CHAR', 'CHARINDEX', 'CHAR_LENGTH', 'CHECK', 'CHECKPOINT'
, 'CEILING', 'CLOSE', 'CLUSTERED'
, 'COALESCE', 'COLLATE', 'COL_LENGTH', 'COL_NAME', 'COLUMN', 'COMMIT', 'COMPUTE', 'CONSTRAINT'
, 'CONTAINS', 'CONTAINSTABLE', 'CONTINUE', 'CONVERT', 'CREATE'
, 'CROSS', 'CURRENT', 'CURRENT_DATE', 'CURRENT_TIME'
, 'CURRENT_TIMESTAMP', 'CURRENT_USER', 'CURSOR', 'DATABASE', 'DBCC'
, 'DEALLOCATE', 'DECLARE', 'DEFAULT', 'DELETE', 'DENY', 'DESC'
, 'DISK', 'DISTINCT', 'DISTRIBUTED', 'DOUBLE', 'DROP', 'DUMMY'
, 'DUMP', 'ELSE', 'END', 'ERRLVL', 'ESCAPE', 'EXCEPT', 'EXEC'
, 'EXECUTE', 'EXISTS', 'EXIT'
 , 'FETCH', 'FILE', 'FILLFACTOR', 'FLOAT', 'FOR'
, 'FOREIGN', 'FREETEXT', 'FREETEXTTABLE', 'FROM', 'FULL', 'FUNCTION'
, 'GOTO', 'GRANT', 'GROUP', 'HAVING', 'HOLDLOCK', 'IDENTITY'
, 'IDENTITY_INSERT', 'IDENTITYCOL', 'IF', 'IN', 'INDEX', 'INNER'
, 'INSERT', 'INT','INTERSECT', 'INTO', 'IS', 'JOIN', 'KEY', 'KILL', 'LEFT'
, 'LIKE', 'LINENO', 'LOAD', 'NATIONAL', 'NOCHECK', 'NONCLUSTERED'
, 'NOT', 'NULL', 'NULLIF', 'OF', 'OFF', 'OFFSETS', 'ON', 'OPEN'
, 'OPENDATASOURCE', 'OPENQUERY', 'OPENROWSET', 'OPENXML', 'OPTION'
, 'OR', 'ORDER', 'OUTER', 'OVER', 'PERCENT', 'PLAN', 'PRECISION'
, 'PRIMARY', 'PRINT', 'PROC', 'PROCEDURE', 'PUBLIC', 'RAISERROR'
, 'READ', 'READTEXT', 'RECONFIGURE', 'REFERENCES', 'REPLICATION'
, 'RESTORE', 'RESTRICT', 'RETURN', 'REVOKE', 'RIGHT', 'ROLLBACK'
, 'ROWCOUNT', 'ROWGUIDCOL', 'RULE', 'SAVE', 'SCHEMA', 'SELECT'
, 'SESSION_USER', 'SET', 'SETUSER', 'SHUTDOWN', 'SOME', 'STATISTICS'
, 'SYSTEM_USER', 'TABLE', 'TEXTSIZE', 'THEN', 'TO', 'TOP', 'TRANSACTION'
, 'TRIGGER', 'TRUNCATE', 'TSEQUAL', 'UNION', 'UNIQUE', 'UPDATE'
, 'UPDATETEXT', 'USE', 'USER', 'VALUES', 'VARYING', 'VIEW'
, 'WAITFOR', 'WHEN', 'WHERE', 'WHILE', 'WITH', 'WRITETEXT'
)
      THEN 1
      ELSE 0
   END
    RETURN @isReserved;
END
/*
EXEC test.test_071_IsReservedWord;
*/


GO
GO

CREATE TYPE [dbo].[IdNmTbl] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[val] [varchar](4000) NULL,
	PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: delimits identifier  if necessary
-- Design:      
-- Tests:       
-- ===============================================
CREATE FUNCTION [dbo].[fnDeLimitIdentifier](@q_id VARCHAR(120))
RETURNS VARCHAR(120)
AS
BEGIN
   DECLARE @v VARCHAR(120)
   DECLARE @vals IdNmTbl
   INSERT INTO @vals (val) select value from string_split(@q_id, '.');
   UPDATE @vals SET val = iif((dbo.IsReservedWord(val)=1 OR CHARINDEX(' ', val)>0), CONCAT('[', val, ']'), val)

   SELECT @v = string_agg(val, '.') FROM @vals;
   RETURN @v;
END
/*
EXEC tSQLt.Run 'test.test_073_fnDeLimitIdentifier';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================
-- Author:      Terry Watts
-- Create date: 13-JUN-2025
--
-- Description: 
-- creates the SQL to create a table
-- based on the input string.
-- All fields are VARCHAR(MAX)
-- Delimits the qualified @tbl_nm if necessary
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    returns creat table SQL
--
-- Tests:
-- =============================================
CREATE FUNCTION [dbo].[fnCrtTblSql]
(
    @tbl_nm VARCHAR(60)
   ,@fields VARCHAR(8000))
RETURNS VARCHAR(8000)
AS
BEGIN
   DECLARE
       @sql      VARCHAR(8000)
      ,@joiner   VARCHAR(40)=' VARCHAR(8000)
   ,'
      ,@snippet  VARCHAR(400)
      ,@NL       CHAR(2)     = CHAR(13) + CHAR(10)
      ,@tab      CHAR        = CHAR(9)
      ,@sep      CHAR        = CHAR(9)
;

   SET @sep = IIF(CHARINDEX( @tab,@fields)>0, @tab, ',');

   -- split the fields and add them as VARCHAR(8000)
SELECT @snippet =string_agg(TRIM(value), @joiner)
FROM   STRING_SPLIT(@fields, @sep);

   SET @sql =
   CONCAT
   ('CREATE TABLE ', dbo.fnDelimitIdentifier(@tbl_nm),'
(
    '
, @snippet
, ' VARCHAR(8000)', @NL
,');'
);

   RETURN @sql;
END
/*
EXEC test.test_069_fnCrtTblSql;
PRINT dbo.fnCrtTblSql('TestTable','id, name,description, location');

EXEC tSQLt.Run 'test.test_069_fnCrtTblSql';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- =================================================
-- Author:      Terry Watts
-- Create date: 24-NOV-2023
--
-- Description: removes square brackets from string
-- in any position in the string
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    [ ] brackets removed
--
-- Tests:
-- =============================================
CREATE FUNCTION [dbo].[fnDeSquareBracket](@s VARCHAR(4000))
RETURNS VARCHAR(4000)
AS
BEGIN
   RETURN REPLACE(REPLACE(@s, '[', ''), ']', '');
END
/*
   EXEC test.sp_crt_tst_rtns 'dbo.fnDeSquareBracket', 69
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry Watts
-- Create date: 30-MAR-2020
-- Description: returns true if the file exists, false otherwise
-- ===============================================================
CREATE FUNCTION [dbo].[fnFileExists](@path varchar(512))
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT
     RETURN cast(@result as bit)
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- Description: returns Last Index of a str in a str
-- or 0 if not found
-- ==================================================
CREATE FUNCTION [dbo].[fnFindLastIndexOf](@searchFor VARCHAR(100),@searchIn VARCHAR(500))
RETURNS INT
AS
BEGIN
   IF LEN(@searchfor) > LEN(@searchin)
      RETURN 0;

   DECLARE @r VARCHAR(500), @rsp VARCHAR(100)
   SELECT @r   = REVERSE(@searchin)
   SELECT @rsp = REVERSE(@searchfor)
   RETURN len(@searchin) - charindex(@rsp, @r) - len(@searchfor)+1;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 17-MAY-2025
-- Description: CamelCase seps = {<spc>, ' -}
--=============================================
CREATE FUNCTION [dbo].[fnFindNthOccurrence]
(
    @input VARCHAR(8000),
    @char CHAR(1),
    @n INT)
RETURNS INT
AS
BEGIN
    DECLARE @position INT = 0;
    DECLARE @count INT = 0;
    DECLARE @result INT = 0;
    
    WHILE @count < @n AND @position < LEN(@input)
    BEGIN
        SET @position = @position + 1;
        IF SUBSTRING(@input, @position, 1) = @char
        BEGIN
            SET @count = @count + 1;
            IF @count = @n
                SET @result = @position;
        END
    END
    
    RETURN @result;
END
/*
SELECT dbo.fnFindNthOccurrence('a,b,c,d,e,f', ',', 3);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from the right end of a string
-- =============================================
CREATE FUNCTION [dbo].[fnRTrim2]
(
    @str VARCHAR(MAX)
   ,@trim_chr VARCHAR(1)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   IF @str IS NOT NULL AND @trim_chr IS NOT NULL
      WHILE Right(@str, 1)= @trim_chr AND dbo.fnLen(@str) > 0
         SET @str = Left(@str, dbo.fnLen(@str)-1);

   RETURN @str
END
/*
PRINT CONCAT('[',  dbo.fnRTrim2('  ', ' '), ']');
PRINT CONCAT('[',  dbo.fnRTrim2(' ', ' '), ']');
PRINT CONCAT('[',  dbo.fnRTrim2('', ' '), ']');
PRINT CONCAT('[', Right('', 1), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' s 5   ', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' ', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2('', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(NULL, ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' ', NULL), ']
PRINT CONCAT('[', dbo.fnRTrim2('', NULL), ']');
IF dbo.fnRTrim2(NULL, NULL) IS NULL PRINT 'IS NULL';
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from 
--              the beginning end of a string
-- =============================================
CREATE FUNCTION [dbo].[fnLTrim2]
(
    @str VARCHAR(MAX)
   ,@trim_chr VARCHAR(1)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   DECLARE @len INT;

   IF @str IS NOT NULL AND @trim_chr IS NOT NULL
      WHILE Left(@str, 1) = @trim_chr
      BEGIN
         SET @len = dbo.fnLen(@str)-1;

         IF @len < 0
            BREAK;

         SET @str = Substring(@str, 2, dbo.fnLen(@str)-1);
      END

   RETURN @str
END

/*
PRINT CONCAT('1: [',  dbo.fnLTrim2('  ', ' '), ']');
PRINT CONCAT('2: [',  dbo.fnLTrim2(' ', ' '), ']');
PRINT CONCAT('3: [',  dbo.fnLTrim2('', ' '), ']');
PRINT CONCAT('4: [', Right('', 1), ']');
PRINT CONCAT('5: [', dbo.fnLTrim2(' s 5   ', ' '), ']');
PRINT CONCAT('6: [', dbo.fnLTrim2(' ', ' '), ']');
PRINT CONCAT('7: [', dbo.fnLTrim2('', ' '), ']');
PRINT CONCAT('8: [', dbo.fnLTrim2(NULL, ' '), ']');
PRINT CONCAT('9: [', dbo.fnLTrim2(' ', NULL), ']');
PRINT CONCAT('10:[', dbo.fnLTrim2('', NULL), ']');
IF dbo.fnLTrim2(NULL, NULL) IS NULL PRINT 'IS NULL';
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from 
--              the beginning end of a string
-- =============================================
CREATE FUNCTION [dbo].[fnTrim2]
(
    @str VARCHAR(MAX)
   ,@trim_chr VARCHAR(1)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   RETURN dbo.fnRTrim2(dbo.fnLTrim2(@str, @trim_chr), @trim_chr);
END




GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: returns the fixed up range
-- =============================================
CREATE FUNCTION [dbo].[fnFixupXlRange](@range VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
   SET @range = dbo.fnTrim2(dbo.fnTrim2(@range, '['), ']');

   IF @range IS NULL OR @range='' SET @range = 'Sheet1$';

   IF CHARINDEX('$', @range) = 0
      SET @range = CONCAT( @range, '$');

   SET @range = CONCAT('[', @range, ']');
   RETURN @range;
END
/*
PRINT dbo.fnFixupXlRange(NULL);
PRINT dbo.fnFixupXlRange('');
PRINT dbo.fnFixupXlRange('Sheet1$');
PRINT dbo.fnFixupXlRange('[Sheet1$]');
PRINT dbo.fnFixupXlRange('Call Register');
PRINT dbo.fnFixupXlRange('Call Register$]');
PRINT dbo.fnFixupXlRange('[Call Register$]');
PRINT dbo.fnFixupXlRange('[Call Register$A:B]');
PRINT dbo.fnFixupXlRange('Call Register$A:B]');
PRINT dbo.fnFixupXlRange('[Call Register$A:B');
PRINT dbo.fnFixupXlRange('Call Register$A:B');
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =====================================================================
-- Author:      Terry Watts
-- Create date: 08 MAR 2025
-- Description: returns true if the foreign key exists, false otherwise
-- Design:      
-- Tests:       
-- =====================================================================
CREATE FUNCTION [dbo].[fnFkExists](@fk VARCHAR(128))
RETURNS BIT
AS
BEGIN
   RETURN iif(EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = @fk), 1, 0);
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_000_FkExists';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================================
-- Author:      Terry Watts
-- Create date: 01-MAY-2025
-- Description: Gets the short dat name like {}MON, TYU, WEd, THU, FRI}
-- Design:      NONE
-- Tests:       test_053_GetDayfromDate
-- =======================================================================
CREATE FUNCTION [dbo].[fnGetDayfromDate](@dt DATE)
RETURNS VARCHAR(3)
AS
BEGIN
   RETURN UPPER(SUBSTRING (DATENAME(dw, @dt), 1, 3));
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_053_fnGetDayfromDate;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================================
-- Author:      Terry Watts
-- Create date: 08-MAY-2025
-- Description: maps the short day name like 
--             like {MON, Tue, WEd, THU, FRI,SAT, SUN}
--             to   {1,2,3,4,5,6,7}
-- Design:      NONE
-- Tests:       test_053_GetDayfromDate
-- =======================================================================
CREATE FUNCTION [dbo].[fnGetDowFromDayName](@ShortDayName VARCHAR(3))
RETURNS VARCHAR(3)
AS
BEGIN
   RETURN CASE @ShortDayName
        WHEN 'Mon'       THEN 1
        WHEN 'Tue'       THEN 2
        WHEN 'Wed'       THEN 3
        WHEN 'Thu'       THEN 4
        WHEN 'Fri'       THEN 5
        WHEN 'Sat'       THEN 6
        WHEN 'Sun'       THEN 7
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
        ELSE -1
    END ;
END
/*
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[GetDowFromDayName]';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- =================================================================================
-- Author:      Terry Watts
-- Create date: 19-Sep-2024
--
-- Description: Gets the file extension from the supplied file path 
--              without the dot prefix
--
-- Tests:
--
-- CHANGES:
-- 240919: made return null if no extension - not '' as is the case with split fn
-- =================================================================================
CREATE FUNCTION [dbo].[fnGetFileExtension](@path VARCHAR(MAX))
RETURNS VARCHAR(200)
AS
BEGIN
   DECLARE
    @t TABLE
    (
       id int IDENTITY(1,1) NOT NULL
      ,val VARCHAR(200)
    );

   DECLARE
       @val VARCHAR(4000)
      ,@ndx INT = -1

   INSERT INTO @t(val)
   SELECT value from string_split(@path,'.'); -- ASCII 92 = Backslash
   SET @val = (SELECT TOP 1 val FROM @t ORDER BY id DESC);

   IF dbo.fnLen(@val) = 0 SET @val = NULL;

   RETURN @val;
END
/*
-- For tests see test.test_092_fnGetFileExtension
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 03-Nov-2023
--
-- Description: Gets the file name optionally with the extension from the supplied file path
--
-- Tests:
--
-- CHANGES:
-- 240307: added @with_ext flag parameter to signal to get either the file with or without the extension
-- ======================================================================================================
CREATE FUNCTION [dbo].[fnGetFileNameFromPath](@path VARCHAR(MAX), @with_ext BIT)
RETURNS VARCHAR(200)
AS
BEGIN
   DECLARE
    @t TABLE
    (
       id int IDENTITY(1,1) NOT NULL
      ,val VARCHAR(200)
    );

   DECLARE 
       @val VARCHAR(4000)
      ,@ndx INT = -1

   INSERT INTO @t(val)
   SELECT value from string_split(@path, NCHAR(92)); -- ASCII 92 = Backslash
   SET @val = (SELECT TOP 1 val FROM @t ORDER BY id DESC);

   IF @with_ext = 0
   BEGIN
      SET @ndx = CHARINDEX('.', @val);

      SET @val = IIF(@ndx=0, @val, SUBSTRING(@val, 1, @ndx-1));
   END

   RETURN @val;
END
/*
EXEC test.test_084_fnGetFileNameFromPath;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================================================================
-- Author:      Terry Watts
-- Create date: 05-APR-2024
-- Description: returns:
--    if @ty_nm is a text array type then returns the full type from a data type + max_len fields
--    else returns @ty_nm on its own.
--
--    This is useful when using sys rtns like sys.columns
--
-- Test: test.test_089_fnGetFullTypeName
-- ================================================================================================
CREATE FUNCTION [dbo].[fnGetFullTypeName]
(
    @ty_nm  VARCHAR(20)
   ,@len    INT
)
RETURNS VARCHAR(50)
AS
BEGIN
   RETURN 
      iif
      (
         @ty_nm in ('VARCHAR','VARCHAR')
         ,CONCAT
         (
            UPPER(@ty_nm), '('
           ,iif(@len=-1, 'MAX', FORMAT(@len, '####'))
           ,')'
         )
         ,UPPER(@ty_nm)
      );
END
/*
  PRINT dbo.fnGetFullTypeName('VARCHAR', -1);
  PRINT dbo.fnGetFullTypeName('VARCHAR', 20);
  PRINT dbo.fnGetFullTypeName('VARCHAR', 4000);
  PRINT dbo.fnGetFullTypeName('INT', 30);
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: returns the log level key
-- =============================================
CREATE FUNCTION [dbo].[fnGetLogLevelKey] ()
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN N'LOG_LEVEL';
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.fnGetLogLevelKey', 
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ===============================================================
-- Author:      Terry Watts
-- Create date: 25-MAY-2020
-- Description: Get session context as int - default = -1
-- RETURNS      if    key/value present returns value as INT
--              if no key/value present returns NULL
--
-- See Also: fnGetSessionContextAsString, sp_set_session_context
--
-- CHANGES:
-- 14-JUL-2023: default = -1 (not found) was 0 before
-- 06-FEB-2024: simply returns value if key found else NULL
-- ===============================================================
CREATE FUNCTION [dbo].[fnGetSessionContextAsInt](@key NVARCHAR(100))
RETURNS INT
BEGIN
   RETURN CONVERT(INT, SESSION_CONTEXT(@key));
END
/*
PRINT CONCAT('[',dbo.fnGetSessionContextAsInt(N'cor_id'),']')
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: returns the log level
-- =============================================
CREATE FUNCTION [dbo].[fnGetLogLevel]()
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetLogLevelKey());
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.fnGetLogLevel', 80;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 15-JAN-2020
-- Description: returns standard NL char(s)
-- =============================================
CREATE FUNCTION [dbo].[fnGetNL]()
RETURNS VARCHAR(2)
AS
BEGIN
   RETURN NCHAR(13)+NCHAR(10)
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================================================
-- Author:      Terry watts
-- Create date: 24-APR-2024
-- Description: returns:
--   a string of n tabs (3 spcs each)
--
-- Test: test.test_086_sp_crt_tst_hlpr_script
-- ================================================================================================
CREATE FUNCTION [dbo].[fnGetNTabs]( @n    INT)
RETURNS VARCHAR(50)
AS
BEGIN
   RETURN REPLICATE(' ', @n*3);
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';

  PRINT CONCAT('[',dbo.fnGetNTabs(NULL),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(-1),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(0),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(1),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(3),']');
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Course](
	[course_id] [int] NOT NULL,
	[course_nm] [varchar](20) NULL,
	[description] [varchar](50) NULL,
 CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED 
(
	[course_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Course_name] UNIQUE NONCLUSTERED 
(
	[course_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Room](
	[room_id] [int] NOT NULL,
	[room_nm] [varchar](20) NOT NULL,
	[has_projector] [bit] NULL,
	[building] [varchar](20) NULL,
	[floor] [int] NULL,
 CONSTRAINT [PK_Room] PRIMARY KEY CLUSTERED 
(
	[room_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Room_name] UNIQUE NONCLUSTERED 
(
	[room_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Section](
	[section_id] [int] NOT NULL,
	[section_nm] [varchar](20) NOT NULL,
	[is_add] [bit] NOT NULL,
 CONSTRAINT [PK_Section] PRIMARY KEY CLUSTERED 
(
	[section_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Section_name] UNIQUE NONCLUSTERED 
(
	[section_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Section] ADD  CONSTRAINT [DF_Section_is_add]  DEFAULT ((1)) FOR [is_add]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Major](
	[major_id] [int] NOT NULL,
	[major_nm] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Major] PRIMARY KEY CLUSTERED 
(
	[major_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Major_name] ON [dbo].[Major]
(
	[major_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ClassSchedule](
	[classSchedule_id] [int] IDENTITY(1,1) NOT NULL,
	[course_id] [int] NOT NULL,
	[major_id] [int] NOT NULL,
	[section_id] [int] NOT NULL,
	[day] [varchar](3) NOT NULL,
	[st_time] [varchar](4) NOT NULL,
	[end_time] [varchar](4) NULL,
	[dow] [int] NULL,
	[description] [varchar](100) NULL,
	[room_id] [int] NULL,
 CONSTRAINT [PK_ClassSchedule_1] PRIMARY KEY CLUSTERED 
(
	[classSchedule_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[ClassSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ClassSchedule_Course] FOREIGN KEY([course_id])
REFERENCES [dbo].[Course] ([course_id])

ALTER TABLE [dbo].[ClassSchedule] CHECK CONSTRAINT [FK_ClassSchedule_Course]

ALTER TABLE [dbo].[ClassSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ClassSchedule_Major] FOREIGN KEY([major_id])
REFERENCES [dbo].[Major] ([major_id])

ALTER TABLE [dbo].[ClassSchedule] CHECK CONSTRAINT [FK_ClassSchedule_Major]

ALTER TABLE [dbo].[ClassSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ClassSchedule_Room] FOREIGN KEY([room_id])
REFERENCES [dbo].[Room] ([room_id])

ALTER TABLE [dbo].[ClassSchedule] CHECK CONSTRAINT [FK_ClassSchedule_Room]

ALTER TABLE [dbo].[ClassSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ClassSchedule_Section] FOREIGN KEY([section_id])
REFERENCES [dbo].[Section] ([section_id])

ALTER TABLE [dbo].[ClassSchedule] CHECK CONSTRAINT [FK_ClassSchedule_Section]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:      Terry Watts
-- Create date: 10-MAY-2025
-- Description: Returns the schedule id for given date, time
-- Tests:       test_058_fnGetScheuleIdForDateTime
-- ==========================================================
CREATE FUNCTION [dbo].[fnGetScheduleIdForDateTime]
(
    @dt     DATE
   ,@time24 VARCHAR(4)
)
RETURNS INT
AS
BEGIN
DECLARE
   @schedule_id  INT = -1
  ,@dow          INT
  ,@day_nm       VARCHAR(10)
  ,@start_time   VARCHAR(4)
;

SET @day_nm     = dbo.fnGetDayfromDate(@dt)--FORMAT(@dt    , 'ddd');
SET @start_time = SUBSTRING(@time24, 1,2);
SET @dow = dbo.fnGetDowFromDayName(@day_nm);

SELECT @schedule_id = classSchedule_id
FROM ClassSchedule
WHERE [day] = @day_nm
AND st_time  <=@time24
AND end_time >@time24
;

   RETURN @schedule_id;
END
/*
EXEC test.test_058_fnGetScheduleIdForDateTime;
EXEC tSQLt.Run 'test.test_058_fnGetScheduleIdForDateTime';

PRINT dbo.fnGetScheuleIdForDateTime('2025-04-10', '0800');

SELECT * FROM classSchedule;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =========================================================
-- View:         list_fks_vw
-- Description:  List the FK fields for all FKs
-- Design:       
-- Tests:        
-- Author:       Terry Watts
-- Create date:  01-MAR-2025
-- Preconditions: none
--
-- Postconditions
-- (@foreign_tbl exists AND (fk_nm=forign key name 
--                      AND f_tbl= foreign table name
--                      AND p_tbl = primary table name)
-- OR
-- (@foreign_tbl exists does not exist AND no rows returned)
-- =========================================================
CREATE VIEW [dbo].[list_fks_vw]
AS
SELECT
    schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table
   ,schema_name(pk_tab.schema_id) + '.' + pk_tab.name as primary_table
   ,fk_cols.constraint_column_id as no --, 
   ,fk_col.name as fk_column_name
   ,' = ' as [join]
   ,pk_col.name as pk_column_name
   ,fk.name as fk_constraint_name
FROM sys.foreign_keys fk
    join sys.tables              fk_tab  on fk_tab.object_id = fk.parent_object_id
    join sys.tables              pk_tab  on pk_tab.object_id = fk.referenced_object_id
    join sys.foreign_key_columns fk_cols on fk_cols.constraint_object_id = fk.object_id
    join sys.columns             fk_col  on fk_col.column_id = fk_cols.parent_column_id
                             and fk_col.object_id = fk_tab.object_id
    join sys.columns             pk_col  on pk_col.column_id = fk_cols.referenced_column_id
                             and pk_col.object_id = pk_tab.object_id
;
/*
SELECT * FROM list_fks_vw
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Function   : dbo.fnGetTableForFk
-- Description: returns the FK foreign table 
--              for the given FK
-- Author:      Terry Watts
-- Create date: 08-MAR-2025
--
-- Preconditions:
-- PRE01:

-- Postconditions:
---- POST01: if table not found throws div by zero exception
-- =========================================================
CREATE FUNCTION [dbo].[fnGetTableForFk](@fk_nm NVARCHAR(150))
RETURNS VARCHAR(60)
AS
BEGIN
   DECLARE @table_nm VARCHAR(60), @x INT
   SELECT @table_nm = foreign_table
   FROM list_fks_vw
   WHERE fk_constraint_name = @fk_nm

--   IF @table_nm IS NULL
--      SET @x = 1/0; -- BOOM

   RETURN @table_nm;
END
/*
PRINT dbo.fnGetTableForFk(NULL);
SELECT * FROM dbo.fnGetFksForForeignTable('UserRole');

EXEC test.sp__crt_tst_rtns 'dbo].[fnGetTableForFk';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
-- Description: returns the type name from the type code
--e.g. sysobjects xtype code 
-- ======================================================
CREATE FUNCTION [dbo].[fnGetTyNmFrmTyCode]
(
   @ty_code VARCHAR(2)
)
RETURNS VARCHAR(30)
AS
BEGIN
   RETURN
   (
      CASE 
         WHEN @ty_code = 'AF' THEN 'CLR aggregate function'
         WHEN @ty_code = 'C'  THEN 'CHECK constraint'
         WHEN @ty_code = 'D'  THEN 'DEFAULT'
         WHEN @ty_code = 'EC' THEN 'Edge constraint'
         WHEN @ty_code = 'ET' THEN 'External tbl'
         WHEN @ty_code = 'F'  THEN 'Foreign key'
         WHEN @ty_code = 'FN' THEN 'Scalar function'
         WHEN @ty_code = 'FS' THEN 'CLR scalar function'
         WHEN @ty_code = 'FT' THEN 'CLR table function'
         WHEN @ty_code = 'IF' THEN 'Inline table function'
         WHEN @ty_code = 'IT' THEN 'Intrnl table'
         WHEN @ty_code = 'P'  THEN 'Procedure'
         WHEN @ty_code = 'PC' THEN 'CLR procedure'
         WHEN @ty_code = 'PG' THEN 'Plan guide'
         WHEN @ty_code = 'PK' THEN 'Primary key'
         WHEN @ty_code = 'R'  THEN 'Rule'
         WHEN @ty_code = 'RF' THEN 'Repl fltr proc'
         WHEN @ty_code = 'S'  THEN 'Sys base table'
         WHEN @ty_code = 'SN' THEN 'Synonym'
         WHEN @ty_code = 'SO' THEN 'Sequence object'
         WHEN @ty_code = 'SQ' THEN 'Service queue'
         WHEN @ty_code = 'TA' THEN 'CLR DML trigger'
         WHEN @ty_code = 'TF' THEN 'Table function'
         WHEN @ty_code = 'TR' THEN 'SQL DML trigger'
         WHEN @ty_code = 'TT' THEN 'Table type'
         WHEN @ty_code = 'U'  THEN 'Table'
         WHEN @ty_code = 'UQ' THEN 'Unique Key'
         WHEN @ty_code = 'V'  THEN 'View'
         WHEN @ty_code = 'X'  THEN 'Extended procedure'
         ELSE '???'
      END
   );
END
/*
PRINT dbo.fnGetTyNmFrmTyCode('TF')
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-MAY-2025
-- Description: 
-- Tests:       
-- =============================================
CREATE FUNCTION [dbo].[fnHasDuplicateCharacters] (@input NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 0;

    IF @input IS NULL OR @input = ''
      RETURN 0;

    ;WITH Tally (n) AS (
        SELECT TOP (LEN(@input))
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
        FROM sys.all_objects
    ),
    Chars AS (
        SELECT 
            SUBSTRING(@input, n, 1) AS ch
        FROM Tally
    )
    SELECT TOP 1 @result = 1
    FROM Chars
    GROUP BY ch
    HAVING COUNT(*) > 1;

    RETURN @result;
END;
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_064_fnHasDuplicateCharacters';
SELECT dbo.fnHasDuplicateCharacters('hlelo') AS HasDuplicates;  -- Returns 1 (true)
SELECT dbo.fnHasDuplicateCharacters('abcd')  AS HasDuplicates;   -- Returns 0 (false)
EXEC test.sp__crt_tst_rtns 'dbo.fnHasDuplicateCharacters';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- See also: fnIsTxtInt
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsInt]( @v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @s VARCHAR(1000) = TRY_CONVERT( VARCHAR(1000), @v);

   IF dbo.fnLen(@s) = 0 -- returns 0 if null or MT
      RETURN 0;

   RETURN iif(TRY_CONVERT(INT, @v) IS NULL, 0, 1);
END
/*
EXEC tSQLt.Run 'test.test_022_fnIsInt';
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[fnIsInt]', @trn=22, @ad_stp=1;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Author:      Terry Watts
-- Create date: 06-DEc-2024
-- Description: compares 2 SQL_VARIANTs
-- RULES:
-- R01: if a < b return 1, 0 otherwise
-- R02: if types are same then a normal comparison should be used
-- R03: NULL < NULL returns 0
-- R04: NULL < NON NULL returns 1
-- R05: NON NULL < NULL returns 0
-- R06: different types try to convert to strings and then compare
--
-- Postconditions
-- Post 01: if a < b return 1
-- Post 02: if types are same then a normal comparison should be used
-- Post 03: NULL < NULL returns 0
-- Post 04: NULL < NON NULL returns 1
-- Post 05: NON NULL < NULL returns 0
-- Post 06: different types try to convert to strings and then compare
-- =========================================================
CREATE FUNCTION [dbo].[fnIsLessThan]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE 
       @aTxt   VARCHAR(4000)
      ,@bTxt   VARCHAR(4000)
      ,@typeA  VARCHAR(50)
      ,@typeB  VARCHAR(50)
      ,@ret    BIT
      ,@res    INT

   ------------------------------------------------------
   -- Handle Null NULL
   ------------------------------------------------------
   IF @a IS NULL AND @b IS NULL RETURN 0;

   ------------------------------------------------------
   -- Handle Null not NULL scenarios
   ------------------------------------------------------
   IF @a IS NULL AND @b IS NOT NULL RETURN 1;
   IF @a IS NOT NULL AND @a IS NULL RETURN 0;

   ------------------------------------------------------
   -- ASSERTION: Both a and b are not NULL
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle different types
   ------------------------------------------------------
   SELECT @typeA = CONVERT(VARCHAR(500),SQL_VARIANT_PROPERTY(@a, 'BaseType'))
         ,@typeB = CONVERT(VARCHAR(500),SQL_VARIANT_PROPERTY(@b, 'BaseType'))
    ;

   IF @typeA <> @typeB
   BEGIN
      SELECT @aTxt = CONVERT(VARCHAR(500),@a)
            ,@bTxt = CONVERT(VARCHAR(500),@b);

      RETURN iif(@aTxt < @bTxt, 1, 0);
   END

   ------------------------------------------------------
   -- ASSERTION: Both a and b are the same type
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle types where the variant < operator
   -- does not return correct value
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle general case where variant < operator works
   ------------------------------------------------------

   RETURN iif(@a<@b, 1, 0);
END
/*
EXEC test.test_054_fnIsLT
EXEC tSQLt.Run 'test.test_054_fnIsLT';
EXEC tSQLt.RunAll;
PRINT DB_Name()

   DECLARE 
       @a      SQL_VARIANT = 2
      ,@b      SQL_VARIANT = '2'
      ,@aTxt   VARCHAR(4000) = CONVERT(VARCHAR(500),@a)
      ,@bTxt   VARCHAR(4000) = CONVERT(VARCHAR(500),@b)
      ;
   PRINT iif(@a<@b, 1, 0);

   DECLARE 
       @a      SQL_VARIANT =  2
      ,@b      SQL_VARIANT = 'abc'
      ,@aTxt   VARCHAR(4000)
      ,@bTxt   VARCHAR(4000)
      ;

   SELECT @aTxt = CONVERT(VARCHAR(500),@a)
         ,@bTxt = CONVERT(VARCHAR(500),@b)

   PRINT iif(@a<@b, 1, 0);
   PRINT iif(@b<@a, 1, 0);
   PRINT iif(@aTxt<@bTxt, 1, 0);
   PRINT iif(@bTxt<@aTxt, 1, 0);
   PRINT CONCAT('[',@aTxt, ']');
   PRINT CONCAT('[',@bTxt, ']');
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 11-APR-2025
--
-- Description: splits a composoite string of 2 parts separated by a separator 
-- into a row containing the first part (a), and the second part (b)
--
--
-- Postconditions:
-- Post 01: if @composit contains sep then returns a 1 row table wher col a = first part 
--             and b  contains the second part when @composit is split using @sep
-- Changes:
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitPair2]
(
    @composit VARCHAR(1000) -- qualified routine name
   ,@sep CHAR(1)
)
RETURNS @t TABLE
(
    a  VARCHAR(1000)
   ,b  VARCHAR(1000)
)
AS
BEGIN
   DECLARE
    @n   INT
   ,@a   VARCHAR(50)
   ,@b   VARCHAR(100)

   IF @composit IS NOT NULL AND @composit <> '' AND @sep IS NOT NULL AND @sep <> ''
   BEGIN
      SET @n = CHARINDEX(@sep, @composit);

      IF @n = 0
      BEGIN
         INSERT INTO @t(a) VALUES( @composit);
         RETURN;
      END

      SET @a = SUBSTRING( @composit, 1   , @n-1);
      SET @b = SUBSTRING( @composit, @n+1, dbo.fnLen(@composit)-@n+1);

      INSERT INTO @t(a, b) VALUES( @a, @b);
   END
   --ELSE INSERT INTO @t(a) VALUES( 'IF @composit: false');

   RETURN;
END
/*
SELECT a, b FROM dbo.fnSplitPair2('a.b', '.');
EXEC tSQLt.Run 'test.test_024_fnSplitPair2';
SELECT * FROM fnSplitQualifiedName('test.fnGetRtnNmBits')
SELECT * FROM fnSplitQualifiedName('a.b')
SELECT * FROM fnSplitQualifiedName('a.b.c')
SELECT * FROM fnSplitQualifiedName('a')
SELECT * FROM fnSplitQualifiedName(null)
SELECT * FROM fnSplitQualifiedName('')
EXEC test.sp__crt_tst_rtns 'dbo].[fnSplitPair2';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 11-APR-2025
-- Description: determines if @s is in DORSU student id fmt 
--
-- Changes:
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsStudentId](@v VARCHAR(20))
RETURNS BIT
AS
BEGIN
   DECLARE
       @s  VARCHAR(1000)
      ,@a  VARCHAR(5)
      ,@b  VARCHAR(5)
   ;

   -- Check the length
   IF dbo.fnLen(@v) <> 9 -- returns 0 bad length
      RETURN 0;

   -- Check contains a - in pos 5
   IF SUBSTRING(@v, 5,1) <> '-'
      RETURN 0;

   -- Check both parts are ints
   SELECT 
       @a = a
      ,@b = b
   FROM dbo.fnSplitPair2(@v, '-')
   ;

   IF dbo.fnIsInt(@a) = 0
      RETURN 0;

   IF dbo.fnIsInt(@b) = 0
      RETURN 0;

   RETURN 1;
END
/*
PRINT dbo.fnIsStudentId('1998-2005')
a	b
1998	2005

EXEC tSQLt.Run 'test.test_035_fnIsStudentId';
EXEC tSQLt.RunAll;
SELECT * FROM dbo.fnSplitPair2('1998-2005', '-')
   ;
   SELECT dbo.fnIsInt('1998')
   SELECT dbo.fnIsInt('2005')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsTxtInt]( @v VARCHAR(50), @must_be_positive BIT)
RETURNS BIT
AS
BEGIN
   DECLARE @val INT
   ,@ret BIT

   -- SETUP
   IF @must_be_positive IS NULL  SET @must_be_positive = 0;

   -- PROCESS
   SET @val = TRY_CONVERT(INT, @v);
   SET @ret = iif(@val IS NULL, 0, 1);

      IF @ret = 1 AND @must_be_positive = 1
      BEGIN
         SET @ret = iif(@val >=0, 1, 0);
      END

   RETURN @ret;
END

/*
   DECLARE
       @v_str  VARCHAR(4000)
      ,@ret    BIT = 0
      ,@val    INT

--   DECLARE @type SQL_VARIANT
--   DECLARE @ty   VARCHAR(500)
--   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
--   SET @ty = CONVERT(VARCHAR(20), @type);
   SET @v_str = CONVERT(VARCHAR(4000), @v);

   WHILE(1=1)
   BEGIN
      IF dbo.fnLen(@v_str) = 0
         BREAK;

      IF @must_be_positive IS NULL  SET @must_be_positive = 0;
      SET @val = TRY_CONVERT(INT, @v);

      SET @ret = iif(@val IS NULL, 0, 1);

      IF @ret = 1 AND @must_be_positive = 1
      BEGIN
         --SET @val =  CONVERT(INT, @v);
         SET @ret = iif(@val >=0, 1, 0);
      END

      BREAK;
   END
   RETURN @ret;
END
*/
/*
PRINT CONVERT(INT, NULL);
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_044_fnIsInt';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GoogleAlias](
	[google_id] [int] NOT NULL,
	[google_alias] [varchar](50) NOT NULL,
	[student_id] [varchar](9) NOT NULL,
	[student_nm] [varchar](50) NULL,
	[gender] [varchar](1) NULL,
 CONSTRAINT [PK_GoogleNameStaging] PRIMARY KEY CLUSTERED 
(
	[student_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UQ_GoogleNameStaging] ON [dbo].[GoogleAlias]
(
	[google_alias] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 18-APR-2025
-- Description: maps the Google name to the student ID
-- Design:      EA
-- Tests:       test_010_fnMapGoogleAliasStudentID'
-- =============================================
CREATE FUNCTION [dbo].[fnMapGoogleAlias2StudentID](@google_alias VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
   DECLARE @student_id VARCHAR(9)
   ;

   SELECT @student_id = student_id
   FROM GoogleAlias
   WHERE google_alias= @google_alias
   ;

   RETURN @student_id;
END
/*
EXEC test.test_010_fnMapGoogleAliasStudentID;

EXEC tSQLt.Run 'test.test_010_fnMapGoogleAliasStudentID';
EXEC tSQLt.RunAll;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE FUNCTION [dbo].[fnMax] (@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
   RETURN CASE WHEN @p1 > @p2 THEN @p1 ELSE @p2 END 
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




CREATE FUNCTION [dbo].[fnMin] (@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
   RETURN CASE WHEN @p1 > @p2 THEN @p2 ELSE @p1 END;
END




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================
-- Description: Returns the normalised name
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 26-MAR-2025
-- =============================================
CREATE FUNCTION [dbo].[fnNormalizeNm](@student_nm VARCHAR(60))
RETURNS VARCHAR(60)
AS
BEGIN
DECLARE 
    --@student_nm VARCHAR(60) = 'Jellian Bungaos'
    @ndx INT
   ,@tmpNm VARCHAR(60)
   ,@i INT
   ;

   SET @ndx = CHARINDEX(' ', @student_nm);

   IF SUBSTRING(@student_nm, @ndx-1, 1)<> ','
   BEGIN
      -- Surname last
      SET @i = dbo.fnFindLastIndexOf(' ', @student_nm);
      SET @student_nm = CONCAT(SUBSTRING(@student_nm, @i+1, 20), ',', SUBSTRING(@student_nm, 1, @i-1));
      --PRINT CONCAT('[', @student_nm, ']');
   END

   RETURN @student_nm;
END
/*
PRINT CONCAT('[', dbo.fnNormalizeNm('Jellian Bungaos'), ']');
PRINT CONCAT('[', dbo.fnNormalizeNm('Pagayawan, Bea Mae M.'), ']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================    
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Pads Left
-- =============================================    
CREATE FUNCTION [dbo].[fnPadLeft2]( @s VARCHAR(500), @width INT, @pad VARCHAR(1)=' ')
RETURNS VARCHAR (1000)
AS
BEGIN
   DECLARE 
    @ret  VARCHAR(1000)
   ,@len INT

   IF @s IS null
      SET @s = '';

   SET @len = dbo.fnLen(@s);

   RETURN iif(@len < @width
      , RIGHT( CONCAT( REPLICATE( @pad, @width-@len), @s), @width)
      , RIGHT(@s, @width))
END
/*
SELECT CONCAT('[', dbo.fnPadLeft2('', 25, '.'), ']  ');
SELECT CONCAT('[', dbo.fnPadLeft2(NULL, 25, '.'), ']  ');
PRINT CONCAT('[', dbo.fnPadLeft2(NULL, 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('', 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('asdfg', 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('asdfg', 3, 'x'),']')
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Pads Left
-- =============================================    
CREATE FUNCTION [dbo].[fnPadLeft]( @s VARCHAR(500), @width INT)
RETURNS VARCHAR (4000)
AS
BEGIN
   RETURN dbo.fnPadLeft2(@s, @width, ' ');
END
/*
PRINT CONCAT('[', dbo.fnPadLeft('abcd', 10), ']');
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- =============================================    
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Pads Right with specified padding character
-- =============================================    
CREATE FUNCTION [dbo].[fnPadRight2]
(
    @s      VARCHAR(MAX)
   ,@width  INT
   ,@pad    VARCHAR(1)
)
RETURNS VARCHAR (1000)
AS
BEGIN
   DECLARE 
      @ret  VARCHAR(1000)
     ,@len  INT

   IF @s IS null
      SET @s = '';

   SET @len = ut.dbo.fnLen(@s)
   RETURN LEFT( CONCAT( @s, REPLICATE( @pad, @width-@len)), @width)
END
/*
SELECT CONCAT('[', dbo.fnPadRight2('a very long string indeed - its about time we had a beer', 25, '.'), ']  ');
SELECT CONCAT('[', dbo.fnPadRight2('', 25, '.'), ']  ');
SELECT CONCAT('[', dbo.fnPadRight2(NULL, 25, '.'), ']  ');
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================    
-- Author:  Terry Watts
-- Create date: 04-OCT-2019
-- Description: Pads Right
-- =============================================    
CREATE FUNCTION [dbo].[fnPadRight]( @s VARCHAR(500), @width INT)
RETURNS VARCHAR (1000)
AS
BEGIN
   RETURN dbo.fnPadRight2( @s, @width, ' ' )
END
/*
SELECT CONCAT(', ]', dbo.fnPadRight([name], 25), ']  ', [type])
FROM [tg].[test].[fnCrtPrmMap]( '          @table_nm                  VARCHAR(50)  
         ,@folder                    VARCHAR(260)  
         ,@workbook_nm               VARCHAR(260)   OUTPUT  
         ,@sheet_nm                  VARCHAR(50)    OUTPUT  
         ,@view_nm                   VARCHAR(50)    OUTPUT  
         ,@error_msg                 VARCHAR(200)   OUTPUT  ')
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================
-- Author:      Terry Watts
-- Create date: 27-NOV-2024
-- Description: returns rex for multiple search special characters
-- Returns the input replaces using the replace cls upto ndx chars
-- ================================================================
CREATE FUNCTION [dbo].[fnRegExMultiple]( @input VARCHAR(MAX), @pattern VARCHAR(1000), @replace_clause VARCHAR(MAX), @ndx int)
RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE
    @v VARCHAR(MAX)
   ,@c NCHAR(1) = SUBSTRING(@pattern, @ndx, 1)
   ,@special_chars VARCHAR(35)='#&*()<>?-_!@$%^=+[]{}'+ NCHAR(92) +'|;'':",./'
   ,@replaceChar NCHAR(2)
   ;

   --SET @pattern = CONCAT(@pattern, ' @ndx: ', @ndx); -- debug

   IF CHARINDEX(@c, @special_chars) > 0
   BEGIN
   SET @replaceChar =  CONCAT(NCHAR(92), @c);
   SET @v = STUFF(@pattern, @ndx, len(@c), @replaceChar);
   END
   ELSE
      SET @v =  CONCAT('log: ',@c); --@pattern;@pattern; --

   -- Reucrsive
   IF(@ndx < LEN(@pattern))
      SET @v = dbo.fnRegExMultiple(@input, @v, @replace_clause,  @ndx + LEN(@replaceChar))

   RETURN @v;
END
/*
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 17-MAY-2025
--
-- Description: Scores a Multiple choice score 
--
-- Postconditions:
-- Post 01: returns: if valid inputs then scrore
-- ELSE if len act> 5                then -200
-- ELSE an invalid selectiopn char   then -100
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnScoreMC50Answer]
(
    @exp       VARCHAR(10)
   ,@act       VARCHAR(10)
   ,@penalty   FLOAT -- for act ansd not in exp
)
RETURNS FLOAT
AS
BEGIN
   DECLARE
    @score  FLOAT = 0.0
   ,@pos    INT   = 0
   ,@cntE   INT   = dbo.fnLen(@exp)
   ,@cntA   INT   = dbo.fnLen(@act)
   ,@c      CHAR
   ;

   ----------------------------------
   -- Validation
   ---------------------------------0
   IF dbo.fnLen(@exp)>5
      RETURN -300.0; -- code/read error

   IF dbo.fnLen(@act)>5
      RETURN -200.0; -- code/read error

   IF dbo.fnLen(@act)= 0
      RETURN 0.0; -- no answer

   -- Validate the exp
   WHILE(@pos< @cntE)
   BEGIN
      SET @pos = @pos + 1;
      SET @c = SUBSTRING(@exp, @pos, 1);

      IF @c< 'A' OR @c > 'E'
         RETURN -400.0; --bad selection character error
   END

   ----------------------------------
   -- No duplicates in either
   ----------------------------------
   IF(dbo.fnHasDuplicateCharacters(@exp) = 1)
      RETURN -500.0;

   IF(dbo.fnHasDuplicateCharacters(@act) = 1)
      RETURN -600.0;


   -- iterate the expect answer
   -- look for each char in act that is exp and add 1 pt for each found
   SET @pos = 0;
   WHILE(@pos< @cntA)
   BEGIN
      SET @pos = @pos + 1;
      SET @c = SUBSTRING(@act, @pos, 1);

      IF @c< 'A' OR @c > 'E'
         RETURN -100.0; --bad selection character error

      IF CHARINDEX(@c, @exp)>0
         SET @score = @score + 1.0;
   END

   -- iterate the act answer
   -- look for each char in act that is not in exp and deduct @penalty pt for each

   IF @cntA > @cntE
   BEGIN
      --SET @cnt = dbo.fnLen(@exp);
      SET @pos = 0;

      WHILE(@pos< @cntA)
      BEGIN
         SET @pos = @pos + 1;
         SET @c = SUBSTRING(@act, @pos, 1);


         IF CHARINDEX(@c, @exp) = 0
            SET @score = @score - @penalty;
      END
   END

   RETURN @score;
END
/*
SELECT dbo.fnMC50ScoreAnswer('A','A', 0.4);
EXEC test.sp__crt_tst_rtns 'dbo.fnScoreMC50Answer'
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



--===========================================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine details
-- ===========================================================
CREATE VIEW [dbo].[SysRtns_vw]
AS
SELECT TOP 2000
    SCHEMA_NAME([schema_id])              AS schema_nm
   ,[name]                                AS rtn_nm
   ,IIF([type] IN ('P','PC'), 'P', 'F')   AS rtn_ty
   ,dbo.fnTrim([type])                    AS ty_code
   ,[type_desc]                           AS ty_nm
   ,IIF([type] IN ('FS','FT','PC'),1,0)   AS is_clr
   ,is_ms_shipped
   ,DATEFROMPARTS(YEAR(create_date), MONTH(create_date), Day(create_date)) AS created
   ,DATEFROMPARTS(YEAR(modify_date), MONTH(modify_date), Day(modify_date)) AS modified
FROM sys.objects
    WHERE
     [type] IN ('P', 'FN', 'TF', 'IF', 'AF', 'FT', 'IS', 'PC', 'FS')
ORDER BY [schema_nm], [type], [name]
;
/*
SELECT * FROM SysRtns_vw WHERE ty_code = 'P' AND schema_nm IN ('dbo','test')
SELECt top 500 * from sys.objects WHERE name like 'sp_%'
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
--
-- Description: splits a qualified rtn name 
-- into a row containing the schema_nm and the rtn_nm
-- removes square brackets
--
-- RULES:
-- @qrn  schema   rtn
-- a.b   a        b
-- a     dbo      a
-- NULL  null     null
-- ''    null     null
--
-- Preconditions
-- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
--          but differnt schema then raise div by zero exception

-- Postconditions:
-- Post 01: if schema is not specifed then get it from the sys rtns PROVIDED ONLY ONE rtn named the @rtn_nm
-- 
-- Changes:
-- 231117: handle [ ] wrappers
-- 240403: handle errors like null @qual_rtn_nm softly as per rules above
-- 241207: changed schema from test to dbo
-- 241227: default schema is now the schema found in the sys rtns for the given rtn in @qrn
--         will throw a div by zero error if PRE 02 violated
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitQualifiedName]
(
   @qrn VARCHAR(150) -- qualified routine name
)
RETURNS @t TABLE
(
    schema_nm  VARCHAR(50)
   ,rtn_nm     VARCHAR(100)
)
AS
BEGIN
   DECLARE
    @n          INT
   ,@schema_nm  VARCHAR(50)
   ,@rtn_nm     VARCHAR(100)

   -- Remove [ ] wrappers
   SET @qrn = dbo.fnDeSquareBracket(@qrn);

   IF @qrn IS NOT NULL AND @qrn <> ''
   BEGIN
      SET @n = CHARINDEX('.',@qrn);

      -- if rtn nm not qualified then assume schema = dbo
      SET @schema_nm = iif(@n=0, 'dbo',SUBSTRING( @qrn, 1   , @n-1));
      SET @rtn_nm    = iif(@n=0,  @qrn,SUBSTRING( @qrn, @n+1, dbo.fnLen(@qrn)-@n))

      -- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
      --          but differnt schema then raise div by zero exception
      IF( CHARINDEX('.', @qrn) = 0)
      BEGIN
         DECLARE @cnt INT;
         SELECT @cnt = COUNT(*) FROM dbo.SysRtns_vw WHERE rtn_nm = @qrn;

         -- Raise div by zero exception
         IF @cnt > 1 SET @cnt = @cnt/0;
      END
   END

   INSERT INTO @t (schema_nm, rtn_nm)
   VALUES( @schema_nm,@rtn_nm);
   RETURN;
END
/*
SELECT * FROM fnSplitQualifiedName('test.fnGetRtnNmBits')
SELECT * FROM fnSplitQualifiedName('a.b')
SELECT * FROM fnSplitQualifiedName('a.b.c')
SELECT * FROM fnSplitQualifiedName('a')
SELECT * FROM fnSplitQualifiedName(null)
SELECT * FROM fnSplitQualifiedName('')
EXEC test.sp__crt_tst_rtns '[dbo].[fnSplitQualifiedName]';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exists else false (0)
-- schema default is dbo
-- Parameters:  @q_table_nm can be qualified
-- Returns      1 if exists, 0 otherwise
-- =============================================================
CREATE FUNCTION [dbo].[fnTableExists](@q_table_nm VARCHAR(100))
RETURNS BIT
AS
BEGIN
   DECLARE
       @schema    VARCHAR(28)
      ,@table_nm  VARCHAR(60)
   ;

   SELECT
       @schema    = schema_nm
      ,@table_nm  = rtn_nm
   FROM fnSplitQualifiedName(@q_table_nm);

   RETURN iif(EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_nm AND TABLE_SCHEMA = @schema), 1, 0);
END

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Format](@input [nvarchar](max), @pattern [nvarchar](max), @format [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Format]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Format_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @format [nvarchar](max), @options [int])
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Format_Opt]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_IsMatch](@input [nvarchar](max), @pattern [nvarchar](max))
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_IsMatch]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_IsMatch_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @options [int])
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_IsMatch_Opt]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Match_Count](@input [nvarchar](max), @pattern [nvarchar](max))
RETURNS [int] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_Count]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Match_Count_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @options [int])
RETURNS [int] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_Count_Opt]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Match_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @options [int])
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_Opt]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Options](@IgnoreCase [bit], @MultiLine [bit], @ExplicitCapture [bit], @Compiled [bit], @SingleLine [bit], @IgnorePatternWhitespace [bit], @RightToLeft [bit], @ECMAScript [bit], @CultureInvariant [bit])
RETURNS [int] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Options]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Replace](@input [nvarchar](max), @pattern [nvarchar](max), @replacement [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Replace]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Replace_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @replacement [nvarchar](max), @options [int])
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Replace_Opt]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Match_All](@input [nvarchar](max), @pattern [nvarchar](max))
RETURNS  TABLE (
	[index] [int] NULL,
	[length] [int] NULL,
	[list] [nvarchar](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_All]

GO
SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Match_All_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @options [int])
RETURNS  TABLE (
	[index] [int] NULL,
	[length] [int] NULL,
	[list] [nvarchar](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_All_Opt]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AppLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[timestamp] [varchar](30) NOT NULL,
	[schema_nm] [varbinary](20) NULL,
	[rtn] [varchar](60) NULL,
	[hit] [int] NULL,
	[log] [varchar](max) NULL,
	[msg] [varchar](max) NULL,
	[level] [int] NULL,
	[row_count] [int] NULL,
 CONSTRAINT [PK_AppLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[AppLog] ADD  CONSTRAINT [DF_AppLog_timestamp]  DEFAULT (getdate()) FOR [timestamp]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =========================================================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Logs to output and to the AppLog table

-- Level: 0 DEBUG
--        1 INFO
--        2 NOTE
--        3 WARNING (CONTINUE)
--        4 ERROR   (STOP)
--
-- Changes:
-- 231014: Added support of table logging: add a row to table for each log 
--            Level and msg
-- 231016: Added fn and optional row count columns
-- 231017: @fn no longer needs the trailing ' :'
-- 231018: @fn, @row_count are stored as separate fields
-- 231115: added Level
-- 231116: always append to the AppLog table - bit print is conditional on level
-- 240309: Trimmed the  @fn paameter as it is left padded
-- 240314: Logic Change: now if less than min log level do not log or print msg
-- 231221: added hold, values:
--          0: print cache first then this msg on same line immediatly
--          1: cache msg for later - dont print it now 
--          2: dump cache first then print this msg on a new line immediatly
-- 240422: separate lines into a separate display line if msg contains \r\n
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_log]
 @level  INT = 1
,@fn     VARCHAR(45)=NULL
,@msg00  VARCHAR(MAX)=NULL,@msg01  VARCHAR(MAX)=NULL,@msg02  VARCHAR(MAX)=NULL,@msg03  VARCHAR(MAX)=NULL,@msg04  VARCHAR(MAX)=NULL,@msg05  VARCHAR(MAX)=NULL,@msg06  VARCHAR(MAX)=NULL,@msg07  VARCHAR(MAX)=NULL,@msg08  VARCHAR(MAX)=NULL,@msg09  VARCHAR(MAX)=NULL
,@msg10  VARCHAR(MAX)=NULL,@msg11  VARCHAR(MAX)=NULL,@msg12  VARCHAR(MAX)=NULL,@msg13  VARCHAR(MAX)=NULL,@msg14  VARCHAR(MAX)=NULL,@msg15  VARCHAR(MAX)=NULL,@msg16  VARCHAR(MAX)=NULL,@msg17  VARCHAR(MAX)=NULL,@msg18  VARCHAR(MAX)=NULL,@msg19  VARCHAR(MAX)=NULL
,@msg20  VARCHAR(MAX)=NULL,@msg21  VARCHAR(MAX)=NULL,@msg22  VARCHAR(MAX)=NULL,@msg23  VARCHAR(MAX)=NULL,@msg24  VARCHAR(MAX)=NULL,@msg25  VARCHAR(MAX)=NULL,@msg26  VARCHAR(MAX)=NULL,@msg27  VARCHAR(MAX)=NULL,@msg28  VARCHAR(MAX)=NULL,@msg29  VARCHAR(MAX)=NULL
,@msg30  VARCHAR(MAX)=NULL,@msg31  VARCHAR(MAX)=NULL,@msg32  VARCHAR(MAX)=NULL,@msg33  VARCHAR(MAX)=NULL,@msg34  VARCHAR(MAX)=NULL,@msg35  VARCHAR(MAX)=NULL,@msg36  VARCHAR(MAX)=NULL,@msg37  VARCHAR(MAX)=NULL,@msg38  VARCHAR(MAX)=NULL,@msg39  VARCHAR(MAX)=NULL
,@msg40  VARCHAR(MAX)=NULL,@msg41  VARCHAR(MAX)=NULL,@msg42  VARCHAR(MAX)=NULL,@msg43  VARCHAR(MAX)=NULL,@msg44  VARCHAR(MAX)=NULL,@msg45  VARCHAR(MAX)=NULL,@msg46  VARCHAR(MAX)=NULL,@msg47  VARCHAR(MAX)=NULL,@msg48  VARCHAR(MAX)=NULL,@msg49  VARCHAR(MAX)=NULL
,@msg50  VARCHAR(MAX)=NULL,@msg51  VARCHAR(MAX)=NULL,@msg52  VARCHAR(MAX)=NULL,@msg53  VARCHAR(MAX)=NULL,@msg54  VARCHAR(MAX)=NULL,@msg55  VARCHAR(MAX)=NULL,@msg56  VARCHAR(MAX)=NULL,@msg57  VARCHAR(MAX)=NULL,@msg58  VARCHAR(MAX)=NULL,@msg59  VARCHAR(MAX)=NULL
,@msg60  VARCHAR(MAX)=NULL,@msg61  VARCHAR(MAX)=NULL,@msg62  VARCHAR(MAX)=NULL,@msg63  VARCHAR(MAX)=NULL,@msg64  VARCHAR(MAX)=NULL,@msg65  VARCHAR(MAX)=NULL,@msg66  VARCHAR(MAX)=NULL,@msg67  VARCHAR(MAX)=NULL,@msg68  VARCHAR(MAX)=NULL,@msg69  VARCHAR(MAX)=NULL
,@msg70  VARCHAR(MAX)=NULL,@msg71  VARCHAR(MAX)=NULL,@msg72  VARCHAR(MAX)=NULL,@msg73  VARCHAR(MAX)=NULL,@msg74  VARCHAR(MAX)=NULL,@msg75  VARCHAR(MAX)=NULL,@msg76  VARCHAR(MAX)=NULL,@msg77  VARCHAR(MAX)=NULL,@msg78  VARCHAR(MAX)=NULL,@msg79  VARCHAR(MAX)=NULL
,@msg80  VARCHAR(MAX)=NULL,@msg81  VARCHAR(MAX)=NULL,@msg82  VARCHAR(MAX)=NULL,@msg83  VARCHAR(MAX)=NULL,@msg84  VARCHAR(MAX)=NULL,@msg85  VARCHAR(MAX)=NULL,@msg86  VARCHAR(MAX)=NULL,@msg87  VARCHAR(MAX)=NULL,@msg88  VARCHAR(MAX)=NULL,@msg89  VARCHAR(MAX)=NULL
,@msg90  VARCHAR(MAX)=NULL,@msg91  VARCHAR(MAX)=NULL,@msg92  VARCHAR(MAX)=NULL,@msg93  VARCHAR(MAX)=NULL,@msg94  VARCHAR(MAX)=NULL,@msg95  VARCHAR(MAX)=NULL,@msg96  VARCHAR(MAX)=NULL,@msg97  VARCHAR(MAX)=NULL,@msg98  VARCHAR(MAX)=NULL,@msg99  VARCHAR(MAX)=NULL
,@msg100 VARCHAR(MAX)=NULL,@msg101 VARCHAR(MAX)=NULL,@msg102 VARCHAR(MAX)=NULL,@msg103 VARCHAR(MAX)=NULL,@msg104 VARCHAR(MAX)=NULL,@msg105 VARCHAR(MAX)=NULL,@msg106 VARCHAR(MAX)=NULL,@msg107 VARCHAR(MAX)=NULL,@msg108 VARCHAR(MAX)=NULL,@msg109 VARCHAR(MAX)=NULL
,@msg110 VARCHAR(MAX)=NULL,@msg111 VARCHAR(MAX)=NULL,@msg112 VARCHAR(MAX)=NULL,@msg113 VARCHAR(MAX)=NULL,@msg114 VARCHAR(MAX)=NULL,@msg115 VARCHAR(MAX)=NULL,@msg116 VARCHAR(MAX)=NULL,@msg117 VARCHAR(MAX)=NULL,@msg118 VARCHAR(MAX)=NULL,@msg119 VARCHAR(MAX)=NULL
,@msg120 VARCHAR(MAX)=NULL,@msg121 VARCHAR(MAX)=NULL,@msg122 VARCHAR(MAX)=NULL,@msg123 VARCHAR(MAX)=NULL,@msg124 VARCHAR(MAX)=NULL,@msg125 VARCHAR(MAX)=NULL,@msg126 VARCHAR(MAX)=NULL,@msg127 VARCHAR(MAX)=NULL,@msg128 VARCHAR(MAX)=NULL,@msg129 VARCHAR(MAX)=NULL
,@msg130 VARCHAR(MAX)=NULL,@msg131 VARCHAR(MAX)=NULL,@msg132 VARCHAR(MAX)=NULL,@msg133 VARCHAR(MAX)=NULL,@msg134 VARCHAR(MAX)=NULL,@msg135 VARCHAR(MAX)=NULL,@msg136 VARCHAR(MAX)=NULL,@msg137 VARCHAR(MAX)=NULL,@msg138 VARCHAR(MAX)=NULL,@msg139 VARCHAR(MAX)=NULL
,@msg140 VARCHAR(MAX)=NULL,@msg141 VARCHAR(MAX)=NULL,@msg142 VARCHAR(MAX)=NULL,@msg143 VARCHAR(MAX)=NULL,@msg144 VARCHAR(MAX)=NULL,@msg145 VARCHAR(MAX)=NULL,@msg146 VARCHAR(MAX)=NULL,@msg147 VARCHAR(MAX)=NULL,@msg148 VARCHAR(MAX)=NULL,@msg149 VARCHAR(MAX)=NULL
,@msg150 VARCHAR(MAX)=NULL,@msg151 VARCHAR(MAX)=NULL,@msg152 VARCHAR(MAX)=NULL,@msg153 VARCHAR(MAX)=NULL,@msg154 VARCHAR(MAX)=NULL,@msg155 VARCHAR(MAX)=NULL,@msg156 VARCHAR(MAX)=NULL,@msg157 VARCHAR(MAX)=NULL,@msg158 VARCHAR(MAX)=NULL,@msg159 VARCHAR(MAX)=NULL
,@msg160 VARCHAR(MAX)=NULL,@msg161 VARCHAR(MAX)=NULL,@msg162 VARCHAR(MAX)=NULL,@msg163 VARCHAR(MAX)=NULL,@msg164 VARCHAR(MAX)=NULL,@msg165 VARCHAR(MAX)=NULL,@msg166 VARCHAR(MAX)=NULL,@msg167 VARCHAR(MAX)=NULL,@msg168 VARCHAR(MAX)=NULL,@msg169 VARCHAR(MAX)=NULL
,@msg170 VARCHAR(MAX)=NULL,@msg171 VARCHAR(MAX)=NULL,@msg172 VARCHAR(MAX)=NULL,@msg173 VARCHAR(MAX)=NULL,@msg174 VARCHAR(MAX)=NULL,@msg175 VARCHAR(MAX)=NULL,@msg176 VARCHAR(MAX)=NULL,@msg177 VARCHAR(MAX)=NULL,@msg178 VARCHAR(MAX)=NULL,@msg179 VARCHAR(MAX)=NULL
,@msg180 VARCHAR(MAX)=NULL,@msg181 VARCHAR(MAX)=NULL,@msg182 VARCHAR(MAX)=NULL,@msg183 VARCHAR(MAX)=NULL,@msg184 VARCHAR(MAX)=NULL,@msg185 VARCHAR(MAX)=NULL,@msg186 VARCHAR(MAX)=NULL,@msg187 VARCHAR(MAX)=NULL,@msg188 VARCHAR(MAX)=NULL,@msg189 VARCHAR(MAX)=NULL
,@msg190 VARCHAR(MAX)=NULL,@msg191 VARCHAR(MAX)=NULL,@msg192 VARCHAR(MAX)=NULL,@msg193 VARCHAR(MAX)=NULL,@msg194 VARCHAR(MAX)=NULL,@msg195 VARCHAR(MAX)=NULL,@msg196 VARCHAR(MAX)=NULL,@msg197 VARCHAR(MAX)=NULL,@msg198 VARCHAR(MAX)=NULL,@msg199 VARCHAR(MAX)=NULL
,@msg200 VARCHAR(MAX)=NULL,@msg201 VARCHAR(MAX)=NULL,@msg202 VARCHAR(MAX)=NULL,@msg203 VARCHAR(MAX)=NULL,@msg204 VARCHAR(MAX)=NULL,@msg205 VARCHAR(MAX)=NULL,@msg206 VARCHAR(MAX)=NULL,@msg207 VARCHAR(MAX)=NULL,@msg208 VARCHAR(MAX)=NULL,@msg209 VARCHAR(MAX)=NULL
,@msg210 VARCHAR(MAX)=NULL,@msg211 VARCHAR(MAX)=NULL,@msg212 VARCHAR(MAX)=NULL,@msg213 VARCHAR(MAX)=NULL,@msg214 VARCHAR(MAX)=NULL,@msg215 VARCHAR(MAX)=NULL,@msg216 VARCHAR(MAX)=NULL,@msg217 VARCHAR(MAX)=NULL,@msg218 VARCHAR(MAX)=NULL,@msg219 VARCHAR(MAX)=NULL
,@msg220 VARCHAR(MAX)=NULL,@msg221 VARCHAR(MAX)=NULL,@msg222 VARCHAR(MAX)=NULL,@msg223 VARCHAR(MAX)=NULL,@msg224 VARCHAR(MAX)=NULL,@msg225 VARCHAR(MAX)=NULL,@msg226 VARCHAR(MAX)=NULL,@msg227 VARCHAR(MAX)=NULL,@msg228 VARCHAR(MAX)=NULL,@msg229 VARCHAR(MAX)=NULL
,@msg230 VARCHAR(MAX)=NULL,@msg231 VARCHAR(MAX)=NULL,@msg232 VARCHAR(MAX)=NULL,@msg233 VARCHAR(MAX)=NULL,@msg234 VARCHAR(MAX)=NULL,@msg235 VARCHAR(MAX)=NULL,@msg236 VARCHAR(MAX)=NULL,@msg237 VARCHAR(MAX)=NULL,@msg238 VARCHAR(MAX)=NULL,@msg239 VARCHAR(MAX)=NULL
,@msg240 VARCHAR(MAX)=NULL,@msg241 VARCHAR(MAX)=NULL,@msg242 VARCHAR(MAX)=NULL,@msg243 VARCHAR(MAX)=NULL,@msg244 VARCHAR(MAX)=NULL,@msg245 VARCHAR(MAX)=NULL,@msg246 VARCHAR(MAX)=NULL,@msg247 VARCHAR(MAX)=NULL,@msg248 VARCHAR(MAX)=NULL,@msg249 VARCHAR(MAX)=NULL
,@row_count INT = NULL
AS
BEGIN
   DECLARE
       @fnThis          VARCHAR(35) = 'sp_log'
      ,@min_log_level   INT
      ,@lvl_msg         VARCHAR(MAX)
      ,@log_msg         VARCHAR(4000)
      ,@row_count_str   VARCHAR(30) = NULL

   SET NOCOUNT ON
   SET @min_log_level = COALESCE(dbo.fnGetSessionContextAsInt(N'LOG_LEVEL'), 1); -- Default: INFO

   SET @lvl_msg = 
   CASE
      WHEN @level = 0 THEN 'DEBUG'
      WHEN @level = 1 THEN 'INFO '
      WHEN @level = 2 THEN 'NOTE '
      WHEN @level = 3 THEN 'WARN '
      WHEN @level = 4 THEN 'ERROR'
      ELSE '???? '
   END;

   SET @fn= dbo.fnPadRight(@fn, 45);

   IF @row_count IS NOT NULL SET @row_count_str = CONCAT(' rowcount: ', @row_count)

   SET @log_msg = CONCAT
   (
       @msg00 ,@msg01 ,@msg02 ,@msg03, @msg04, @msg05, @msg06 ,@msg07 ,@msg08 ,@msg09 
      ,@msg10 ,@msg11 ,@msg12 ,@msg13, @msg14, @msg15, @msg16 ,@msg17 ,@msg18 ,@msg19
      ,@msg20 ,@msg21 ,@msg22 ,@msg23, @msg24, @msg25, @msg26 ,@msg27 ,@msg28 ,@msg29
      ,@msg30 ,@msg31 ,@msg32 ,@msg33, @msg34, @msg35, @msg36 ,@msg37 ,@msg38 ,@msg39
      ,@msg40 ,@msg41 ,@msg42 ,@msg43, @msg44, @msg45, @msg46 ,@msg47 ,@msg48 ,@msg49
      ,@msg50 ,@msg51 ,@msg52 ,@msg53, @msg54, @msg55, @msg56 ,@msg57 ,@msg58 ,@msg59
      ,@msg60 ,@msg61 ,@msg62 ,@msg63, @msg64, @msg65, @msg66 ,@msg67 ,@msg68 ,@msg69
      ,@msg70 ,@msg71 ,@msg72 ,@msg73, @msg74, @msg75, @msg76 ,@msg77 ,@msg78 ,@msg79
      ,@msg80 ,@msg81 ,@msg82 ,@msg83, @msg84, @msg85, @msg86 ,@msg87 ,@msg88 ,@msg89
      ,@msg90 ,@msg91 ,@msg92 ,@msg93, @msg94, @msg95, @msg96 ,@msg97 ,@msg98 ,@msg99
      ,@msg100,@msg101,@msg102,@msg103,@msg104,@msg105,@msg106,@msg107,@msg108,@msg109 
      ,@msg110,@msg111,@msg112,@msg113,@msg114,@msg115,@msg116,@msg117,@msg118,@msg119 
      ,@msg120,@msg121,@msg122,@msg123,@msg124,@msg125,@msg126,@msg127,@msg128,@msg129 
      ,@msg130,@msg131,@msg132,@msg133,@msg134,@msg135,@msg136,@msg137,@msg138,@msg139 
      ,@msg140,@msg141,@msg142,@msg143,@msg144,@msg145,@msg146,@msg147,@msg148,@msg149 
      ,@msg150,@msg151,@msg152,@msg153,@msg154,@msg155,@msg156,@msg157,@msg158,@msg159 
      ,@msg160,@msg161,@msg162,@msg163,@msg164,@msg165,@msg166,@msg167,@msg168,@msg169 
      ,@msg170,@msg171,@msg172,@msg173,@msg174,@msg175,@msg176,@msg177,@msg178,@msg179 
      ,@msg180,@msg181,@msg182,@msg183,@msg184,@msg185,@msg186,@msg187,@msg188,@msg189 
      ,@msg190,@msg191,@msg192,@msg193,@msg194,@msg195,@msg196,@msg197,@msg198,@msg199 
      ,@msg200,@msg201,@msg202,@msg203,@msg204,@msg205,@msg206,@msg207,@msg208,@msg209 
      ,@msg210,@msg211,@msg212,@msg213,@msg214,@msg215,@msg216,@msg217,@msg218,@msg219 
      ,@msg220,@msg221,@msg222,@msg223,@msg224,@msg225,@msg226,@msg227,@msg228,@msg229 
      ,@msg230,@msg231,@msg232,@msg233,@msg234,@msg235,@msg236,@msg237,@msg238,@msg239 
      ,@msg240,@msg241,@msg242,@msg243,@msg244,@msg245,@msg246,@msg247,@msg248,@msg249 
      ,@row_count_str
   );

   -- Always log to log table
   INSERT INTO AppLog (rtn, msg, [level], row_count)
   VALUES (dbo.fnTrim(@fn), @log_msg, @level, @row_count);

   -- Only display if required
   IF @level >=@min_log_level
   BEGIN
      PRINT CONCAT(@lvl_msg, ' ',@fn, ': ', @log_msg);
   END
END
/*
EXEC tSQLt.RunAll;
SELECT * From AppLog
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Author:      Terry Watts
-- Create date: 25-MAR-2020
-- Description: Raises an exception
--    Ensures @state is positive
--    if @ex_num < 50000 message and raise to 50K+ @ex_num
-- =========================================================
CREATE PROCEDURE [dbo].[sp_raise_exception]
       @ex_num    INT           = 53000
      ,@msg0      VARCHAR(max)  = NULL
      ,@msg1      VARCHAR(max)  = NULL
      ,@msg2      VARCHAR(max)  = NULL
      ,@msg3      VARCHAR(max)  = NULL
      ,@msg4      VARCHAR(max)  = NULL
      ,@msg5      VARCHAR(max)  = NULL
      ,@msg6      VARCHAR(max)  = NULL
      ,@msg7      VARCHAR(max)  = NULL
      ,@msg8      VARCHAR(max)  = NULL
      ,@msg9      VARCHAR(max)  = NULL
      ,@msg10     VARCHAR(max)  = NULL
      ,@msg11     VARCHAR(max)  = NULL
      ,@msg12     VARCHAR(max)  = NULL
      ,@msg13     VARCHAR(max)  = NULL
      ,@msg14     VARCHAR(max)  = NULL
      ,@msg15     VARCHAR(max)  = NULL
      ,@msg16     VARCHAR(max)  = NULL
      ,@msg17     VARCHAR(max)  = NULL
      ,@msg18     VARCHAR(max)  = NULL
      ,@msg19     VARCHAR(max)  = NULL
      ,@msg20     VARCHAR(max)  = NULL
      ,@fn        VARCHAR(35)   = NULL
AS
BEGIN
   DECLARE
       @fnThis    VARCHAR(35) = 'sp_raise_exception'
      ,@msg       VARCHAR(max)


   SET @msg =
      CONCAT
      (
          @msg0
         ,iif(dbo.fnLen(@msg1)=0,'',' '), @msg1
         ,iif(dbo.fnLen(@msg2)=0,'',' '), @msg2
         ,@msg3
         ,@msg4
         ,@msg5
         ,@msg6
         ,@msg7
         ,@msg8
         ,@msg9
         ,@msg10
         ,@msg11
         ,@msg12
         ,@msg13
         ,@msg14
         ,@msg15
         ,@msg16
         ,@msg17
         ,@msg18
         ,@msg19
         ,@msg20
      );

      IF @ex_num IS NULL SET @ex_num = 53000; -- default
      EXEC sp_log 4, @fnThis, '000: throwing exception ', @ex_num, ' ', @msg, ' st: 1';

   ------------------------------------------------------------------------------------------------
   -- Validate
   ------------------------------------------------------------------------------------------------
   -- check ex num >= 50000 if not add 50000 to it
   IF @ex_num < 50000
   BEGIN
      SET @ex_num = abs(@ex_num) + 50000;
      EXEC sp_log 3, @fnThis, '010: supplied exception number is too low changing to ', @ex_num;
   END

   ------------------------------------------------------------------------------------------------
   -- Throw the exception
   ------------------------------------------------------------------------------------------------
   ;THROW @ex_num, @msg, 1;
END
/*
EXEC sp_raise_exception 53000, 'test exception msg 1',' msg 2', @state=2, @fn='test_fn'
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is null or empty
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_null_or_empty]
    @val       VARCHAR(3999)
   ,@msg1      VARCHAR(200)   = NULL
   ,@msg2      VARCHAR(200)   = NULL
   ,@msg3      VARCHAR(200)   = NULL
   ,@msg4      VARCHAR(200)   = NULL
   ,@msg5      VARCHAR(200)   = NULL
   ,@msg6      VARCHAR(200)   = NULL
   ,@msg7      VARCHAR(200)   = NULL
   ,@msg8      VARCHAR(200)   = NULL
   ,@msg9      VARCHAR(200)   = NULL
   ,@msg10     VARCHAR(200)   = NULL
   ,@msg11     VARCHAR(200)   = NULL
   ,@msg12     VARCHAR(200)   = NULL
   ,@msg13     VARCHAR(200)   = NULL
   ,@msg14     VARCHAR(200)   = NULL
   ,@msg15     VARCHAR(200)   = NULL
   ,@msg16     VARCHAR(200)   = NULL
   ,@msg17     VARCHAR(200)   = NULL
   ,@msg18     VARCHAR(200)   = NULL
   ,@msg19     VARCHAR(200)   = NULL
   ,@msg20     VARCHAR(200)   = NULL
   ,@ex_num    INT            = NULL
   ,@fn        VARCHAR(35)    = '*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE 
       @fnThis    VARCHAR(35) = N'sp_assert_not_null_or_empty'
      ,@valTxt    VARCHAR(20)= @val
   ;

   EXEC sp_log @log_level, @fnThis, '000: starting,' ,@msg1,': @val:[',@val,']';

   IF dbo.fnLen(@val) > 0
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
       IF dbo.fnLen(@valTxt) < 20 SET @valTxt= CONCAT(@valTxt, '   ');
      EXEC sp_log @log_level, @fnThis, '010: OK, ASSERTION: val: [',@valTxt, '] IS NOT NULL';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fn, '020: @val IS NULL OR EMPTY, raising exception';
   IF @ex_num IS NULL SET @ex_num = 50005;
   DECLARE @msg0 VARCHAR(20)= 'val is NULL or empty'

   EXEC sp_raise_exception
       @ex_num = @ex_num
      ,@msg1   = @msg0
      ,@msg2   = @msg1
      ,@msg3   = @msg2
      ,@msg4   = @msg3
      ,@msg5   = @msg4
      ,@msg6   = @msg5
      ,@msg7   = @msg6
      ,@msg8   = @msg7
      ,@msg9   = @msg8
      ,@msg10  = @msg9
      ,@msg11  = @msg10
      ,@msg12  = @msg11
      ,@msg13  = @msg12
      ,@msg14  = @msg13
      ,@msg15  = @msg14
      ,@msg16  = @msg15
      ,@msg17  = @msg16
      ,@msg18  = @msg17
      ,@msg19  = @msg18
      ,@msg20  = @msg19
      ,@fn     = @fn
      ;
END
/*
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
EXEC tSQLt.RunAll;
EXEC sp_assert_not_null_or_empty NULL
EXEC sp_assert_not_null_or_empty ''
EXEC sp_assert_not_null_or_empty 'Fred'
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-MAR-2020
-- Description: standard error handling:
--              get the exception message, log messages
--              clear the log cache first
-- NB: this does not throw
--
-- CHANGES
-- 231221: added clear the log cache first
-- 240315: added ex num, ex msg as optional out parmeters
-- 241204: it is possible that ERROR_MESSAGE() or ERROR_NUMBER() are throwing exceptions 
--        -this can happen inside tranactions when low level errors like select * from non existant table
-- 241221: error proc and error line do not always work - for example when executing SQL statements that
--         return a low error number like the following: 207:Invalid column name    
-- ========================================================================================================
CREATE PROCEDURE [dbo].[sp_log_exception]
       @fn        VARCHAR(35)
      ,@msg01     VARCHAR(4000) = NULL
      ,@msg02     VARCHAR(1000) = NULL
      ,@msg03     VARCHAR(1000) = NULL
      ,@msg04     VARCHAR(1000) = NULL
      ,@msg05     VARCHAR(1000) = NULL
      ,@msg06     VARCHAR(1000) = NULL
      ,@msg07     VARCHAR(1000) = NULL
      ,@msg08     VARCHAR(1000) = NULL
      ,@msg09     VARCHAR(1000) = NULL
      ,@msg10     VARCHAR(1000) = NULL
      ,@msg11     VARCHAR(1000) = NULL
      ,@msg12     VARCHAR(1000) = NULL
      ,@msg13     VARCHAR(1000) = NULL
      ,@msg14     VARCHAR(1000) = NULL
      ,@msg15     VARCHAR(1000) = NULL
      ,@msg16     VARCHAR(1000) = NULL
      ,@msg17     VARCHAR(1000) = NULL
      ,@msg18     VARCHAR(1000) = NULL
      ,@msg19     VARCHAR(1000) = NULL
      ,@ex_num    INT            = NULL OUT
      ,@ex_msg    VARCHAR(500)  = NULL OUT
      ,@ex_proc   VARCHAR(80)   = NULL OUT
      ,@ex_line   VARCHAR(20)   = NULL OUT
AS
BEGIN
   DECLARE 
       @fnThis    VARCHAR(35) = 'sp_log_exception'
      ,@NL        VARCHAR(2)  =  NCHAR(13) + NCHAR(10)
      ,@msg       VARCHAR(500)
      ,@fnHdr     VARCHAR(100)
      ,@isTrans   BIT = 0
      ,@line      VARCHAR(4000)

   SET @ex_num = -1; -- unknown
   SET @msg    = 'UNKNOWN MESSAGE';

   --EXEC sp_log 4, @fnThis, '510: starting';

   SELECT
       @ex_num = ERROR_NUMBER()
      ,@ex_proc= ERROR_PROCEDURE()
      ,@ex_line= CAST(ERROR_LINE() AS VARCHAR(20))
      ,@ex_msg = ERROR_MESSAGE();

   SET @fnHdr = CONCAT(@ex_proc, '(',@ex_line,'): ')

   BEGIN TRY
      SET @msg =
      CONCAT
      (
         '500: caught exception ', @ex_num, ': ', @ex_msg, ' ', 
          @msg01
         ,iif(@msg02 IS NOT NULL, CONCAT(' ', @msg02 ), '')
         ,iif(@msg03 IS NOT NULL, CONCAT(' ', @msg03 ), '')
         ,iif(@msg04 IS NOT NULL, CONCAT(' ', @msg04 ), '')
         ,iif(@msg05 IS NOT NULL, CONCAT(' ', @msg05 ), '')
         ,iif(@msg06 IS NOT NULL, CONCAT(' ', @msg06 ), '')
         ,iif(@msg07 IS NOT NULL, CONCAT(' ', @msg07 ), '')
         ,iif(@msg08 IS NOT NULL, CONCAT(' ', @msg08 ), '')
         ,iif(@msg09 IS NOT NULL, CONCAT(' ', @msg09 ), '')
         ,iif(@msg10 IS NOT NULL, CONCAT(' ', @msg10 ), '')
         ,iif(@msg11 IS NOT NULL, CONCAT(' ', @msg11 ), '')
         ,iif(@msg12 IS NOT NULL, CONCAT(' ', @msg12 ), '')
         ,iif(@msg13 IS NOT NULL, CONCAT(' ', @msg13 ), '')
         ,iif(@msg14 IS NOT NULL, CONCAT(' ', @msg14 ), '')
         ,iif(@msg15 IS NOT NULL, CONCAT(' ', @msg15 ), '')
         ,iif(@msg16 IS NOT NULL, CONCAT(' ', @msg16 ), '')
         ,iif(@msg17 IS NOT NULL, CONCAT(' ', @msg17 ), '')
         ,iif(@msg18 IS NOT NULL, CONCAT(' ', @msg18 ), '')
         ,iif(@msg19 IS NOT NULL, CONCAT(' ', @msg19 ), '')
      );

      SET @line = REPLICATE('*', dbo.fnMin(300, dbo.fnLen(@msg)+46));

      PRINT CONCAT(@nl, @line);
      EXEC sp_log 4, @fnThis, @fnHdr, @msg;
      PRINT CONCAT(@line, @nl);
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fnThis, '590: failed. exception was: ', @ex_num, ': ', @ex_msg;
      SET @ex_num = ERROR_NUMBER();
      SET @ex_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fnThis,  '580: sp_log failed, exception: ',@ex_num, ': @ex_msg';
      SET @ex_msg ='*** system error: failed to get error msg ***';
   END CATCH
END




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE View [dbo].[fk_vw]
AS
SELECT
    name                              AS fk_nm
   ,SCHEMA_NAME(schema_id)            AS schema_nm
   ,OBJECT_NAME(parent_object_id)     AS f_table_nm
   ,OBJECT_NAME(referenced_object_id) AS p_table_nm
   ,is_disabled
FROM sys.foreign_keys
;
/*
SELECT * FROM fk_vw
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Description: returns 1 row containing the
--              FK main details (not columns)
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 07-MAR-2025
-- =============================================
CREATE FUNCTION [dbo].[fnGetFk]( @fk_nm VARCHAR(60))
RETURNS @t TABLE
(
    fk_nm         VARCHAR(60)
   ,schema_nm     VARCHAR(60)
   ,f_table_nm    VARCHAR(60)
   ,p_table_nm    VARCHAR(60)
   ,is_disabled   BIT
)
AS
BEGIN
   INSERT INTO @t(fk_nm,schema_nm,f_table_nm,p_table_nm, is_disabled)
   SELECT fk_nm,schema_nm,f_table_nm,p_table_nm, is_disabled
   FROM fk_vw
   WHERE fk_nm LIKE @fk_nm OR @fk_nm IS NULL;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetFk('')

*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: creates a releationship
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 07-MAR-2025
--
-- PRECONDITIONS:
-- PRE 01 @fk_nm NOT NULL or EMPTY  Checked
-- =============================================
CREATE PROCEDURE [dbo].[sp_drop_FK]
    @fk_nm        VARCHAR(80)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
     @fn          VARCHAR(35) = 'sp_drop_FK'
    ,@sql         NVARCHAR(MAX)
    ,@f_table_nm  VARCHAR(60)
    ,@f_schema_nm VARCHAR(60)
    ,@qtn         VARCHAR(120)
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000 starting
fk_nm:      [', @fk_nm     , ']';

   -----------------------------------------------------------------
   -- Validation
   -----------------------------------------------------------------
   -- PRE 01 @fk_nm NOT NULL or EMPTY  Checked
   EXEC sp_assert_not_null_or_empty @fk_nm, @fn=@fn;

   SELECT
       @f_table_nm  = f_table_nm
      ,@f_schema_nm = schema_nm
   FROM dbo.fnGetFk( @fk_nm);

   SET @qtn = CONCAT(@f_schema_nm,  '.', @f_table_nm);

   EXEC sp_log 1, @fn, '010 params:
fk_nm:      [', @fk_nm     , ']
f_table_nm: [', @f_table_nm, ']
f_schema_nm:[', @f_schema_nm,']
qtn:        [', @qtn        ,']
';

      IF @f_table_nm IS NULL
      BEGIN
         EXEC sp_log 1, @fn, '020: cannot find ', @fk_nm, ' skipping droppping it';
         RETURN;
      END

      EXEC sp_assert_not_null_or_empty @f_table_nm, '@f_table_nm';
      EXEC sp_log 1, @fn, '030: found ', @fk_nm, ', f_table_: ', @f_table_nm;

      ---------------------------------------------------------
      --- ASSERTION: @fk_nm exists
      ---------------------------------------------------------
      EXEC sp_assert_not_null_or_empty @f_table_nm, '@f_table_nm';

      SET @sql = CONCAT('IF dbo.fnFkExists(''', @fk_nm,''') = 1
BEGIN
   EXEC sp_log 1, ''',@fn,''','' 010: dropping constraint ', @qtn,'.',@fk_nm,''';
   ALTER TABLE ', @qtn,' DROP CONSTRAINT ',@fk_nm,';
END
ELSE
   EXEC sp_log 1, ''',@fn,''', ''020: constraint ',@fk_nm, ' not found'';
   ');

      EXEC sp_log 1, @fn, '040 @sql:
   ', @sql;

      EXEC sp_executesql @sql;

      IF dbo.fnFkExists(@fk_nm) = 1
         EXEC sp_raise_exception 50600, 'ERROR: ', @fk_nm, 'still exists ', @fn=@fn;
      ELSE
         EXEC sp_log 1, @fn, '499: successfully dropped: ', @fk_nm;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   --EXEC sp_log 1, @fn, '999: leaving';
END
/*
EXEC test.sp__crt_tst_rtns 'sp_drop_FK';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:         Terry Watts
-- Create date:    03-APR-2025
-- Description:    drops all Auth schema foreign keys
-- Design:         EA
-- Tests:         test_004_sp_create_FKs
-- Preconditions:  none
-- Postconditions: Return value = count of dropped relations
-- Tests:       test_004_sp_create_FKs
-- ==========================================================
CREATE PROCEDURE [dbo].[sp_drop_FKs_Auth]
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE
       @fn     VARCHAR(35) = 'sp_drop_FKs_Auth'
      ,@cnt    INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';

      ----------------------------------------
      --  Foreign table  UserRole
      ----------------------------------------
      EXEC sp_log 1, @fn, '010: dropping keys for table UserRole';
      EXEC sp_drop_FK 'FK_UserRole_User';
      EXEC sp_drop_FK 'FK_UserRole_Role';

      ----------------------------------------
      -- Foreign table RoleFeature
      ----------------------------------------
      EXEC sp_log 1, @fn, '020: dropping keys for table RoleFeature';
      EXEC sp_drop_FK 'FK_RoleFeature_Role';
      EXEC sp_drop_FK 'FK_RoleFeature_Feature';

      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: dropped all Auth constraints';
      EXEC sp_log 1, @fn, '499: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: dropped ', @cnt, ' keys';
   RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_create_FKs';
EXEC tSQL.RunAll;

EXEC sp_drop_FKs_Auth;
EXEC sp_create_FKs_Auth;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Author:        Terry Watts
-- Create date:   25-Feb-2025
-- Description:   drops all foreign keys
-- Design:        EA
-- Tests:         test_004_sp_create_FKs
-- Preconditions: none
-- Postconditions:
-- POST01:        returns the count of the dropped keys
-- =====================================================
CREATE PROCEDURE [dbo].[sp_drop_FKs]
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE
       @fn     VARCHAR(35) = 'sp_drop_FKs'
      ,@cnt    INT         = 0
      ,@delta  INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';

      ------------------------------------------------------------------------------------
      -- 1: Foreign table Attendance: 2 FKs: FK_Attendance_ClassSchedule, FK_Attendance_Student
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: dropping keys for table Attendance';
      EXEC sp_drop_FK 'FK_Attendance_ClassSchedule';
      EXEC sp_drop_FK 'FK_Attendance_Student';

      ----------------------------------------------------------------------------------------
      --  Foreign table  Attendance2: 2 FKs: FK_Attendance_Course, FK_Attendance_Student
      ----------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: dropping keys for table Attendance2';
      EXEC sp_drop_FK 'FK_Attendance2_ClassSchedule';
      EXEC sp_drop_FK 'FK_Attendance2_Student';

      ---------------------------------------------------------------------------------------------------------------------------------------------
      -- Foreign table ClassSchedule: 4 Fks: FK_ClassSchedule_Major, FK_ClassSchedule_Room, FK_ClassSchedule_Section
      ---------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: dropping keys for table Attendance';
      EXEC sp_drop_FK 'FK_ClassSchedule_Course';
      EXEC sp_drop_FK 'FK_ClassSchedule_Major';
      EXEC sp_drop_FK 'FK_ClassSchedule_Room';
      EXEC sp_drop_FK 'FK_ClassSchedule_Section';

      -----------------------------------------------------------------------------------------------------------------------------------------------------
      -- Foreign table Enrollment 5 Fks: FK_Enrollment_Course, FK_Enrollment_Major, FK_Enrollment_Section, FK_Enrollment_Semester, FK_Enrollment_Student
      -----------------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: dropping FKs for table Enrollment';
      EXEC sp_drop_FK 'FK_Enrollment_Course';
      EXEC sp_drop_FK 'FK_Enrollment_Major';
      EXEC sp_drop_FK 'FK_Enrollment_Section';
      EXEC sp_drop_FK 'FK_Enrollment_Semester';
      EXEC sp_drop_FK 'FK_Enrollment_Student';

      ----------------------------------------
      -- Foreign table GoogleAlias
      ----------------------------------------
      EXEC sp_log 1, @fn, '050: dropping keys for Primary table GoogleName';
      EXEC sp_drop_FK 'FK_GoogleAlias_Student';

      ----------------------------------------
      -- Foreign table Team
      ----------------------------------------
      EXEC sp_log 1, @fn, '060: dropping keys for table Team';
      EXEC sp_drop_FK 'FK_Team_Event';

      ----------------------------------------
      -- Foreign table TeamMembers
      ----------------------------------------
      EXEC sp_log 1, @fn, '070: dropping keys for table TeamMembers';
      EXEC sp_drop_FK 'FK_TeamMembers_Team';

      ----------------------------------------
      -- Role tables
      ----------------------------------------
      EXEC sp_log 1, @fn, '80: Dropping auth table relationships, calling sp_drop_FKs_Auth';
      EXEC @delta = sp_drop_FKs_Auth;
      SET @cnt = @cnt + @delta;
         /*
      ----------------------------------------
      -- Test tables
      ----------------------------------------
      ----------------------------------------
      -- Foreign table test.test_005_F
      ----------------------------------------
      IF dbo.FkExists('FK_test_005_F_test_005_P') = 1
      BEGIN
         EXEC sp_log 1, @fn, '255: dropping constraint FK_StudentSection_Student';
         ALTER TABLE test.test_005_F DROP CONSTRAINT FK_test_005_F_test_005_P;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '260: constraint FFK_test_005_F_test_005_P does not exist';
*/
      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: dropped all necessary constraints';
      EXEC sp_log 1, @fn, '499: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: dropped ', @cnt, ' relationships';
-- POST01:        returns the count of the dropped keys
   RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_create_FKs';
EXEC tSQL.RunAll;

EXEC sp_drop_FKs;
EXEC sp_create_FKs;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ======================================================================
-- Author:      Terry Watts
-- Create Date: 06-AUG-2023
-- Description: Checks that the given table is populated    or not
-- Normal mode: this checks to see if the table has atleast 1 row
--
-- However it can be use to Checks that the given table is NOT populated
-- by setting @exp_cnt to 0
--
-- Called by sp_chk_tbl_not_pop
-- ======================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_pop]
    @table           VARCHAR(60)
   ,@msg             VARCHAR(MAX)   = NULL
   ,@display_msgs    BIT            = 0
   ,@exp_cnt         INT            = NULL
   ,@ex_num          INT            = 56687
   ,@ex_msg          VARCHAR(500)   = NULL
   ,@fn              VARCHAR(35)    = N'*'
   ,@log_level       INT            = 0
   ,@display_row_cnt BIT            = 1
AS
BEGIN
   DECLARE 
    @fnThis          VARCHAR(35)   = N'sp_assert_tbl_pop'
   ,@sql             NVARCHAR(MAX)
   ,@act_cnt         INT           = -1
   ,@schema_nm       VARCHAR(50)
   ;

   SET NOCOUNT ON;

   SELECT 
       @table     = rtn_nm 
      ,@schema_nm = schema_nm
   FROM dbo.fnSplitQualifiedName(@table)
   ;

   SET @sql = CONCAT('SELECT @act_cnt = COUNT(*) FROM [', @schema_nm, '].[', @table, ']');
   EXEC sp_executesql @sql, N'@act_cnt INT OUT', @act_cnt OUT

   IF @display_row_cnt = 1
   BEGIN
      EXEC sp_log 1, @fnThis, @msg, 'table:[', @table, '] has ', @act_cnt, ' rows';
   END

   IF @exp_cnt IS NOT null
   BEGIN
      IF @exp_cnt <> @act_cnt
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' row count: exp ',@exp_cnt,'  act:', @act_cnt);

         EXEC sp_log 4, @fnThis ,'040: @exp_cnt (', @exp_cnt, ')<> @act_cnt (', @act_cnt, ') raising exception: ',@ex_msg;
         EXEC sp_raise_exception @ex_num, @ex_msg, 1, @fn=@fn;
      END
   END
   ELSE
   BEGIN -- Check at least 1 row
      IF @act_cnt = 0
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' does not have any rows');

         EXEC sp_log 4, '070: table ',@table,' has no rows: ', @ex_msg;
         THROW @ex_num, @ex_msg, 1;
      END
   END
END
/*
   -- This should not create an exception as dummytable has rows
   EXEC dbo.sp_assert_tbl_po 'use'
   EXEC dbo.sp_assert_tbl_po 'dummytable'
   
   -- This should create the following exception:
   -- Msg 56687, Level 16, State 1, Procedure dbo.sp_assert_tbl_po, Line 27 [Batch Start Line 37]
   -- Table: [AppLog] does not have any rows
    
   EXEC dbo.sp_assert_tbl_po 'AppLog'
   IF EXISTS (SELECT 1 FROM [dummytable]) PRINT '1' ELSE PRINT '0'
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===================================================================
-- Author:      Terry Watts
-- Create Date: 05-FEB-2024
-- Description: Asserts that the given table does not have any rows
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_not_pop]
    @table           VARCHAR(60)
   ,@log_level       INT = 0
   ,@display_row_cnt BIT = 1
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)    = N'sp_assert_tbl_not_pop'

   EXEC sp_assert_tbl_pop @table, @exp_cnt =0, @log_level=@log_level, @display_row_cnt=@display_row_cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_chk_tbl_not_pop';
TRUNCATE TABLE AppLog;
EXEC test_sp_chk_tbl_not_pop 'AppLog'; -- ok no rows
INSERT iNTO AppLog ()
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:         Terry Watts
-- Create date:    18-APR-2027
-- Description:    Truncates the given table
-- Preconditions:
--    PRE01: all Table Relationships removed
--    PRE02: @table_nm is suitably qualified and bracketed
-- Postconditions:
--    POST01: table empty
--    POST02: success loggged
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:         EA: Model.Conceptual Model.Truncate table
-- Tests:          test_040_sp_TruncateTable
-- ==========================================================
CREATE PROCEDURE [dbo].[sp_TruncateTable] @table_nm VARCHAR(60)
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn  VARCHAR(35) = 'sp_TruncateTable'
      ,@sql VARCHAR(4000)
   ;

   SET @sql = CONCAT('TRUNCATE TABLE ', @table_nm, ';');
   EXEC(@sql);

   -- POST01: table empty
   EXEC sp_assert_tbl_not_pop @table_nm, @display_row_cnt=0;
   EXEC sp_log 1, @fn, '100: truncated table ', @table_nm,'';
END
/*
EXEC test.sp__crt_tst_rtns 'dbo.sp_TruncateTable';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC TruncateTable
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================================
-- Description:  deletes the data tables ready for a new import
--               of all the data, resets the auto increment counter
-- Design:       EA
-- Tests:        
-- Author:       
-- Create date:  
--
-- preconditions: none
-- postconditions: POST 01: all data tables crd and and auto incrment coubnters reset to 1
--                 POST 02: all FKs dropped
-- ===============================================================================
CREATE PROCEDURE [dbo].[sp_delete_tbls]
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE 
       @fn     VARCHAR(35) = 'sp_delete_tbls'

   EXEC sp_TruncateTable 'AppLog';
   EXEC sp_log 1, @fn, '000: starting';
   EXEC sp_log 1, @fn, '010: dropping constraints';
   EXEC sp_drop_FKs;

   --EXEC sp_log 1, @fn, '100: truncating table attendance';  -- ok
   --TRUNCATE TABLE Attendance;
   EXEC sp_TruncateTable 'Attendance';

   --EXEC sp_log 1, @fn, '020: truncating table AttendanceStaging'; --ok
   --TRUNCATE TABLE AttendanceStaging;
   EXEC sp_TruncateTable 'AttendanceStaging';

   --EXEC sp_log 1, @fn, '050: truncating table ClassSchedule'; --ok
   --TRUNCATE TABLE ClassSchedule;
   EXEC sp_TruncateTable 'ClassSchedule';

   --EXEC sp_log 1, @fn, '030: truncating table ClassScheduleStaging'; -- ok
   --TRUNCATE TABLE ClassScheduleStaging;
   EXEC sp_TruncateTable 'ClassScheduleStaging';

   --EXEC sp_log 1, @fn, '080: truncating table Course'; -- ok
   --TRUNCATE TABLE Course;
   EXEC sp_TruncateTable 'Course';

   --EXEC sp_log 1, @fn, '070: truncating table CourseSection'; -- ok
   --TRUNCATE TABLE CourseSection;
   --EXEC sp_TruncateTable 'CourseSection';

   --EXEC sp_log 1, @fn, '040: truncating table Enrollment'; --ok
   --TRUNCATE TABLE Enrollment;
   EXEC sp_TruncateTable 'Enrollment';

   --EXEC sp_log 1, @fn, '040: truncating table EnrollmentStaging'; --ok
   --TRUNCATE TABLE EnrollmentStaging;
   EXEC sp_TruncateTable 'EnrollmentStaging';

--    EXEC sp_log 1, @fn, '060: truncating table StudentSection'; -- ok
--    TRUNCATE TABLE StudentSECTION;
   --EXEC sp_log 1, @fn, '090: truncating table Major';  -- ok
   --TRUNCATE TABLE Major;
   EXEC sp_TruncateTable 'Major';

   --EXEC sp_log 1, @fn, '110: truncating table Room'; -- ok
   --TRUNCATE TABLE Room;
   EXEC sp_TruncateTable 'Room';

   --EXEC sp_log 1, @fn, '120: truncating table Section'; -- ok
   --TRUNCATE TABLE Section;
   EXEC sp_TruncateTable 'Section';

   --EXEC sp_log 1, @fn, '130: truncating table Student'; -- ok
   --TRUNCATE TABLE Student;
   EXEC sp_TruncateTable 'Student';

   EXEC sp_log 1, @fn, '200: checking tables not populated';
   EXEC sp_assert_tbl_not_pop 'ClassScheduleStaging', @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'EnrollmentStaging',    @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'AttendanceStaging',    @display_row_cnt=0;
                                                      
   EXEC sp_assert_tbl_not_pop 'ClassSchedule',        @display_row_cnt=0;
   --EXEC sp_assert_tbl_not_pop 'CourseSection';
   --EXEC sp_assert_tbl_not_pop 'StudentSection';

   EXEC sp_assert_tbl_not_pop 'Attendance',           @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'Course',               @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'Major',                @display_row_cnt=0;

   EXEC sp_assert_tbl_not_pop 'Room',                 @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'Section',              @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'Student',              @display_row_cnt=0;

   EXEC sp_log 1, @fn, '999: completed clring tables';
END
/*
EXEC sp_delete_tbls;
SELECT * from DBO.fnGetFksForPrimaryTable('Course')
SELECT * from DBO.fnGetFksForForeignTable('Course')
*/


GO
GO

CREATE TYPE [dbo].[ChkFldsNotNullDataType] AS TABLE(
	[ordinal] [int] NOT NULL,
	[col] [varchar](120) NOT NULL,
	[sql] [varchar](4000) NOT NULL
)

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--================================================================================================
-- Author:        Terry Watts
-- Create date:   15-Nov-2024
-- Description:   check there are no NULL entries supplied columns
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: returns 0 and no inccurrences in any of the specified fields in the specified table 
-- OR throws exception 56321, msg: 'mandatory field:['<@table?'].'<field> has Null value
--================================================================================================
CREATE PROCEDURE [dbo].[sp_chk_flds_not_null]
    @table            VARCHAR(60)
   ,@non_null_flds    VARCHAR(MAX) = NULL
   ,@display_results  BIT           = 0
   ,@msg              VARCHAR(100) = ''
AS
BEGIN
   DECLARE
    @fn           VARCHAR(35)   = N'sp_chk_flds_not_null'
   ,@max_len_fld  INT
   ,@col          VARCHAR(32)
--   ,@msg          VARCHAR(200)
   ,@sql          NVARCHAR(MAX)
   ,@ndx          INT = 1
   ,@end          INT
   ,@nl           NCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@flds         ChkFldsNotNullDataType
    ;

   EXEC sp_log 1, @fn, '000: starting:
table           :[', @table          , ']
non_null_flds   :[', @non_null_flds  , ']
display_results :[', @display_results, ']'
   ;

   IF @non_null_flds IS NULL
      RETURN;

   BEGIN TRY
      SET @sql = CONCAT('SELECT @max_len_fld = MAX(dbo.fnLen(column_name)) FROM list_table_columns_vw WHERE table_name = ''', @table, ''';');
      EXEC sp_log 0, @fn, '010: getting max field len: @sql:', @sql;
      EXEC sp_executesql @sql, N'@max_len_fld INT OUT', @max_len_fld OUT;
      EXEC sp_log 1, @fn, '020: @max_len_fld: ', @max_len_fld;

      ----------------------------------------------------------------
      -- Create script to run non null chks on a set of fields
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Creating script to run non null chks on a set of fields';
      INSERT INTO @flds (ordinal, col, sql) 
      SELECT
          ordinal
         ,value
         ,CONCAT
         (
            'IF EXISTS (SELECT 1 FROM ['
            , @table,'] WHERE ',CONCAT('[',value,']'), ' IS NULL) EXEC sp_raise_exception 56321, ''mandatory field:['
            , @table,'].',CONCAT('[',value,'] has Null value'';')
         ) as sql
         FROM
         (
            SELECT ordinal, TRIM(dbo.fnDeSquareBracket(value)) as value FROM string_split( @non_null_flds, ',', 1)
         ) X

      IF @display_results = 1 SELECT * FROM @flds;
      --THROW 51000, 'debug',20;

      ----------------------------------------------------------------
      -- Execute script: run non null chks on each required field
      ----------------------------------------------------------------
      SELECT @end = COUNT(*) FROM @flds;

      WHILE @ndx < = @end
      BEGIN
         SELECT 
             @sql = sql
            ,@col = col
         FROM @flds
         WHERE ordinal = @ndx;

         --SET @msg = CONCAT('040: checking col: ', dbo.fnPadRight( CONCAT( '[', @col, ']'), @max_len_fld +1), ' has no NULL values');
         --SET @msg = CONCAT('050: check sql: ', @sql);
         --EXEC sp_log 1, @fn, @msg;
         EXEC (@sql);
         SET @ndx = @ndx + 1
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, 'table: ', @table, ' col ', @col,'has a null value. ', @msg;
      SELECT * FROM @flds;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: there are no null values in the checked columns';
END
/*
EXEC tSQLt.Run 'test.test_030_sp_chk_flds_not_null';
SELECT * FROM @flds
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
-- Author:      Terry watts
-- Create date: 30-MAR-2020
-- Description: assert the given file exists or throws exception @ex_num* 'the file[<@file>] does not exist', @state
-- * if @ex_num default: 53200, state=1
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_file_exists]
    @file      VARCHAR(500)
   ,@msg1      VARCHAR(200)   = NULL
   ,@msg2      VARCHAR(200)   = NULL
   ,@msg3      VARCHAR(200)   = NULL
   ,@msg4      VARCHAR(200)   = NULL
   ,@msg5      VARCHAR(200)   = NULL
   ,@msg6      VARCHAR(200)   = NULL
   ,@msg7      VARCHAR(200)   = NULL
   ,@msg8      VARCHAR(200)   = NULL
   ,@msg9      VARCHAR(200)   = NULL
   ,@msg10     VARCHAR(200)   = NULL
   ,@msg11     VARCHAR(200)   = NULL
   ,@msg12     VARCHAR(200)   = NULL
   ,@msg13     VARCHAR(200)   = NULL
   ,@msg14     VARCHAR(200)   = NULL
   ,@msg15     VARCHAR(200)   = NULL
   ,@msg16     VARCHAR(200)   = NULL
   ,@msg17     VARCHAR(200)   = NULL
   ,@msg18     VARCHAR(200)   = NULL
   ,@msg19     VARCHAR(200)   = NULL
   ,@msg20     VARCHAR(200)   = NULL
   ,@ex_num    INT             = 53200
   ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE
       @fn_       VARCHAR(35)   = N'ASSERT_FILE_EXISTS'
      ,@msg       VARCHAR(MAX)

   EXEC sp_log @log_level, @fn_, '000: checking file [', @file, '] exists';

   IF dbo.fnFileExists( @file) = 1
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fn, '010: OK,File [',@file,'] exists';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   SET @msg = CONCAT('File [',@file,'] does not exist');
   EXEC sp_log 3, @fn, '020:', @msg, ' raising exception';

   EXEC sp_raise_exception
       @ex_num = @ex_num
      ,@msg1   = @msg
      ,@msg2   = @msg1
      ,@msg3   = @msg2 
      ,@msg4   = @msg3 
      ,@msg5   = @msg4 
      ,@msg6   = @msg5 
      ,@msg7   = @msg6 
      ,@msg8   = @msg7 
      ,@msg9   = @msg8 
      ,@msg10  = @msg9 
      ,@msg11  = @msg10
      ,@msg12  = @msg11
      ,@msg13  = @msg12
      ,@msg14  = @msg13
      ,@msg15  = @msg14
      ,@msg16  = @msg15
      ,@msg17  = @msg16
      ,@msg18  = @msg17
      ,@msg19  = @msg18
      ,@msg20  = @msg19
      ,@fn     = @fn
   ;
END
/*
EXEC sp_assert_file_exists 'non existant file', ' second msg',@fn='test fn', @state=5  -- expect ex: 53200, 'the file [non existant file] does not exist', ' extra detail: none', @state=1, @fn='test fn';
EXEC sp_assert_file_exists 'C:\bin\grep.exe'   -- expect OK
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ===========================================================
-- Author:      Terry watts
-- Create date: 20-SEP-2024
-- Description: Deletes the file on disk
--
-- Postconditions:
-- POST 01 raise exception if failed to delete the file
-- ===========================================================
CREATE PROCEDURE [dbo].[sp_delete_file]
    @file_path    VARCHAR(500)   = NULL
   ,@chk_exists   BIT = 0 -- chk exists in the first place
   ,@fn           VARCHAR(35)    = N'*'
AS
BEGIN
   DECLARE
    @fnThis       VARCHAR(35)   = N'SP DELETE_FILE'
   ,@cmd          VARCHAR(MAX)
   ,@msg          VARCHAR(1000)
   ;

   EXEC sp_log 1, @fnThis,'000: starting, deleting file:[',@file_path,']';
   DROP TABLE IF EXISTS #tmp;
   CREATE table #tmp (id INT identity(1,1), [output] NVARCHAR(4000))

   IF (dbo.fnFileExists(@file_path) <> 0)
   BEGIN
      --SET @cmd = CONCAT('INSERT INTO #tmp  EXEC xp_cmdshell ''del "', @file_path, '"'' ,NO_OUTPUT');
      SET @cmd = CONCAT('INSERT INTO #tmp  EXEC xp_cmdshell '' del "', @file_path, '"''');
      --PRINT @cmd;
      EXEC sp_log 1, @fnThis,'010: sql:[',@cmd,']';
      EXEC (@cmd);

      --IF EXISTS (SELECT TOP 2 1 FROM #tmp) SELECT * FROM #tmp;
   END
   ELSE -- file does not exist
      IF (@chk_exists = 1) -- POST 01 raise exception if failed to delete the file
         EXEC sp_raise_exception 58147, ' 020: file [',@file_path,'] does not exist but chk_exists specified', @fn=@fnThis;

   IF dbo.fnFileExists(@file_path) <> 0
   BEGIN
      IF EXISTS (SELECT TOP 2 1 FROM #tmp)
         SELECT @msg = [output] FROM #tmp where id = 1;

      EXEC sp_raise_exception 63500, '030: failed to delete file [', @file_path, '], reason: ',@msg, @fn=@fnThis;
   END

   EXEC sp_log 0, @fnThis,'999: leaving';
END
/*
EXEC sp_delete_file 'D:\Logs\a.txt';
EXEC sp_delete_file 'non exist file';
EXEC sp_delete_file 'D:\Logs\Farming.log';

EXEC xp_cmdshell 'del "D:\Logs\Farming.log"'


*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================================================================
-- Author:      Terry Watts
-- Create date: 20-OCT-2024
-- Description: Imports a txt file into @table
-- Returns the count of rows imported
-- Design: EA?
-- Responsibilities:
-- R00: delete the log files beefore importing if they exist
-- R01: Import the table from the tsv file
-- R02: Remove double quotes
-- R03: Trim leading/trailing whitespace
-- R04: Remove in-field line feeds
-- R05: check the list of @non_null_flds fields do not have any nulls - if @non_null_flds supplied
--
-- Tests: test_037_sp_import_txt_file
--
-- Preconditions:
-- PRE01: File must be specified: chkd
-- PRE02: Filpath must exist : chkd
--
-- Postconditions:
-- POST01 ret: the count of rows imported
--
-- Changes:
-- 20-OCT-2024: increased @spreadsheet_file parameter len from 60 to 500 as the file path was being truncated
-- 31-OCT-2024: cleans each imported text field for double quotes and leading/trailing white space
-- 05-NOV-2024: optionally display imported table: sometimes we need to do more fixup before data is ready
--              so when this is the case then dont display the table here, but do post import fixup in the 
--              calling sp first and then display the table
-- 11-NOV-2024: added an optional view to control field mapping
-- 06-APR-2025  @table may be qualified with the schema - sort out bracketing
-- =============================================================================================================
CREATE PROCEDURE [dbo].[sp_import_txt_file]
    @table            VARCHAR(60)
   ,@file             VARCHAR(500)
   ,@folder           VARCHAR(600)  = NULL
   ,@field_terminator VARCHAR(4)    = NULL -- tab 0x09
   ,@row_terminator   VARCHAR(10)   = NULL -- '0x0d0a'
   ,@codepage         INT           = 65001 -- Claude: Note that if your text file has a BOM (Byte Order Mark), SQL Server should automatically detect it when using codepage 65001.
   ,@first_row        INT           = 2
   ,@last_row         INT           = NULL
   ,@clr_first        BIT           = 1
   ,@view             VARCHAR(120)  = NULL
   ,@format_file      VARCHAR(500)  = NULL
   ,@expect_rows      BIT           = 1
   ,@exp_row_cnt      INT           = NULL
   ,@non_null_flds    VARCHAR(1000) = NULL
   ,@display_table    BIT           = 0
AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)       = N'sp_import_txt_file'
   ,@cmd                NVARCHAR(MAX)
   ,@sql                VARCHAR(MAX)
   ,@CR                 CHAR(1)           = CHAR(13)
   ,@LF                 CHAR(2)           = CHAR(10)
   ,@NL                 CHAR(2)           = CHAR(13)+CHAR(10)
   ,@line_feed          CHAR(1)           = CHAR(10)
   ,@bkslsh             CHAR(1)           = CHAR(92)
   ,@tab                CHAR(1)           = CHAR(9)
   ,@max_len_fld        INT
   ,@del_file           VARCHAR(1000)
   ,@error_file         VARCHAR(1000)
   ,@ndx                INT = 1
   ,@end                INT
   ,@line               VARCHAR(128) = REPLICATE('-', 100)
   ,@file_path          VARCHAR(600)
   ,@row_cnt            INT
   ,@schema_nm          VARCHAR(28)
   ,@table_nm           VARCHAR(40)
   ,@table_nm_no_brkts  VARCHAR(40)
   ,@ex_num             INT
   ,@ex_msg             INT
   ;

   --SET @row_terminator_str = iif(@row_terminator='0x0d0a', '0x0d0a',@row_terminator);

   EXEC sp_log 1, @fn, '000: starting:
table           :[',@table             ,']
file            :[',@file              ,']
folder          :[',@folder            ,']
row_terminator  :[',@row_terminator    ,']
field_terminator:[',@field_terminator  ,']
first_row       :[',@first_row         ,']
last_row        :[',@last_row          ,']
clr_first       :[',@clr_first         ,']
view            :[',@view              ,']
format_file     :[',@format_file       ,']
expect_rows     :[',@expect_rows       ,']
exp_row_cnt     :[',@exp_row_cnt       ,']
non_null_flds   :[',@non_null_flds     ,']
display_table   :[',@display_table     ,']'
;

   BEGIN TRY
      ---------------------------------------------------
      -- Set defaults
      ---------------------------------------------------
      IF @field_terminator IS NULL SET @field_terminator = @tab;
      IF @field_terminator IN (0x09, '0x09', '\t') SET @field_terminator = @tab;

      IF @field_terminator NOT IN ( @tab,',',@CR, @LF, @NL)
         EXEC sp_raise_exception 53051, @fn, '005: error: field terminator must be one of comma, tab, NL';

      IF @row_terminator   IS NULL OR @row_terminator='' SET @row_terminator = @nl;

      ---------------------------------------------------
      -- Validate parameters
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '010: Validate parameters';

      -- PRE01: File must be specified
      EXEC sp_assert_not_null_or_empty @file, 50001, 'File must be specified';
      ---------------------------------------------------
      -- Set defaults
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '020: Set defaults';

      IF @codepage IS NULL SET @codepage = 1252;

      SET @file_path = iif( @folder IS NOT NULL,  CONCAT(@folder, @bkslsh, @file), @file);

      -- sort out double \\
      SET @file_path = REPLACE(@file_path, @bkslsh+@bkslsh, @bkslsh);

      -- ASSERTION 

      -- 06-APR-2025  @table may be qualified with the schema - sort out bracketing
      SET @ndx = CHARINDEX('.', @table);

      IF @ndx>0
      BEGIN
         SELECT
             @schema_nm = schema_nm
            ,@table_nm  = rtn_nm
         FROM dbo.fnSplitQualifiedName(@table);

         SET @table = CONCAT('[',@schema_nm,'].[',@table_nm, ']');
      END
      ELSE
      BEGIN
         SET @table = CONCAT('[',@table, ']');
      END

      SET @table_nm_no_brkts = REPLACE(REPLACE(@table, '[', ''),']', '');
      EXEC sp_log 1, @fn, '030: table:',@table, ' @table_nm_no_brkts: ', @table_nm_no_brkts;

      ---------------------------------------------------
      -- Validate inputs
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '040: validating inputs, @file_path: [',@file_path,']';

      -- PRE02: Filpath must exist : chkd
      EXEC sp_assert_file_exists @file_path
      -------------------------------------------------------------
      -- ASSERTION: @table is now like [table] or [schema].[table]
      -------------------------------------------------------------

      IF @table IS NULL OR @table =''
         EXEC sp_raise_exception 53050, @fn, '050: error: table must be specified';

      IF @first_row IS NULL OR @first_row < 1
         SET @first_row = 2;

      IF @last_row IS NULL OR @last_row < 1
         SET @last_row = 1000000;

      -- View is optional - defaults to the table stru
      IF @view IS NULL
         SET @view = @table;

      IF @clr_first = 1
      BEGIN
         SET @cmd = CONCAT('TRUNCATE TABLE ', @table,';');
         EXEC sp_log 1, @fn, '060: clearing table first: EXEC SQL:',@NL, @cmd;

         EXEC (@cmd);
      END

      ----------------------------------------------------------------------------------
      -- R00: delete the log files before importing if they exist
      ----------------------------------------------------------------------------------

      SET @error_file = CONCAT('D:',NCHAR(92),'logs',NCHAR(92),@table_nm_no_brkts,'import.log');
      SET @del_file = @error_file;
      EXEC sp_log 1, @fn, '070: deleting log file ', @del_file;
      EXEC sp_delete_file @del_file;
      SET @del_file = CONCAT(@del_file, '.Error.Txt');
      EXEC sp_log 1, @fn, '080: deleting log file ',@del_file;
      EXEC sp_delete_file @del_file;

      ----------------------------------------------------------------------------------
      -- R01: Import the table from the tsv file
      ----------------------------------------------------------------------------------

      SET @cmd = 
         CONCAT('BULK INSERT ',@view,' FROM ''',@file_path,''' 
WITH
(
    DATAFILETYPE    = ''Char''
   ,FIRSTROW        = ',@first_row, @nl
);

      IF @last_row         IS NOT NULL 
      BEGIN
         EXEC sp_log 1, @fn, '090: @last_row is not null, =[',@last_row, ']';
         SET @cmd = CONCAT( @cmd, '   ,LASTROW        =   ', @last_row        , @nl);
      END

      IF @format_file      IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '100: @last_row is not null, =[',@last_row, ']';
         SET @cmd = CONCAT( @cmd, '   ,FORMATFILE     = ''', @format_file, '''', @nl);
      END

      IF @field_terminator IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '110: @field_terminator is not null, =[',@field_terminator, ']';
         If @field_terminator = 't' SET @field_terminator = '\t';
         SET @cmd = CONCAT( @cmd, '   ,FIELDTERMINATOR= ''', @field_terminator, '''', @nl);
      END

      if @row_terminator IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '120: @row_terminator is not null, =[',@row_terminator, ']';
         SET @cmd = CONCAT( @cmd, '   ,ROWTERMINATOR= ''', @row_terminator, '''', @nl);
      END

      SET @cmd = CONCAT( @cmd, '  ,ERRORFILE      = ''',@error_file,'''', @nl
         ,'  ,MAXERRORS      = 20', @nl
         ,'  ,CODEPAGE       = ',@codepage, @nl
         ,');'
      );

      PRINT CONCAT( @nl, @line);
      EXEC sp_log 1, @fn, '130: importing file: SQL: 
', @cmd;

      PRINT CONCAT( @line, @nl);

      EXEC (@cmd);
      SET @row_cnt = @@ROWCOUNT;

      EXEC sp_log 1, @fn, '140: imported ', @row_cnt, ' rows';

      ----------------------------------------------------------------------------------------------------
      -- 05-NOV-2024: optionally display imported table
      ----------------------------------------------------------------------------------------------------
      IF @display_table = 1
      BEGIN
         EXEC sp_log 1, @fn, '150: displaying table: ', @table;
         SET @cmd = CONCAT('SELECT * FROM ', @table,';');
         EXEC (@cmd);
      END

      IF @expect_rows = 1
      BEGIN
         EXEC sp_log 1, @fn, '160: checking resulting row count';
         EXEC sp_assert_tbl_pop @table;
      END

      IF  @exp_row_cnt IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '170: checking resulting row count';
         EXEC sp_assert_tbl_pop @table, @exp_cnt = @exp_row_cnt;
      END

      ----------------------------------------------------------------------------------------------------
      -- 31-OCT-2024: cleans each imported text field for double quotes and leading/trailing white space
      ----------------------------------------------------------------------------------------------------
      SET @cmd = CONCAT('SELECT @max_len_fld = MAX(dbo.fnLen(column_name)) FROM list_table_columns_vw WHERE table_name = ''', @table, ''' AND is_txt = 1;');
      EXEC sp_log 1, @fn, '180: getting max field len: @cmd:', @cmd;
      EXEC sp_executesql @cmd, N'@max_len_fld INT OUT', @max_len_fld OUT;
      EXEC sp_log 1, @fn, '190: @max_len_fld: '       , @max_len_fld;
      EXEC sp_log 1, @fn, '200: @table_nm_no_brkts: ' , @table_nm_no_brkts;
      EXEC sp_log 1, @fn, '210: @table            : ' , @table ;

      ----------------------------------------------------------------------------------
      -- R02: Remove double quotes
      -- R03: Trim leading/trailing whitespace
      -- R04: Remove line feeds
      ----------------------------------------------------------------------------------
      SET @sql = dbo.fnCrtRemoveDoubleQuotesSql( @table_nm_no_brkts, @max_len_fld);
      PRINT @sql;
      EXEC sp_log 1, @fn, '220: trim replacing double quotes, @sql:', @NL, @sql;
      EXEC (@sql);

     ----------------------------------------------------------------------------------------------------
      -- R05: check the list of @non_null_flds fields do not have any nulls - if @non_null_flds supplied
      ----------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '230: check mandatory fields for null values';
      EXEC sp_chk_flds_not_null @table_nm_no_brkts, @non_null_flds ;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;--, ' launching notepad++ to display the error files';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ',@row_cnt,' rows from: ', @file_path;
   -- POST01 ret: the count of rows imported
   RETURN @row_cnt;
END
/*
EXEC test.test_037_sp_import_txt_file;
EXEC tSQLt.Run 'test.test_037_sp_import_txt_file';
EXEC sp_AppLog_display

EXEC tSQLt.RunAll;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 21-JAN-2020
-- Description: 1 line check null or mismatch and throw message
--              ASSUMES data types are the same
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_equal]
    @a         SQL_VARIANT
   ,@b         SQL_VARIANT
   ,@msg0      VARCHAR(200)   = NULL
   ,@msg1      VARCHAR(200)   = NULL
   ,@msg2      VARCHAR(200)   = NULL
   ,@msg3      VARCHAR(200)   = NULL
   ,@msg4      VARCHAR(200)   = NULL
   ,@msg5      VARCHAR(200)   = NULL
   ,@msg6      VARCHAR(200)   = NULL
   ,@msg7      VARCHAR(200)   = NULL
   ,@msg8      VARCHAR(200)   = NULL
   ,@msg9      VARCHAR(200)   = NULL
   ,@msg10     VARCHAR(200)   = NULL
   ,@msg11     VARCHAR(200)   = NULL
   ,@msg12     VARCHAR(200)   = NULL
   ,@msg13     VARCHAR(200)   = NULL
   ,@msg14     VARCHAR(200)   = NULL
   ,@msg15     VARCHAR(200)   = NULL
   ,@msg16     VARCHAR(200)   = NULL
   ,@msg17     VARCHAR(200)   = NULL
   ,@msg18     VARCHAR(200)   = NULL
   ,@msg19     VARCHAR(200)   = NULL
   ,@msg20     VARCHAR(200)   = NULL
   ,@ex_num    INT             = 50001
   ,@fn        VARCHAR(35)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
DECLARE
    @fnThis VARCHAR(35) = 'sp_assert_equal'
   ,@aTxt   VARCHAR(100)= CONVERT(VARCHAR(20), @a)
   ,@bTxt   VARCHAR(100)= CONVERT(VARCHAR(20), @b)

   EXEC sp_log @log_level, @fnThis, '000: starting @a:[',@aTxt, '] @b:[', @bTxt, ']';

   IF dbo.fnChkEquals(@a ,@b) <> 0
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fnThis, '010: OK, @a:[',@aTxt, '] = @b:[', @bTxt, ']';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fnThis, '020: @a:[',@aTxt, '] <> @b:[', @bTxt, '], raising exception';

   EXEC sp_raise_exception
       @msg0   = @msg0 
      ,@msg1   = @msg1 
      ,@msg2   = @msg2 
      ,@msg3   = @msg3 
      ,@msg4   = @msg4 
      ,@msg5   = @msg5 
      ,@msg6   = @msg6 
      ,@msg7   = @msg7 
      ,@msg8   = @msg8 
      ,@msg9   = @msg9 
      ,@msg10  = @msg10
      ,@msg11  = @msg11
      ,@msg12  = @msg12
      ,@msg13  = @msg13
      ,@msg14  = @msg14
      ,@msg15  = @msg15
      ,@msg16  = @msg16
      ,@msg17  = @msg17
      ,@msg18  = @msg18
      ,@msg19  = @msg19
      ,@msg20  = @msg20
      ,@ex_num = @ex_num
      ,@fn     = @fn
END
/*
   EXEC tSQLt.RunAll;
   EXEC sp_assert_equal 1, 1;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStagingHdr](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[stu_id] [varchar](2000) NULL,
	[nm] [varchar](2000) NULL,
	[attendance] [varchar](2000) NULL,
	[hdr] [varchar](max) NOT NULL,
 CONSTRAINT [PK_AttendanceStagingHdr] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStagingCourseHdr](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[course_nm] [varchar](400) NOT NULL,
	[section_nm] [varchar](20) NOT NULL,
	[stage] [varchar](7000) NULL,
 CONSTRAINT [PK_AttendanceStagingCourseHdr] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStagingDetail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NULL,
	[ordinal] [int] NULL,
	[present] [bit] NULL,
	[date] [date] NULL,
	[schedule_id] [int] NULL,
 CONSTRAINT [PK_AttendanceStagingDetail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStagingColMap](
	[ordinal] [int] NOT NULL,
	[dt] [date] NULL,
	[time24] [varchar](4) NULL,
	[schedule_id] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStaging](
	[index] [varchar](10) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[attendance_percent] [varchar](10) NULL,
	[stage] [varchar](8000) NULL,
	[course_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NULL,
	[course_id] [int] NULL,
	[section_id] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================================
-- Author:         Terry Watts
-- Create date:    17-Mar-2025
-- Description:    Imports 2 Attendance staging tables from a tsv
--                 AttendanceStagingHdr and AttendanceStaging
--
-- sp_Import_AttendanceStaging Responsibilities:
-- Import AttendanceStagingCourseHdr
-- Import AttendanceStagingHdr
-- Import AttendanceStaging
-- Clean pop AttendanceStagingColMap
-- Update AttendanceStaging with course and section data
-- Clean pop AttendanceStagingDetail with the time and sched id
--
-- Design:         EA
-- Tests:          test_012_sp_Import_AttendanceStaging
--                 test_056_sp_Import_AttendanceStaging
--
-- Preconditions:  none
--
-- Postconditions:
--    POST 01: the following tables are popd: AttendanceStagingHdr, AttendanceStaging, AttendanceStagingColMap, AttendanceStagingDetail
--    POST 02: returns the count of rows imported, error thrown otherwise,
--    POST 03: AttendanceStagingDetail.classSchedule_id is not NULL
-- ===========================================================================
CREATE PROCEDURE [dbo].[sp_Import_AttendanceStaging]
    @file            VARCHAR(500)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              VARCHAR(40) = 'sp_Import_AttendanceStaging'
      ,@tab             CHAR(1)=CHAR(9)
      ,@row_cnt         INT
      ,@course_nm       VARCHAR(20) = NULL
      ,@section_nm      VARCHAR(20) = NULL
      ,@txt1            VARCHAR(MAX) = NULL
      ,@txt2            VARCHAR(MAX) = NULL
      ,@len1            INT
      ,@len2            INT

   EXEC sp_log 1, @fn, '000: starting
file:          [', @file          ,']
folder:        [', @folder        ,']
clr_first:     [', @clr_first     ,']
sep:           [', @sep           ,']
codepage:      [', @codepage      ,']
display_tables:[', @display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: Validating preconditions: none';

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import AttendanceStagingCourseHdr table
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: importing the AttendanceStagingCourseHdr';

      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'AttendanceStagingCourseHdr'
         ,@view            = 'ImportAttendanceStagingCourseHdr_vw'
         ,@file            = @file
         ,@folder          = @folder
         ,@first_row       = 1
         ,@last_row        = 1
         ,@field_terminator= @sep
         ,@display_table   = @display_tables
         ,@non_null_flds   = 'course_nm,section_nm'
      ;

      -- 250621: removing trailing wsp
      UPDATE AttendanceStagingCourseHdr SET stage = dbo.fnTrim(stage);

      -- Get the course and section data from the AttendanceStagingCourseHdr table
      --45	ITC 130	IT 3C	46	Tue	Tue	Thu	Thu	Tue	Tue	Thu	Thu	Tue	Tue	Thu	Thu	Tue	Tue	Thu	Thu	Tue	Tue	Thu	Thu
      --IT 3C 46 Tue Tue Thu Thu Tue Tue Thu Thu Tue Tue Thu Thu Tue Tue Thu Thu Tue Tue Thu Thu

      ---------------------------------------------------
      -- Check no trailing empty columns
      ---------------------------------------------------
      SELECT @txt1 = hdr FROM AttendanceStagingHdr;
      SET @txt2 = TRIM(@txt1);
      SET @len1 = dbo.fnLen(@txt1);
      SET @len2 = dbo.fnLen(@txt2);
      EXEC sp_assert_equal @len1, @len2, 'AttendanceStagingHdr.hdr contains trailing spcs';

      SELECT
          @course_nm = dbo.fnTrim(course_nm)
         ,@section_nm= dbo.fnTrim(section_nm)
      FROM AttendanceStagingCourseHdr;

      ----------------------------------------------------------------
      -- Import AttendanceStagingHdr table
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: importing the AttendanceStagingHdr,
@course_nm:  ', @course_nm,'
@section_nm: ', @section_nm
;

      ----------------------------------------------------------------
      -- Assertion: @course_nm, @section_nm specified
      ----------------------------------------------------------------
      EXEC sp_assert_not_null_or_empty @course_nm;
      EXEC sp_assert_not_null_or_empty @section_nm;

      EXEC @row_cnt = sp_import_txt_file
          @table           = 'AttendanceStagingHdr'
         ,@file            = @file
         ,@folder          = @folder
         ,@first_row       = 2
         ,@last_row        = 3
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@display_table   = @display_tables
      ;

     -- SELECT * FROM AttendanceStagingHdr;

      EXEC sp_log 1, @fn, '030: TRUNCATE TABLEs AttendanceStagingColMap, AttendanceStaging';
      TRUNCATE TABLE AttendanceStagingColMap;
      TRUNCATE TABLE AttendanceStaging;

      ----------------------------------------------------------------
      -- Cleanpop the AttendanceStagingColMap dt and time24 columns
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: Cleanpop the AttendanceStagingColMap dt and time24 columns';

      INSERT INTO AttendanceStagingColMap(ordinal, dt)
      SELECT ordinal, dbo.fnCovertStringToDate([value])
      FROM AttendanceStagingHdr h CROSS APPLY string_split(h.hdr, NCHAR(9), 1)
      WHERE VALUE <> '' AND h.id = 1;
      ;

      EXEC sp_chk_flds_not_null 'AttendanceStagingColMap', 'ordinal,dt';

      EXEC sp_log 1, @fn, '043: UPDATE AttendanceStagingColMap SET time24';
      UPDATE AttendanceStagingColMap
      SET time24 =  VALUE
      FROM AttendanceStagingHdr h CROSS APPLY string_split(h.hdr, NCHAR(9), 1) x
      JOIN AttendanceStagingColMap m on m.ordinal = x.ordinal
      WHERE x.VALUE <> '' AND h.id = 2;
      ;

      EXEC sp_chk_flds_not_null 'AttendanceStagingColMap', 'time24';


      ----------------------------------------------------------------
      -- Pop the AttendanceStagingColMap schedule_id column
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '045: UPDATE AttendanceStagingColMap SET schedule_id';
      UPDATE AttendanceStagingColMap
      SET schedule_id = dbo.fnGetScheduleIdForDateTime(dt, time24);

      EXEC sp_log 1, @fn, '046:';
      SELECT * FROM AttendanceStagingColMap;

      EXEC sp_log 1, @fn, '047: Checking AttendanceStagingColMap for bad schedule_ids';
      IF EXISTS (SELECT 1 FROM AttendanceStagingColMap WHERE schedule_id IS NULL OR schedule_id = -1)
         EXEC sp_raise_exception 51234, 'AttendanceStagingColMap: not all schedule_ids were found', @fn=@fn;

      EXEC sp_log 1, @fn, '048:';
      IF @display_tables = 1 SELECT * FROM AttendanceStagingColMap;

      ----------------------------------------------------------------
      -- Import the AttendanceStaging table
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '050: importing the AttendanceStaging table rows, @file: ',@file;
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'AttendanceStaging'
         ,@view            = 'ImportAttendanceStaging_vw'
         ,@file            = @file
         ,@folder          = @folder
         ,@first_row       = 6
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@field_terminator= @sep
         ,@display_table   = @display_tables
      ;

      ----------------------------------------------------------------
      -- Update the course and section id and nm fields
      ----------------------------------------------------------------

      EXEC sp_log 1, @fn, '060: UPDATE AttendanceStaging
course_nm: [',@course_nm,']
section_nm:[',@section_nm,']'
;

      -- do first
      UPDATE AttendanceStaging
      SET
          course_nm  = @course_nm
         ,section_nm = @section_nm
      ;

      -- do second
      UPDATE AttendanceStaging
      SET
          course_id  = c.course_id
         ,section_id = s.section_id
      FROM AttendanceStaging attStg
      LEFT JOIN Course  c ON attStg.course_nm   = @course_nm
      LEFT JOIN section s ON attStg.section_nm = @section_nm

      IF @display_tables = 1 SELECT * FROM AttendanceStaging;

      EXEC sp_chk_flds_not_null 'AttendanceStaging', 'course_nm,section_nm,course_id,section_id';

      -- AttendanceStagingDetail holds the student id, ordinal, present status
      -- Clean populate AttendanceStagingDetail

      --------------------------------------------------------------------------------
      -- Clean pop the AttendanceStagingDetail table from the AttendanceStaging table
      --------------------------------------------------------------------------------
      TRUNCATE TABLE AttendanceStagingDetail;
      INSERT INTO AttendanceStagingDetail(student_id, ordinal, present)
      SELECT student_id,ordinal, iif(value ='', NULL, value) as present
      FROM AttendanceStaging CROSS APPLY string_split(stage, CHAR(9), 1)
      WHERE (value IS NOT NULL AND value <> '')
      ;

      -------------------------------------------------------------
      -- Update AttendanceStagingDetail with the time and sched id
      -------------------------------------------------------------
      UPDATE AttendanceStagingDetail
      SET
          [date]      = cm.dt
         ,schedule_id = cm.schedule_id
      FROM
      AttendanceStagingDetail asd JOIN AttendanceStagingColMap cm ON asd.ordinal = cm.ordinal
      ;

      IF @display_tables = 1 SELECT * FROM AttendanceStagingDetail;

      ------------------------
      -- Chk postconditions
      ------------------------
      EXEC sp_log 1, @fn, '100: Checking postconditions';

      -- POST 03: AttendanceStagingDetail.classSchedule_id is not NULL
      EXEC sp_chk_flds_not_null 'AttendanceStagingDetail','schedule_id', @msg='proc: sp_Import_AttendanceStaging';

      ------------------------
      -- Completed processing
      ------------------------

      EXEC sp_log 1, @fn, '300: Completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   -- POST 02: returns the count of rows imported, error thrown otherwise,
   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC test.test_012_sp_Import_AttendanceStaging;
EXEC test.test_056_sp_Import_AttendanceStaging;
SELECT * FROM Course,section
SELECT * FROM Course
SELECT * FROM AttendanceStaging;
EXEC sp_AppLog_display 'sp_ImportAttendanceStaging,hlpr_056_sp_Import_AttendanceStaging,sp_import_txt_file'
EXEC sp_AppLog_display 'sp_ImportAttendanceStaging'
SELECT * From AttendanceStagingColMap;
SELECT * From AttendanceStagingCourseHdr;
SELECT * From AttendanceStagingHdr;
SELECT * From AttendanceStaging
SELECT * FROM AttendanceStagingDetail;
SELECT * FROM AttendanceStagingDetail WHERE student_id = '2023-1908' -- IS NULL;

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[ClassSchedule_vw] AS
SELECT TOP 1000
    classSchedule_id
   ,[day]
   ,st_time
   ,end_time
   ,course_nm
   ,c.[description]
   ,section_nm
   ,r.room_nm
   ,has_projector
   ,building
   ,[floor]
   ,c.course_id
   ,s.section_id
FROM ClassSchedule cs 
LEFT JOIN Course  c ON c.course_id  = cs.course_id
LEFT JOIN section s ON s.section_id = cs.section_id
LEFT JOIN Room    r ON cs.room_id   = r.room_id
ORDER BY dow, st_time;
/*
SELECT * FROM ClassSchedule;
SELECT * FROM ClassSchedule_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--====================================================================================
-- Author:      Terry Watts
-- Create date: 11-May-2025
-- Description: Displays the Attendance Staging Detail
-- Attendance   is references the ClassSchedule to define the course, section,class
-- Attendance   further defines the student
-- Design: EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceStagingDetail_vw]
AS
SELECT
     id
    ,student_id
    ,ordinal
    ,present
    ,cs.[day]
    ,[date]
    ,cs.classSchedule_id
    ,asd.schedule_id AS asd_schedule_id
    ,course_nm
    ,section_nm
    ,st_time
    ,end_time
FROM
   AttendanceStagingDetail asd
   LEFT JOIN ClassSchedule_vw cs ON asd.schedule_id = cs.classSchedule_id
;
/*
SELECT * FROM AttendanceStagingDetail_vw
where section_nm = '2B';
SELECT * FROM AttendanceStagingDetail;
SELECT * FROM ClassSchedule;
SELECT * FROM ClassSchedule_vw;
SELECT * FROM AttendanceStagingDetail asd JOIN ClassSchedule_vw cs ON asd.schedule_id = cs.classSchedule_id;

student_id, ordinal, present, date, schedule_id, classSchedule_id, course_id, major_id, section_id, day, st_time, end_time, dow, description, room_id
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Student](
	[student_id] [varchar](9) NOT NULL,
	[student_nm] [varchar](50) NULL,
	[gender] [char](1) NULL,
	[google_alias] [varchar](50) NULL,
	[fb_alias] [varchar](50) NULL,
	[email] [varchar](30) NULL,
	[photo_url] [varchar](150) NULL,
	[section_id] [varchar](20) NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[student_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Student] ON [dbo].[Student]
(
	[student_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Terry Watts
-- Create date: 05-Mar-2025
-- Description: debug
-- =============================================
CREATE TRIGGER [dbo].[sp_student_insert_trigger]
   ON [dbo].[Student]
   AFTER DELETE
AS 
BEGIN
   SET NOCOUNT ON;
   THROW 65525, 'student_insert_trigger alert', 1;

END

ALTER TABLE [dbo].[Student] DISABLE TRIGGER [sp_student_insert_trigger]

ALTER TABLE [dbo].[Student] DISABLE TRIGGER [sp_student_insert_trigger]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Attendance](
	[classSchedule_id] [int] NOT NULL,
	[student_id] [varchar](9) NOT NULL,
	[date] [date] NOT NULL,
	[present] [bit] NULL,
	[updated]  AS (getdate()),
 CONSTRAINT [PK_Attendance] PRIMARY KEY CLUSTERED 
(
	[classSchedule_id] ASC,
	[student_id] ASC,
	[date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_Attendance_ClassSchedule] FOREIGN KEY([classSchedule_id])
REFERENCES [dbo].[ClassSchedule] ([classSchedule_id])

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_Attendance_ClassSchedule]

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_Attendance_Student] FOREIGN KEY([student_id])
REFERENCES [dbo].[Student] ([student_id])

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_Attendance_Student]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================
-- Author:      Terry Watts
-- Create date: 01-MAR-2025
-- Description: Imports the file to AttendanceStaging
--                   then merges to Attendance
-- Design:      EA: Dorsu/Attendance
-- Preconditions the following tables must be populated:
--   Course, ClassSchedule, Section, Enrollment, Student
--
-- Postconditions:
--    POST 01: The attendance tables merged
--    POST 02: returns the count of rows imported, error thrown otherwise
--
-- Tests:       test_014_sp_import_Attendance
--
-- Changes:
-- 250522: Always clear the staging table, dont clear the main here
--         as it is called by sp_import_all_attendance which 
--         can handle that as a 1 off, if you want to clear the 
--         table first do it in the client code
--
-- ======================================================
CREATE PROCEDURE [dbo].[sp_import_Attendance]
    @file            VARCHAR(500)
   ,@folder          VARCHAR(500)= NULL
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
       @fn VARCHAR(35) = 'sp_import_Attendance'
      ,@row_cnt         INT
   ;

   EXEC sp_log 1, @fn, '000: starting
file  :        [',@file          ,']
folder:        [',@folder        ,']
sep:           [',@sep           ,']
codepage       [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '005: checking preconditions: tables popd';
      -- Preconditions the following tables must be populated:
      --   Course, ClassSchedule, Enrollment, Section, Student
      EXEC sp_assert_tbl_pop 'Course';
      EXEC sp_assert_tbl_pop 'ClassSchedule';
      EXEC sp_assert_tbl_pop 'Enrollment';
      EXEC sp_assert_tbl_pop 'Section';
      EXEC sp_assert_tbl_pop 'Student';

      EXEC sp_log 1, @fn, '010: truncating table AttendanceStagingDetail';
      TRUNCATE TABLE AttendanceStagingDetail;
      EXEC sp_log 1, @fn, '020: calling sp_Import_AttendanceStaging';

      -- Clean Import the tsv @file into the Attendance staging table:
      -- Then merge the staging table to the main attendance table
      EXEC @row_cnt =
         sp_Import_AttendanceStaging 
            @file           = @file
           ,@folder         = @folder
           ,@clr_first      = 1 -- always clr staging table first -- @clr_first
           ,@display_tables = @display_tables
      ;

      EXEC sp_log 1, @fn, '030: merging tbl Attendance, imported ', @row_cnt,' rows';

      WITH SourceData AS
      (
         SELECT
             a.classSchedule_id
            ,a.student_id
            ,[date]
            ,st_time
            ,present
         FROM
         AttendanceStagingDetail_vw a
      )
      MERGE Attendance AS Target
      USING SourceData AS src
      ON  src.student_id = Target.student_id
      AND src.classSchedule_id = Target.classSchedule_id
      AND src.[date]           = Target.[date]
      -- For Inserts
      WHEN NOT MATCHED BY Target THEN
      INSERT (classSchedule_id    ,     student_id,    [date],     present)
      VALUES (src.classSchedule_id, src.student_id,src.[date], src.present)
      -- For Updates
      WHEN MATCHED THEN 
      UPDATE
      SET
         Target.present	= src.present
      ;

      IF @display_tables = 1
         SELECT * FROM Attendance;

      EXEC sp_log 1, @fn, '499: Completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt,' rows.';
   RETURN @row_cnt;
END
/*
EXEC test.test_014_sp_import_Attendance;

EXEC tSQLt.Run 'test.test_014_sp_importAttendance';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Filenames](
	[path] [varchar](500) NULL,
	[file] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================================================
-- Author:      Terry Watts
-- Create date: 06-APR-2025
-- Description: Gets all the file names that match @mask from a directory
-- Design:      EA
-- Tests:       test_033_sp_getFilesInFolder
-- Postconditions: 
-- POST 01:if error throws exception ELSE returns the count of files in the folder
-- =======================================================================================
CREATE PROCEDURE [dbo].[sp_getFilesInFolder]
    @folder          VARCHAR(500)
   ,@mask            VARCHAR(60)
   ,@display_tables  BIT = 0
   ,@clr_first       BIT = 1
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE 
    @fn              VARCHAR(35)= 'sp_getFilesInFolder'
   ,@cmd             VARCHAR(1000)
   ,@fileCnt         INT            = 0
   ;

    EXEC sp_log 1, @fn ,'000: starting
folder         :[', @folder        , ']
mask           :[', @mask          , ']
display_tables :[', @display_tables, ']
clr_first      :[', @clr_first     , ']
';

   If @clr_first = 1
   BEGIN
      EXEC sp_log 1, @fn ,'010: clearing Filenames table';
      DELETE FROM Filenames;
   END

   SET @cmd = CONCAT('dir "', @folder ,CHAR(92),@mask,'" /b');
   EXEC sp_log 1, @fn ,'010: @cmd:
', @cmd ;

   INSERT INTO Filenames([file])
   EXEC Master..xp_cmdShell @cmd;

   DELETE FROM Filenames 
   WHERE [file] IS NULL OR [file] = 'File Not Found';

   UPDATE Filenames SET [path] = @folder WHERE [path] IS NULL;

   If @display_tables = 1
      SELECT * FROM Filenames ORDER BY [file];

   SELECT @fileCnt = COUNT(*) FROM Filenames;
   EXEC sp_log 1, @fn ,'999: leaving, processing complete, found ', @fileCnt,  ' files';
   RETURN @fileCnt;
END
/*
EXEC tSQLt.RunAll;
EXEC test.test_033_sp_getFilesInFolder;
EXEC tSQLt.Run 'test.test_033_sp_getFilesInFolder';
EXEC test.sp__crt_tst_rtns 'dbo.sp_getFilesInFolder'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================
-- Procedure:   sp_import_attendance
-- Description: Imports the file to AttendanceStaging
--                   then merges to Attendance
-- Design:      EA: Dorsu/Attendance
-- Preconditions the following tables must be populated:
--             Student, Course, Section, Enrollment
--
-- Postconditions: The attendance tables merged 
-- Tests:       test_055_sp_import_All_Attendance
--              test_014_sp_importAttendance
-- Author:      Terry Watts
-- Create date: 07-APR-2025
-- ======================================================
CREATE PROCEDURE [dbo].[sp_import_All_Attendance]
    @folder          VARCHAR(350)
   ,@mask            VARCHAR(50) = NULL
   ,@sep             VARCHAR(50) = NULL
   ,@clr_first       BIT         = 1
   ,@display_tables  BIT = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_import_All_Attendance'
      ,@file      VARCHAR(100)
      ,@path      VARCHAR(500)
      ,@backslash CHAR(1)     = CHAR(92) --'\';
      ,@row_cnt   INT         = 0
      ,@delta     INT
      ,@file_cnt  INT         = 0

   EXEC sp_log 1, @fn, '000: starting
folder:        [',@folder        ,']
mask:          [',@mask          ,']
sep:           [',@sep           ,']
clr_first:     [',@clr_first     ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      --------------------------------------------------------
      -- VALIDATION
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validating';

      --------------------------------------------------------
      -- Defaults
      --------------------------------------------------------
      IF @folder IS NULL
      BEGIN
         SET @folder = 'D:\Dorsu\Data';
         EXEC sp_log 1, @fn, '020: setting the folder to the default: ',@folder;
      END

      -- Create the import file mask
      IF @mask IS NULL SET @mask = '*.txt';
      IF @sep IS NULL  SET @sep  = CHAR(9); -- tab;

      --------------------------------------------------------
      -- Process
      --------------------------------------------------------
       EXEC sp_log 1, @fn, '030: Processing using the following params:
folder:        [',@folder        ,']
mask:          [',@mask          ,']
sep:           [',@sep           ,']
clr_first:     [',@clr_first     ,']
display_tables:[',@display_tables,']
';

       IF @clr_first = 1
         TRUNCATE TABLE Attendance; -- DELETE FROM Attendance;

      -- Get all the file nams in the given folder that match the file mask
       EXEC sp_getFilesInFolder @folder, @mask, @display_tables;

   -----------------------------------------------
   -- ASSERTION: the filenames table is populated
   ----------------------------------------------

      DECLARE FileName_cursor CURSOR FAST_FORWARD FOR
      SELECT [file], [path]
      FROM FileNames;

      -- Open the cursor
      OPEN FileName_cursor;
      EXEC sp_log 1, @fn, '040: B4 import file loop';
      -- Fetch the first row
      FETCH NEXT FROM FileName_cursor INTO @file, @path;

      -- Start processing rows
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Process the current row
         SET @file_cnt = @file_cnt +1;
         EXEC sp_log 1, @fn, '050: @file_cnt: ',@file_cnt,' in file loop: calling sp_Import_Enrollment, file: ', @file,  ' @folder: [', @folder, ']  ';


         EXEC @delta = sp_import_Attendance
             @file     = @file
            ,@folder   = @folder
--            ,@clr_first= 0
            ,@sep      = @sep
         ;

         SET @row_cnt = @row_cnt + @delta;

         EXEC sp_log 1, @fn, '060: imported ',@delta, ' rows, @row_cnt: ', @row_cnt;

         -- Fetch the next row
         FETCH NEXT FROM FileName_cursor INTO @file, @path;
      END

            --------------------------------------------------
      -- ASSERTION: completed processing
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '399: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;
      THROW;
   END CATCH

      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;
   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC tSQLt.Run 'test.test_055_sp_import_All_Attendance';

EXEC sp_appLog_display 'sp_import_All_Attendance'
EXEC sp_import_All_Attendance 'D:\Dorsu\Data\Attendance 250529-2030';

SELECT * FROM AttendanceStagingHdr;
SELECT * FROM AttendanceStaging;
SELECT * FROM Attendance;
SELECT * FROM Attendance_vw;
EXEC test.test_014_sp_importAttendance;
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[sp_import_All_Attendance]'
   -- Clean Import the tsv @file into the Attendance staging table:
   -- Then merge the staging table to the main attendance table
   --EXEC sp_ImportAttendanceStaging @file, @display_tables; --, @course_nm, @section_nm;

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================
-- Description: creates a relationship
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 07-MAR-2025
--
-- PRECONDITIONS:
-- PRE 01 @fk_nm        NOT NULL or EMPTY
-- PRE 02 @f_table_nm   NOT NULL or EMPTY
-- PRE 03 @col_nm NOT   NULL or EMPTY
-- PRE 04 @p_table_nm   NOT NULL or EMPTY
-- PRE 05 @p_schema_nm  NOT NULL or EMPTY
--
-- POSTCONDITIONS:
-- POST 01: returns 1 AND FK created OR (0 AND FK already exists)
-- POST 02: throws exception if failed to create a non existent FK
-- ================================================================
CREATE PROCEDURE [dbo].[sp_create_FK]
    @fk_nm        VARCHAR(60)
   ,@f_table_nm   VARCHAR(60)
   ,@p_table_nm   VARCHAR(60)
   ,@f_col_nm     VARCHAR(60)
   ,@p_col_nm     VARCHAR(60) = NULL
   ,@cnt          INT         = NULL    OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @fn           VARCHAR(35) = 'sp_create_FK'
   ,@sql          NVARCHAR(MAX)
   ,@NL           NVARCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@msg          VARCHAR(500)
   ,@ret          INT  = 0
   ;

      EXEC sp_log 1, @fn ,' starting
fk_nm     :[', @fk_nm     ,']
f_table_nm:[', @f_table_nm,']
p_table_nm:[', @p_table_nm,']
p_table_nm:[', @p_table_nm,']
f_col_nm  :[', @f_col_nm  ,']
p_col_nm  :[', @p_col_nm  ,']
cnt       :[', @cnt       ,']
';

   IF @p_col_nm IS NULL  SET @p_col_nm = @f_col_nm;

   IF dbo.fnFkExists(@fk_nm) = 0
   BEGIN
      -- dbo.FkExists returns 1 if the foriegn exists, 0 otherwise
      SET @sql = CONCAT('
ALTER TABLE ', @f_table_nm,' WITH CHECK ADD CONSTRAINT ',@fk_nm,' FOREIGN KEY(',@f_col_nm,') 
REFERENCES ',@p_table_nm,'(',@p_col_nm,');
ALTER TABLE ', @f_table_nm,' CHECK CONSTRAINT ',@fk_nm,';');

      PRINT @sql;
      EXEC (@sql);

      SET @ret = dbo.fnFkExists(@fk_nm);

      IF @cnt IS NOT NULL SET @cnt = @cnt +1;

      -- POST 02: throws exception if failed to create a non existent FK
      EXEC sp_assert_equal 1, @ret, 'Failed to create FK: ', @fk_nm;
      EXEC sp_log 1, @fn ,'created FK ',@fk_nm;
   END
   ELSE
   BEGIN
      EXEC sp_log 1, @fn ,@fk_nm, ' already exists';
   END

   -- POST 01: returns 1 AND FK created OR (0 AND FK already exists)
   RETURN @ret;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Description: re creates all Auth schema foreign keys
--              after total import
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 03-APR-2025
-- =====================================================
CREATE PROCEDURE [dbo].[sp_create_FKs_Auth] @tables VARCHAR(MAX) = NULL
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn     VARCHAR(35) = 'sp_create_FKs_Auth'
      ,@cnt    INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, @tables: ', @tables, '';

      -------------------------------------------------------------------------------------------------------
      -- 1: Foreign table UserRole: 2 FKs:  FK_UserRole_Role, FK_UserRole_User
      -------------------------------------------------------------------------------------------------------
      EXEC sp_create_FK 'FK_UserRole_Role' , 'UserRole', 'Role' , 'role_id' , @cnt=@cnt OUT;
      EXEC sp_create_FK 'FK_UserRole_User' , 'UserRole', '[User]', 'user_id', @cnt=@cnt OUT;;

      -------------------------------------------------------------------------------------------------------
      -- 1: Foreign table RoleFeature: 2 FKs:  FK_RoleFeature_Feature, FK_RoleFeature_Role
      -------------------------------------------------------------------------------------------------------
      EXEC sp_create_FK 'FK_RoleFeature_Feature', 'RoleFeature', 'Feature', 'feature_id', @cnt=@cnt OUT;;
      EXEC sp_create_FK 'FK_RoleFeature_Role'   , 'RoleFeature', 'Role'   , 'role_id'   , @cnt=@cnt OUT;;

      -------------------------
      -- Completed processing
      -------------------------
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: created ', @cnt, ' Foreign key  constraints';
   RETURN @cnt;
END
/*
EXEC sp_drop_FKs_Auth;
EXEC sp_create_FKs_Auth;
SELECT * FROM [User]
SELECT * FROM [Role]
SELECT * FROM [UserRole]
SELECT * FROM Feature
SELECT * FROM [RoleFeature]
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the Role table from a tsv
-- Design:      EA
-- Tests:       test_027_sp_Import_Feature
-- Author:      Terry Watts
-- Create date: 31-MAR-2025
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Feature]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_Feature'
      ,@row_cnt   INT         = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file, params:';
   EXEC sp_log 1, @fn, '000: file:          [',@file          ,']';
   EXEC sp_log 1, @fn, '000: folder:        [',@folder        ,']';
   EXEC sp_log 1, @fn, '000: clr_first:     [',@clr_first     ,']';
   EXEC sp_log 1, @fn, '000: sep:           [',@sep           ,']';
   EXEC sp_log 1, @fn, '000: codepage:      [',@codepage      ,']';
   EXEC sp_log 1, @fn, '000: display_tables:[',@display_tables,']';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'Feature'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;
      EXEC sp_log 1, @fn, '010: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows into the Feature table';
END
/*
EXEC sp_Import_Feature 'D:\Dorsu\data\UsersRolesFeatures.Features.txt';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_027_sp_Import_Feature';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the Major table from a tsv
-- Design:      EA
-- Tests:       test_025_sp_Import_User'
-- Author:      Terry Watts
-- Create date: 31-MAR-2025
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_User]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_User'
      ,@row_cnt   INT         = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [', @file          ,']
folder:        [', @folder        ,']
clr_first:     [', @clr_first     ,']
sep:           [', @sep           ,']
codepage:      [', @codepage      ,']
display_tables:[', @display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'User'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC sp_Import_User 'D:\Dorsu\data\UsersRolesFeatures.Users.txt';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_025_sp_Import_User';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the UserRole table from a tsv
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 31-MAR-2025
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_UserRole]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_UserRole'
      ,@row_cnt   INT         = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [', @file          ,']
folder:        [', @folder        ,']
clr_first:     [', @clr_first     ,']
sep:           [', @sep           ,']
codepage:      [', @codepage      ,']
display_tables:[', @display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'UserRole'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows into the UserRole table';
END
/*
EXEC sp_Import_UserRole 'D:\Dorsu\data\UserRoles.UserRoles.txt';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the Role table from a tsv
-- Design:      EA: role model
-- Tests:       
-- Author:      Terry Watts
-- Create date: 31-MAR-2025
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Role]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_Role'
      ,@row_cnt   INT         = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'Role'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC sp_Import_Role 'D:\Dorsu\data\Roles.Roles.txt';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_Import_Role]', @trn=26, @ad_stp=1;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the UserRole table from a tsv
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 31-MAR-2025
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_RoleFeature]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_RoleFeature'
      ,@row_cnt   INT         = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'RoleFeature'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows into the RoleFeature table';
END
/*
EXEC sp_Import_RoleFeature 'D:\Dorsu\data\RoleFeatures.RoleFeatures.txt';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Feature](
	[feature_id] [int] NOT NULL,
	[feature_nm] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Feature] PRIMARY KEY CLUSTERED 
(
	[feature_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Feature_nm] ON [dbo].[Feature]
(
	[feature_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Role](
	[role_id] [int] NOT NULL,
	[role_nm] [varchar](20) NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Role_nm] UNIQUE NONCLUSTERED 
(
	[role_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RoleFeature](
	[role_id] [int] NOT NULL,
	[feature_id] [int] NOT NULL,
 CONSTRAINT [PK_RoleAction] PRIMARY KEY CLUSTERED 
(
	[role_id] ASC,
	[feature_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[RoleFeature]  WITH CHECK ADD  CONSTRAINT [FK_RoleFeature_Feature] FOREIGN KEY([feature_id])
REFERENCES [dbo].[Feature] ([feature_id])

ALTER TABLE [dbo].[RoleFeature] CHECK CONSTRAINT [FK_RoleFeature_Feature]

ALTER TABLE [dbo].[RoleFeature]  WITH CHECK ADD  CONSTRAINT [FK_RoleFeature_Role] FOREIGN KEY([role_id])
REFERENCES [dbo].[Role] ([role_id])

ALTER TABLE [dbo].[RoleFeature] CHECK CONSTRAINT [FK_RoleFeature_Role]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[User](
	[user_id] [varchar](9) NOT NULL,
	[user_nm] [varchar](50) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_User_nm] UNIQUE NONCLUSTERED 
(
	[user_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[UserRole](
	[user_id] [varchar](9) NOT NULL,
	[role_id] [int] NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC,
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_Role] FOREIGN KEY([role_id])
REFERENCES [dbo].[Role] ([role_id])

ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role]

ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_User] FOREIGN KEY([user_id])
REFERENCES [dbo].[User] ([user_id])

ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ========================================================
-- Author:      Terry Watts
-- Create date: 1-MAR-2025
-- Description: Imports the User-role-auth Features schema
-- Design:      EA: Roles model
-- Tests:       test_034_sp_ImportAuthUserRoleFeature
-- Preconditions  None
--
-- Postconditions Features table imported
-- ========================================================
CREATE PROCEDURE [dbo].[sp_Import_All_AuthUserRoleFeature]
   @folder         NVARCHAR(MAX)
  ,@file_mask      NVARCHAR(50)
  ,@display_tables BIT = 1
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_All_AuthUserRoleFeature'
      ,@file      VARCHAR(100)
      ,@path      VARCHAR(500)
      ,@file_path VARCHAR(600)
      ,@backslash CHAR(1)         = CHAR(92) --'\';

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, clearing tables';
      EXEC sp_drop_FKs_Auth;
      DELETE FROM RoleFeature;
      DELETE FROM UserRole;
      DELETE FROM [User];
      DELETE FROM [Role];
      DELETE FROM Feature;

      -- Get all the file name sin the folder
      EXEC sp_log 1, @fn, '010: calling sp_getFilesInFolder';
      EXEC sp_getFilesInFolder  @folder, @file_mask;
      EXEC sp_log 1, @fn, '020: ret frm sp_getFilesInFolder';

      --------------------------------------------------------------------
      -- ASSERTION: we have all the file names in the FileNames table;
      --------------------------------------------------------------------
      SELECT * FROM FileNames;

      DECLARE FileName_cursor CURSOR FAST_FORWARD FOR
      SELECT [file], [path]
      FROM FileNames;

      -- Open the cursor
      OPEN FileName_cursor;

         -- Fetch the first row
         FETCH NEXT FROM FileName_cursor INTO @file, @path;

      -- Start processing rows
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Process the current row
         SET @file_path = CONCAT(@path, @backslash, @file);
         EXEC sp_log 1, @fn, '030: in file loop: file:      [', @file,']';
         EXEC sp_log 1, @fn, '030: in file loop: path:      [', @path, ']';
         EXEC sp_log 1, @fn, '030: in file loop: file_path: [',@file_path,']';

         IF      @file LIKE '%.UserRoles.%'     EXEC sp_Import_UserRole    @file_path, @display_tables = @display_tables;
         ELSE IF @file LIKE '%.Users.%'         EXEC sp_Import_User        @file_path, @display_tables = @display_tables;
         ELSE IF @file LIKE '%.Roles.%'         EXEC sp_Import_Role        @file_path, @display_tables = @display_tables;
         ELSE IF @file LIKE '%.RoleFeatures.%'  EXEC sp_Import_RoleFeature @file_path, @display_tables = @display_tables;
         ELSE IF @file LIKE '%.Features.%'      EXEC sp_Import_Feature     @file_path, @display_tables = @display_tables;
--            ELSE IF @file LIKE '%Sections%'      EXEC sp_Import_Section     @file_path, @display_tables;
--            ELSE IF @file LIKE '%Students%'      EXEC sp_Import_Students    @file_path, @display_tables;
         ELSE EXEC sp_log 1, @fn, '040:  not processing [', @file,  '] path: [', @path, ']';

         -- Fetch the next row
         EXEC sp_log 1, @fn, '050: getting next file from cursor';
         FETCH NEXT FROM FileName_cursor INTO @file, @path;
      END

      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;

      EXEC sp_log 1, @fn, '399: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;
      EXEC sp_create_FKs_Auth;
      THROW;
   END CATCH

   EXEC sp_create_FKs_Auth;
   EXEC sp_log 1, @fn, '999: leaving, imported the Auth-User-Role-Feature schema';
END
/*
EXEC test.test_034_sp_Import_All_AuthUserRoleFeature;

EXEC sp_Import_All_AuthUserRoleFeature   
   @folder         ='D:\Dorsu\Tests\test_037'
  ,@file_mask      = '*.txt'
  ,@display_tables = 1
  ;

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_034_sp_Import_All_AuthUserRoleFeature';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EnrollmentStaging](
	[impid] [varchar](50) NOT NULL,
	[student_id] [varchar](50) NOT NULL,
	[student_nm] [varchar](50) NULL,
	[gender] [varchar](50) NULL,
	[course_nm] [varchar](50) NOT NULL,
	[section_nm] [varchar](50) NOT NULL,
	[major_nm] [varchar](50) NULL,
	[year] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Description: tidies up the StudentCourseStaging table
-- names - removes double spaces
-- Part of the data load
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 04-MAR-2025
-- PRECONDITIONS: none
-- POSTCONDITONS: StudentCourseStaging.student_nm has no double spaces
-- ====================================================================
CREATE PROCEDURE [dbo].[sp_fixup_EnrollmentStaging]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @fn VARCHAR(35) = 'sp_fixup_EnrollmentStaging'

   EXEC sp_log 1, @fn, '000: starting';
   UPDATE EnrollmentStaging SET student_nm = REPLACE(student_nm, '  ', ' ');
   UPDATE EnrollmentStaging SET student_nm = REPLACE(student_nm, 'Ã±', 'ñ');

   -- Caldoza , Psyche A.
   UPDATE EnrollmentStaging SET student_nm = REPLACE(student_nm, ' , ', ', ');
   UPDATE EnrollmentStaging SET student_nm = REPLACE(student_nm, ' ,', ', ');
   EXEC sp_log 1, @fn, '999: leaving: OK';
END
/*
SELECT * FROM EnrollmentStaging ORDER BY student_nm, course_nm;
EXEC sp_fixup_EnrollmentStaging
SELECT * FROM EnrollmentStaging ORDER BY student_nm, course_nm;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Semester](
	[semester_id] [int] NOT NULL,
	[semester_nm] [nchar](10) NULL,
	[acedemic_year] [varchar](9) NULL,
 CONSTRAINT [PK_Semmester] PRIMARY KEY CLUSTERED 
(
	[semester_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Semmester] UNIQUE NONCLUSTERED 
(
	[semester_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Enrollment](
	[enrollment_id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NOT NULL,
	[course_id] [int] NOT NULL,
	[section_id] [int] NOT NULL,
	[major_id] [int] NULL,
	[semester_id] [int] NULL,
 CONSTRAINT [PK_Enrollment_1] PRIMARY KEY CLUSTERED 
(
	[enrollment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Enrollment] ON [dbo].[Enrollment]
(
	[student_id] ASC,
	[course_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

ALTER TABLE [dbo].[Enrollment]  WITH CHECK ADD  CONSTRAINT [FK_Enrollment_Course] FOREIGN KEY([course_id])
REFERENCES [dbo].[Course] ([course_id])

ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_Course]

ALTER TABLE [dbo].[Enrollment]  WITH CHECK ADD  CONSTRAINT [FK_Enrollment_Major] FOREIGN KEY([major_id])
REFERENCES [dbo].[Major] ([major_id])

ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_Major]

ALTER TABLE [dbo].[Enrollment]  WITH CHECK ADD  CONSTRAINT [FK_Enrollment_Section] FOREIGN KEY([section_id])
REFERENCES [dbo].[Section] ([section_id])

ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_Section]

ALTER TABLE [dbo].[Enrollment]  WITH CHECK ADD  CONSTRAINT [FK_Enrollment_Semester] FOREIGN KEY([semester_id])
REFERENCES [dbo].[Semester] ([semester_id])

ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_Semester]

ALTER TABLE [dbo].[Enrollment]  WITH CHECK ADD  CONSTRAINT [FK_Enrollment_Student] FOREIGN KEY([student_id])
REFERENCES [dbo].[Student] ([student_id])

ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_Student]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Description:   Imports the EnrollmentStaging table from a tsv
-- Design:        EA
-- Tests:         
-- Author:        Terry Watts
-- Create date:   23-Feb-2025
-- Preconditions: FKs dropped, Stuent table clrd if necessary
-- Postconditions:
-- POST 01: inmported the import file successfully and returns the number of rows imnported
--          error otherwise
-- ==============================================================================
CREATE PROCEDURE [dbo].[sp_Import_Enrollment]
    @file            VARCHAR(500)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
    @fn        VARCHAR(35) = 'sp_Import_Enrollment'
   ,@tab       NCHAR(1)=NCHAR(9)
   ,@row_cnt   INT
   ,@tot_cnt   INT

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file to EnrollmentStaging tbl clr first
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'EnrollmentStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = 1 -- @clr_first
         ,@display_table   = @display_tables
      ;

      SELECT @tot_cnt = Count(*) FROM EnrollmentStaging;
      EXEC sp_log 1, @fn, '010: calling sp_fixup_EnrollmentStaging';
      EXEC sp_fixup_EnrollmentStaging;

      --Do not TRUNCATE TABLE Student;

      EXEC sp_log 1, @fn, '020: merge student table with basic data: student_id, student_nm, gender';

      WITH SourceData AS
      (
         SELECT student_id, student_nm, course_id, s.section_id, m.major_id, gender
         FROM EnrollmentStaging es
         LEFT JOIN Course  c ON es.course_nm  = c.course_nm
         LEFT JOIN Section s ON es.section_nm = s.section_nm
         LEFT JOIN Major   m ON es.major_nm   = m.major_nm
      )
      MERGE Student as Target
      USING SourceData AS SRC 
      ON  SRC.student_id = Target.student_id
      WHEN NOT MATCHED BY Target THEN
      INSERT (    student_id,     student_nm, section_id    ,     gender)
      VALUES (SRC.student_id, SRC.student_nm, SRC.section_id, SRC.gender)
      WHEN  MATCHED THEN 
      UPDATE SET 
          section_id = SRC.section_id
         ,gender     = SRC.gender
      ;


      -- Pop Enrollment
      --TRUNCATE TABLE Enrollment;
      WITH SourceData AS
      (
         SELECT student_id, course_id, s.section_id, m.major_id
         FROM EnrollmentStaging es
         LEFT JOIN Course  c ON es.course_nm  = c.course_nm
         LEFT JOIN Section s ON es.section_nm = s.section_nm
         LEFT JOIN Major   m ON es.major_nm   = m.major_nm
      )
      MERGE Enrollment AS Target --(student_id, course_id, section_id, major_id)
      USING SourceData AS SRC
      ON  SRC.student_id = Target.student_id
      AND SRC.course_id  = Target.course_id
      WHEN NOT MATCHED BY Target THEN
      INSERT (student_id, course_id, section_id, major_id)
      VALUES (student_id, course_id, section_id, major_id)
      ;

   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows, StudentCourseStaging table now has ', @tot_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC tSQLt.Run 'test.test_000_sp_importAllStudents';
EXEC test.test_000_sp_importAllStudents;
EXEC sp_importAllStudents;

EXEC sp_drop_fks;
TRUNCATE TABLE Student
EXEC sp_Import_StudentCourse 'Students.250224.GEC E2 2B.txt','D:\Dorsu\Data';
EXEC sp_create_fks;

SELECT * FROM StudentCourseStaging;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
SELECT * FROM Student;
SELECT * FROM EnrollmentStaging;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:         Terry watts
-- Create date:    23-Feb-2025
-- Description:    Imports all Student enrollments
-- Design:      
-- Tests:       
-- Preconditions: 
--    PRE 01: all necessary FKs dropped
--    PRE 02: course, section  data imported
-- Postconditions:
--    POT 01: all student course, section  data imported
--```and returns the number of rows imnported
--          error otherwise
-- ============================================================
CREATE PROCEDURE [dbo].[sp_import_All_Enrollments]
 @folder          VARCHAR(500)= NULL
,@mask            VARCHAR(50) = NULL
,@sep             VARCHAR(50) = NULL
,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_import_All_Enrollments'
      ,@file      VARCHAR(100)
      ,@path      VARCHAR(500)
      ,@backslash CHAR(1)     = CHAR(92) --'\';
      ,@row_cnt   INT         = 0
      ,@delta     INT

   EXEC sp_log 1, @fn, '000: starting
@folder:        [',@folder        ,']
@mask:          [',@mask          ,']
@set:           [',@sep           ,']
@display_tables:[',@display_tables,']
';

   BEGIN TRY
      --------------------------------------------------------
      -- VALIDATION
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validating';

      --------------------------------------------------------
      -- Defaults
      --------------------------------------------------------
      IF @folder IS NULL
      BEGIN
         SET @folder = 'D:\Dorsu\Data';
         EXEC sp_log 1, @fn, '020: setting the folder to the default: ',@folder;
      END

      -- Create the import file mask
      IF @mask IS NULL SET @mask = '*.txt';
      IF @sep IS NULL  SET @sep  = CHAR(9); -- tab;

      --------------------------------------------------------
      -- Process
      --------------------------------------------------------
       EXEC sp_log 1, @fn, '030: Processing using the following params:
@folder:        [',@folder        ,']
@mask:          [',@mask          ,']
@set:           [',@sep           ,']
@display_tables:[',@display_tables,']
';

      -- Get all the file nams in the given folder that match the file mask
       EXEC sp_getFilesInFolder @folder, @mask, @display_tables;

   -----------------------------------------------
   -- ASSERTION: the filenames table is populated
   ----------------------------------------------

      DECLARE FileName_cursor CURSOR FAST_FORWARD FOR
      SELECT [file], [path]
      FROM FileNames;

      -- Open the cursor
      OPEN FileName_cursor;
      EXEC sp_log 1, @fn, '040: B$ import file loop';
      -- Fetch the first row
      FETCH NEXT FROM FileName_cursor INTO @file, @path;

      -- Start processing rows
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Process the current row
         EXEC sp_log 1, @fn, '050: in file loop: calling sp_Import_Enrollment, file: ', @file,  ' @folder: [', @folder, ']  ';
         EXEC @delta = sp_Import_Enrollment @file, @folder, @clr_first=0, @sep=@sep;
         EXEC sp_log 1, @fn, '060: imported ',@row_cnt, ' rows';
         SET @row_cnt = @row_cnt + @delta;
         -- Fetch the next row
         FETCH NEXT FROM FileName_cursor INTO @file, @path;
      END

      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;

            --------------------------------------------------------
      -- ASSERTION: completed processing
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '399: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC test.test_054_sp_import_All_Enrollments;

EXEC tSQLt.Run 'test.test_054_sp_import_All_Enrollments';

EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if exp = act
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_equal]
    @a         SQL_VARIANT
   ,@b         SQL_VARIANT
   ,@msg       VARCHAR(200)   = NULL
   ,@msg2      VARCHAR(200)   = NULL
   ,@msg3      VARCHAR(200)   = NULL
   ,@msg4      VARCHAR(200)   = NULL
   ,@msg5      VARCHAR(200)   = NULL
   ,@msg6      VARCHAR(200)   = NULL
   ,@msg7      VARCHAR(200)   = NULL
   ,@msg8      VARCHAR(200)   = NULL
   ,@msg9      VARCHAR(200)   = NULL
   ,@msg10     VARCHAR(200)   = NULL
   ,@msg11     VARCHAR(200)   = NULL
   ,@msg12     VARCHAR(200)   = NULL
   ,@msg13     VARCHAR(200)   = NULL
   ,@msg14     VARCHAR(200)   = NULL
   ,@msg15     VARCHAR(200)   = NULL
   ,@msg16     VARCHAR(200)   = NULL
   ,@msg17     VARCHAR(200)   = NULL
   ,@msg18     VARCHAR(200)   = NULL
   ,@msg19     VARCHAR(200)   = NULL
   ,@msg20     VARCHAR(200)   = NULL
   ,@ex_num    INT             = NULL
   ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
DECLARE
    @fnThis    VARCHAR(35) = 'sp_assert_not_equal'
   ,@aTxt      VARCHAR(100)= CONVERT(VARCHAR(20), @a)
   ,@bTxt      VARCHAR(100)= CONVERT(VARCHAR(20), @b)
   ,@std_msg   VARCHAR(200)

    EXEC sp_log @log_level, @fnThis, '000: starting @a:[',@aTxt, '] @b:[', @bTxt, ']';

   -- a<>b MEANS a<b OR b<a -> !(!a<b AND !(b<a))
   IF ((dbo.fnIsLessThan(@a ,@b) = 1) OR (dbo.fnIsLessThan(@b ,@a) = 1))
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fnThis, '010: OK, [',@aTxt, '] <> [', @bTxt, ']';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   --EXEC sp_log 3, @fnThis, '020: [', @aTxt , '] equals [',@bTxt,'], raising exception';
   IF @ex_num IS NULL SET @ex_num = 50003;

   SET @std_msg = CONCAT(@fnThis, ' [', @aTxt , '] equals [',@bTxt,'] ');

   EXEC sp_raise_exception
       @msg1   = @std_msg
      ,@msg2   = @msg
      ,@msg3   = @msg2
      ,@msg4   = @msg3
      ,@msg5   = @msg4
      ,@msg6   = @msg5
      ,@msg7   = @msg6
      ,@msg8   = @msg7
      ,@msg9   = @msg8
      ,@msg10  = @msg9
      ,@msg11  = @msg10
      ,@msg12  = @msg11
      ,@msg13  = @msg12
      ,@msg14  = @msg13
      ,@msg15  = @msg14
      ,@msg16  = @msg15
      ,@msg17  = @msg16
      ,@msg18  = @msg17
      ,@msg19  = @msg18
      ,@msg20  = @msg19
      ,@ex_num = @ex_num
      ,@fn     = @fn
   ;
END
/*
-- Smoke test 
EXEC sp_assert_not_equal 0, 1, 'Failed: tested routine not qualified'
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_047_sp_assert_not_equal';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_assert_not_equal]'
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeet2Staging](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[s_no] [varchar](50) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[google_alias] [varchar](50) NULL,
	[meet_st] [varchar](50) NULL,
	[Joined] [varchar](50) NULL,
	[stopped] [varchar](50) NULL,
	[duration] [varchar](50) NULL,
	[gmeet_id] [varchar](50) NULL,
	[date] [varchar](20) NULL,
	[cls_st] [varchar](4) NULL,
	[course_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NULL,
 CONSTRAINT [PK_AttendanceGMeet2Staging] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeet2StagingHdr](
	[id] [varchar](1000) NULL,
	[date] [varchar](1000) NULL,
	[cls_st] [varchar](1000) NULL,
	[course_nm] [varchar](1000) NULL,
	[section_nm] [varchar](1000) NULL,
	[gmeet_id] [varchar](1000) NULL,
	[seq] [varchar](1000) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 01-APR 2025
-- Description: fixup rtn for sp_ImportAllAttendanceGMeet2
-- Design:      EA
-- Preconditions: 
--    PRE 01: AttendanceGMeet2Staging    pop chkd
--    PRE 02: AttendanceGMeet2StagingHdr pop chkd

-- Postconditions:
--    POST 01: AttendanceGMeet2Staging
-- Tests:       test_044_sp_fixup_AttendanceGMeet2';
-- ===============================================================
CREATE PROCEDURE [dbo].[sp_fixup_AttendanceGMeet2Staging]
AS
BEGIN
   DECLARE
       @fn              VARCHAR(35)= 'sp_fixup_AttendanceGMeet2Staging'
      ,@course_nm       NVARCHAR(20)
      ,@section_nm      NVARCHAR(20)
      ,@date            DATE
      ,@cls_st          NVARCHAR(4)
      ,@class_st_time   TIME

   SET NOCOUNT ON;

   BEGIN TRY
      EXEC sp_log 1, @fn ,'000: starting';

      EXEC sp_log 1, @fn ,'010: Validating chkd preconditions';
      -- Preconditions: PRE 01: AttendanceGMeet2Staging pop chkd
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2Staging';
      -- Preconditions: PRE 02: AttendanceGMeet2StagingHdr pop chkd
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2StagingHdr';
      EXEC sp_log 1, @fn ,'020: Validated chkd preconditions';

      -- Import  the headers into a separate table called AttendanceGMeet2StagingHdr
      EXEC sp_log 1, @fn ,'030: Fixup the AttendanceGMeet2 header into';

      --SELECT * FROM AttendanceGMeet2StagingHdr;

      SELECT
          @date      = [date]
         ,@cls_st    = cls_st
         ,@course_nm = course_nm
         ,@section_nm= section_nm
      FROM AttendanceGMeet2StagingHdr;

         EXEC sp_log 1, @fn, '040: hdr info:
   date          :[',@date      ,']
   cls_st        :[',@cls_st    ,']
   course_nm     :[',@course_nm ,']
   section_nm    :[',@section_nm,']
   ';

      EXEC sp_log 1, @fn ,'050: mapping google alias to studend ID';
      UPDATE AttendanceGMeet2Staging SET student_id = dbo.fnMapGoogleAlias2StudentId(google_alias);
      EXEC sp_assert_not_equal 0, @@ROWCOUNT, 'AttendanceGMeet2StagingHdr failed to map any google aliases to student ids'

      -- ASSERTION: Got the headers
      EXEC sp_log 1, @fn ,'060: ASSERTION: Got the headers';
      EXEC sp_log 1, @fn ,'070: UPDATEing AttendanceGMeet2Staging';

      -- pop the class details
      UPDATE AttendanceGMeet2Staging
      SET
          [date]     = h.[date]
         ,cls_st     = h.cls_st
         ,course_nm  = h.course_nm
         ,section_nm = h.section_nm
   --      ,student_id = dbo.fnMapGoogleNm2StudentID(participant_nm)
         ,student_nm = s.student_nm
      FROM
         AttendanceGMeet2Staging a JOIN AttendanceGMeet2StagingHdr h ON a.id>=h.id
         LEFT JOIN Student s ON s.student_id = a.student_id
         WHERE  s.student_id IS NOT NULL
      ;
      /*
      UPDATE AttendanceGMeet2Staging
      SET student_nm = s.student_nm
      FROM
         AttendanceGMeet2Staging a 
         LEFT JOIN Student s ON s.student_id = a.student_id
      */
      EXEC sp_log 1, @fn ,'080: UPDATEed AttendanceGMeet2Staging';
      --SELECT * FROM AttendanceGMeet2Staging;
      --THROW 50000, '*** DEBUG sp_fixup_AttendanceGMeet2Staging ***', 1;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, fn, 'Caught exception'
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 1, @fn ,'999: leaving: OK';
END
/*
EXEC test.test_044_sp_fixup_AttendanceGMeet2;
EXEC tSQLt.Run 'test.test_044_sp_fixup_AttendanceGMeet2';
EXEC tSQLt.RunAll;

SELECT * FROM AttendanceGMeet2;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeet2](
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[google_alias] [varchar](50) NULL,
	[meet_st] [varchar](50) NULL,
	[course_id] [int] NULL,
	[section_id] [int] NULL,
	[joined] [time](7) NULL,
	[stopped] [time](7) NULL,
	[duration] [varchar](20) NULL,
	[gmeet_id] [varchar](35) NULL,
	[date] [date] NULL,
	[cls_st] [varchar](4) NULL,
	[course_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================
-- Author:      Terry Watts
-- Create date: 26 Apr 2025
-- Description: 
-- Design:      none
-- Tests:       indirect: sp_ImportAllGMeet2FilesInFolder
-- =======================================================
CREATE PROCEDURE [dbo].[sp_merge_AttendanceGMeet2]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn     VARCHAR(35) = 'sp_merge_AttendanceGMeet2'
   ,@cnt_1  INT
   ,@cnt_2  INT
   ,@diff   INT

   SELECT @cnt_1 = COUNT(*) FROM AttendanceGMeet2;
   EXEC sp_log 1, @fn ,'000: starting, initial count: ',@diff;

   MERGE AttendanceGMeet2 AS Target
   USING
   (
      SELECT s.student_id, s.student_nm, agms.google_alias, meet_st, joined, [stopped], duration, gmeet_id, [date], cls_st, c.course_nm, c.course_id, sec.section_nm, sec.section_id
      FROM AttendanceGMeet2Staging agms
      LEFT JOIN Student s   ON s  .student_nm = agms.student_nm
      LEFT JOIN Course  c   ON c  .course_nm  = agms.course_nm
      LEFT JOIN section sec ON sec.section_nm = agms.section_nm
   ) src
   ON Target.student_id = src.student_id
   WHEN NOT MATCHED BY Target THEN
      INSERT (    student_id,     student_nm,     google_alias, joined, [stopped], duration, cls_st, gmeet_id, [date], course_nm, course_id, section_nm, section_id)
      VALUES (src.student_id, src.student_nm, src.google_alias, joined, [stopped], duration, cls_st, gmeet_id, [date], course_nm, course_id, section_nm, section_id)
   ;

   SELECT @cnt_2 = COUNT(*) FROM AttendanceGMeet2;
   SET @diff = @cnt_2 - @cnt_1
   EXEC sp_log 1, @fn ,'999: leaving, merged', @diff,  ' files';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================================
-- Author:         Terry Watts
-- Create date:    17-Mar-2025
-- Description:    Imports the Attendance 2 staging table from a tsv
-- Design:         EA
-- Tests:          test_019_sp_ImportAttendanceGMeet2
-- Preconditions:  if @one_off = 0 AttendanceGMeet2StagingHdr must be popd
-- Postconditions: POST 01: AttendanceGMeet2 tbl populated
--                 POST 02L: if @one_off = 0 teh tAttendanceGMeet2 tbl popd
--
-- Parameters:
-- @@file_path: file path of the file imported
-- @one_off   : flag used to define wheter this import is a single import or 
--              part of many, in which case neither the hdr or merge need be handled here
-- Process:
-- User: Record the GMeet using the tracker
-- User: Close the GMeet session to save the report
-- User: Download the saved report as a csv
-- User: Add a 2 row header to the csv 
-- Sys:  Import the file using the GMeet attendance Tracker Import
-- Sys:  Import the header to the header table
-- Sys:  Import the attendance data to the AttendanceGMeet2Staging table
-- Sys:  Merge it and the header info to the main AttendanceGMeet2 table
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_Import_AttendanceGMeet2]
       @file            NVARCHAR(MAX)
      ,@folder          NVARCHAR(MAX) = NULL
      ,@one_off         BIT = 1 --  -- flag to signal to clr first and do merge after
      ,@display_tables  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              VARCHAR(35) = 'sp_ImportAttendanceGMeet2'
      ,@row_cnt         INT
      ,@course_nm       NVARCHAR(20)
      ,@section_nm      NVARCHAR(20)
      ,@class_date      DATE
      ,@class_st_time   TIME
      ,@file_path       NVARCHAR(MAX)

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting
file          :[',@file     ,']
folder        :[',@folder     ,']
one_off       :[',@one_off       ,']
display_tables:[',@display_tables,']
';

      IF @one_off = 1
      BEGIN
         EXEC sp_log 1, @fn, '005: truncating table AttendanceGMeet2';
         TRUNCATE TABLE AttendanceGMeet2;
      END

      SET @file_path = IIF( @folder IS NOT NULL, CONCAT(@folder, CHAR(92), @file ), @file);

   -- Sys: Import the file using the GMeet attendance Tracker Import
   -- Sys: Import the header to the header table
      EXEC sp_log 1, @fn, '010: Importing the AttendanceGMeet2StagingHdr table, file: ',@file_path;
      EXEC sp_import_txt_file
          @table           = 'AttendanceGMeet2StagingHdr'
         ,@file            = @file_path
         ,@field_terminator = ','
         ,@row_terminator   = '0x0a'
         ,@first_row       = 2
         ,@last_row        = 2
         ,@clr_first       = 1
         ,@display_table   = @display_tables
         ,@exp_row_cnt     = 1                     -- Make sure only 1 row
      ;

      -------------------------------------------------------------------
      -- ASSERTION got the header row
      -------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: ASSERTION: Imported 1 row into AttendanceGMeet2StagingHdr table';

      -- Set the meta data from the hdr row/tbl
      SELECT
          @class_date    = [date]
         ,@class_st_time = cls_st
         ,@course_nm     = course_nm
         ,@section_nm    = section_nm
      FROM AttendanceGMeet2StagingHdr
      ;

      -- Sys: Import the attendance data to the AttendanceGMeet2Staging table
      EXEC sp_log 1, @fn, '030: Importing the AttendanceGMeet2Staging table, file: ',@file_path;

      EXEC @row_cnt = sp_import_txt_file
          @table            = 'AttendanceGMeet2Staging'
         ,@file             = @file_path
         ,@field_terminator = ','
         ,@row_terminator   = '0x0a'
         ,@first_row        = 5
         ,@clr_first        = @one_off -- in this scenario clear the table first
         ,@view            = 'import_AttendanceGMeet2Staging_vw'
         ,@display_table    = 0--@display_tables
         ,@expect_rows      = 1
      ;

      -- Fixup AttendanceGMeet2Staging
      EXEC sp_log 1, @fn, '040: performing fixup; calling sp_fixup_AttendanceGMeet2Staging'
      EXEC sp_fixup_AttendanceGMeet2Staging;

      -------------------------------------------------------------------
      -- Sys:  Merge the header info to the main AttendanceGMeet2 table
      -------------------------------------------------------------------
      IF @one_off = 1 -- in this scenario do the merge now
      BEGIN
         EXEC sp_log 1, @fn ,'050: merge calling sp_merge_AttendanceGMeet2';
         EXEC sp_merge_AttendanceGMeet2;
         EXEC sp_log 1, @fn ,'060: merge completed';
      END
      -------------------------------------------------------------------
      -- Postconditions:
      -------------------------------------------------------------------

      EXEC sp_log 1, @fn, '300: checking Postconditions';
      EXEC sp_log 1, @fn, '310: chking POST 01: AttendanceGMeet2Staging populated';
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2Staging';
      EXEC sp_log 1, @fn, '100: Completed processing';

      IF @display_tables = 1
      BEGIN
         SELECT * FROM AttendanceGMeet2Staging;
         SELECT * FROM AttendanceGMeet2;
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      SELECT 'sp_ImportAttendanceGMeet2 Caught exception';

      IF @display_tables = 1
      BEGIN
         SELECT * FROM AttendanceGMeet2Staging;
         SELECT * FROM AttendanceGMeet2;
      END

      ;THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
END
/*
DELETE FROM AttendanceGMeet2;
-- SELECT * FROM AttendanceGMeet2;
EXEC test.test_019_sp_ImportAttendanceGMeet2;

EXEC sp_ImportAttendanceGMeet2Staging 'D:\Dorsu\Data\Attendance Record.GEC E2 2D.txt'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FileExists](
	[file_exists] [bit] NULL,
	[folder_exists] [bit] NULL,
	[parent_folder_exists] [bit] NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 25-APR-2025
-- Description: returns @result = true if the file exists, false otherwise
-- also proc returns @result
-- Tests:       test.test_047_sp_FolderExists
-- ===============================================================
CREATE PROC [dbo].[sp_FolderExists] @path varchar(512), @result BIT = NULL OUT
AS
BEGIN
   DELETE FROM dbo.FileExists;
   INSERT INTO dbo.FileExists EXEC master.dbo.xp_fileexist @path;
   SELECT @result = folder_exists FROM FileExists;
   RETURN @result;
END
/*
EXEC test.sp__crt_tst_rtns 'sp_FolderExists'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- Description: Imports all the GMeet attendance from the supplied folder
-- Design:      EA
-- Tests:       test_023_sp_ImportAllGMeet2FilesInFolder
--
-- Preconditions PRE001: folder must exist: chkd
--
-- Postconditions
-- POST 01: returns @fileCnt and successfule import of all files in folder or 
-- ============================================================================
CREATE PROCEDURE [dbo].[sp_Import_All_GMeet2FilesInFolder]
    @folder          VARCHAR(500)
   ,@file_mask       VARCHAR(20) = '*.csv'
   ,@display_tables  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
    @fn              VARCHAR(35) = 'sp_ImportAllGMeet2FilesInFolder'
   ,@filename        VARCHAR(255)
   ,@table           VARCHAR(50) = 'AttendanceGMeet2Staging'
   ,@view            VARCHAR(50) = 'import_AttendanceGMeet2Staging_vw'
   ,@cnt             INT         = 0
   ,@fileCnt         INT         = 0
   ,@sql             VARCHAR(8000)
   ,@cmd             VARCHAR(1000)
   ,@backslash       CHAR        = CHAR(92)
   ,@tab             NCHAR       = NCHAR(9)
   ,@id              INT
   ,@date            VARCHAR(20)
   ,@time24          VARCHAR(20)
   ,@course_nm       VARCHAR(20)
   ,@section_nm      VARCHAR(20)
   ,@folder_exists   BIT
   ;

    EXEC sp_log 1, @fn ,'000: starting
folder         :[', @folder         , ']
file_mask      :[', @file_mask      , ']
display_tables :[', @display_tables , ']
';

   IF @view IS NULL
      SET @view = @table;

   BEGIN TRY
      EXEC sp_log 1, @fn ,'010: Validating inputs';
      -- Preconditions PRE001: folder exists chkd
      EXEC @folder_exists = sp_FolderExists @folder;--, @folder_exists OUT;
      EXEC sp_assert_equal 1, @folder_exists, 'PRE001: folder must exist'

      EXEC sp_log 1, @fn ,'010: TRUNCATING TABLE: AttendanceGMeet2Staging';
      TRUNCATE TABLE AttendanceGMeet2Staging;

      -------------------------------------------------
      -- Get the files from the folder
      -------------------------------------------------
      DELETE FROM Filenames;
      SET @cmd = CONCAT('dir ', @folder ,'\\', @file_mask, ' /b');

      EXEC sp_log 1, @fn ,'020: Get the files from the folder -> Filenames table, @cmd:
', @cmd ;

      INSERT INTO Filenames([file])
      EXEC Master..xp_cmdShell @cmd;

      DELETE FROM Filenames WHERE [file] IS NULL;

      IF @display_tables =1
         SELECT * FROM Filenames ORDER BY [file];

      EXEC sp_log 1, @fn ,'020: updating the Filenames paths ';
      UPDATE Filenames SET [path] = @folder WHERE [path] IS NULL;

      DECLARE c1 CURSOR FOR
         SELECT [file]
         FROM Filenames
         --WHERE [file] LIKE @file_mask
         ORDER BY [file]
      ;

      OPEN c1;
      FETCH NEXT FROM c1 INTO @filename;

      --------------------------------------------------
        -- Main import loop
     --------------------------------------------------
      EXEC sp_log 1, @fn ,'030: main import loop: importing all files in Filenames table';
      IF @@fetch_status = -1
         EXEC sp_log 3, @fn ,'035: no files were found in folder ',@folder,' that matched mask: ',@file_mask;

      WHILE @@fetch_status <> -1
      BEGIN
         SET @fileCnt = @fileCnt + 1;
         EXEC sp_log 1, @fn ,'040: import  [', @fileCnt,']:  importing:[', @filename,']';
       --SET @path = CONCAT(@folder, '\\', @filename);

         EXEC sp_Import_AttendanceGMeet2
             @file            = @filename
            ,@folder          = @folder
            ,@one_off         = 0
            ,@display_tables  = @display_tables
         ;

         FETCH NEXT FROM c1 INTO @filename;
      END

      CLOSE c1;
      DEALLOCATE c1;
      EXEC sp_log 1, @fn ,'050: completedfile import loop';

      --------------------------------------------------
      -- Merge to main table
      --------------------------------------------------
      EXEC sp_log 1, @fn ,'070: merge calling sp_merge_AttendanceGMeet2';
      EXEC sp_merge_AttendanceGMeet2;
      EXEC sp_log 1, @fn ,'080: merge completed';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn ,'120:completed mn processing loop';
   EXEC sp_log 1, @fn ,'999: leaving, processing complete, imported ', @fileCnt,  ' files';
   RETURN @fileCnt;
END
/*
SELECT * FROM AttendanceGMeet2Staging ORDER BY participant_nm, course_nm, section_nm, [date], time_24;

EXEC test.test_023_sp_ImportAllGMeet2FilesInFolder;
SELECT count(*) FROM AttendanceGMeet2;
EXEC tSQLt.Run 'test.test_023_sp_ImportAllGMeet2FilesInFolder';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: Imports all the GMeet attendance from the supplied folder
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- =============================================
CREATE PROCEDURE [dbo].[sp_Import_All_FilesInFolder]
    @folder          VARCHAR(500)
   ,@mask            VARCHAR(60)    = '*.txt'
   ,@table           VARCHAR(50)
   ,@view            VARCHAR(50)    = NULL
   ,@clr_first       BIT = 1
   ,@display_tables  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @fn       VARCHAR(35)    = 'sp_ImportAllFilesInFolder'
   ,@filename        VARCHAR(255)
   ,@fileCnt         INT            = 0
   ,@sql             VARCHAR(8000)
   ,@cmd             VARCHAR(1000)
   ,@path            VARCHAR(500)
   ,@backslash       CHAR           = CHAR(92)
   ,@tab             NCHAR          = NCHAR(9)
   ;

    EXEC sp_log 1, @fn ,'000: starting
folder         :[', @folder         , ']
mask           :[', @mask           , ']
table          :[', @table          , ']
view           :[', @view           , ']
clr_first      :[', @clr_first      , ']
display_tables :[', @display_tables , ']
';

/*
   IF @clr_first = 1
   BEGIN
    --SET  @cmd = CONCAT('DELETE from [', @table, ']');
    --SET  @cmd = CONCAT('TRUNCATE  TABLE [', @table, ']');
    --EXEC @cmd;
    ;
   END
*/
   IF @view IS NULL
      SET @view = @table;
   EXEC sp_getFilesInFolder
       @folder          = @folder
      ,@mask            = @mask
      ,@display_tables  = @display_tables
   ;

   BEGIN TRY
      --cursor loop
      DECLARE c1 CURSOR FOR
         SELECT /*[path], */[file]
         FROM Filenames
         WHERE [file] like '%.txt'
         ORDER BY [file]
      ;

      OPEN c1;
      FETCH NEXT FROM c1 INTO @filename;

      EXEC sp_log 1, @fn ,'010:B4 mn loop';
      WHILE @@fetch_status <> -1
      BEGIN
         SET @fileCnt = @fileCnt + 1;
         PRINT '';
         EXEC sp_log 1, @fn ,'020:in mn loop [', @fileCnt,']: @filename:[', @filename,']';
         SET @path = CONCAT(@folder, '\\', @filename);

         EXEC sp_import_txt_file 
           @table
          ,@path
          ,@clr_first      = 0
          ,@view           = @view
          ,@display_table  = @display_tables
         ;

         EXEC sp_log 1, @fn ,'030: ret frm sp_import_txt_file';
         FETCH NEXT FROM c1 INTO @filename;
         EXEC sp_log 1, @fn ,'040: next file: ', @filename;
      END -- while files loop

      EXEC sp_log 1, @fn ,'050:done mn loop';
      CLOSE c1;
      DEALLOCATE c1;
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn ,'0500 caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   --delete from ALLFILENAMES where WHICHFILE is NULL
   --select * from ALLFILENAMES
   EXEC sp_log 1, @fn ,'999: leaving, processing complete, imported ', @fileCnt,  ' files';
   RETURN @fileCnt;
END
/*
EXEC test.test_020_sp_ImportAllFilesInFolder;
EXEC tSQLt.Run 'test.test_020_sp_ImportAllFilesInFolder';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_ImportAllFilesInFolder]';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================
-- Author:       Terry Watts
-- Create date:  5-Apr-2025
-- Description:  Imports the GoogleAlias table from all files in given folder
-- Design:       EA
-- Tests:        
-- Preconditions: All dependent tables have been cleared
-- ==========================================================================
CREATE PROCEDURE [dbo].[sp_Import_All_GoogleAliases]
 @folder          NVARCHAR(MAX)
,@display_tables  BIT = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_ImportAllGoogleAliases'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, 
folder        :[',@folder        ,']
display_tables:[',@display_tables,']
';
      EXEC sp_log 1, @fn ,'010: truncating TABLE GoogleNameStaging';
      TRUNCATE TABLE GoogleAlias;

      EXEC sp_log 1, @fn ,'020: calling sp_ImportAllFilesInFolder -> GoogleAlias table';

      EXEC sp_Import_All_FilesInFolder
                @folder          = @folder
               ,@table           = 'GoogleAlias'
--             ,@view            = 'import_AttendanceGMeet2Staging_vw'
               ,@display_tables  = @display_tables
   ;

      IF @display_tables = 1
         SELECT student_id, student_nm, gender, google_alias 
         FROM GoogleAlias
         ORDER BY student_nm;

      EXEC sp_log 1, @fn, '030: updating the Student table google alias field';

      UPDATE Student
      SET google_alias = dbo.fnCamelCase(ga.google_alias)
      FROM GoogleAlias ga JOIN Student s ON ga.student_id = s.student_id

      IF @display_tables = 1
         SELECT * FROM Student WHERE google_alias IS NOT NULL;

      EXEC sp_log 1, @fn, '499: completed processing, file: [',@folder,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from folder: [',@folder,']';
END
/*
EXEC sp_ImportAllGoogleAliases 'D:\Dorsu\Data\GoogleAliases', 1
EXEC tSQLt.Run 'test.';
DELETE FROM GoogleNameAliase WHERE student_id IS NULL;
EXEC sp_Import_GoogleAlias 'D:\Dorsu\Data\GoogleNames.GEC E2 2B.txt', 1, 1;
EXEC sp_Import_GoogleAliase 'D:\Dorsu\Data\GoogleNames.GEC E2 2D.txt', 1, 0;
SELECT * FROM Student;
SELECT * FROM GoogleAlias;
EXEC sp_FindStudent2 '2023-0474';

SELECT Student_id, count(Student_id) 
FROM GoogleAliase
GROUP BY Student_id
ORDER BY count(Student_id) DESC
EXEC test.sp__crt_tst_rtns 'dbo].[sp_ImportAllGoogleAliases'
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================
-- Author:        Terry Watts
-- Create date:   25-Feb-2025
-- Description:   re creates all the foreign keys
-- Design:        EA
-- Tests:         test_004_sp_create_FKs
-- Preconditions: none
-- Postconditions:all required relationships created
-- POST01:        returns the count of the created keys
-- ======================================================
CREATE PROCEDURE [dbo].[sp_create_FKs]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn     VARCHAR(35) = 'sp_create_FKs'
      ,@cnt    INT         = 0
      ,@delta  INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';

      ------------------------------------------------------------------------------------
      -- 1: Foreign table Attendance: 2 FKs: FK_Attendance_Course, FK_Attendance_Student
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: creating FKs for table Attendance';
      EXEC sp_create_FK 'FK_Attendance_ClassSchedule', 'Attendance', 'ClassSchedule', 'classSchedule_id', @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Attendance_Student'     , 'Attendance' , 'Student'      , 'student_id', @cnt = @cnt OUT;

      ----------------------------------------------------------------------------------------
      --  Foreign table  Attendance2: 2 FKs: FK_Attendance_Course, FK_Attendance_Student
      ----------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: creating FKs for table Attendance2';
      EXEC sp_create_FK 'FK_Attendance2_ClassSchedule', 'Attendance2', 'ClassSchedule', 'classSchedule_id', @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Attendance2_Student'      , 'Attendance2', 'Student'      , 'student_id', @cnt = @cnt OUT;

      ---------------------------------------------------------------------------------------------------------------------------------------------
      -- Foreign table ClassSchedule: 4 Fks: FK_ClassSchedule_Course, FK_ClassSchedule_Major, FK_ClassSchedule_Room, FK_ClassSchedule_Section
      ---------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: creating FKs for table ClassSchedule';
      EXEC sp_create_FK 'FK_ClassSchedule_Course'     , 'ClassSchedule', 'Course'       , 'course_id',   @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_ClassSchedule_Major'      , 'ClassSchedule', 'Major'        , 'major_id',    @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_ClassSchedule_Room'       , 'ClassSchedule', 'Room'         , 'room_id',     @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_ClassSchedule_Section'    , 'ClassSchedule', 'Section'      , 'section_id',  @cnt = @cnt OUT;

      -----------------------------------------------------------------------------------------------------------------------------------------------------
      -- Foreign table Enrollment 5 Fks: FK_Enrollment_Course, FK_Enrollment_Major, FK_Enrollment_Section, FK_Enrollment_Semester, FK_Enrollment_Student
      -----------------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: creating FKs for table Enrollment';
      EXEC sp_create_FK 'FK_Enrollment_Course'  , 'Enrollment', 'Course'  , 'course_id'   , @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Enrollment_Major'   , 'Enrollment', 'Major'   , 'major_id'    , @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Enrollment_Section' , 'Enrollment', 'Section' , 'section_id'  , @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Enrollment_Semester', 'Enrollment', 'Semester', 'semester_id' , @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Enrollment_Student' , 'Enrollment', 'Student' , 'student_id'  , @cnt = @cnt OUT;

      ----------------------------------------
      -- Foreign table GoogleAlias
      ----------------------------------------
      --EXEC sp_log 1, @fn, '050: creating keys for  table GoogleAlias';
      --EXEC sp_create_FK 'FK_GoogleAlias_Student', 'GoogleAlias', 'Student', 'student_id';

      --------------------------------------------
      -- Foreign table Team: 1 FK: FK_Team_Event
      --------------------------------------------
      EXEC sp_log 1, @fn, '060: creating keys for table Team';
      EXEC sp_create_FK 'FK_Team_Event' , 'Team', 'Event', 'event_id', @cnt = @cnt OUT;

      --------------------------------------------------------
      -- Foreign table TeamMembers: 1 FK: FK_TeamMembers_Team
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '070: creating keys for table TeamMembers';
      EXEC sp_create_FK 'FK_TeamMembers_Team' , 'TeamMembers', 'Team' , 'team_id', @cnt = @cnt OUT;

      EXEC sp_log 1, @fn, '250: Creating auth table relationships, calling sp_create_FKs_Auth';
      EXEC @delta = sp_create_FKs_Auth;
      SET @cnt = @cnt + @delta;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, created ', @cnt, ' relationships';
   -- POST01: returns the count of the created keys
   RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_create_FKs'
EXEC sp_drop_FKs;
EXEC sp_create_FKs;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ClassScheduleStaging](
	[id] [int] NOT NULL,
	[course_nm] [nvarchar](50) NULL,
	[major_nm] [nvarchar](50) NULL,
	[section_nm] [nvarchar](50) NULL,
	[day] [nvarchar](50) NULL,
	[dow] [int] NULL,
	[times] [nvarchar](50) NULL,
	[room_nm] [nvarchar](50) NULL,
 CONSTRAINT [PK_ClassSchedule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================================
-- Author:         Terry Watts
-- Create date:    23-Feb-2025
-- Description:    Imports the Classschedule table from a tsv
-- Design:         EA Model.Use Case Model.Importing data.Generic Import of a table
--
-- Parameters:
--    file path:      full path to the import file
--    clr first:      if true clear the staging and main tables fist
--    sep:            field separator used in the import file tab or spc (1 character)
--    display tables: if true display the tables staging and main after import
--
-- Tests:          
-- Preconditions:  None
-- Postconditions: 
-- POST 01: ClassSchedule table populated
-- =========================================================================================
CREATE PROCEDURE [dbo].[sp_Import_ClassSchedule]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)   = NULL
   ,@clr_first       BIT            = 1
   ,@sep             CHAR           = 0x09
   ,@codepage        INT            = 65001
   ,@exp_row_cnt     INT            = NULL
   ,@display_tables  BIT            = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              VARCHAR(35)    = 'sp_Import_ClassSchedule'
   ,@tab             NCHAR(1)       = NCHAR(9)
   ,@row_cnt         INT 
   ,@backslash       VARCHAR(2)     = CHAR(92)
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:         :[', @file            ,']
folder:       :[', @folder          ,']
clr_first:    :[', @clr_first       ,']
sep:          :[', @sep             ,']
codepage      :[', @codepage        ,']
exp_row_cnt   :[', @exp_row_cnt     ,']
display_tables:[', @display_tables  ,']
';

   BEGIN TRY

      ----------------------------------------------------------------
      --Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      --Import text file
      ----------------------------------------------------------------

      EXEC sp_log 1, @fn, '010: calling sp_import_txt_file  @table: ClassScheduleStaging, @file: ',@file;

      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'ClassScheduleStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@view            = 'ImportClassScheduleStaging_vw'
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
         ,@exp_row_cnt     = @exp_row_cnt
      ;

      EXEC sp_log 1, @fn, '020: TRUNCATE TABLE ClassSchedule';
      TRUNCATE TABLE ClassSchedule;
      EXEC sp_log 1, @fn, '030: pop ClassSchedule';

      INSERT INTO ClassSchedule
           (
            course_id
           ,major_id
           ,section_id
           ,[day]
           ,dow
           ,st_time
           ,end_time
           ,[description]
           ,room_id
           )
           SELECT
            course_id
           ,major_id
           ,section_id
           ,[day]
           ,dbo.fnGetDowFromDayName(css.[day])
           ,SUBSTRING(times, 1,CHARINDEX('-',times)-1)
           ,SUBSTRING(times,   CHARINDEX('-',times)+1, 4)
           ,c.[description]
           ,room_id
      FROM ClassScheduleStaging css 
      left JOIN Course  c ON c.course_nm = css.course_nm
      left JOIN Major   m ON m.major_nm  = css.major_nm
      left JOIN Section s ON s.section_nm= css.section_nm
      left JOIN Room    R ON r.room_nm =   css.room_nm
      ;

      -- POST 01: ClassSchedule table populated
      EXEC sp_log 1, @fn, '040: inserted ',@row_cnt,' rows into ClassSchedule';
      EXEC sp_assert_tbl_pop 'ClassSchedule';

      IF @display_tables = 1
      BEGIN
         SELECT * FROM ClassScheduleStaging;
         SELECT * FROM ClassSchedule;
         SELECT * FROM ClassSchedule_vw;
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC test.test_060_sp_Import_ClassSchedule;

EXEC sp_drop_FKs;
EXEC sp_Import_ClassSchedule 'D:\Dorsu\Data\Class Schedule.Schedule 250317.txt', 1;
EXEC sp_create_FKs;
SELECT * FROM timetable_vw;

EXEC sp_Import_ClassSchedule 'D:\Dorsu\Data\Class Schedule.Schdeule 250221.txt', 1;
SELECT distinct Program from ClassScheduleStaging
SELECT * FROM Program;
SELECT * FROM Major;
SELECT * FROM ClassScheduleStaging
SELECT * FROM ClassSchedule
EXEC sp_AppLog_display 'sp__importSchema';
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[sp_Import_ClassSchedule]';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Procedure:   
-- Description:  Imports the Classschedule table from a tsv
-- Design:       EA
-- Tests:        
-- Author:       
-- Create date:  25-Feb-2025
-- Preconditions: All dependent tables have been cleared
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Course]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_Course'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'Course'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
END
/*
EXEC sp_Import_Course 'D:\Dorsu\Courses\Courses.Course.txt';
EXEC sp_importAllStudentCourses;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Event](
	[event_id] [int] NOT NULL,
	[event_nm] [varchar](100) NOT NULL,
	[date] [date] NOT NULL,
	[course_nm] [varchar](20) NULL,
 CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED 
(
	[event_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Event] ON [dbo].[Event]
(
	[event_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Team](
	[team_id] [int] NOT NULL,
	[team_nm] [varchar](40) NULL,
	[github_project] [varchar](250) NULL,
	[team_gc] [varchar](100) NULL,
	[team_url] [varchar](300) NULL,
	[section_id] [int] NULL,
	[event_id] [int] NULL,
	[notes] [varchar](150) NULL,
 CONSTRAINT [PK_Team] PRIMARY KEY CLUSTERED 
(
	[team_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [IX_Team] ON [dbo].[Team]
(
	[team_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

ALTER TABLE [dbo].[Team]  WITH CHECK ADD  CONSTRAINT [FK_Team_Event] FOREIGN KEY([event_id])
REFERENCES [dbo].[Event] ([event_id])

ALTER TABLE [dbo].[Team] CHECK CONSTRAINT [FK_Team_Event]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[TeamMembers](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[is_lead] [bit] NULL,
	[team_id] [int] NULL,
	[section_id] [int] NULL,
 CONSTRAINT [PK_TeamMembers] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UQ_TeamMembers] ON [dbo].[TeamMembers]
(
	[student_id] ASC,
	[team_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

ALTER TABLE [dbo].[TeamMembers]  WITH CHECK ADD  CONSTRAINT [FK_TeamMembers_Team] FOREIGN KEY([team_id])
REFERENCES [dbo].[Team] ([team_id])

ALTER TABLE [dbo].[TeamMembers] CHECK CONSTRAINT [FK_TeamMembers_Team]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the Event table from a tsv
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 24-Mar-2025
-- Preconditions: 
-- Postconditions: TeamMembers, Team tables will be clrd
--                 Event will be populated
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Event]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_Event'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0


   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      --Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      --setup
      ----------------------------------------------------------------
      IF dbo.fnFkExists('FK_TeamMembers_Team') = 1 ALTER TABLE TeamMembers DROP CONSTRAINT FK_TeamMembers_Team;
      IF dbo.fnFkExists('FK_Team_Event')       = 1 ALTER TABLE Team        DROP CONSTRAINT FK_Team_Event;

      TRUNCATE TABLE TeamMembers;
      TRUNCATE TABLE Team;
      TRUNCATE TABLE [Event];

      ----------------------------------------------------------------
      --Import text file
      ----------------------------------------------------------------

      EXEC @row_cnt = sp_import_txt_file
          @table           = 'Event'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
            ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      ALTER TABLE TeamMembers WITH CHECK ADD CONSTRAINT FK_TeamMembers_Team FOREIGN KEY(team_id) REFERENCES Team (team_id);
      ALTER TABLE TeamMembers CHECK CONSTRAINT FK_TeamMembers_Team;
      ALTER TABLE Team WITH CHECK ADD CONSTRAINT FK_Team_Event FOREIGN KEY(event_id)REFERENCES Event (event_id)
      ALTER TABLE Team CHECK CONSTRAINT FK_Team_Event;

      EXEC sp_log 1, @fn, '399: finished importing file: ',@file,'';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      ALTER TABLE TeamMembers WITH CHECK ADD CONSTRAINT FK_TeamMembers_Team FOREIGN KEY(team_id) REFERENCES Team (team_id);
      ALTER TABLE TeamMembers CHECK CONSTRAINT FK_TeamMembers_Team;
      ALTER TABLE Team WITH CHECK ADD CONSTRAINT FK_Team_Event FOREIGN KEY(event_id)REFERENCES Event (event_id)
      ALTER TABLE Team CHECK CONSTRAINT FK_Team_Event;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from',@file;
END
/*
EXEC sp_Import_Event 'D:\Dorsu\Data\Events.Events.txt', 1;
SELECT * FROM Event;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Description: Imports the Major table from a tsv
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 25-Feb-2025
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Major]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_Major'
      ,@tab       NCHAR(1)    = NCHAR(9)
      ,@row_cnt   INT         = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'Major'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '020: starting, file: ',@file,'';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC sp_Import_Major 'D:\Dorsu\Courses\Majors.Majors.txt';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Description: Imports theRoom table from a tsv
--
-- Notes: Will truncate table ClassSchedule
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 25-Feb-2025
-- Preconditions: related FKs have been dropped
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Room]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_Room'
      ,@tab       NCHAR(1)    = NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'Room'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC sp_Import_Room 'D:\Dorsu\Data\Rooms.rooms.txt';
EXEC tSQLt.Run 'test.test_003_sp_Import_Room';
SELECT * FROM Room;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Description: Imports theSection table from a tsv
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 25-Feb-2025
-- Preconditions: related FKs have been dropped
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Section]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_Section'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------
      TRUNCATE TABLE ClassSchedule;

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'Section'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '399: finished importing file: ',@file,'';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      --EXEC sp_create_FKs 'Section';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from',@file;
END
/*
EXEC sp_Import_Section 'D:\Dorsu\Courses\Sections.Sections.txt';
EXEC sp_importAllStudentCourses;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ========================================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if a is not less than b
--              or if Either is NULL
-- ========================================================
CREATE PROCEDURE [dbo].[sp_assert_less_than]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT            = 53503
      ,@state     INT            = 1
AS
BEGIN
   IF dbo.fnIsLessThan(@a ,@b) = 1
      RETURN 0;

   -- ASSERTION: if here then mismatch
   EXEC sp_raise_exception
          @msg1   = @msg
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
END;
/*
EXEC tSQLt.Run 'test.test_044_sp_assert_less_than';
EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 08-APR-2020
-- Description: Raises exception if a is less than b
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_gtr_than_or_equal]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)  = NULL
      ,@msg2      NVARCHAR(200)  = NULL
      ,@msg3      NVARCHAR(200)  = NULL
      ,@msg4      NVARCHAR(200)  = NULL
      ,@msg5      NVARCHAR(200)  = NULL
      ,@msg6      NVARCHAR(200)  = NULL
      ,@msg7      NVARCHAR(200)  = NULL
      ,@msg8      NVARCHAR(200)  = NULL
      ,@msg9      NVARCHAR(200)  = NULL
      ,@msg10     NVARCHAR(200)  = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT            = 53503
      ,@state     INT            = 1
      ,@fn        NVARCHAR(60)    = N'*'  -- function testing the assertion
AS
BEGIN
   IF dbo.fnIsLessThan(@a ,@b) = 0
      RETURN 0;

   -- ASSERTION: if here then mismatch
      EXEC sp_raise_assert
          @a      = @a
         ,@b      = @b
         ,@msg    = @msg
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@state  = @state
         ,@fn_    = N'ASRT GTR THN OR EQL EQL'
         ,@fn     = @fn -- -- function testing the assertion
END
/*
EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[TeamMembersStaging](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[is_lead] [bit] NULL,
	[team_id] [int] NULL,
	[section_nm] [varchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[TeamStaging](
	[team_id] [varchar](500) NOT NULL,
	[team_nm] [varchar](500) NOT NULL,
	[members] [varchar](500) NOT NULL,
	[github_project] [varchar](500) NULL,
	[section_nm] [varchar](500) NULL,
	[course_nm] [varchar](500) NULL,
	[event_nm] [varchar](500) NULL,
	[team_gc] [varchar](500) NULL,
	[team_url] [varchar](500) NULL,
	[notes] [varchar](500) NULL,
 CONSTRAINT [PK_TeamStaging] PRIMARY KEY CLUSTERED 
(
	[team_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_TeamStaging] UNIQUE NONCLUSTERED 
(
	[team_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================================
-- Description:      Imports Team members
-- Design:           EArtyryiryikrui
-- Tests:            test_017_sp_Import_Teams
-- Author:           Terry Watts
-- Create date:      24-MAR-2025
-- Preconditions:
-- PRE 01: Event table pop

-- Postconditions:
--
--                   POST02: TeamStaging, Team, TeamMembers pop
--                   POST03: any Student is only ever a member of 0 or 1 teams
--                   POST04: Minimum/max team member count chd
--                   POST05: @min_tm_mbr_cnt > 0
--                   POST06: @max_tm_mbr_cnt > min_tm_mbr_cnt
-- ===========================================================================
CREATE PROCEDURE [dbo].[sp_Import_Teams]
    @file            NVARCHAR(600)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@min_tm_mbr_cnt  INT
   ,@max_tm_mbr_cnt  INT
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_Teams'
      ,@team_nm   VARCHAR(50)
      ,@tab       NCHAR(1)    = NCHAR(9)
      ,@row_cnt   INT         = 0
      ,@cnt       INT         = 0
      ,@event_id  INT
   ;
   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [', @file          ,']
folder:        [', @folder        ,']
clr_first:     [', @clr_first     ,']
sep:           [', @sep           ,']
codepage:      [', @codepage      ,']
min_tm_mbr_cnt:[', @min_tm_mbr_cnt,']
max_tm_mbr_cnt:[', @max_tm_mbr_cnt,']
display_tables:[', @display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------
      -- POST01: Event table pop
      EXEC sp_assert_tbl_pop 'Event';
      -- POST04: @min_tm_mbr_cnt > 0
      EXEC sp_assert_less_than 0, @min_tm_mbr_cnt, ' POST04: @min_tm_mbr_cnt > 0';
      -- POST05: @max_tm_mbr_cnt > min_tm_mbr_cnt
      EXEC sp_assert_gtr_than_or_equal @max_tm_mbr_cnt, @min_tm_mbr_cnt, 'POST05: @max_tm_mbr_cnt > min_tm_mbr_cnt';

      ----------------------------
      -- ASSERTION Validation OK
      ----------------------------

      ----------------------------
      -- Setup
      ----------------------------
      DELETE FROM TeamMembersStaging;
      DELETE FROM TeamMembers;
      DELETE FROM Team;

      ----------------------------
      -- ASSERTION: Event found, TeamMembers, Team clrd
      ----------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: calling  sp_import_txt_file ''TeamStaging'', ''', @file, ''', @codepage=65001, @display_table=1;';

      EXEC @row_cnt = sp_import_txt_file
          @table           = 'TeamStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      --EXEC @row_cnt = sp_import_txt_file  'TeamStaging', @file, @codepage=65001, @display_table=@display_tables;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '020: populating the Team table';

      -- Copy to the main table: Teams
      INSERT INTO Team(team_id, team_nm, github_project, section_id, event_id, team_gc, team_url)
      SELECT team_id, team_nm, github_project, section_id, e.event_id, team_gc, team_url
      FROM
         TeamStaging ts 
         LEFT JOIN Event   e ON e.event_nm   = ts.event_nm
         LEFT JOIN section s ON s.section_nm = ts.section_nm
--       Left JOIN Course  c ON c.course_nm =  ts.course_nm
      ;

      IF @display_tables = 1
      BEGIN
         SELECT 'Team table';
         SELECT * FROM Team;
      END

      -- Fixup the team members:
      EXEC sp_log 1, @fn, '030: populating the TeamMembers table';
      INSERT INTO TeamMembersStaging(team_id, student_nm, student_id, is_lead, section_nm)
      SELECT team_id, [value], s.student_id, IIF(ordinal=1, 1,0), section_nm
      FROM TeamStaging ts CROSS APPLY STRING_SPLIT(members, ';', 1)
      LEFT JOIN Student s ON s.student_nm = [value]
      WHERE [value]<>''
      ;

      EXEC sp_log 1, @fn, '040: processing students names not found';
      SELECT * FROM TeamMembersStaging;

      ---------------------------------------------------------
      -- Ensure all student ids found
      ---------------------------------------------------------
      EXEC sp_log 2, @fn, '055: chking all student ids found ';

      IF EXISTS
      (
         SELECT 1 
         FROM TeamMembersStaging 
         WHERE student_id IS NULL
      ) THROW 50623, 'sp_Import_Teams: Not all students found in student table', 1;

      ---------------------------------------------------------
      -- ASSERTION all student ids found
      ---------------------------------------------------------

      IF EXISTS (SELECT 1 FROM TeamMembersStaging WHERE student_id IS NULL )
         EXEC sp_raise_exception 65000, @fn, 'failed: TeamMembersStaging student_nm column has erros, was not able to match all student nms to ids';

      EXEC sp_log 1, @fn, '070: popping  TeamMembers';

      INSERT INTO TeamMembers(team_id, student_nm, student_id, is_lead)
      SELECT team_id, student_nm, student_id, is_lead
      FROM TeamMembersStaging;

      IF @display_tables = 1
         SELECT * FROM TeamMembers;

      -------------------------------------------------------
      -- Check Postconditions
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '080: Check Postconditions';
      -- POST01: TeamStaging, Team, TeamMembers pop
      EXEC sp_assert_tbl_pop 'TeamStaging';
      EXEC sp_assert_tbl_pop 'Team';

      -- POST02: Student only member of 1 team
      -- chd by UQ on the TeamMember table
      -- POST03: Minimum team member count chkd
      EXEC sp_log 1, @fn, '090: Check POST03: Minimum';

      SELECT 
          @cnt     = COUNT(*)
         ,@team_nm = team_nm
      FROM TeamMembers tm JOIN Team t ON tm.team_id = t.team_id
      GROUP BY team_nm
      HAVING COUNT(*) < @min_tm_mbr_cnt
      ;

      IF @cnt IS NOT NULL AND @cnt> 0
         EXEC sp_raise_exception 56301, 'POST03: Min team ',@team_nm,' member count chk failed exp: ',@min_tm_mbr_cnt, ',  @cnt: ', @cnt;


      -- POST03: Max team member count chkd
      EXEC sp_log 1, @fn, '100: Check POST03: Max';
      SELECT @cnt = COUNT(*), @team_nm = team_nm
            FROM TeamMembers tm JOIN Team t ON tm.team_id = t.team_id
            GROUP BY team_nm
            HAVING COUNT(*) > @max_tm_mbr_cnt
            ;

      IF @cnt IS NOT NULL AND @cnt> 0
         EXEC sp_raise_exception 56301, 'POST03: Max team ',@team_nm,' member count chk failed: shld be < ', @max_tm_mbr_cnt;

      EXEC sp_log 1, @fn, '300: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC sp_Import_Teams
 @file           ='D:\Dorsu\Data\Teams.Teams.txt'
,@min_tm_mbr_cnt = 2
,@max_tm_mbr_cnt = 5
,@display_tables = 1
;

SELECT
team_nm, course_nm, section_nm, student_id, student_nm, is_lead, position, event_nm
FROM Team_vw WHERE Section_nm IN ('2B','2D') ORDER BY Section_nm, team_nm, is_lead DESC, student_nm;;

EXEC test.test_017_sp_Import_Teams;
EXEC tSQLt.Run 'test.test_017_sp_Import_Teams';
EXEC tSQLt.RunAll;
SELECT * FROM TeamMembersStaging where student_id IS NULL;
SELECT * FROM TeamStaging order by team_id;
SELECT * FROM dbo.fnGetTeamMembers('Team Albert& Friends');

EXEC sp_FindStudent2 'Francisco, Hanney';
EXEC sp_FindStudent2 'Liza';
EXEC sp_FindStudent2 'Jay Bee';
EXEC sp_FindStudent2 'Esperanza, Kaye';
EXEC sp_FindStudent2 'Dumandan, Jhonalyn';
EXEC sp_FindStudent2 'Maynagcot, Kristine';
EXEC sp_FindStudent2 'Vidal, Francine Mae';

EXEC sp_FindStudent2 'Balucanag, John Laurence';
EXEC sp_FindStudent2 'Floren, Jhelaisy Joy';
EXEC sp_FindStudent2 'Galladora, Jan Mayen';
EXEC sp_FindStudent2 'Masinaring, Geremiah';
EXEC sp_FindStudent2 'Alaba, Jake';
EXEC sp_FindStudent2 'Nierra, Michelle';
EXEC sp_FindStudent2 'Banzawan, Jamaica';
EXEC sp_FindStudent2 'Madanlo, Romel';

EXEC sp_FindStudent2 'Burgos, Christopher Jr. A..';
EXEC sp_FindStudent2 'Abelgas, Reymund';
EXEC sp_FindStudent2 'Bungaos, Jellian';
EXEC sp_FindStudent2 'Espe, Niño';
EXEC sp_FindStudent2 'Sarda, Jemar Lhoyd';
EXEC sp_FindStudent2 'Mondia, John Jefferson';
EXEC sp_FindStudent2 'Masungcad, Jennifer';
EXEC sp_FindStudent2 'Labajo, Rashelle';
EXEC sp_FindStudent2 'Lindo, Sheryl';
EXEC sp_FindStudent2 'Cubelo, Nicimel Grace';

EXEC sp_FindStudent2 'Pilapil, April';
EXEC sp_FindStudent2 'Labaco, Del Junry';
EXEC sp_FindStudent2 'Candia, Yzalyn';
EXEC sp_FindStudent2 'Jay, Bee';
EXEC sp_FindStudent2 'Labajo, Sunshine';
EXEC sp_FindStudent2 'Bentayao, Jezabel';

EXEC sp_FindStudent2 'Filtro, Rosheille';
EXEC sp_FindStudent2 'Gomez, Irene';
EXEC sp_FindStudent2 'Bongcaron, Lei heart';
EXEC sp_FindStudent2 'Bello, Glydel Jade';
EXEC sp_FindStudent2 'Sandayan, Stefhamel';
EXEC sp_FindStudent2 'Estopito, April';


EXEC sp_FindStudent2 'John Kenneth Gade'
EXEC sp_FindStudent2 'Ivan Vasay'
EXEC sp_FindStudent2 'Kissy Faith M. Candia'
EXEC sp_FindStudent2 'Leopoldo Dumadangon'
EXEC sp_FindStudent2 'Christian Jay Barbas'
EXEC sp_FindStudent2 'James Bernard Verdeflor'
EXEC sp_FindStudent2 'Richard Fuertes'
EXEC sp_FindStudent2 'Jomari Gamao'
EXEC sp_FindStudent2 'Rudelito Dongiapon'
EXEC sp_FindStudent2 'Jhon Ryan Pagantian'
EXEC sp_FindStudent2 'Sitti Monera F. Martin'
EXEC sp_FindStudent2 'Honey Jane P. Pangasate'
EXEC sp_FindStudent2 'Kyle Alonzo'
EXEC sp_FindStudent2 'Jemar Carlos'
EXEC sp_FindStudent2 'ALonzo'
EXEC sp_FindStudent2 'Rudelito Dongiapon'
SELECT * FROM TeamMembersStaging where student_id IS NULL;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[TableInfo](
	[table_name] [varchar](50) NOT NULL,
	[row_cnt] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================
-- Description: list the tables and their counts in dbo
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 30-MAY-2025
-- ==========================================================
CREATE PROC [dbo].[sp_ListTables]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn  VARCHAR(35) = 'sp_ListTables'
      ,@sql VARCHAR(8000)
   ;

   EXEC sp_log 1, @fn, '000: starting';
   TRUNCATE TABLE TableInfo;

   PRINT 'TRUNCATE TABLE TableInfo;';

   SELECT CONCAT('INSERT INTO TableInfo(table_name, row_cnt)
 SELECT ''',TABLE_NAME,''', COUNT(*)
 FROM [', TABLE_NAME,'];') AS [sql]
   FROM [INFORMATION_SCHEMA].[TABLES] 
   WHERE TABLE_SCHEMA='dbo' AND TABLE_TYPE='BASE TABLE'
   ;
   PRINT 'SELECT * FROM TableInfo ORDER BY row_cnt;';

   EXEC sp_log 1, @fn, '000: leaving';
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: Imports the entire schema
-- Design:      
-- Tests:       test_001_sp__import_Schema, test_061_sp__import_Schema
-- Author:      Terry Watts
-- Create date: 25-Feb-2025
-- =============================================
CREATE PROCEDURE [dbo].[sp__import_Schema]
    @root            VARCHAR(500) ='D:\Dorsu\Data'
   ,@display_tables  BIT  = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn           VARCHAR(35)  = 'sp__import_Schema'
      ,@file         VARCHAR(500)
      ,@folder       VARCHAR(500)
      ,@backslash    VARCHAR(2) = CHAR(13) + CHAR(10)
      ;

   EXEC sp_log 1, @fn, '000: starting
@root          :[', @root          , ']
@display_tables:[', @display_tables, ']
';

   BEGIN TRY
      --------------------------------------------------------
      -- Defaults
      --------------------------------------------------------

      --------------------------------------------------------
      -- VALIDATION
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validating';

      --------------------------------------------------------
      -- Process
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '030: process';

      -- Drop all constraints ahead of the data import and clear tables
      -- and clr the table data
      EXEC sp_delete_tbls;

      --------------------------------------------------------
      -- Import Major
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '040: calling sp_Import_Major ',@file;
      EXEC sp_Import_Major @file='Majors.Majors.txt', @folder = @root, @display_tables = @display_tables;

      --------------------------------------------------------
      -- Import Room
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '050: calling sp_Import_Room ',@file;
      EXEC sp_Import_Room @file='Rooms.Rooms.txt', @folder = @root, @display_tables = @display_tables;

      --------------------------------------------------------
      -- Import Course
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '060: calling sp_Import_Course ''Courses.Courses.txt''';
      EXEC sp_Import_Course 
          @file= 'Courses.Courses.txt'
         ,@folder = @root
      ;

      IF @display_tables = 1 SELECT * FROM Course ORDER BY course_nm;

      --------------------------------------------------------
      -- Import Section
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '070: calling sp_Import_Section ', @file;
      EXEC sp_Import_Section @file = 'Sections.Sections.txt', @folder = @root, @display_tables = @display_tables;

      IF @display_tables = 1
         SELECT * FROM Section ORDER BY section_nm;

      ----------------------------------------------------------
      -- ASSERTION:  popd
      ----------------------------------------------------------

      --------------------------------------------------------
      -- Import Students and Enrollments
      --------------------------------------------------------
      SET @folder = CONCAT(@root,'\','Students')
      EXEC sp_log 1, @fn, '080: calling sp_import_All_Enrollments ', @folder;
      EXEC sp_import_All_Enrollments @folder;

      --ALTER TABLE [dbo].[Student] ENABLE TRIGGER [sp_student_insert_trigger];

      --------------------------------------------------------
      -- Import Class schedule - time table data
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '090: calling sp_Import_ClassSchedule';

      EXEC sp_Import_ClassSchedule 
             @file            = 'Class Schedule.Schedule 250317.txt'
            ,@folder          = @root
            ,@display_tables  = @display_tables
            ,@exp_row_cnt     = 19
           ;

      EXEC sp_log 1, @fn, '100: ret frm sp_Import_ClassSchedule';
      SELECT * FROM ClassSchedule;

      --------------------------------------------------------
      -- Import GoogleNames
      --------------------------------------------------------
      SET @folder =  CONCAT(@root,'\','GoogleAliases');
      EXEC sp_log 1, @fn, '110: calling sp_Import_All_GoogleAliases ', @folder;

      EXEC sp_Import_All_GoogleAliases
          @folder          = @folder
         ,@display_tables  = @display_tables

      IF @display_tables = 1
      BEGIN
         SELECT * FROM Student ORDER BY student_nm;
         --SELECT * FROM StudentCourses_vw ORDER BY student_nm;
      END

      --------------------------------------------------------
      --  Import Event
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '120: calling sp_Import_Event ', @file;
      EXEC sp_Import_Event @file = 'Events.Events.txt', @folder = @root, @display_tables = @display_tables;

      --------------------------------------------------------
      --  Import Team
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '130: calling sp_Import_Teams ''Teams.Teams.txt''';
      --EXEC sp_Import_Teams @file = 'Teams.Teams.txt', @folder = 'D:\Dorsu\data', @min_tm_mbr_cnt=1, @max_tm_mbr_cnt= 6, @display_tables = 1;

      EXEC sp_Import_Teams @file = 'Teams.Teams.txt', @folder = 'D:\Dorsu\data', @min_tm_mbr_cnt=1, @max_tm_mbr_cnt= 6, @display_tables = 1;

      --------------------------------------------------------
      --  Import Users Roles Features
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '140: calling sp_ImportAuthUserRoleFeature ', @file;
      EXEC sp_Import_All_AuthUserRoleFeature @folder = @root, @file_mask = '*.txt', @display_tables = @display_tables;

      --------------------------------------------------------
      --  Import Attendance
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '150: importing Attendance, @root: [', @root, '] @mask = Attendance Record Main*.txt';
      EXEC sp_Import_All_Attendance @folder = @root, @mask = 'Attendance Record Main*.txt', @display_tables = @display_tables;

      --------------------------------------------------------
      --  Import GMeet2 Files
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '160: Importing the GMeet2 Files: ';
      SET @folder = CONCAT(@root, '\Attendance\GoogleMeetAttendance\Staging');
      EXEC sp_Import_All_GMeet2FilesInFolder
          @folder         = @folder
         ,@file_mask      = '*.csv'
         ,@display_tables = @display_tables
      ;

      --------------------------------------------------------
      -- Recreate the constraints once all data imported
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '200: recreating constraints';
      EXEC sp_create_FKs;

            --------------------------------------------------------
      -- Chking postconditions
      --------------------------------------------------------
      EXEC sp_ListTables;

      EXEC sp_log 1, @fn, '210: Chking postconditions';
      EXEC sp_assert_tbl_pop 'Attendance';
      EXEC sp_assert_tbl_pop 'AttendanceDates';
      --EXEC sp_assert_tbl_pop 'AttendanceGMeet2';
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2Staging';
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2StagingHdr';
      EXEC sp_assert_tbl_pop '[AttendanceStaging';
      EXEC sp_assert_tbl_pop 'AttendanceStagingColMap';
      EXEC sp_assert_tbl_pop 'AttendanceStagingCourseHdr';
      EXEC sp_assert_tbl_pop 'AttendanceStagingHdr';
      EXEC sp_assert_tbl_pop 'ClassSchedule';
      EXEC sp_assert_tbl_pop 'ClassScheduleStaging';
      EXEC sp_assert_tbl_pop 'Course';
      EXEC sp_assert_tbl_pop 'Enrollment'
      EXEC sp_assert_tbl_pop 'Enrollmentstaging'
      EXEC sp_assert_tbl_pop 'Event';
      EXEC sp_assert_tbl_pop 'Feature';
      EXEC sp_assert_tbl_pop 'GoogleAlias';
      EXEC sp_assert_tbl_pop 'Major';
      EXEC sp_assert_tbl_pop 'Role';
      EXEC sp_assert_tbl_pop 'RoleFeature';
      EXEC sp_assert_tbl_pop 'Room';
      EXEC sp_assert_tbl_pop 'Section';
      EXEC sp_assert_tbl_pop 'Student';
      EXEC sp_assert_tbl_pop 'StudentStaging';
      EXEC sp_assert_tbl_pop 'TeamStaging';           -- *******
      EXEC sp_assert_tbl_pop 'Team';                  -- *******
      EXEC sp_assert_tbl_pop 'TeamMembersStaging';    -- *******
      EXEC sp_assert_tbl_pop 'TeamMembers';           -- *******
      EXEC sp_assert_tbl_pop 'User';
      EXEC sp_assert_tbl_pop 'UserRole';

      --------------------------------------------------------
      -- Optionally display the table
      --------------------------------------------------------
      IF @display_tables = 1
      BEGIN
         SELECT * FROM Major;
         SELECT * FROM Section;
         SELECT * FROM Course;
         SELECT * FROM ClassSchedule;
      END

            --------------------------------------------------------
      -- ASSERTION: completed processing
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '399: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
 --   EXEC sp_create_FKs;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving';
END
/*
EXEC tSQLt.Run 'test_001_sp__import_Schema';
EXEC tSQLt.Run 'test_061_sp__import_Schema';

EXEC sp__import_Schema 'D:\Dorsu\Data', 1;

EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 03-APR-2020
-- Description: Inserts a log row in the app log
--
--              Splits into column based on tabs in the the message or 

   -- set @tmp = LEFT(CONCAT(REPLICATE( '  ', @sf), REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
   -- set @tmp = LEFT(CONCAT( REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
-- =============================================
CREATE PROCEDURE [dbo].[sp_appLog_display]
    @rtns   VARCHAR(MAX) = NULL -- like 'dbo.fnA,test.sp_b'
   ,@msg    VARCHAR(4000)= NULL     -- no %%
   ,@level  INT          = NULL
   ,@id     INT          = NULL -- starting id
   ,@dir    BIT          = 1 -- ASC
AS
BEGIN
DECLARE
    @fn                 VARCHAR(35)   = N'sp_appLog_display '
   ,@sql                VARCHAR(4000)
   ,@need_where         BIT = 0
   ,@nl                 VARCHAR(2)   = CHAR(13) + CHAR(10)
   ,@fns                IdNmTbl
   ,@s                  VARCHAR(4000)
   ;

   SET NOCOUNT ON;

   INSERT into @fns(val) SELECT value FROM string_split(@rtns,',');
   SELECT @s = string_agg(CONCAT('''', val, ''''),',') FROM @fns;
--   PRINT(@s);
   SET @need_where = 
      IIF(    @rtns  IS NOT NULL
           OR @level IS NOT NULL
           OR @id    IS NOT NULL
           OR @msg   IS NOT NULL
           ,1, 0);

   SET @sql = CONCAT(
'SELECT
  id
,[level]
,rtn AS [rtn',   REPLICATE('_',20), ']
,SUBSTRING(msg, 1  , 128) AS ''msg1', REPLICATE('_',100), '''
,SUBSTRING(msg, 129, 128) AS ''msg2', REPLICATE('_',100), '''
,SUBSTRING(msg, 257, 128) AS ''msg3', REPLICATE('_',100), '''
,SUBSTRING(msg, 385, 128) AS ''log4', REPLICATE('_',100), '''
FROM AppLog
'
,iif(@need_where= 0, '', CONCAT('WHERE '                                                            , @nl))
,iif(@rtns  IS NULL, '', CONCAT(' rtn IN (', @s, ')'                                                , @nl))
,iif(@msg   IS NULL, '', CONCAT(IIF(@rtns IS NULL                   ,'', ' AND'),' msg LIKE (''%', @msg, '%'')'         , @nl))
,iif(@level IS NULL, '', CONCAT(IIF(@rtns IS NULL                   ,'', ' AND'),' level = ', @level, @nl))
,iif(@id    IS NULL, '', CONCAT(IIF(@rtns IS NULL AND @level IS NULL,'', ' AND'),' id >= '  , @id   , @nl))
,'ORDER BY ID ', iif(@dir=1, 'ASC','DESC'), ';'
);

 --  PRINT CONCAT(@fn, '100: executing sql:', @sql);
   EXEC (@sql);

/*   IF dbo.fnGetLogLevel() = 0
      PRINT CONCAT( @fn,'999: leaving:');*/
END
/*
EXEC tSQLt.RunAll;

EXEC sp_appLog_display;
EXEC sp_appLog_display @rtns='S2_UPDATE_TRIGGER',@msg='@fixup_row_id: 4'
EXEC sp_appLog_display @id=140;
000: starting @fixup_row_id: 4, @imp_file_nm: [ImportCorrections_221018-Crops.txt], @fixup_stg_id: 4, @search_clause: [ agricult
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 28-APR-2025
-- Description: assert the given file exists or throws exception @ex_num* 'the file[<@file>] does not exist', @state
-- * if @ex_num default: 53200, state=1
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_folder_exists]
    @folder    VARCHAR(500)
   ,@msg1      VARCHAR(200)   = NULL
   ,@msg2      VARCHAR(200)   = NULL
   ,@msg3      VARCHAR(200)   = NULL
   ,@msg4      VARCHAR(200)   = NULL
   ,@msg5      VARCHAR(200)   = NULL
   ,@msg6      VARCHAR(200)   = NULL
   ,@msg7      VARCHAR(200)   = NULL
   ,@msg8      VARCHAR(200)   = NULL
   ,@msg9      VARCHAR(200)   = NULL
   ,@msg10     VARCHAR(200)   = NULL
   ,@msg11     VARCHAR(200)   = NULL
   ,@msg12     VARCHAR(200)   = NULL
   ,@msg13     VARCHAR(200)   = NULL
   ,@msg14     VARCHAR(200)   = NULL
   ,@msg15     VARCHAR(200)   = NULL
   ,@msg16     VARCHAR(200)   = NULL
   ,@msg17     VARCHAR(200)   = NULL
   ,@msg18     VARCHAR(200)   = NULL
   ,@msg19     VARCHAR(200)   = NULL
   ,@msg20     VARCHAR(200)   = NULL
   ,@ex_num    INT             = 53200
   ,@fn        VARCHAR(60)    = N'*'
AS
BEGIN
   DECLARE
    @fn_       VARCHAR(35)   = N'ASSERT_FOLDER_EXISTS'
   ,@msg       VARCHAR(MAX)
   ,@ret       INT

   EXEC sp_log 1, @fn_, '000: checking folder [', @folder, '] exists';

   EXEC @ret = dbo.sp_FolderExists @folder;

   IF @ret = 1
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log 1, @fn, '010: OK,folder [',@folder,'] exists';
      RETURN 1;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   SET @msg = CONCAT('Folder [',@folder,'] does not exist');
   EXEC sp_log 3, @fn, '020:', @msg, ' raising exception';

   EXEC sp_raise_exception
       @ex_num = @ex_num
      ,@msg1   = @msg
      ,@msg2   = @msg1
      ,@msg3   = @msg2 
      ,@msg4   = @msg3 
      ,@msg5   = @msg4 
      ,@msg6   = @msg5 
      ,@msg7   = @msg6 
      ,@msg8   = @msg7 
      ,@msg9   = @msg8 
      ,@msg10  = @msg9 
      ,@msg11  = @msg10
      ,@msg12  = @msg11
      ,@msg13  = @msg12
      ,@msg14  = @msg13
      ,@msg15  = @msg14
      ,@msg16  = @msg15
      ,@msg17  = @msg16
      ,@msg18  = @msg17
      ,@msg19  = @msg18
      ,@msg20  = @msg19
      ,@fn     = @fn
   ;
END
/*
EXEC sp_assert_folder_exists 'non existant file', ' second msg',@fn='test fn', @state=5  -- expect ex: 53200, 'the file [non existant file] does not exist', ' extra detail: none', @state=1, @fn='test fn';
EXEC sp_assert_folder_exists 'C:\bin\'   -- expect OK
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: asserts that a is greater than b
--              raises an exception if not
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_gtr_than]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       VARCHAR(200)  = NULL
      ,@msg2      VARCHAR(200)  = NULL
      ,@msg3      VARCHAR(200)  = NULL
      ,@msg4      VARCHAR(200)  = NULL
      ,@msg5      VARCHAR(200)  = NULL
      ,@msg6      VARCHAR(200)  = NULL
      ,@msg7      VARCHAR(200)  = NULL
      ,@msg8      VARCHAR(200)  = NULL
      ,@msg9      VARCHAR(200)  = NULL
      ,@msg10     VARCHAR(200)  = NULL
      ,@msg11     VARCHAR(200)  = NULL
      ,@msg12     VARCHAR(200)  = NULL
      ,@msg13     VARCHAR(200)  = NULL
      ,@msg14     VARCHAR(200)  = NULL
      ,@msg15     VARCHAR(200)  = NULL
      ,@msg16     VARCHAR(200)  = NULL
      ,@msg17     VARCHAR(200)  = NULL
      ,@msg18     VARCHAR(200)  = NULL
      ,@msg19     VARCHAR(200)  = NULL
      ,@msg20     VARCHAR(200)  = NULL
      ,@ex_num    INT            = 53502
      ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE
       @fnThis VARCHAR(35) = 'sp_assert_gtr_than'
      ,@aTxt   VARCHAR(100)= CONVERT(VARCHAR(100), @a)
      ,@bTxt   VARCHAR(100)= CONVERT(VARCHAR(100), @b)

   EXEC sp_log @log_level, @fnThis, '000: starting @a:[',@aTxt, '] @b:[', @bTxt, ']';

   -- a>b -> b<a 
   IF dbo.fnIsLessThan(@b ,@a) = 1
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fnThis, '010: OK, @a:[',@aTxt, '] IS GTR THN @b:[', @bTxt, ']';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fnThis, '020: [',@aTxt, '] IS GTR THN [', @bTxt, '] IS FALSE, raising exception';

   EXEC sp_raise_exception
          @msg1   = @msg
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@fn     = @fn
   ;
END
/*
EXEC sp_assert_gtr_than 4, 5;
EXEC sp_assert_gtr_than 5, 4;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_055_sp_assert_gtr_than';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if a is not <= b
-- ===============================================
CREATE PROCEDURE [dbo].[sp_assert_less_than_or_equal]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT             = 50001
      ,@state     INT             = 1
      ,@fn        NVARCHAR(60)    = N'*'  -- function testing the assertion
AS
BEGIN
   IF dbo.fnIsLessThan(@a ,@b) = 1
      RETURN 0;

   IF dbo.fnChkEquals(@a ,@b) = 1
      RETURN 0;

   -- ASSERTION: if here then mismatch
      EXEC sp_raise_exception
             @msg1   = @msg
            ,@msg2   = @msg2
            ,@msg3   = @msg3
            ,@msg4   = @msg4
            ,@msg5   = @msg5
            ,@msg6   = @msg6
            ,@msg7   = @msg7
            ,@msg8   = @msg8
            ,@msg9   = @msg9
            ,@msg10  = @msg10
            ,@msg11  = @msg11
            ,@msg12  = @msg12
            ,@msg13  = @msg13
            ,@msg14  = @msg14
            ,@msg15  = @msg15
            ,@msg16  = @msg16
            ,@msg17  = @msg17
            ,@msg18  = @msg18
            ,@msg19  = @msg19
            ,@msg20  = @msg20
            ,@ex_num = @ex_num
            ;
END
/*
EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is NULL
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_null]
       @val       SQL_VARIANT
      ,@msg1      NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT             = 50001
AS
BEGIN
   DECLARE @fn NVARCHAR(60)    = N'sp_assert_not_null';
   EXEC sp_log 0, @fn, '000 starting';

   IF (@val IS NULL)
   BEGIN
      EXEC sp_log 4, @fn, 'value is NULL - raising exception ', @ex_num;
      -- ASSERTION: if here then is NULL -> error
      EXEC sp_raise_exception
          @msg1   = @msg1
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ;
   END

   EXEC sp_log 0, @fn, '999: OK';
END
/*
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================================
-- Author:      Terry Watts
-- Create Date: 14-JUN-2025
-- Description: assert the table exists
-- Parameters:
--    @table to check if existscan be qualified
--    @exp_exists if 1 asserts @table exists else asserts @table does not exist
-- Returns      1 if exists
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_exists]
    @table_nm        VARCHAR(100)
   ,@exp_exists      BIT         = 1
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)   = N'sp_assert_tbl_exists'
   ,@sql             NVARCHAR(MAX)
   ,@act_exists      BIT
   ,@schema_nm       VARCHAR(50)
   ,@msg             VARCHAR(100)
   ,@nm_has_spcs     BIT
   ;

   SET NOCOUNT ON;
   SET @act_exists =dbo.fnTableExists(@table_nm);
   SET @nm_has_spcs = CHARINDEX(' ', @table_nm);

   IF @act_exists = @exp_exists
   BEGIN
      SET @msg = CONCAT('table ', iif(@nm_has_spcs=1, '[', ''), @table_nm, iif(@nm_has_spcs=1, ']', ''), iif(@exp_exists = 1, ' exists ', 'does not exist'), ' as expected');
      EXEC sp_log 1, @fn, @msg;
   END
   ELSE
   BEGIN -- failed test
      SET @msg = CONCAT('table [', @table_nm, iif(@exp_exists = 1, '] does not exist but should', 'exists but should not'));
      EXEC sp_raise_exception 50001, @msg, @fn=@fn;
   END

   RETURN 1;
END
/*
EXEC test.test_070_sp_assert_tbl_exists;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FindStudentInfo](
	[srch_cls] [varchar](60) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](60) NULL,
	[gender] [char](1) NULL,
	[section_nm] [varchar](20) NULL,
	[course_nm] [varchar](100) NULL,
	[major_nm] [varchar](20) NULL,
	[match_ty] [int] NULL,
	[pos] [int] NULL,
	[sql] [varchar](3000) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27 APR 2025
-- Description: gets the  first and last words 
--   from a clause excluding Initials with trailing dot
--   used for Dorsu Student Names
-- Design:      none
-- Tests:       test_050_fnGetFirstLastWords
-- =============================================
CREATE FUNCTION [dbo].[fnGetFirstLastWords]
(
    @clause VARCHAR(4000)
   ,@sep    VARCHAR(1))
RETURNS @t TABLE
(
    first_nm VARCHAR(1000)
   ,last_nm VARCHAR(1000)
)
AS
BEGIN
INSERT INTO  @t (first_nm, last_nm)
SELECT
    TRIM(',' FROM X.cls) AS first_nm
   ,TRIM(',' FROM Y.cls) AS last_nm
FROM
(
   SELECT TOP 1
   TRIM(',' FROM value) AS cls
   FROM string_split(@clause, @sep, 1) AS cls
   WHERE value NOT LIKE '%.%'
) X
,
(
   SELECT TOP 1
   TRIM(', ' FROM value) as cls
   FROM string_split(@clause, @sep, 1) AS cls
   WHERE value NOT LIKE '%.%'
   ORDER BY ordinal DESC
) Y;

   RETURN;
END
/*
EXEC test.test_050_fnGetFirstLastWords;
EXEC tSQLt.Run'test.test_050_fnGetFirstLastWords';
EXEC tSQLt.RunAll;

SELECT * FROM dbo.fnGetFirstLastWords('Sitti Monera F. Martin', ' ');
SELECT * FROM dbo.fnGetFirstLastWords('Zaragoza, Princess Ann D.', ' ');
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns 'dbo.fnGetFirstLastWords'
SELECT * FROM student

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================================================================================================
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- Description: Finds a student by likeness 
--              and populates the FindStudentInfo 
-- Design:      EA: Model.Use Case Model.Find student.Find student_ActivityGraph.Find student_ActivityGraph, Model.Conceptual Model.Findstudent
-- Tests:       test_039_spFindStudent
-- Postconditions:
-- POST 01:     Poplated FindStudentInfo with 0,1 or more rows: [student id student nm,gender, section, course, match ty]
-- =============================================================================================================================================
CREATE PROCEDURE [dbo].[sp_FindStudent]
--(
    @student_nm         VARCHAR(60)   = NULL  -- NULL for all students
   ,@gender             VARCHAR(20)   = NULL  -- NULL for all genders
   ,@section_nm         VARCHAR(20)   = NULL  -- NULL for all sections
   ,@course_nm          VARCHAR(60)   = NULL  -- NULL for all courses
   ,@major_nm           VARCHAR(10)   = NULL  -- NULL for all majors
   ,@match_ty           INT           = NULL  -- NULL for all match types
   ,@display_rows       BIT           = 1
--)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn               VARCHAR(35) = 'sp_FindStudent'
     ,@len              INT
     ,@pos              INT         = 0
     ,@cnt              INT
     ,@found            BIT         = 0
     ,@sep_ty           BIT         -- = 0: spc, 1: comma
     ,@cls1             VARCHAR(60)
     ,@cls2             VARCHAR(60)
     ,@nm_part_sql      VARCHAR(1000)
     ,@insert_cls       VARCHAR(1000)
     ,@from_cls         VARCHAR(20) = 'FROM Student_vw s'
     ,@where_cls        VARCHAR(1000)
     ,@filter_cls       VARCHAR(1000)
     ,@main_sql         VARCHAR(4000)
     ,@Line             VARCHAR(100)= REPLICATE('-', 100)
     ,@NL               CHAR(2)     = CHAR(13) + CHAR(10)
     ,@need_where_cls   BIT =1
     ,@sep_chr          CHAR(1)
   ;

   EXEC sp_log 1, @fn, '000 starting
    @student_nm :[',@student_nm,']
   ,@course_nm  :[',@course_nm ,']
   ,@section_nm :[',@section_nm,']
   ,@gender     :[',@gender    ,']
   ,@match_ty   :[',@match_ty  ,']
';

   SET @need_where_cls = 
   iif(@student_nm IS NULL AND @major_nm IS NULL AND @course_nm IS NULL AND @section_nm IS NULL AND @gender IS NULL, 0, 1);

   TRUNCATE TABLE FindStudentInfo;

   -- If no criteria

   IF @match_ty IS NULL SET @match_ty = 4;

   -- Trim the search clause
   SET @student_nm = dbo.fnTrim(@student_nm);

   IF @student_nm IS NOT NULL
   BEGIN
      SET @pos = CHARINDEX(',', @student_nm);
      IF @pos > 0
      BEGIN
         SET @pos = CHARINDEX(',', @student_nm);
         SET @sep_ty = 1; -- 1: comma
         SET @sep_chr= ',';
      END
      ELSE
         SET @sep_ty = 0; -- 0: spc
         SET @sep_chr= ' ';
   END

      ------------------------
   -- Assertion @sep_ty known
   ---------------------------
   WHILE 1=1
   BEGIN
      SET @insert_cls = CONCAT('INSERT INTO FindStudentInfo
      (        srch_cls    ,student_id ,student_nm ,gender, section_nm ,course_nm, major_nm, match_ty)
   SELECT ''', @student_nm,''',student_id, student_nm, gender, section_nm, courses, major_nm,' --, '    1  '
   );

      -- ASSERTION: @pre_cls needs the match_ty appending later

      -- Build the where clause
      SET @where_cls = iif(@student_nm IS NOT NULL, CONCAT( 'student_nm =''',@student_nm, '''', @NL), NULL);

      SET @filter_cls = 
      CONCAT
      (
       iif( @gender     IS NULL, '', CONCAT( iif(@student_nm IS NOT NULL,'AND ',''),' gender     LIKE ''%', @gender    , '%''', @NL))
      ,iif( @section_nm IS NULL, '', CONCAT( iif(@student_nm IS NOT NULL OR @gender IS NOT NULL,'AND ',''),' section_nm LIKE ''%', @section_nm, '%''', @NL))
      ,iif( @course_nm  IS NULL, '', CONCAT( iif(@student_nm IS NOT NULL OR @gender IS NOT NULL OR @section_nm IS NOT NULL,'AND ',''),' courses    LIKE ''%', @course_nm , '%''', @NL))
      ,iif( @major_nm   IS NULL, '', CONCAT( iif(@student_nm IS NOT NULL OR @gender IS NOT NULL OR @section_nm IS NOT NULL OR @course_nm IS NOT NULL,'AND ',''),' major_nm   LIKE ''%', @major_nm  , '%''', @NL))
      );

      --IF dbo.fnLen(@filter_cls)>0 SET @filter_cls = CONCAT('AND ',@filter_cls);
      --------------------------------------------------------------
      -- Do a type 1 search: exact match on student_nm and criteria
      --------------------------------------------------------------

      -- if no criteria
      exec sp_log 1, @fn, 15, ' @where_cls: [', @where_cls, '], @filter_cls:[',@filter_cls,']';

      SET @main_sql = 
      CONCAT
      (
          @insert_cls
         ,iif(@need_where_cls=1, '1', '0'), @NL
         ,@from_cls, @NL
         ,iif(@need_where_cls=1, CONCAT('WHERE', @NL, @where_cls, @filter_cls), '')
       );

      PRINT CONCAT(@NL,@Line, @NL);
      EXEC sp_log 1, @fn, '020: doing a type 1 search, @sql:', @NL
      , @main_sql, @NL;

      PRINT CONCAT(@Line, @NL);

      EXEC(@main_sql);
      UPDATE FindStudentInfo SET [sql] = @main_sql;

      IF @@ROWCOUNT > 0
      BEGIN
         EXEC sp_log 1, @fn, '030: found type 1: exact match, returning';
         BREAK;
      END

      -------------------------------------------
      -- Assertion type 1 search yielded no rows
      -------------------------------------------
      EXEC sp_log 1, @fn, '035: did not find an exact match';

      -------------------------------------------------
      -- Do a type 2 search:
      -------------------------------------------------
      -- do a search based on splitting the words in the name and doing an AND( a=b or a IS NULL) CNF connective
      SELECT @cnt = COUNT(*) FROM string_split(@student_nm, ',');

      ------------------------------------------------------------------------------
      -- Do a type 2 search: based on comma or spc sep if the search cls has parts
      ------------------------------------------------------------------------------

      IF @cnt > 0
      BEGIN
         -- Get the comma separated name parts and do a CNF filter on them
         ;WITH cte AS
         (
            SELECT CONCAT('%', dbo.fnTrim(value), '%') as cls
            FROM string_split(@student_nm, @sep_chr) AS cls
         )
         SELECT @nm_part_sql = 
         CONCAT
         (
            ' (student_nm LIKE ''', string_agg(cls, ''' AND student_nm LIKE '''), ''')', @NL
         )
         FROM cte
         ;
      END

      --SET @where_cls = iif(@student_nm IS NOT NULL, CONCAT( 'student_nm =''',@student_nm, '''', @NL), NULL);
      --SET @main_sql = CONCAT ( @insert_cls, '2', @NL, @from_cls, @NL, iif(@need_where_cls=1, CONCAT('WHERE', @NL), ''), @filter_cls, @nm_part_sql, @NL,  @filter_cls);
      SET @where_cls = iif(@student_nm IS NOT NULL, @nm_part_sql, '')
      SET @main_sql =
      CONCAT
      (
          @insert_cls
         ,iif(@need_where_cls=1, '2', '2'), @NL
         ,@from_cls, @NL
         ,iif(@need_where_cls=1, CONCAT('WHERE', @NL, @where_cls, @filter_cls), '')
       );

      PRINT CONCAT(@NL,@Line, @NL) ;

      EXEC sp_log 1, @fn, '040: doing a ty 2 search, @sql:', @NL, @main_sql, @NL;
      PRINT CONCAT(@NL,@Line);

      -----------------------------------------------
      EXEC(@main_sql);
      UPDATE FindStudentInfo SET [sql] = @main_sql;

      SET @cnt =  @@ROWCOUNT;
      EXEC sp_log 1, @fn, '050: found ',@cnt, ' rows using ty 2 search';

      IF @cnt> 0
      BEGIN
         EXEC sp_log 1, @fn, '060: found type 2 match';
         BREAK;
      END

      --------------------------------------------------
      -- Do a type 3 search: search based on student id
      --------------------------------------------------

      EXEC sp_log 1, @fn, '070: doing a type 3 search based on student id';
      SET @main_sql = CONCAT (@insert_cls, '3', @NL, @from_cls, @NL, ' WHERE', @NL,'student_id LIKE ''%',@student_nm,'%''');
      PRINT CONCAT(@NL,@Line, @NL);
      EXEC sp_log 1, @fn, '080: doing a ty 3 search, @sql:', @NL, @main_sql, @NL;
      PRINT CONCAT(@NL,@Line);

      -----------------------------------------------
      EXEC(@main_sql);

      UPDATE FindStudentInfo SET [sql] = @main_sql;

      SET @cnt =  @@ROWCOUNT;
      EXEC sp_log 1, @fn, '090: found ',@cnt, ' rows using ty 3 search';

      IF @cnt> 0
      BEGIN
         EXEC sp_log 1, @fn, '100: found type 3 match';
         BREAK;
      END

      ------------------------------------------------------------------------------------
      -- Do a type 4 search: based on first and last parts of the name igmnring initials.
      -- currently no other criteria used
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '110: doing a ty 4 search based on first AND last parts of the name ignoring initials';
      DECLARE
          @first_nm VARCHAR(500)
          ,@last_nm VARCHAR(500)
      ;

      SELECT
         @first_nm = first_nm
        ,@last_nm  = last_nm 
      FROM dbo.fnGetFirstLastWords(@student_nm, ' ');

      SET @main_sql = CONCAT
      (
'INSERT INTO FindStudentInfo
      (srch_cls   ,student_id, student_nm, gender, section_nm, course_nm, major_nm, match_ty)
SELECT student_nm, student_id, student_nm, gender, section_nm, courses  , major_nm, 4
FROM Student_vw
WHERE student_nm LIKE ''%',@first_nm,'%''
AND   student_nm LIKE ''%',@last_nm ,'%''
;'
      );
      PRINT CONCAT(@NL,@Line, @NL);
      EXEC sp_log 1, @fn, '120: doing a ty 4 search, @sql:', @NL, @main_sql, @NL;
      PRINT CONCAT(@NL,@Line);
      --DELETE FROM FindStudentInfo;
      EXEC(@main_sql);
      SET @cnt = @@ROWCOUNT;
      EXEC sp_log 1, @fn, '121: found ',@cnt, ' rows using ty 4 search';
      SELECT @cnt = COUNT(*) FROM FindStudentInfo;
      EXEC sp_log 1, @fn, '122: *** found ',@cnt, ' rows using ty 4 search';

      IF @cnt> 0
      BEGIN
         EXEC sp_log 1, @fn, '140: found type 4 match';
         BREAK;
      END

      ------------------------------------------------------------------------------------
      -- Do a type 5 search: based on first OR last parts of the name igmnring initials.
      -- currently no other criteria used
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '150: doing a ty 5 search based on first OR last parts of the name ignoring initials';

      SET @main_sql = CONCAT
      (
'INSERT INTO FindStudentInfo
      (srch_cls   ,student_id, student_nm, gender, section_nm, course_nm, major_nm, match_ty)
SELECT student_nm, student_id, student_nm, gender, section_nm, courses  , major_nm, 4
FROM Student_vw
WHERE student_nm LIKE ''%',@first_nm,'%''
OR   student_nm LIKE ''%',@last_nm ,'%''
;'
      );

      PRINT CONCAT(@NL,@Line, @NL);
      EXEC sp_log 1, @fn, '120: doing a ty 5 search, @sql:', @NL, @main_sql, @NL;
      PRINT CONCAT(@NL,@Line);
      EXEC(@main_sql);

      SET @cnt = @@ROWCOUNT;
      EXEC sp_log 1, @fn, '050: found ',@cnt, ' rows using ty 5 search';
      SELECT @cnt = COUNT(*) FROM FindStudentInfo;
      EXEC sp_log 1, @fn, '051: *** found ',@cnt, ' rows using ty 5 search';

      IF @cnt> 0
      BEGIN
         EXEC sp_log 1, @fn, '060: found type 5 match';
         BREAK;
      END

      ------------------------------------------------------------------------------------
      -- Not found
      ------------------------------------------------------------------------------------

      EXEC sp_log 3, @fn, '200: ', @student_nm, ' not found';
      INSERT INTO FindStudentInfo
             (srch_cls   ,  gender,  section_nm,  course_nm,  major_nm, match_ty)
      VALUES (@student_nm, @gender, @section_nm, @course_nm, @major_nm, -1)
      ;

      BREAK;
      END -- While 1=1

   /*
   SELECT s.student_id, s.student_nm, s.gender, google_alias, course_nm, section_nm, @major_nm, match_ty
   FROM FindStudentInfo fsi 
   JOIN Student s ON fsi.student_id = s.student_id 
   ORDER BY fsi.student_nm, course_nm, section_nm;
   */

   SELECT @cnt = COUNT(*) FROM FindStudentInfo;

   if @display_rows = 1
      SELECT * FROM FindStudentInfo

   EXEC sp_log 1, @fn, '999 leaving, found ',@cnt , ' rows';
   RETURN @cnt;
END
/*
Martin, Sitti Monera F.
EXEC sp_FindStudent 'Sitti Fernando Martin'
EXEC sp_FindStudent 'Sitti'
EXEC test.test_039_sp_FindStudent;
EXEC tSQLt.Run 'test.test_039_spFindStudent';
EXEC spFindStudent 'Estrera, Jeros Kent A.', NULL, NULL, NULL, NULL;
Pangasate, Honey Jane P.

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[StudentPic](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[url] [varchar](500) NULL,
 CONSTRAINT [PK_StudentPic] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:        Terry Watts
-- Create date:   28-Apr-2025
-- Description:   associate pics with students
--
-- Algorithm:
-- 1. user starts a db proc that gets the all the picture file names for a given folder
-- 2. system loads the picture file names from the folder into a staging table
-- 3. system then try to map the file name to the student
-- 4. this will not always be successful if the Find student algorithm cannot find it
--
-- Design:        EA Associate Photos with students
-- Tests:         test_052_sp_associate_student_pics
--
-- PRECONDITIONS: 
-- PRE01: folder exists (chkd)
-- POSTCONDITIONS:
-- POST 01:if error throws exception ELSE returns the count of files in the folder
-- POST 02 
-- POST 03 
-- POST 04 
-- POST 05 
-- =============================================
CREATE PROCEDURE [dbo].[sp_associate_student_pics]
    @folder    VARCHAR(500)
   ,@clr_first       BIT = 1
   ,@display_tables  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @fn           VARCHAR(35) = 'sp_associate_student_pics'
   ,@sql          VARCHAR(MAX)
   ,@url          VARCHAR(500)
   ,@filename     VARCHAR(100)
   ,@student_id   VARCHAR(9)
   ,@student_nm   VARCHAR(50)
   ,@srch_cls     VARCHAR(50) -- could be FB name, google alias, dorsu stud nm or id
   ,@ret          INT
   ,@file_cnt     INT
   ,@match_cnt    INT
   ,@i            INT         = 0 -- loop index
   ,@n            INT         = 0 -- loop index
   ,@delta        INT
   ,@status       INT
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000 sarting:
folder :       [', @folder        ,']
clr_first:     [', @clr_first     ,']
display_tables:[', @display_tables,']
';
   ------------------------------------------------
   -- Validate inputs
   ------------------------------------------------
      -- PRE01: folder exists (chkd)
      EXEC sp_assert_folder_exists @folder;

      ------------------------------------------------
      -- Process
      ------------------------------------------------
      IF @clr_first = 1
      BEGIN
         EXEC sp_log 1, @fn, '020 truncating the StudentPic table';
         TRUNCATE TABLE StudentPic;
      END

      -- 1. user starts a db proc that gets the all the picture file names for a given folder
      -- 2. system loads the picture file names from the folder into a staging table
      -- list all the files picture files -m the folder dir *.jp*,*.png, *.bmp
      EXEC sp_log 1, @fn, '030 getting the list of picture files in folder: ', @folder;
      EXEC @file_cnt = sp_getFilesInFolder @folder, '*.jp*', 0, 1; -- disp tbls, clr first
      EXEC @delta    = sp_getFilesInFolder @folder, '*.png', 1, 0; -- disp tbls, not clr first
      SET  @file_cnt = @file_cnt + @delta;
      EXEC sp_getFilesInFolder @folder, '*.bmp', 0, 0; -- disp tbls, not clr first
      SET  @file_cnt = @file_cnt + @delta;
      EXEC sp_log 1, @fn, '040 found ',@file_cnt,' picture files in ', @folder;
      SELECT *  FROM Filenames;

      --cursor loop
      DECLARE c1 CURSOR FOR
         SELECT [file]
         FROM Filenames
--         WHERE [file] like '%.txt'
         ORDER BY [file]
      ;

      OPEN c1;
      FETCH NEXT FROM c1 INTO @filename;
      SET @status =  @@fetch_status

      EXEC sp_log 1, @fn ,'050: B4 mn process loop, @status: ',@status;
      WHILE @@fetch_status <> -1
      BEGIN
         SET @i = @i + 1;
         -- pop the staging table
         SET @url = CONCAT(@folder, CHAR(92), @filename);
         SET @srch_cls = @filename;
         EXEC sp_log 1, @fn ,'060: top of mn process loop, file [', @i,']: [', @filename, '], @url:[',@url,']';

         -- extract student alais  
         -- examples: Albert Velasco 2.jpeg, Gella Marie Elayde Loguinsa.jpeg
         SET @n =  CHARINDEX('.', @filename);
         SET @srch_cls = SUBSTRING(@filename, 1, @n-1);
         EXEC sp_log 1, @fn ,'070: @srch_cls: [',@srch_cls, '], @n: ',@n;
         EXEC sp_assert_not_equal 0, @n, ' 075 error @n = 0';

         -- remove any numbers
         SET @srch_cls = dbo.Regex_Replace(@srch_cls, '[0-9]', '')
         EXEC sp_log 1, @fn ,'071: @srch_cls: [',@srch_cls, ']';

         -- 3. try to map each file name to the student
         EXEC @match_cnt =sp_FindStudent @srch_cls;
         EXEC sp_log 1, @fn ,'072: @match_cnt: [', @match_cnt, ']';
         --throw 50000, 'DEBUG', 1

         -- 4. this will not always be successful if the Find student algorithm cannot find it
         IF @match_cnt = 0
         BEGIN
            EXEC sp_log 1, @fn ,'080: failed to match [', @srch_cls, '] to a student';
         END

         IF @match_cnt = 1
         BEGIN
            SELECT
                @student_id = student_id
               ,@student_nm = student_nm
            FROM FindStudentInfo

            EXEC sp_log 1, @fn ,'090: found student: [', @srch_cls, ']-> ', @student_id, ' ', @student_nm;
            INSERT INTO StudentPic(student_id, student_nm, url)
            VALUES( @student_id, @student_nm, @url);

            --THROW 50000, 'DEBUG', 1;
         END

         IF @match_cnt > 1
         BEGIN
            EXEC sp_log 1, @fn ,'080: found multiple matches match [', @srch_cls, '] to a student';
         END

         FETCH NEXT FROM c1 INTO @filename;
      END -- while files loop

      EXEC sp_log 1, @fn ,'050:done mn loop';
      CLOSE c1;
      DEALLOCATE c1;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      CLOSE c1;
      DEALLOCATE c1;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, processed ', @file_cnt, ' files';
   RETURN @file_cnt;
END
/*
EXEC tSQLt.Run 'test.test_052_sp_associate_student_pics';
EXEC tSQLt.RunAll;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
-- Description: creates a relationship
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 07-MAR-2025
--
-- PRECONDITIONS:
-- PRE 01 @fk_nm        NOT NULL or EMPTY
-- PRE 02 @f_table_nm   NOT NULL or EMPTY
-- PRE 03 @col_nm NOT   NULL or EMPTY
-- PRE 04 @p_table_nm   NOT NULL or EMPTY
-- PRE 05 @p_schema_nm  NOT NULL or EMPTY
--
-- POSTCONDITIONS:
-- POST 01: FK created
-- =============================================
CREATE PROCEDURE [dbo].[sp_create_FK_old]
    @fk_nm        VARCHAR(60)
   ,@f_table_nm   VARCHAR(60)
   ,@p_table_nm   VARCHAR(60)
   ,@f_col_nm     VARCHAR(60)
   ,@p_col_nm     VARCHAR(60) = NULL
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @fn           VARCHAR(35) = 'sp_create_FK_old'
   ,@sql          NVARCHAR(MAX)
   ,@NL           NVARCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@msg          VARCHAR(500)
   ;

      EXEC sp_log 1, @fn ,' starting
fk_nm     :[', @fk_nm     ,']
f_table_nm:[', @f_table_nm,']
p_table_nm:[', @p_table_nm,']
p_table_nm:[', @p_table_nm,']
f_col_nm  :[', @f_col_nm    ,']
p_col_nm  :[', @p_col_nm    ,']
';

 
   -- dbo.FkExists returns 1 if the foriegn exists, 0 otherwise
   SET @sql = CONCAT('IF dbo.fnFkExists(''', @fk_nm,''') = 0
   BEGIN
      ALTER TABLE ', @f_table_nm,' WITH CHECK ADD CONSTRAINT ',@fk_nm,' FOREIGN KEY(',@f_col_nm,') 
      REFERENCES ',@p_table_nm,'(',@p_col_nm,');
      ALTER TABLE ', @f_table_nm,' CHECK CONSTRAINT ',@fk_nm,';
   END
   ELSE
      PRINT ''constraint ',@fk_nm, ' already exists''');

   PRINT @sql;
   EXEC (@sql);

   IF dbo.fnFkExists(@fk_nm) = 1
   BEGIN
      EXEC sp_log 1, @fn ,'created FK ',@fk_nm;
   END
   ELSE
   BEGIN
      EXEC sp_log 4, @fn ,'failed to create FK ',@fk_nm;
      --THROW 68100, @msg, 1;
      EXEC sp_raise_exception 68100, @fn ,' failed to create FK:[',@fk_nm,'] ', @fn=@fn;
   END
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Description: re creates all Auth schema foreign keys
--              after total import
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 03-APR-2025
-- =====================================================
CREATE PROCEDURE [dbo].[sp_create_FKs_Auth_old] @tables VARCHAR(MAX) = NULL
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn     VARCHAR(35) = 'sp_create_FKs_Auth'
      ,@cnt    INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, @tables: ', @tables, '';


      -------------------------------------------------------------------------------------------------------
      -- 1: Foreign table UserRole
      -------------------------------------------------------------------------------------------------------
      IF dbo.fnFkExists('FK_UserRole_User') = 0
      BEGIN
         EXEC sp_log 1, @fn, '005: recreating constraint UserRole.FK_UserRole_User';
         ALTER TABLE UserRole WITH CHECK ADD CONSTRAINT FK_UserRole_User FOREIGN KEY([user_id]) REFERENCES dbo.[User]([user_id]);
         ALTER TABLE UserRole CHECK CONSTRAINT FK_UserRole_User;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '010: constraint UserRole.FK_UserRole_User already exists';

      IF dbo.fnFkExists('FK_UserRole_Role') = 0
      BEGIN
         EXEC sp_log 1, @fn, '015: recreating constraint UserRole.FK_UserRole_Role';
         ALTER TABLE UserRole WITH CHECK ADD CONSTRAINT FK_UserRole_Role FOREIGN KEY(role_id) REFERENCES dbo.[Role](role_id);
         ALTER TABLE UserRole CHECK CONSTRAINT FK_UserRole_Role;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint UserRole.FK_UserRole_Use already exists';

      -------------------------------------------------------------------------------------------------------
      -- 1: Foreign table RoleFeature
      --------------------------------------------------------------
      IF dbo.fnFkExists('FK_RoleFeature_Role') = 0
      BEGIN
         EXEC sp_log 1, @fn, '025: recreating constraint FK_RoleFeature_Role';
         ALTER TABLE dbo.RoleFeature WITH CHECK ADD CONSTRAINT FK_RoleFeature_Role FOREIGN KEY(role_id) REFERENCES dbo.[Role](Role_id)
         ALTER TABLE dbo.RoleFeature CHECK CONSTRAINT FK_RoleFeature_Role
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '030: constraint RoleFeature.FK_RoleFeature_Role already exists';

      IF dbo.fnFkExists('FK_RoleFeature_Feature') = 0
      BEGIN
         EXEC sp_log 1, @fn, '035: recreating constraint FK_RoleFeature_Feature';
         ALTER TABLE RoleFeature WITH CHECK ADD CONSTRAINT FK_RoleFeature_Feature FOREIGN KEY(feature_id) REFERENCES dbo.Feature(feature_id);
         ALTER TABLE RoleFeature CHECK CONSTRAINT FK_RoleFeature_Feature;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '040: constraint RoleFeature.FK_RoleFeature_Feature already exists';

      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: created all necessary constraints';
      EXEC sp_log 1, @fn, '499: completed processing';


   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: created ', @cnt, ' keys';
   RETURN @cnt;
END
/*
EXEC sp_drop_FKs_Auth;
EXEC sp_create_FKs_Auth;
SELECT * FROM [User]
SELECT * FROM [Role]
SELECT * FROM [UserRole]
SELECT * FROM Feature
SELECT * FROM [RoleFeature]
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: Drops a table if it exists
-- Design:      
-- Tests:       
--
-- PRECONDITIONS:
-- PRE 01 @tbl_nm must be specified NOT NULL or EMPTY Checked
--
-- POSTCONDITIONS:
-- POST01: table does not exist
-- ==============================================================
CREATE PROCEDURE [dbo].[sp_drop_table]
    @q_table_nm        VARCHAR(80)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
     @fn          VARCHAR(35) = 'sp_drop_table'
    ,@sql         NVARCHAR(MAX)
    ,@ret         INT
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000 dropping table [', @q_table_nm, ']';

      -----------------------------------------------------------------
      -- Validation
      -----------------------------------------------------------------
      -- PRE 01 @fk_nm NOT NULL or EMPTY  Checked
      EXEC sp_log 1, @fn, '010 validating checked preconditions';
      SET @q_table_nm = dbo.fnDeLimitIdentifier(@q_table_nm);
      EXEC sp_assert_not_null_or_empty @q_table_nm, '@q_table_nm must be specified', @fn=@fn;

      -- delimit [ brkt name if necessary
      SET @q_table_nm = dbo.fnDeLimitIdentifier(@q_table_nm);
      -- chk if the table existed initially
      SET @ret = dbo.fnTableExists(@q_table_nm);

      SET @sql = CONCAT('DROP table if exists ', @q_table_nm);
      EXEC sp_log 1, @fn, '030 executing the drop Table SQL:
',@sql;

      EXEC (@sql);

      EXEC sp_log 1, @fn, '040 checking postconditions'
      ---------------------------------------------------------
      --- ASSERTION: POST01: table does not exist
      ---------------------------------------------------------
      EXEC sp_assert_tbl_exists @q_table_nm, 0;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: successfully dropped table ', @q_table_nm;
   return @ret; -- table did exist
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[sp_drop_table]';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FieldInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[nm] [varchar](50) NULL,
	[ty] [varchar](15) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JUN-2025
-- Description: infers the field types froma staging table
--    based on its data
--    pops the FieldInfo table
--
-- Design:      EA: Dorsu Model.Use Case Model.Create and populate a table from a data file.Infer the field types from the staged data
-- Tests:       test_074_sp_infer_field_types
--
-- Postconditions: POST01: pops the FieldInfo table
-- =============================================
CREATE PROCEDURE [dbo].[sp_infer_field_types]
   @q_table_nm VARCHAR(60)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           VARCHAR(35)   = N'sp_infer_field_types'
      ,@sql          NVARCHAR(4000)
      ,@schema       VARCHAR(60)
      ,@table_nm     VARCHAR(60)
      ,@fld_ty       VARCHAR(25)
      ,@fld_id       INT
      ,@fld_nm       VARCHAR(50)
      ,@len          INT
  ;

   EXEC sp_log 1, @fn, '000: starting:
@q_table_nm:[',@q_table_nm,']
';

   BEGIN TRY
      SELECT
          @schema = a
         ,@table_nm = b
      FROM dbo.fnSplitPair2(@q_table_nm, '.');

      IF @table_nm IS NULL
      BEGIN
         EXEC sp_log 1, @fn, '005: schema not specified - defaulting to dbo';
         SELECT
             @table_nm = @schema
            ,@schema   = 'dbo'
         ;
      END

      EXEC sp_log 1, @fn, '010: starting:
   @schema:  [',@schema,']
   @table_nm:[',@table_nm,']
   ';

      -- Clear the field info table
      TRUNCATE TABLE FieldInfo;

      -- Get the field info for the table
      SET @sql = CONCAT('INSERT INTO FieldInfo(nm) SELECT COLUMN_NAME
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_NAME = '''  , @table_nm, '''
     AND TABLE_SCHEMA = ''', @schema, ''';'
     );

      EXEC sp_log 1, @fn, '020: @sql:
', @sql;

      EXEC (@sql);
      EXEC sp_log 1, @fn, '030:';
      --SELECT * FROM FieldInfo;

      -- For each field in the staged data
      DECLARE _cursor CURSOR FOR SELECT id, nm  FROM FieldInfo;
      OPEN _cursor;
      FETCH NEXT FROM _cursor INTO @fld_id, @fld_nm;
      EXEC sp_log 1, @fn, '035:';

      -- For each fields
      WHILE @@FETCH_STATUS = 0
      BEGIN
         EXEC sp_log 1, @fn, '040: @fld_id: ',@fld_id, ' @fld_nm[',@fld_nm,']';

         -- For each field type we are interested in:
         -- Chk if all data item in that field are:
         WHILE 1=1
         BEGIN
            SET @fld_ty = NULL;
            EXEC sp_log 1, @fn, '050: trying BIT';

            -- Bit?	Set field type = bit
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'BIT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- Int?	Set field type = int
            EXEC sp_log 1, @fn, '060: trying INT';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'INT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            EXEC sp_log 1, @fn, '070: trying REAL';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'REAL');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

         -- Floating point?	Set field type = double
            EXEC sp_log 1, @fn, '080: trying FLOAT';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'FLOAT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- GUID ?	Set field type = GUID
            EXEC sp_log 1, @fn, '090: trying GUID';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'UNIQUEIDENTIFIER');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- Assume text field
            EXEC sp_log 1, @fn, '100: Assume text field';
            -- Set len = max len of the field
            SET @sql =
            CONCAT
            (
               'SELECT @len = MAX(dbo.fnLen(',@fld_nm,')) FROM 
            ', @q_table_nm, ';'
            )

            EXEC sp_log 1, @fn, '110:sql:
',@sql;
            EXEC sp_executesql @sql, N'@len INT OUT', @len OUT;
            EXEC sp_log 1, @fn, '120:@len:
',@len;
            SET @fld_ty = CONCAT('VARCHAR(', @len, ')')
            BREAK;
         END -- for each wanted field ty

         EXEC sp_log 1, @fn, '110: field ty is ',@fld_ty;
         -- Add the field info to the FieldInfo table
         UPDATE FieldInfo SET ty = @fld_ty WHERE id = @fld_id;
         FETCH NEXT FROM _cursor INTO @fld_id, @fld_nm;
      END -- outer while - for each row in FieldInfo

      CLOSE _cursor;
      DEALLOCATE _cursor;
      EXEC sp_log 1, @fn, '200: checking postconditions';

      -- Postconditions: POST01: pops the FieldInfo table
      EXEC sp_log 1, @fn, '210: checking POST01: pops the FieldInfo table';
      EXEC sp_assert_tbl_pop 'FieldInfo';
      EXEC sp_log 1, @fn, '299: completed processing loop';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';

      IF CURSOR_STATUS('global','_cursor')>=-1 
      BEGIN
         CLOSE _cursor;
         DEALLOCATE _cursor;
      END
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving ok';
END
/*
EXEC test.test_074_sp_infer_field_types;
SELECT * FROM FileActivityStaging

EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GenericStaging](
	[staging] [varchar](8000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_GenericStaging] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 12-JUN-2025
-- Description: Create and populate a table from a data file
-- 
-- Design:      EA: Model.Use Case Model.Create and populate a table from a data file
-- Define the import data file path
-- Table name = file name
-- Reads the header for the column names
-- Create a table with table name, columns = field names, type = text
-- Create a staging table 
-- Create a format file using BCP and the table
-- Generate the import routine using the table and the format file
--
-- Parameters:
--    @file_path     VARCHAR(500) -- the import data file path
-- Tests:       test_068_sp_crt_pop_table
--
-- Preconditions:
-- PRE01: @file_path populated
-- Postconditions:
-- =============================================
CREATE PROCEDURE [dbo].[sp_crt_pop_table]
    @file_path       VARCHAR(500) -- the import data file path
   ,@sep             VARCHAR(6)  = NULL
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
       @fn           VARCHAR(35)   = N'sp_crt_pop_table'
      ,@fields       VARCHAR(8000)
      ,@file         VARCHAR(500)
      ,@folder       VARCHAR(500)= NULL
      ,@format_file  VARCHAR(500)= NULL
      ,@NL           CHAR = CHAR(13)
      ,@tab          CHAR = CHAR(9)
      ,@ndx          INT
      ,@table_nm     VARCHAR(50)
      ,@stg_table_nm VARCHAR(50)
      ,@row_cnt      INT
      ,@cmd          VARCHAR(8000)
      ,@sql          VARCHAR(8000)

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
@file_path:       [',@file_path,']
@sep:             [',@sep,']
@codepage:        [',@codepage,']
@display_tables:  [',@display_tables,']
';

      ---------------------------------------------------------------
      -- Setup
      ---------------------------------------------------------------

      IF @sep IS NULL OR @sep IN('',0x09,'0x09', '\t') SET @sep = @tab; -- default
      SET @ndx = dbo.fnFindLastIndexOf('\', @file_path);
      -- Table name = file name less the extension
      SET @file   = SUBSTRING(@file_path, @ndx+2, dbo.fnLen(@file_path)-@ndx);
      SET @folder = iif(@ndx = 0, NULL, SUBSTRING(@file_path, 1, @ndx));
      SELECT @table_nm = a FROM dbo.fnSplitPair2(@file, '.');

      EXEC sp_log 1, @fn, '010:
@ndx:     [', @ndx     , ']
@file:    [', @file    , ']
@table_nm:[', @table_nm, ']
@folder:  [', @folder  , ']
';
      -- Table name = file name  less the extension
      -- Import the header into a single column generic text table
      -- Reads the header for the column names
      -- Read the header for the column names
         EXEC sp_log 1, @fn, '020: importing the file header for the column names';
         EXEC @row_cnt = sp_import_txt_file
             @table           = 'GenericStaging'
            ,@file            = @file
            ,@folder          = @folder
            ,@first_row       = 1
            ,@last_row        = 1
            ,@field_terminator= @NL
            ,@view            = 'ImportGenericStaging_vw'
            ,@codepage        = @codepage
            ,@display_table   = 1
         ;

      -- Create the staging table,  columns = field names, type = text
      -- Create a staging table
      SET @stg_table_nm = CONCAT(@table_nm, 'Staging');
      EXEC sp_drop_table @stg_table_nm;

      -- Create a table with table name, columns = field names, type = text
      EXEC sp_log 1, @fn, '030: creating the staging table, cmd: ', @NL, @cmd;
      SELECT @fields = staging FROM GenericStaging;
      EXEC sp_log 1, @fn, '040: @fields: ', @fields, ' @stg_table_nm: ',@stg_table_nm;

      SET @cmd = dbo.fnCrtTblSql(@stg_table_nm, @fields); -- delimits the qualified @stg_table_nm if necessary
      EXEC sp_log 1, @fn, '050: executing @cmd: ', @cmd;
      EXEC (@cmd);
      -- Bracket table name as necessary
      -- Bracket field names as necessary
      -- Create a format file using BCP and the table
      --SET @cmd = dbo.fnCrtTblSql(@table_nm, @fields);
      --EXEC sp_log 1, @fn, '060: creating the main table, sql: ', @NL, @cmd;
      --EXEC (@cmd);

   -- Create and populate the table from data file : Create and populate a table from a data file_ActivityGraph
   -- Infer the field types from the staged data
   -- Merge the staging table to the main table

      -- Create a format file using BCP and the table
      SET @format_file = CONCAT(@folder, '\',@table_nm,'_fmt.xml');
      --SET @cmd = CONCAT('bcp ',DB_NAME(),'.dbo.',@table_nm,' format nul -c -x -f ',@format_file, ' -t, -T');
      SET @cmd = 
         CONCAT
         (
            'bcp '
           ,DB_NAME()
           ,'.dbo.',@table_nm
           ,' format nul -c -x -f ',@format_file
           ,iif(@sep=@tab, '', ' -t, '),' -T'
         );

      EXEC sp_log 1, @fn, '060: creating format file: ', @NL, @cmd;
      EXEC xp_cmdshell @cmd;

      -- Import the staging table
      -- Import staging table using the table and the format file
      EXEC sp_log 1, @fn, '070: importing ', @file_path, ' to staging: ', @stg_table_nm;

      EXEC sp_import_txt_file
          @table            = @stg_table_nm
         ,@file             = @file_path
         ,@folder           = NULL
         ,@field_terminator = @sep
         ,@codepage         = @codepage
         ,@first_row        = 2
         ,@format_file      = @format_file
         ,@display_table    = @display_tables
      ;

      -- Infer the field types from the staged data
      EXEC sp_log 1, @fn, '080: Infer the field types from the staged data';

      -- Infer field types: pops the FieldInfo table
      EXEC sp_infer_field_types @stg_table_nm;
      EXEC sp_log 1, @fn, '090: Drop the main  if it exists';

      -- Drop table if it exists
      EXEC sp_drop_table @table_nm;

      -- Create the main table with table name, columns = field names, type = inferred type
      EXEC sp_log 1, @fn, '100: Create the main table with table name, columns = field names, type = inferred type';
      SELECT @sql = 
      CONCAT
      (
      'CREATE TABLE ', @table_nm, '
(
'
,STRING_AGG(CONCAT('   ', lower(nm), ' ', ty), ',
'
),'
);'
      )
      FROM FieldInfo
      ;

      EXEC sp_log 1, @fn, '110: Creating the main table, sql:
', @sql;

      EXEC(@sql);

      -- Migrating the staging data to the main table
      SET @sql = CONCAT('INSERT INTO ', @table_nm,' SELECT * FROM ',@stg_table_nm,';')
      EXEC sp_log 1, @fn, '120: Migrating the staging data to the main table, @sql:
', @sql;

      EXEC(@sql);

      SELECT @table_nm as [main table];
      SET @sql = CONCAT('SELECT * FROM ',@table_nm,';')
      EXEC sp_log 1, @fn, '130: displaying the main table';
      EXEC(@sql);
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: completed processing';
END
/*
EXEC test.test_068_sp_crt_pop_table;

EXEC tSQLt.Run 'test.test_068_sp_crt_pop_table';
EXEC sp_AppLog_display 'sp_crt_pop_table';

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns 'dbo.sp_crt_pop_table'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:         Terry Watts
-- Create date:    03-APR-2025
-- Description:    drops all Auth schema foreign keys
-- Design:         EA
-- Tests:         test_004_sp_create_FKs
-- Preconditions:  none
-- Postconditions: Return value = count of dropped relations
-- Tests:       test_004_sp_create_FKs
-- ==========================================================
CREATE PROCEDURE [dbo].[sp_drop_FKs_Auth_old]
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE
       @fn     VARCHAR(35) = 'sp_drop_FKs_Auth'
      ,@cnt    INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';

      ----------------------------------------
      --  Foreign table  UserRole
      ----------------------------------------
      EXEC sp_log 1, @fn, '005: dropping keys for Referenced table UserRole';

      IF dbo.fnFkExists('FK_UserRole_User') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint FK_UserRole_User';
         ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_User];
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint UserRole.FK_UserRole_User does not exist';

      IF dbo.fnFkExists('FK_UserRole_Role') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint FK_UserRole_Role';
         ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_Role]
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint UserRole.FK_UserRole_Role does not exist';

      ----------------------------------------
      -- Foreign table RoleFeature
      ----------------------------------------
      IF dbo.fnFkExists('FK_RoleFeature_Role') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint FK_RoleFeature_Role';
         ALTER TABLE [dbo].[RoleFeature] DROP CONSTRAINT FK_RoleFeature_Role;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint RoleFeature.FK_RoleFeature_Role does not exist';

      IF dbo.fnFkExists('FK_RoleFeature_Feature') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint FK_RoleFeature_Feature';
         ALTER TABLE dbo.RoleFeature DROP CONSTRAINT FK_RoleFeature_Feature
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint RoleFeature.FK_RoleFeature_Feature does not exist';

      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: dropped all necessary constraints';
      EXEC sp_log 1, @fn, '499: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: dropped ', @cnt, ' keys';
   RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_create_FKs';
EXEC tSQL.RunAll;

EXEC sp_drop_FKs_Auth;
EXEC sp_create_FKs_Auth;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Author:        Terry Watts
-- Create date:   25-Feb-2025
-- Description:   drops all foreign keys
-- Design:        EA
-- Tests:         test_004_sp_create_FKs
-- Preconditions: none
-- Postconditions:
-- POST01:        returns the count of the dropped keys
-- =====================================================
CREATE PROCEDURE [dbo].[sp_drop_FKs_old]
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE
       @fn     VARCHAR(35) = 'sp_drop_FKs'
      ,@cnt    INT         = 0
      ,@delta  INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';

      ------------------------------------------------------------------------------------
      -- 1: Foreign table Attendance: 2 FKs: FK_Attendance_Course, FK_Attendance_Student
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: dropping keys for Referenced table Attendance';
      EXEC sp_log 1, @fn, '010: dropping constraint Attendance.FK_Attendance_Student';

      IF dbo.FkExists('FK_Attendance_Student') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint Attendance.FK_Attendance_Student';
         ALTER TABLE Attendance DROP CONSTRAINT FK_Attendance_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint Attendance.FK_Attendance_Student does not exist';

      EXEC sp_log 1, @fn, '010: dropping constraint Attendance.FK_Attendance_ClassSchedule';

      IF dbo.FkExists('FK_Attendance_ClassSchedule') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint Attendance.FK_Attendance_ClassSchedule';
         ALTER TABLE Attendance DROP CONSTRAINT FK_Attendance_ClassSchedule;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint Attendance.FK_Attendance_ClassSchedule does not exist';

      ----------------------------------------
      --  Foreign table  Attendance2: 2 FKs: FK_Attendance_Enrollment, FK_Attendance2_Student
      ----------------------------------------
      EXEC sp_log 1, @fn, '005: dropping keys for Referenced table Attendance2';
      EXEC sp_log 1, @fn, '010: dropping constraint Attendance2.FK_Attendance_Enrollment';

      IF dbo.FkExists('FK_Attendance2_Student') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint Attendance2.FK_Attendance2_Student';
         ALTER TABLE Attendance2 DROP CONSTRAINT FK_Attendance2_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint Attendance2.FK_Attendance2_Student does not exist';

      EXEC sp_log 1, @fn, '010: dropping constraint Attendance2.FK_Attendanc2_ClassSchedule';

      IF dbo.FkExists('FK_Attendance2_ClassSchedule') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint Attendance2.FK_Attendanc2_ClassSchedule';
         ALTER TABLE Attendance2 DROP CONSTRAINT FK_Attendance2_ClassSchedule;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint Attendance2.FK_Attendanc2_ClassSchedule does not exist';

      ----------------------------------------
      -- Foreign table ClassSchedule 4 FKs: Major, Room, Course, Section
      ----------------------------------------
      EXEC sp_log 1, @fn, '025: dropping keys for Referenced table Attendance';
      IF dbo.FkExists('FK_ClassSchedule_Major') = 1
      BEGIN
         EXEC sp_log 1, @fn, '030: dropping constraint ClassSchedule.FK_ClassSchedule_Major';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Major;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '035: constraint ClassSchedule.FK_ClassSchedule_Major does not exist';

      IF dbo.FkExists('FK_ClassSchedule_Room') = 1
      BEGIN
         EXEC sp_log 1, @fn, '040: dropping constraint ClassSchedule.FK_ClassSchedule_Room';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Room;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '045: constraint ClassSchedule.FK_ClassSchedule_Section does not exist';

      EXEC sp_log 1, @fn, '050: FK_ClassSchedule_Course';
      IF dbo.FkExists('FK_ClassSchedule_Course') = 1
      BEGIN
         EXEC sp_log 1, @fn, '055: dropping constraint ClassSchedule.FK_ClassSchedule_Course';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Course;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '060: constraint ClassSchedule.FK_ClassSchedule_Course does not exist';

      EXEC sp_log 1, @fn, '050: FK_ClassSchedule_Section';
      IF dbo.FkExists('FK_ClassSchedule_Section') = 1
      BEGIN
         EXEC sp_log 1, @fn, '055: dropping constraint ClassSchedule.FK_ClassSchedule_Section';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Section;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '060: constraint ClassSchedule.FK_ClassSchedule_Section does not exist';

      EXEC sp_log 1, @fn, '065: dropping keys for Primary table Course';

      EXEC sp_log 1, @fn, '070: FK_ClassSchedule_Course';
      IF dbo.FkExists('FK_ClassSchedule_Course') = 1
      BEGIN
         EXEC sp_log 1, @fn, '075: dropping constraint ClassSchedule.FK_ClassSchedule_Course';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Course;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '080: constraint ClassSchedule.FK_ClassSchedule_Course does not exist';

      EXEC sp_log 1, @fn, '085: dropping keys for Primary table Room';
      EXEC sp_log 1, @fn, '090: FK_ClassSchedule_room';

      IF dbo.FkExists('FK_ClassSchedule_room') = 1
      BEGIN
         EXEC sp_log 1, @fn, '095: dropping constraint ClassSchedule.FK_ClassSchedule_room';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_room;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '100: constraint ClassSchedule.FK_ClassSchedule_room does not exist';

      ----------------------------------------
      -- Foreign table CourseSection
      ----------------------------------------
      EXEC sp_log 1, @fn, '105: dropping keys for Referenced table CourseSectiont';
      IF dbo.FkExists('FK_CourseSection_Course') = 1
      BEGIN
         EXEC sp_log 1, @fn, '110: dropping constraint StudentSection.FK_CourseSection_Course';
         ALTER TABLE CourseSection DROP CONSTRAINT FK_CourseSection_Course;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '115: constraint CourseSection.FK_CourseSection_Course does not exist';

      IF dbo.FkExists('FK_CourseSection_Section') = 1
      BEGIN
         EXEC sp_log 1, @fn, '120: dropping constraint CourseSection.FK_CourseSection_Section';
         ALTER TABLE CourseSection DROP CONSTRAINT FK_CourseSection_Section;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '125: constraint StudentCourse.FK_CourseSection_Section does not exist';

      ----------------------------------------
      -- Foreign table: Enrollment
      ----------------------------------------
      EXEC sp_log 1, @fn, '130: dropping keys for Referenced table Enrollment';
      IF dbo.FkExists('FK_Enrollment_Course') = 1
      BEGIN
         EXEC sp_log 1, @fn, '135: dropping constraint FK_Enrollment_Course';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Course;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '140: constraint FK_Enrollment_Course does not exist';

      IF dbo.FkExists('FK_Enrollment_Major') = 1
      BEGIN
         EXEC sp_log 1, @fn, '145: dropping constraint FK_Enrollment_Major';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Major;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '150: constraint FK_Enrollment_Major does not exist';

      IF dbo.FkExists('FK_Enrollment_Student') = 1
      BEGIN
         EXEC sp_log 1, @fn, '155: dropping constraint FK_Enrollment_Student';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '160: constraint FK_Enrollment_Student does not exist';

      IF dbo.FkExists('FK_Enrollment_Section') = 1
      BEGIN
         EXEC sp_log 1, @fn, '165: dropping constraint FK_Enrollment_Section';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Section;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '170: constraint FK_Enrollment_Section does not exist';

      IF dbo.FkExists('FK_Enrollment_Semester') = 1
      BEGIN
         EXEC sp_log 1, @fn, '175: dropping constraint FK_Enrollment_Semester';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Semester
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '180: constraint FK_Enrollment_Semester does not exist';

      ----------------------------------------
      -- Foreign table StudentCourse
      ----------------------------------------
      EXEC sp_log 1, @fn, '185: dropping keys for Referenced table StudentCourse';
      IF dbo.FkExists('FK_StudentCourse_Section') = 1
      BEGIN
         EXEC sp_log 1, @fn, '190: dropping constraint StudentCourse.FK_StudentCourse_Section';
         ALTER TABLE StudentCourse DROP CONSTRAINT FK_StudentCourse_Section;
         SET @cnt = @cnt + 1;
      END
         EXEC sp_log 1, @fn, '195: constraint StudentCourse.FK_StudentCourse_Section does not exist';

      ----------------------------------------
      -- Foreign table StudentSection
      ----------------------------------------
      EXEC sp_log 1, @fn, '200: dropping keys for Primary table StudentSection';
      IF dbo.FkExists('FK_StudentSection_Student') = 1
      BEGIN
         EXEC sp_log 1, @fn, '205: dropping constraint FK_StudentSection_Student';
         ALTER TABLE [dbo].StudentSection DROP CONSTRAINT FK_StudentSection_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '210: constraint FK_StudentCourse_Student does not exist';

      ----------------------------------------
      -- Foreign table GoogleName
      ----------------------------------------
      EXEC sp_log 1, @fn, '215: dropping keys for Primary table GoogleName';
      IF dbo.FkExists('FK_GoogleName_Student') = 1
      BEGIN
         ALTER TABLE GoogleName DROP CONSTRAINT FK_GoogleName_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '220: constraint FK_GoogleName_Student does not exist';

      ----------------------------------------
      -- Foreign table Team
      ----------------------------------------
      EXEC sp_log 1, @fn, '225: dropping keys for table Team';
      IF dbo.FkExists('FK_Team_Event') = 1
      BEGIN
         EXEC sp_log 1, @fn, '230: dropping constraint Team.FK_Team_Event';
         ALTER TABLE Team DROP CONSTRAINT FK_Team_Event;

         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '235: constraint Team.FK_Team_Event does not exist';


      ----------------------------------------
      -- Foreign table TeamMembers
      ----------------------------------------
      EXEC sp_log 1, @fn, '240: dropping keys for table TeamMembers';
      IF dbo.FkExists('FK_TeamMembers_Team') = 1
      BEGIN
         EXEC sp_log 1, @fn, '245: dropping constraint TeamMembers.FK_TeamMembers_Team';
         ALTER TABLE TeamMembers DROP CONSTRAINT FK_TeamMembers_Team;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '250: constraint TeamMembers.FK_TeamMembers_Team does not exist';

      EXEC sp_log 1, @fn, '250: Dropping auth table relationships, calling sp_drop_FKs_Auth';
      EXEC @delta = sp_drop_FKs_Auth;
      SET @cnt = @cnt + @delta;
         /*
      ----------------------------------------
      -- Test tables
      ----------------------------------------
      ----------------------------------------
      -- Foreign table test.test_005_F
      ----------------------------------------
      IF dbo.FkExists('FK_test_005_F_test_005_P') = 1
      BEGIN
         EXEC sp_log 1, @fn, '255: dropping constraint FK_StudentSection_Student';
         ALTER TABLE test.test_005_F DROP CONSTRAINT FK_test_005_F_test_005_P;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '260: constraint FFK_test_005_F_test_005_P does not exist';
*/
      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: dropped all necessary constraints';
      EXEC sp_log 1, @fn, '499: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: dropped ', @cnt, ' relationships';
-- POST01:        returns the count of the dropped keys
   RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_create_FKs';
EXEC tSQL.RunAll;

EXEC sp_drop_FKs;
EXEC sp_create_FKs;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeet](
	[student_id] [varchar](150) NULL,
	[student_nm] [varchar](50) NOT NULL,
	[date] [date] NOT NULL,
	[class_start] [varchar](4) NOT NULL,
	[course_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NULL,
 CONSTRAINT [PK_AttendanceGMeet_1] PRIMARY KEY CLUSTERED 
(
	[student_nm] ASC,
	[date] ASC,
	[class_start] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_AttendanceGMeet_name] ON [dbo].[AttendanceGMeet]
(
	[student_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeetStaging](
	[line] [varchar](150) NULL,
	[candidate_nm] [varchar](150) NULL,
	[student_nm] [varchar](50) NULL,
	[surname] [varchar](50) NULL,
	[student_id] [varchar](9) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================
-- Description: Performs the fixup for the AttendanceGMeetStagingimport
-- Design:      EA
-- Tests:       test_011_sp_ImportGMeetAttendance
-- Author:      Terry Watts
-- Create date: 14-Mar-2025
-- =====================================================================
CREATE PROCEDURE [dbo].[sp_fixup_AttendanceGMeetStaging]
    @course_nm     NVARCHAR(20)
   ,@section_nm    NVARCHAR(20)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_fixup_AttendanceGMeetStaging';

   EXEC sp_log 1, @fn, '000: starting
course_nm:    [',@course_nm    ,']
section_nm:   [',@section_nm   ,']
';

   BEGIN TRY
      -- Copy to the line to  candidate_nm column
      UPDATE AttendanceGMeetStaging SET candidate_nm = line;
      --------------------------------------------------
      -- Removing lines with no characters
      --------------------------------------------------
      EXEC sp_log 1, @fn, '010: removing timestamps';
      DELETE FROM AttendanceGMeetStaging
      WHERE dbo.Regex_IsMatch(candidate_nm,'[a-zA-Z]') = 0
      ;

      EXEC sp_log 1, @fn, '020: removed ', @@ROWCOUNT, ' timestamps';

      --------------------------------------------------
      -- Removing double quotes
      --------------------------------------------------
      EXEC sp_log 1, @fn, '030: removing double quotes';
      UPDATE AttendanceGMeetStaging SET candidate_nm = REPLACE(candidate_nm, '"', '') WHERE CHARINDEX('"', candidate_nm) > 0;
      EXEC sp_log 1, @fn, '040: removed ', @@ROWCOUNT, ' double quotes';

      --------------------------------------------------
      -- Removing lines without the word present
      --------------------------------------------------
      EXEC sp_log 1, @fn, '050: Removing lines withut the word present';
      DELETE FROM AttendanceGMeetStaging WHERE candidate_nm NOT LIKE '%present%'
      EXEC sp_log 1, @fn, '060: removed ', @@ROWCOUNT, ' lines without the word present';

      --------------------------------------------------
      -- Removing null lines
      --------------------------------------------------
      EXEC sp_log 1, @fn, '050: Removing lines withuut the word present';
      DELETE FROM AttendanceGMeetStaging WHERE candidate_nm IS NULL
      EXEC sp_log 1, @fn, '060: removed ', @@ROWCOUNT, ' NULL lines';

      --------------------------------------------------
      -- Removing present
      --------------------------------------------------
      EXEC sp_log 1, @fn, '070: Removing Removing the word present';
      UPDATE AttendanceGMeetStaging SET candidate_nm = REPLACE(candidate_nm, 'present', '') WHERE CHARINDEX('present', candidate_nm) > 0;
      EXEC sp_log 1, @fn, '080: removed ', @@ROWCOUNT, ' double quotes';

      --------------------------------------------------
      -- Removing combinations of endings like '-'
      --------------------------------------------------
      EXEC sp_log 1, @fn, '090: trimming combinations of [, -] present';
      UPDATE AttendanceGMeetStaging SET candidate_nm = TRIM(' -' FROM candidate_nm);
      EXEC sp_log 1, @fn, '100: removed ', @@ROWCOUNT, ' double quotes';

      ----------------------------------------------------------------
      -- Make sure the last character of the full name is not a comma
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '105: replacing end comma with . if it exists';
      UPDATE AttendanceGMeetStaging SET candidate_nm = CONCAT(TRIM(',' FROM candidate_nm), '.')
      WHERE RIGHT(candidate_nm, 1) = ',';
      EXEC sp_log 1, @fn, '100: update ', @@ROWCOUNT, ' ending commas';

      --------------------------------------------------
      -- Make sure the surname is followed by a comma
      -- First word is followed by
      --------------------------------------------------
       UPDATE AttendanceGMeetStaging 
       SET candidate_nm = dbo.Regex_Replace(candidate_nm, '^(\w+)([-,\s]+)(.*)', '$1, $3')
       FROM AttendanceGMeetStaging;

      ----------------------------------------------------------------
      -- fnCamelCase candidate_nm
      ----------------------------------------------------------------
       UPDATE AttendanceGMeetStaging 
       SET candidate_nm = dbo.fnCamelCase(candidate_nm)

       -- PRINT dbo.fnCamelCase('abGd Eefg');

      -- Matching name against the registered student List
      -- stage 1 : do a direct comparison
      EXEC sp_log 1, @fn, '110: Matching name against the registered student List';
      EXEC sp_log 1, @fn, '120: Matching name stage 1';

      UPDATE a
      SET 
          student_id = s.student_id
         ,student_nm = s.student_nm
         ,surname    = IIF(CHARINDEX(',', a.candidate_nm)>0, SUBSTRING(a.candidate_nm, 1, CHARINDEX(',', a.candidate_nm)-1), '????')
      FROM AttendanceGMeetStaging a
      LEFT JOIN Student s ON s.student_nm = a.candidate_nm;

      EXEC sp_log 1, @fn, '130: Matching name stage 2';
      SELECT * FROM AttendanceGMeet a;

   /*   SELECT * FROM AttendanceGMeetStaging a 
      JoIn Enrollment_vw e
      ON a.candidate_nm = e.student_nm
      */

      -- stage2: compare against surname and enrollment if of unique
      EXEC sp_log 1, @fn, '499: Completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '510: rethrowing exception';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving';
END
/*
EXEC test.test_011_sp_ImportGMeetAttendance;

EXEC tSQLt.Run 'test.test_011_sp_ImportGMeetAttendance';
EXEC tSQLt.RunAll;

EXEC sp_ImportGMeetAttendance 'D:\Dorsu\Data\Attendance 250314.txt';
SELECT * FROM AttendanceGMeet;
SELECT * FROM AttendanceGMeetStaging;
EXEC sp_fixup_AttendanceGMeetStaging;
SELECT * FROM AttendanceGMeetStaging;
*/
--Salminang, Irizgle C. - --

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FbMapStaging](
	[id] [int] NULL,
	[fb_nm] [varchar](1000) NULL,
	[section_nm] [varchar](1000) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[match_ty] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Description:   Imports the FbMap table from a tsv
-- Design:        
-- Tests:         
-- Author:        Terry Watts
-- Create date:   26-Mar-2025
-- Preconditions: none
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_FbMapStaging]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_FbMap'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0


   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, file: ',@file,' truncating FbMap table';
      TRUNCATE TABLE FbMapStaging;

      EXEC @row_cnt = sp_import_txt_file
          @table           = 'FbMapStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;


      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '399: finished importing file: ',@file,'';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      --EXEC sp_create_FKs 'Section';
      THROW;
   END CATCH


   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from ',@file;
   RETURN @row_cnt;
END
/*
EXEC sp_Import_FbMapStaging 'D:\Dorsu\Data\Teams.FB Name map.txt', 1;
EXEC sp_importAllStudentCourses;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_Import_FbMap]';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE View [dbo].[FindStudentInfo_vw]
AS
SELECT TOP 10000 
   fsi.srch_cls, s.student_id, s.student_nm, s.gender, google_alias, course_nm, section_nm, major_nm, match_ty
FROM FindStudentInfo fsi 
LEFT JOIN  Student s on fsi.student_id = s.student_id
ORDER BY fsi.student_nm, course_nm, section_nm
;
/*
SELECT * FROM FindStudentInfo_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FbNameMap](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fb_nm] [varchar](1000) NULL,
	[section_nm] [varchar](1000) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[match_ty] [int] NULL,
	[candidates] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:         Terry Watts
-- Create date:    27 April
-- Description:    
-- Design:         EA: Model.Use Case Model.FixupStudentFbNames
-- Preconditions:  
-- Postconditions: 
-- Tests:       
-- ============================================================
CREATE PROCEDURE [dbo].[sp_FixupStudentFbNames]
    @file            VARCHAR(MAX)
   ,@clr_first       BIT = 1
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35)    = N'sp_FixupStudentFbNames'
      ,@id           INT
      ,@row_cnt      INT
      ,@fb_nm        VARCHAR(50)
      ,@section_nm   VARCHAR(20)
   ;

   SET NOCOUNT ON;
   EXEC sp_log 1, @fn, '000:  starting:
file     :[', @file     ,']
clr_first:[',@clr_first ,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '010:  Validate initial state';
      EXEC sp_assert_file_exists @file;

      --------------------------------------
      -- Assertion: good to go
      --------------------------------------
      if @clr_first = 1
      BEGIN
         EXEC sp_log 1, @fn, '020:  clearing the FbNameMap table';
         DELETE FROM FbNameMap;
      END

      -- Import the fb name file to the FbMapStaging table
      EXEC sp_log 1, @fn, '030:  Import the fb name file to the FbMapStaging table';
      EXEC sp_Import_FbMapStaging @file;

      -- Iterate this table trying to find the student name based solely on the fb name and section
      EXEC sp_log 1, @fn, '040:  Iterate this table trying to find the student name based solely on the fb name and section';
      DECLARE my_cursor CURSOR FAST_FORWARD FOR 
         SELECT id, fb_nm, section_nm 
         FROM FBMapStaging;

      OPEN my_cursor;

      -- Fetch the first row
      FETCH NEXT FROM my_cursor INTO @id, @fb_nm, @section_nm;

      -- Loop through the rows
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Process the row
         DELETE FROM FindStudentInfo;

         EXEC sp_log 1, @fn, '050: Process the row: id: ',@id, ' fb_nm:[',@fb_nm,'] section_nm:[', @section_nm, ']';
         EXEC @row_cnt = sp_FindStudent @student_nm = @fb_nm, @section_nm=@section_nm, @display_rows=0;

         EXEC sp_log 1, @fn, '060: found ', @row_cnt, ' rows';

         EXEC sp_log 1, @fn, '070: If 0 rows found skip';

         WHILE 1=1
         BEGIN
            -- If 0 result pop empty found cols
            IF @row_cnt = 0
            BEGIN
               EXEC sp_log 1, @fn, '080: 0 row found pop empty found cols';
               THROW 5000, 'DEBUG', 1;
               INSERT INTO FbNameMap(fb_nm, section_nm)
               SELECT               @fb_nm, @section_nm
               BREAK;
            END

            -- If 1 result use it
            IF @row_cnt = 1
            BEGIN
               EXEC sp_log 1, @fn, '090: 1 row found pop it';
               --SELECT * FROM FindStudentInfo_vw;

               INSERT INTO FbNameMap(fb_nm, section_nm, student_id, student_nm, match_ty)
               SELECT               @fb_nm, section_nm, student_id, student_nm, match_ty
               FROM FindStudentInfo_vw;
               --THROW 5000, 'DEBUG', 1;
               BREAK;
            END

/*
            -- Else concat the found rows separating with a line feed character
             EXEC sp_log 1, @fn, '100: Else concat the found rows separating with a line feed character';
               INSERT INTO FbNameMap(fb_nm, candidates)
               SELECT               @fb_nm, string_agg(student_nm, ';')
               FROM FindStudentInfo_vw;
*/
             BREAK;
         END -- while 1=1

         -- When completed the iteration loop
         EXEC sp_log 1, @fn, '110: Finished fb name iteration loop';

         -- Display the list (FBNamemap table)
         EXEC sp_log 1, @fn, '120: Add these rows to the FBNameMap Table';

         -- Fetch the next row
         FETCH NEXT FROM my_cursor INTO @id, @fb_nm, @section_nm;
      END

      --------------------------------------
      -- Completed processing
      --------------------------------------
      -- Clean up
      CLOSE my_cursor;
      DEALLOCATE my_cursor;

      -- Display the map
      EXEC sp_log 1, @fn, '130: Display the FBNameMap Table'
      SELECT * FROM FbNameMap;
      EXEC sp_log 1, @fn, '900: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      -- Clean up
      CLOSE my_cursor;
      DEALLOCATE my_cursor;

      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999 leaving';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns 'sp_FixupStudentFbNames'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 19-NOV-2024
-- Description: function to compare 2 strings
-- Returns TABLE with 3 rows,[A as chars, B as chars, A as ascii codes, B as ASCII codes]
-- Stops at first mismatch
--
-- Tests: test_037_fnCompareStrings
-- ======================================================================================
CREATE PROC [dbo].[sp_fnCompareStrings]( @a VARCHAR(MAX), @b VARCHAR(MAX))
/*
RETURNS @t TABLE
(
    SA            VARCHAR(MAX) -- STRING characters             for A
   ,SB            VARCHAR(MAX) -- STRING characters             for B
   ,CA            VARCHAR(MAX) -- SEQ ASCII codes formattd 00N  for A
   ,CB            VARCHAR(MAX) -- SEQ ASCII codes formattd 00N  for B
   ,msg           VARCHAR(MAX) -- match results
   ,[match]       BIT
   ,status_msg    VARCHAR(120)
   ,code          INT
   ,ndx           INT
   ,[log]         VARCHAR(MAX)
)
*/
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35) = N'sp_fnCompareStrings'
      ,@charA        CHAR
      ,@charB        CHAR
      ,@asciA        CHAR(3)
      ,@asciB        CHAR(3)
      ,@CA           VARCHAR(MAX) -- Ascii codes in hex/spx
      ,@CB           VARCHAR(MAX) -- Ascii codes in hex/spc
      ,@SA           VARCHAR(MAX) -- Characters matching Ascii codes/spx
      ,@SB           VARCHAR(MAX) -- Characters matching Ascii codes/spx
      ,@first_time   BIT = 1
      ,@i            INT
      ,@lenMax       INT
      ,@lenA         INT
      ,@lenB         INT
      ,@match        BIT = 1
      ,@msg          VARCHAR(MAX)
      ,@nl           VARCHAR(2) = CHAR(13) + CHAR(10)
      ,@status_msg   VARCHAR(50)
      ,@code         INT
      ,@log          VARCHAR(MAX)
      ,@t            test.CompareStringsTbl
      ,@params       VARCHAR(MAX)
   ;

   WHILE(1=1)
   BEGIN
      SET @params = CONCAT
      (
'a:[', iif(@a IS NULL, '<NULL>', iif( LEN(@a)=0,'<empty string>',@a)), ']', @nl,
'b:[', iif(@a IS NULL, '<NULL>', iif( LEN(@b)=0,'<empty string>',@b)), ']', @nl
      );

      EXEC sp_log 1, @fn, '000: starting, params:',@nl, @params;
      IF (@a IS NULL OR @b IS NULL) -- But not both
      BEGIN
         -----------------------------------------------------------------
         -- ASSERTION: @a IS NULL OR @b IS NULL may be both
         -----------------------------------------------------------------
         EXEC sp_log 0, @fn, '010: ASSERTION: @a IS NULL OR @b IS NULL maybe both';

         IF(@a IS NULL AND @b IS NULL)
         BEGIN
            SELECT
                @msg   = 'both a or b are NULL'
               ,@match = 1
               ,@status_msg= 'OK'
               ,@code  = 1
            ;

            EXEC sp_log 1, @fn, '020: match: both inputs are NULL'
            BREAK;
         END

      ------------------------------------------------------
      -- ASSERTION: one or other input is null but not both
      ------------------------------------------------------
       EXEC sp_log 1, @fn, '030: ASSERTION: one or other input is null but not both'

         SELECT
             @msg       = 'one of a or b is NULL but not both '
            ,@match     = 0
            ,@status_msg= 'OK'
            ,@code      = 2 -- 'one of a or b is NULL but not both '

         EXEC sp_log 1, @fn, '040: mismatch, one of a or b is NULL but not both';
         BREAK;
      END

      -----------------------------------------------------------------
      -- ASSERTION: both are not null
      -----------------------------------------------------------------
      SET @lenA = dbo.fnLen(@a);
      SET @lenB = dbo.fnLen(@b);
      EXEC sp_log 1, @fn, '050: len(a): ', @lenA, ' len(b): ', @lenB;

      -- Check length of both strings <=1000 (need 4 chars per char compared
      EXEC sp_log 1, @fn, '060: check string length <=1333';
      SET @lenMax = dbo.fnMax(@lenA, @lenb);

      IF @lenA <> @lenb
      BEGIN
         SELECT
             @msg       = CONCAT('strings differ in length a: ', @lenA, ' b: ', @lenb)
            ,@match     = 0
            ,@status_msg= 'OK'
            ,@code      = 5 -- length mismatch

         EXEC sp_log 1, @fn, '070: mismatch, string lengths differ, @lenA: ', @lenA, ' @lenB: ', @lenB;
         --BREAK;
      END

      -- Need 3 chars like [ xx] for each char checked so limit is 8000/3 = 2666
      IF @lenA > 1000 OR @lenB > 2666
      BEGIN
         SELECT
             @msg       = 'a or b is too long to store the results of a detailed comparison, it has more than 2666 characters whih means the formatted output is more than MAX size of string'
            ,@match     = 0
            ,@status_msg= 'TOO LONG TO STORE DETAILED RESULTS'
            ,@code      = -1 -- one of a or b is too long to compare

         EXEC sp_log 3, @fn, '050:', @msg;
         --BREAK;
      END

      -----------------------------------------------------------------
      -- ASSERTION: No previous check failed, strings are same length
      -----------------------------------------------------------------

      EXEC sp_log 1, @fn, '080: detailed check, @lenMax: ', @lenMax;
      SET @i = 0;

      WHILE(@i<=@lenMax)
      BEGIN
         SET @charA = iif(@i<=@lenA, SUBSTRING(@a, @i,1), '_');
         SET @charB = iif(@i<=@lenB, SUBSTRING(@b, @i,1), '_');

         SET @asciA = iif(@i<=@lenA, FORMAT(ASCII(@charA), 'x2'), '  ')
         SET @asciB = iif(@i<=@lenB, FORMAT(ASCII(@charB), 'x2'), 'xx')

      -----------------------------------------------------------------
      -- Only do the HEX thing if have room to store result
      -----------------------------------------------------------------
         if(@i < 2667)
         BEGIN
            SET @CA = CONCAT(@CA, ' ', @asciA);
            SET @CB = CONCAT(@CB, ' ', @asciB);

            
            SET @SA = CONCAT(@SA,
            CASE
               WHEN @charA = CHAR(09) THEN '\t'
               WHEN @charA = CHAR(13) THEN '\r'
               WHEN @charA = CHAR(10) THEN '\n'
               ELSE @charA
            END
            )
            ;

            SET @SB = CONCAT(@SB,
            CASE
               WHEN @charB = CHAR(09) THEN '\t'
               WHEN @charB = CHAR(13) THEN '\r'
               WHEN @charB = CHAR(10) THEN '\n'
               ELSE @charB
            END
            );
         END

         SET @i = @i + 1;

         IF @asciA <> @asciB
         BEGIN
            SELECT 
                @msg       = CONCAT('mismatch at pos: ', @i, ' @lenMax: ',@lenMax,' char: [',@charA,']/[',@charB,'], ASCII: [',@asciA,']/[',@asciB,']')
               ,@code      = 4
               ,@status_msg= 'OK'
               ,@code      = 5 -- length mismatch

            IF @first_time = 1
            BEGIN
               EXEC sp_log 1, @fn, '090: ASCII code mismatch at pos ', @i, ', ASCII codes differ  ASCII: [',@asciA,']/[',@asciB,']';
               SET @first_time = 0;
               SET @match      = 0;
            END
            --BREAK;
         END
      END

      -----------------------------------------------------------------
      -- ASSERTION: if here match already set
      -----------------------------------------------------------------
      SELECT
          @msg       = 'strings match'
         ,@status_msg= 'OK'
         ,@code      = 0 -- match

      --SET @log = CONCAT(@log, '|', '100: strings match');
      BREAK;
   END -- while 1=1 main do loop

   -----------------------------------------------------------------
   -- ASSERTION: @a, @b, @CA, @CB, @msg ARE SET
   -----------------------------------------------------------------
   EXEC sp_log 1, @fn, '100: match:',@match,' status_msg:[', @status_msg, '] code:[', @code, '} @i:', @i,' max len: ', @lenMax;

   INSERT INTO @t( A,  B,  SA,  SB,  CA,  CB,  msg, [match], status_msg,  code, ndx, [log])
   VALUES        (@a, @b, @SA, @SB, @CA, @CB, @msg, @match, @status_msg, @code, @i,  @log);
   --RETURN;
   SELECT * FROM @t;

   if(@match = 0)
   BEGIN
      EXEC sp_log 1, @fn, '025: mismatch:', @nl
,'a:',@SA, @nl
,'b:',@SB, @nl
,'a:',@CA, @nl
,'b:',@CB;
   END
END
/*
EXEC tSQLt.Run 'test.test_037_sp_fnCompareStrings';
EXEC tSQLt.Run 'test.test_018_fnCrtUpdateSql';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: gets the fields from the first row of a tsv file and returns as csl in the @fields out param
--
-- PRECONDITIONS:
-- PRE 01: @file_path must be specified   OR EXCEPTION 58000, 'file must be specified'
-- PRE 02: @file_path exists,             OR EXCEPTION 58001, 'file does not exist'
-- 
-- POSTCONDITIONS:
-- POST01: returns @file_type =
--          1    if tsv file
--          0    if csv file
--          NULL if undecided (when file has only 1 column)
--
-- CALLED BY: sp_get_get_hdr_flds
--
-- TESTS: test.test_sp_get_fields_from_tsv_hdr
--
-- CHANGES:
-- 05-MAR-2024: put brackets around the field names to handle spaces reserved words etc.
-- 05-MAR-2024: added parameter validation
-- 14-NOV-2024: changed the rtn name from s_get_fields_from_tsv_hdr to [sp_get_fields_from_txt_file_hdr
-- 02-DEC-2024: handling csv or tsv files, optionaly displaying the header,
--              returning the file type 0: txt, 1: tsv
-- ==========================================================================================================
CREATE PROCEDURE [dbo].[sp_get_flds_frm_hdr_txt]
    @file            VARCHAR(500)        -- include path
   ,@fields          VARCHAR(2000) OUT   -- comma separated list
   ,@display_tables  BIT = 0
   ,@file_type       BIT OUT -- 0:txt, 1: tsv
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = N'sp_get_flds_frm_hdr_txt'
      ,@cmd       VARCHAR(4000)
      ,@msg       VARCHAR(100)
      ,@row_cnt   INT
      ,@tab_cnt   INT            = 0
      ,@comma_cnt INT            = 0

   EXEC sp_log 2, @fn, '000: starting:
file          :[', @file,']
fields        :[',@fields        ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      SET @file_type = NULL -- initially
      -------------------------------------------------------
      -- Param validation, fixup
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validating inputs';

      --------------------------------------------------------------------------------------------------------
      -- PRE 01: @file_path must be specified   OR EXCEPTION 58000, 'file must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: checking PRE 01';
      EXEC dbo.sp_assert_not_null_or_empty @file, 'file must be specified', @ex_num=58000--, @fn=@fn;

      --------------------------------------------------------------------------------------------------------
      -- PRE 02: @file_path exists,             OR EXCEPTION 58001, 'file does not exist'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: checking PRE 02: @file_path must exist';
      EXEC sp_assert_file_exists @file, @ex_num = 58001, @fn=@fn;

      -------------------------------------------------------
      -- ASSERTION: Passed parameter validation
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '040: ASSERTION: validation passed';

      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '050: importing file hdr row';
      DROP TABLE IF EXISTS hdrCols;

      CREATE TABLE hdrCols
      (fields VARCHAR(MAX));

      ---------------------------------------------------------------
      -- Get the entire header row as 1 column in tmp.fields
      ---------------------------------------------------------------
      SET @cmd = 
         CONCAT
         (
'BULK INSERT [hdrCols] FROM ''', @file, '''
WITH
(
   DATAFILETYPE    = ''Char''
  ,FIRSTROW        = 1
  ,LASTROW         = 1
  ,ERRORFILE       = ''D:\Logs\GET_FLDS_FRM_HDR_TSV.log''
  ,FIELDTERMINATOR = ''\n''
  ,ROWTERMINATOR   = ''\n''
  ,CODEPAGE       = 65001  
);
   ');-- -- CODEPAGE = 1252

      EXEC sp_log 1, @fn, '060:sql: ',@cmd;
      EXEC(@cmd);

      IF @display_tables = 1 SELECT TOP 10 * FROM hdrCols;

      ---------------------------------------------------------------
      -- Tidy the hdr row up
      ---------------------------------------------------------------
      UPDATE hdrCols SET fields = REPLACE(fields, '"','');
      SET @row_cnt = (SELECT COUNT(*) FROM hdrCols);
      EXEC sp_log 1, @fn, '070: @row_cnt: ',@row_cnt;

       ---------------------------------------------------------------
      -- Which is more commas or tabs?
      -- NB: if only 1 column then it does not matter which
      -- but could use the file extension as a guide
      -- csv - comma, tsv: tab, txt ?? could be either
      ---------------------------------------------------------------
      SELECT @tab_cnt   = COUNT(*) FROM hdrCols CROSS APPLY string_split(fields, NCHAR(9)) ;
      SELECT @comma_cnt = COUNT(*) FROM hdrCols CROSS APPLY string_split(fields, ',');
      EXEC sp_log 1, @fn, '080';
      IF ((@tab_cnt = @comma_cnt) AND (@comma_cnt=0))
      BEGIN
      EXEC sp_log 1, @fn, '090';
         DECLARE @ext VARCHAR(10)
         -- implies 1 field so try to get from file extension
         SET @ext = dbo.fnGetFileExtension(@file);
         PRINT @ext;

         SELECT 
             @tab_cnt   = iif(@ext='tsv', 1, 0)
            ,@comma_cnt = iif(@ext='csv', 1, 0) -- .txt can be either - now way then of knowing csv or tsv with 1 col in file
         ;

         EXEC sp_log 3, @fn, '100: file only contains 1 column, so can only deduce from the file ext .tsv or .csv, else will return NULL';
      END

       EXEC sp_log 1, @fn, '110';
     -- Replace tabs with , this works ok with CSVs also
      UPDATE hdrCols SET fields = REPLACE(fields, NCHAR(9), ',');
      SET @fields = (SELECT TOP 1 fields FROM hdrCols);
      EXEC sp_log 1, @fn, '120: fields:[',@fields, ']';
      EXEC sp_assert_gtr_than @row_cnt, 0, 'header row not found (no rows inmported)';

      ---------------------------------------------------------------
      -- SET @file_type       BIT OUT -- 0:txt, 1: tsv, NULL: UNDECIDED
       ---------------------------------------------------------------
     SET @file_type = 
         case
            WHEN (@tab_cnt = @comma_cnt) THEN NULL -- TAB   separated file
            WHEN (@tab_cnt > @comma_cnt) THEN 1    -- COMMA separated file
            ELSE                              0    -- UNDECIDED
         END;

     set @msg       = iif(@file_type = 1, 'tsv', 'csv');

   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '500: bulk insert command was:
',@cmd;
      DROP TABLE IF EXISTS hdrCols;
      THROW;
   END CATCH

   DROP TABLE IF EXISTS hdrCols;
   EXEC sp_log 2, @fn, '999: leaving, OK, @file_type: ',@msg;
END
/*
EXEC tSQLt.Run 'test.test_020_sp_get_flds_frm_hdr_txt';

-----------------------------------------------------------
DECLARE
    @fields       VARCHAR(4000)
   ,@file_type    BIT
;
EXEC dbo.sp_get_flds_frm_hdr_txt 'D:\Dev\Farming\Data\LRAP-240910.txt', @fields  OUT, @file_type = @file_type, @display_tables=1; -- comma separated list
PRINT @fields;
-----------------------------------------------------------
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO





-- =============================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2023
-- Description: lists the columns for the tables
-- =============================================================
CREATE VIEW [dbo].[list_table_columns_vw]
AS
SELECT TOP 10000 
    TABLE_SCHEMA
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,DATA_TYPE
   ,dbo.fnIsTextType(DATA_TYPE) as is_txt
   ,CHARACTER_MAXIMUM_LENGTH
   ,isc.COLLATION_NAME
   ,is_computed
   ,so.[object_id] AS table_oid
   ,so.[type_desc]
   ,so.[type]
FROM [INFORMATION_SCHEMA].[COLUMNS] isc
JOIN sys.objects     so ON so.[name]        = isc.TABLE_NAME
JOIN sys.all_columns sac ON sac.[object_id] =  so.[object_id] AND sac.[name]=isc.column_name
ORDER BY TABLE_NAME, ORDINAL_POSITION;
/*
SELECT column_name FROM list_table_columns_vw where table_name = 'PathogenStaging' and is_txt = 1;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-FEB-2024
-- Description: 
--
-- PRECONDITIONS:
-- PRE 01: @spreadsheet must be specified OR EXCEPTION 58000, 'spreadsheet must be specified'
-- PRE 02: @spreadsheet exists,           OR EXCEPTION 58001, 'spreadsheet does not exist'
-- PRE 03: @range not null or empty       OR EXCEPTION 58002, 'range must be specified'
-- 
-- POSTCONDITIONS:
-- POST01:
--
-- CALLED BY:
-- sp_import_XL_new, sp_import_XL_existing
--
-- TESTS:
--
-- CHANGES:
-- 05-MAR-2024: put brackets around the field names to handle spaces reserved words etc.
-- 05-MAR-2024: added parameter validation
-- ==========================================================================================================
CREATE PROCEDURE [dbo].[sp_get_flds_frm_hdr_xl]
    @import_file  VARCHAR(500)                 -- include path, and optional range
   ,@range        VARCHAR(100) -- = N'Sheet1$'   -- for XL: like 'Table$' OR 'Table$A:B'
   ,@fields       VARCHAR(4000) OUT            -- comma separated list
AS
BEGIN
   DECLARE 
    @fn           VARCHAR(35)   = N'GET_FLDS_FRM_HDR_XL'
   ,@cmd          NVARCHAR(4000)
   ,@n            INT

   EXEC sp_log 1, @fn, '000: starting, 
@import_file:  [', @import_file,']
@range:        [', @range,']
@fields:       [', @fields,']
';

   BEGIN TRY
      -------------------------------------------------------
      -- Param validation, fixup
      -------------------------------------------------------
      SET @n = charindex('!', @import_file, 0);
      IF( @n > 0)
      BEGIN
         SET @range = SUBSTRING(@import_file, @n+1, 100);
         SET @import_file = SUBSTRING(@import_file,1, @n-1);
      END

      -- soert out []$ etc.
      SET @range = dbo.fnFixupXlRange(@range);

      --------------------------------------------------------------------------------------------------------
      -- PRE 01: @spreadsheet must be specified OR EXCEPTION 58000, 'spreadsheet must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: checking PRE 01,. @range: [',@range,']';
      EXEC sp_assert_not_null_or_empty @import_file, 'spreadsheetfile  must be specified', @ex_num=58000--, @fn=@fn;

      --------------------------------------------------------------------------------------------------------
      -- PRE 02: @spreadsheet exists,           OR EXCEPTION 58001, 'spreadsheet does not exist'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: checking PRE 02';

      IF dbo.fnFileExists(@import_file) = 0 
         EXEC sp_raise_exception 58001, @import_file, ' does not exist'--, @fn=@fn

      --------------------------------------------------------------------------------------------------------
      -- PRE 03: @range not null or empty       OR EXCEPTION 58002, 'range must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '025: checking PRE 03';
      EXEC sp_assert_not_null_or_empty @range, 'range must be specified', @ex_num=58002--, @fn=@fn;

      -------------------------------------------------------
      -- ASSERTION: Passed parameter validation
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Passed parameter validation';

      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '040: processing';
      DROP TABLE IF EXISTS temp;

      -- IMEX=1 treats everything as text
      SET @cmd = 
         CONCAT
         (
      'SELECT * INTO temp 
      FROM OPENROWSET
      (
          ''Microsoft.ACE.OLEDB.12.0''
         ,''Excel 12.0;IMEX=1;HDR=NO;Database='
         ,@import_file,';''
         ,''SELECT TOP 2 * FROM ',@range,'''
      )'
         );

      EXEC sp_log 1, @fn, '050: open rowset sql:
   ', @cmd;

      EXEC(@cmd);
      SELECT @fields = string_agg(CONCAT('concat (''['',','', column_name, ','']''',')'), ','','',') FROM list_table_columns_vw WHERE TABLE_NAME = 'temp';
      SELECT @cmd = CONCAT('SET @fields = (SELECT TOP 1 CONCAT(',@fields, ') FROM [temp])');
      EXEC sp_log 1, @fn, '060: get fields sql:
   ', @cmd;

      EXEC sp_executesql @cmd, N'@fields VARCHAR(4000) OUT', @fields OUT;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '500: parameters, 
import_file:  [', @import_file,']
range:        [', @range,']'
;
      THROW
   END CATCH
   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
DECLARE @fields VARCHAR(MAX);
EXEC sp_get_fields_from_xl_hdr 'D:\Dev\Repos\Farming\Data\Distributors.xlsx!Distributors$A:H', @fields OUT;
PRINT @fields;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Description: returns the count crom a query or table
-- Author:      Terry Watts
-- Create date: 17-APR-2025
-- Design:      
-- Tests:       
-- ====================================================
CREATE PROCEDURE [dbo].[sp_GetCount] @sql NVARCHAR(4000)
AS
BEGIN
   DECLARE @cnt   INT
   ;

   SET NOCOUNT ON;

   IF CHARINDEX('SELECT COUNT', @sql) = 0
      SET @sql = CONCAT('SELECT @cnt = COUNT(*) FROM ',@sql);

   PRINT CONCAT('modified SQL: ', @sql);

   EXEC sp_executesql @sql, N'@cnt   INT OUT', @cnt OUT;
   PRINT CONCAT(@sql, ' count: ',@cnt);
   RETURN  @cnt;
END
/*
-------------------------------------------------
DECLARE @cnt   INT;
EXEC @cnt = sp_GetCount '[test].[TstDef]';
PRINT @cnt;
SELECT COUNT(*) FROM country
SELECT COUNT(*) FROM [test].[TstDef]
-------------------------------------------------

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns 'dbo.sp_GetCount @sql'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 05-05-2025
-- Description: 
-- Design:      
-- Tests:       
-- =============================================
CREATE PROCEDURE [dbo].[sp_getSchedule]
    @course_nm  VARCHAR(20) = NULL
   ,@major_nm   VARCHAR(10) = NULL
   ,@day        VARCHAR(3)  = NULL
AS
BEGIN
   SELECT * FROM dbo.fnGetSchedule(@course_nm, @major_nm, @day);
END
/*
EXEC sp_getSchedule NULL, 'BSIT', NULL
EXEC sp_getSchedule  NULL, 'BSIT';
EXEC sp_getSchedule  @major_nm='BSIT';

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- Description: Teams and the team members
-- =============================================================
CREATE VIEW [dbo].[Team_vw]
AS
WITH CTE AS
(
   SELECT
   t.team_id
  ,team_nm
  ,section_nm
  ,string_agg(tm.student_nm, ', ') as members
  ,github_project
  ,team_gc
  ,s.section_id
  ,event_nm

FROM TeamMembers tm
LEFT JOIN Team t on t.team_id = tm.team_id
LEFT JOIN section s ON s.section_id = t.section_id
LEFT JOIN [Event] e ON e.event_id = t.event_id
GROUP BY t.team_id, team_nm, section_nm, s.section_id, github_project, team_gc,event_nm
)
SELECT TOP 1000
  row_number() OVER(ORDER BY team_nm) as row_id
, *
FROM cte
ORDER BY team_nm

/*
SELECT * FROM Team_vw;
EXEC sp_FindStudent 'Niez';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- Description: Teams and the team members 1 row per team member
-- =============================================================
CREATE VIEW [dbo].[TeamMember_vw]
AS
SELECT TOP  10000
    row_number() OVER(ORDER BY event_nm, team_nm, student_nm) as row_id
  , t.team_id
   ,t.team_nm
   ,event_nm
   ,t.section_nm
   ,tm.student_id
   ,tm.student_nm
   ,tm.is_lead
   ,iif(is_lead = 1, 'team lead','member') AS position
   ,github_project
   ,t.section_id
   ,t.team_gc
FROM
     Team_vw t
LEFT JOIN TeamMembers tm ON t.team_id = tm.team_id
ORDER BY team_nm ASC, is_lead DESC, student_nm ASC;
/*
SELECT * FROM TeamMember_vw;
SELECT * FROM Team;
SELECT * FROM Team_vw;
EXEC sp_FindStudent 'Niez';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================
-- Description: returns the team details for the parameters
-- Design:      EA
-- Tests:       test_030_sp_GetTeams
-- Author:      Terry Watts
-- Create date: 5-APR-2025
-- ==========================================================
CREATE FUNCTION [dbo].[fnGetTeams]
(
    @section_nm   VARCHAR(20)
   ,@event_nm     VARCHAR(100)
   ,@team_nm      VARCHAR(40)
   ,@student_nm   VARCHAR(50)
   ,@student_id   VARCHAR(9)
   ,@is_lead      BIT
)
RETURNS @t TABLE
(
    row_id           INT
   ,section_nm       VARCHAR(20)
   ,event_nm         VARCHAR(100)
   ,team_nm          VARCHAR(60)
   ,team_gc          VARCHAR(150) NULL
   ,github_project   VARCHAR(8000) NULL
   ,student_id       VARCHAR(9)
   ,student_nm       VARCHAR(50)
   ,is_lead          BIT
   ,position         VARCHAR(20)
   ,team_id          INT
)
AS
BEGIN
   INSERT INTO @t
(
    row_id
   ,section_nm
   ,event_nm
   ,team_nm
   ,team_gc
   ,github_project
   ,student_id
   ,student_nm
   ,is_lead
   ,position
   ,team_id
)
   SELECT row_number() OVER(ORDER BY event_nm,team_nm, student_nm) as row_id
   ,section_nm
   ,event_nm
   ,team_nm
   ,team_gc
   ,SUBSTRING(github_project, 1, 200)
   ,student_id
   ,student_nm
   ,is_lead
   ,position
   ,team_id

   FROM TeamMember_vw
   WHERE
       (event_nm   LIKE CONCAT('%', @event_nm  , '%') OR @event_nm   IS NULL)
   AND (team_nm    LIKE CONCAT('%', @team_nm   , '%') OR @team_nm    IS NULL)
   AND (student_nm LIKE CONCAT('%', @student_nm, '%') OR @student_nm IS NULL)
   AND (section_nm LIKE CONCAT('%', @section_nm, '%') OR @section_nm IS NULL)
   AND (student_id = @student_id                      OR @student_id IS NULL)
   AND (is_lead    = @is_lead                         OR @is_lead    IS NULL)
   ORDER BY event_nm, team_nm, student_nm
   ;

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_030_sp_GetTeams';
EXEC test.test_030_sp_GetTeams;

SELECT * FROM dbo.fnGetTeams(NULL,NULL,NULL,NULL,NULL,NULL);
SELECT * FROM dbo.fnGetTeams('3B',NULL,NULL,NULL,NULL,NULL);
SELECT * FROM dbo.fnGetTeams(NULL,NULL,NULL,NULL,'2023-1531',NULL);
EXEC sp_GetTeams ;

EXEC dbo.sp_GetTeams @student_nm ='Misoles';
EXEC dbo.sp_GetTeams @student_nm ='Misoles';
EXEC dbo.sp_GetTeams @event_nm = 'Project X Requirements Presentation IT 3C';

*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================
-- Description: returns the team details for the parameters
-- Design:      EA
-- Tests:       test_030_sp_GetTeams
-- Author:      Terry Watts
-- Create date: 5-APR-2025
-- ==========================================================
CREATE PROC [dbo].[sp_GetTeams]
    @section_nm   VARCHAR(20)  = NULL
   ,@event_nm     VARCHAR(100) = NULL
   ,@team_nm      VARCHAR(40)  = NULL
   ,@student_nm   VARCHAR(50)  = NULL
   ,@student_id   VARCHAR(9)   = NULL
   ,@is_lead      BIT          = NULL
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)   = N'SP_GetTeams'
   ,@s_section_nm   VARCHAR(20)  = iif(@section_nm IS NULL ,'<NULL>', @section_nm)
   ,@s_event_nm     VARCHAR(100) = iif(@event_nm   IS NULL ,'<NULL>', @event_nm  )
   ,@s_team_nm      VARCHAR(40)  = iif(@team_nm    IS NULL ,'<NULL>', @team_nm   )
   ,@s_student_nm   VARCHAR(50)  = iif(@student_nm IS NULL ,'<NULL>', @student_nm)
   ,@s_student_id   VARCHAR(9)   = iif(@student_id IS NULL ,'<NULL>', @student_id)
   ,@s_is_lead      VARCHAR(9)   = iif(@is_lead    IS NULL ,'<NULL>', CONVERT(VARCHAR(9), @is_lead))
--      ,@row_cnt   INT
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn,'000: starting, params:
section_nm:[',@s_section_nm,']
event_nm  :[',@s_event_nm  ,']
team_nm   :[',@s_team_nm   ,']
student_nm:[',@s_student_nm,']
student_id:[',@s_student_id,']
is_lead   :[',@s_is_lead   ,']
';

      EXEC sp_log 1, @fn,'010: calling dbo.fnGetTeams(',@s_section_nm,',',@s_team_nm,',',@s_team_nm,',',@s_student_nm,',',@s_student_id,',',@s_is_lead,')';

      SELECT * FROM dbo.fnGetTeams
      (
          @section_nm
         ,@event_nm
         ,@team_nm
         ,@student_nm
         ,@student_id
         ,@is_lead
      );

      EXEC sp_log 1, @fn,'019';
--      SET @row_cnt = @@ROWCOUNT;
      EXEC sp_log 1, @fn,'020';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

  EXEC sp_log 1, @fn,'999: leaving';--, selected ', @row_cnt, ' rows';
END
/*
EXEC dbo.sp_GetTeams @student_nm ='Misoles, Mike A.';
SELECT * FROM team_vw;
EXEC test.test_030_sp_GetTeams;

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_030_sp_GetTeams';
EXEC dbo.sp_GetTeams @event_nm = 'Project X Requirements Presentation IT 3C';
EXEC dbo.sp_GetTeams @event_nm = 'Requ';

Team Powerpuff	GEC E2	2B	2023-2602	Duray, Cristian Dave	NULL
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- Description:
-- 1: Imports all the GMeet attendance from the supplied folder to the staging tables
-- 2: merges the Attendance data into the Main tables
-- Design:      EA
-- Tests:       
-- =============================================
CREATE PROCEDURE [dbo].[sp_Import_All_AttendanceGMeet2]
    @folder          VARCHAR(500)
   ,@display_tables  BIT = 0
AS
BEGIN
   DECLARE @fn VARCHAR(35)= 'sp_ImportAllFilesInFolder'
   SET NOCOUNT ON;

   EXEC sp_log 1, @fn ,'000: starting:
folder        :[', @folder        ,']
';

-- 1: Import all the GMeet attendance from the supplied folder to the staging tables
   TRUNCATE TABLE AttendanceGMeet2Staging;

   EXEC sp_log 1, @fn ,'010: calling sp_ImportAllFilesInFolder -> AttendanceGMeet2Staging table';
   EXEC sp_Import_All_FilesInFolder
                @folder          = @folder
               ,@table           = 'AttendanceGMeet2Staging'
               ,@view            = 'import_AttendanceGMeet2Staging_vw'
               ,@display_tables  = @display_tables
   ;

   EXEC sp_log 1, @fn ,'020: ret frm sp_ImportAllFilesInFolder chking AttendanceGMeet2Staging pop';
   EXEC sp_assert_tbl_pop 'dbo.AttendanceGMeet2Staging', 'AttendanceGMeet2Staging';

-- 2: merge the Attendance data into the Main tables
   EXEC sp_log 1, @fn ,'030: 2: merge the Attendance data into the Main tables';
   EXEC sp_log 1, @fn ,'999: leaving:';
END
/*
EXEC test.test_021_sp_Import_All_AttendanceGMeet2;
EXEC tSQLt.Run 'test.test_021_sp_Import_All_AttendanceGMeet2';

EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ClassScheduleNewStaging](
	[course_id] [varchar](20) NOT NULL,
	[description] [nvarchar](150) NULL,
	[major_nm] [varchar](20) NULL,
	[section_nm] [varchar](20) NOT NULL,
	[days] [varchar](20) NOT NULL,
	[times] [varchar](50) NOT NULL,
	[rooms] [varchar](20) NULL,
 CONSTRAINT [PK_ClassScheduleNewStaging] PRIMARY KEY CLUSTERED 
(
	[course_id] ASC,
	[section_nm] ASC,
	[days] ASC,
	[times] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================
-- Description:    Imports the new format Classschedule table from a tsv
-- Design:         EA
-- Tests:          
-- Author:         Terry Watts
-- Create date:    23-Feb-2025
-- Preconditions:  None
-- Postconditions: ClassSchedule table populated
-- ======================================================================
CREATE PROCEDURE [dbo].[sp_Import_ClassSchedule_new_fmt]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_ClassSchedule_new_fmt'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '020: TRUNCATE TABLE ClassScheduleNewStaging';
      TRUNCATE TABLE ClassScheduleNewStaging;
      EXEC sp_log 1, @fn, '010: calling sp_import_txt_file  @table: ClassScheduleStaging, @file: ',@file;
      EXEC @row_cnt = sp_import_txt_file 'ClassScheduleNewStaging', @file, @field_terminator=@tab;

      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'ClassScheduleNewStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '030: pop ClassSchedule';

      /*
      INSERT INTO ClassSchedule
           (
            dow
           ,[day]
           ,st_time
           ,end_time
           ,course_id
           ,[description]
           ,lec_units
           ,lab_units
           ,tot_units
           ,major_id
           ,section_id
           ,room_id
           ,eus
           )
           SELECT
            dow
           ,[day]
           ,st_time
           ,end_time
           ,course_id
           ,[description]
           ,lec_units
           ,lab_units
           ,tot_units
           ,major_id
           ,section_id
           ,room_id
           ,eus
      FROM ClassScheduleStaging css 
      JOIN Course  c ON c.course_nm = css.course_nm
      JOIN Major   m ON m.major_nm  = css.major_nm
      JOIN Section s ON s.section_nm= css.section_nm
      JOIN Room    R ON r.room_nm =   css.room_nm
      ;
      */

      EXEC sp_log 1, @fn, '040: populated ClassScheduleNew';

      IF @display_tables = 1
      BEGIN
         SELECT * 
         FROM ClassScheduleNewStaging 
         CROSS Apply string_split('days', ',')  as [day]
         CROSS Apply string_split('times', ',') as st_time
         CROSS Apply string_split('rooms', ',') as room
         ;
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
END
/*
EXEC sp_Import_ClassSchedule_new_fmt 'D:\Dorsu\Data\Class Schedule.Schedule 250305.txt', 1;
SELECT distinct Program from ClassScheduleNewStaging;

SELECT * FROM Program;
SELECT * FROM Major;
SELECT * FROM ClassScheduleStaging
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ExamScheduleStaging](
	[id] [varchar](1000) NULL,
	[days] [varchar](1000) NULL,
	[st] [varchar](1000) NULL,
	[end] [varchar](1000) NULL,
	[ex_st] [varchar](1000) NULL,
	[ex_end] [varchar](1000) NULL,
	[ex_date] [varchar](1000) NULL,
	[ex_day] [varchar](1000) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Examschedule](
	[id] [int] NOT NULL,
	[days] [varchar](1000) NOT NULL,
	[st] [varchar](1000) NOT NULL,
	[end] [varchar](1000) NOT NULL,
	[ex_st] [varchar](1000) NOT NULL,
	[ex_end] [varchar](1000) NOT NULL,
	[ex_date] [varchar](1000) NOT NULL,
	[ex_day] [varchar](1000) NOT NULL,
 CONSTRAINT [PK_Examschedule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Author:       Terry Watts
-- Create date:  25-Feb-2025
-- Description:  Imports the ExamSchedule table from a tsv
-- Design:       EA
-- Tests:        test.test_056_sp_Import_AttendanceStaging
-- Preconditions: All dependent tables have been cleared
-- Postconditions: pops the ExamSchedule table and returns row cnt 
-- =================================================================
CREATE PROCEDURE [dbo].[sp_Import_ExamSchedule]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_ExamSchedule'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'ExamScheduleStaging'
--         ,@view            = 'ImportExamSchedule_vw'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = 1
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '015: truncating table ExamSchedule';
      TRUNCATE TABLE ExamSchedule;
      EXEC sp_log 1, @fn, '010: copygn to main table ', @row_cnt,  ' rows';

      INSERT INTO ExamSchedule
      (
            [id]
           ,[days]
           ,[st]
           ,[end]
           ,[ex_st]
           ,[ex_end]
           ,[ex_date]
           ,[ex_day]
       )
       SELECT [id]
           ,[days]
           ,[st]
           ,[end]
           ,[ex_st]
           ,[ex_end]
           ,[ex_date]
           ,[ex_day]
      FROM 
         ExamScheduleStaging;

      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
   RETURN @row_cnt;
END
/*
EXEC test.test_057_sp_Import_ExamSchedule;

EXEC tSQLt.Run 'test.test_057_sp_Import_ExamSchedule';
EXEC tSQLt.RunAll;
// EXEC test.test_057_sp_Import_ExamSchedule'D:\Dorsu\Courses\Courses.Course.txt';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ===========================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- Description: imports an Excel sheet into an existing table
-- returns the row count [optional]
-- 
-- Postconditions:
-- POST01: IF @expect_rows set then expect at least 1 row to be imported or EXCEPTION 56500 'expected some rows to be imported'
--
-- Changes:
-- 05-MAR-2024: parameter changes: made fields optional; swopped @table and @fields order
-- 08-MAR-2024: added @expect_rows parameter defult = yes(1)
-- ===========================================================
CREATE PROCEDURE [dbo].[sp_import_XL_existing]
(
    @import_file  VARCHAR(500)              -- include path, (and range if XL)
   ,@range        VARCHAR(100)              -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@table        VARCHAR(60)               -- existing table
   ,@clr_first    BIT            = 1         -- if 1 then delete the table contets first
   ,@fields       VARCHAR(4000)  = NULL      -- comma separated list
   ,@expect_rows  BIT            = 1
   ,@row_cnt      INT            = NULL  OUT -- optional rowcount of imported rows
   ,@start_row    INT            = NULL
   ,@end_row      INT            = NULL
)
AS
BEGIN
   DECLARE 
    @fn           VARCHAR(35)   = N'sp_import_XL_existing'
   ,@cmd          VARCHAR(4000)

   EXEC sp_log 1, @fn,'005: starting
import_file:[', @import_file,']
range      :[', @range      ,']
table      :[', @table      ,']
clr_first  :[', @clr_first  ,']
fields     :[', @fields     ,']
expect_rows:[', @expect_rows,']
start_row  :[', @start_row  ,']
end_row    :[', @end_row    ,']'
;

   ----------------------------------------------------------------------------------
   -- Process
   ----------------------------------------------------------------------------------
   BEGIN TRY
      IF @clr_first = 1
      BEGIN
         EXEC sp_log 1, @fn,'010: clearing data from table';
         SET @cmd = CONCAT('DELETE FROM [', @table,']');
         EXEC( @cmd)
      END
      EXEC sp_log 1, @fn,'007';

      IF @fields IS NULL
      BEGIN
         EXEC sp_log 1, @fn,'010: getting fields from XL hdr';
         IF @fields IS NULL 
            EXEC sp_get_flds_frm_hdr_xl @import_file, @fields OUT, @range; -- , @range
      END

      EXEC sp_log 1, @fn,'015: importing data';
      SET @cmd = dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @import_file, @range, 0);
      EXEC sp_log 1, @fn, '020 open rowset sql:
', @cmd;

      EXEC( @cmd);
      SET @row_cnt = @@rowcount;
      EXEC sp_log 1, @fn, '22: imported ', @row_cnt,' rows';

      ----------------------------------------------------------------------------------
      -- Check post conditions
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'025: Checking post conditions';
      IF @expect_rows = 1 EXEC sp_assert_gtr_than @row_cnt, 0, 'expected some rows to be imported';--, @fn=@fn;

      ----------------------------------------------------------------------------------
      -- Processing complete
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '950: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '510:';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving OK, imported ', @row_cnt,' rows';
END
/*
EXEC tSQLt.Run 'test.test_010_sp_import_TypeStaging';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- Description: Excel sheet importer into a new table
-- returns the row count [optional]
-- 
-- Postconditions:
-- POST01: IF @expect_rows set then expect at least 1 row to be imported or EXCEPTION 56500 'expected some rows to be imported'
--
-- Changes:
-- 05-MAR-2024: parameter changes: made fields optional; swopped @table and @fields order
-- 08-MAR-2024: added @expect_rows parameter defult = yes(1)
-- ===========================================================================================
CREATE PROCEDURE [dbo].[sp_import_XL_new]
(
    @import_file  VARCHAR(400)        -- path to xls
   ,@range        VARCHAR(100)        -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@table        VARCHAR(60)         -- new table
   ,@fields       VARCHAR(4000) = NULL-- comma separated list
   ,@row_cnt      INT            = NULL  OUT -- optional rowcount of imported rows
   ,@expect_rows  BIT            = 1
   ,@start_row    INT            = NULL
   ,@end_row      INT            = NULL
)
AS
BEGIN
   DECLARE 
    @fn           VARCHAR(35)   = N'IMPRT_XL_NEW'
   ,@cmd          VARCHAR(4000)

   EXEC sp_log 2, @fn,'000: starting:
@import_file:[', @import_file, ']
@range      :[', @range, ']
@table      :[', @table, ']
@fields     :[', @fields, ']
@start_row  :[', @start_row,']
@end_row    :[', @end_row  ,']'
;

   SET @cmd = CONCAT('DROP table if exists [', @table, ']');
   EXEC( @cmd)

   IF @fields IS NULL EXEC sp_get_flds_frm_hdr_xl @import_file, @range, @fields OUT; -- , @range

   EXEC sp_log 2, @fn,'010: importing data';
   SET @cmd = ut.dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @import_file, @range, 1);
   EXEC sp_log 2, @fn,'020: import cmd:
', @cmd;
   EXEC( @cmd);

   SET @row_cnt = @@rowcount;
   IF @expect_rows = 1 EXEC sp_assert_gtr_than @row_cnt, 0, 'expected some rows to be imported';

   EXEC sp_log 2, @fn, '999: leaving OK, imported ', @row_cnt,' rows';
END
/*
EXEC dbo.sp_import_XL_new 'D:\Dev\Repos\Farming_Dev\Data\ForeignKeys.xlsx', 'Sheet1$', 'ForeignKeys';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a txt (csv or tsv) or xlsx file
--
-- Parameters:    Mandatory,optional M/O
-- @import_file  [M] the import source file can be a tsv or xlsx file
--                   if an XL file then the normal format for the sheet is field names in the top row including an id for ease of debugging 
--                   data issues
-- @table        [O] the table to import the data to. 
--                if an XL file defaults to sheet name if not Sheet1$ otherwise file name less the extension
--                if a tsv defaults to file name less the extension
-- @view         [O] if a tsv this is the view used to control which columns are used n the Bulk insert command
--                   the default is NULL when the view name is constructed as import_<table name>_vw
-- @range        [O] for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$' default is 'Sheet1$'
-- @fields       [O] for XL: comma separated list
-- @clr_first    [O] if 1 then delete the table contents first           default is 1
-- @is_new       [O] if 1 then create the table - this is a double check default is 0
-- @expect_rows  [O] optional @expect_rows to assert has imported rows   default is 1
--
-- Preconditions: none
--
-- Postconditions:
-- POST01: @import file must not be null or ''             OR exception 63240, 'import_file must be specified'
-- POST02: @import file must exist                         OR exception 63241, 'import_file must exist'
-- POST03: if @is_new is false then (table must exist      OR exception 63242, 'table must exist if @is_new is false')
-- POST04: if @is_new is true  then (table must not exist  OR exception 63243, 'table must not exist if @is_new is true'))
-- 
-- RULES:
-- RULE01: @table:  if xl import then @table must be specified or deducable from the sheet name or file name OR exception 63245
-- RULE02: @table:  if a tsv then must specify table or the file name is the table 
-- RULE03: @view:   if a tsv file then if the view is not specified then it is set as Import<table>_vw
-- RULE04: @range:  if an Excel file then range defaults to 'Sheet1$'
-- RULE05: @fields: if an Excel file then @fields is optional
--                  if not specified then it is taken from the excel header (first row)
-- RULE07: @is_new: if new table and is an excel file and @fields is null then the table is created with fields taken from the spreadsheet header.
--
-- Changes:
-- 240326: added an optional root dir which can be specified once by client code and the path constructed here
-- ================================================================================================================================================
CREATE PROCEDURE [dbo].[sp_import_file]
    @import_file  VARCHAR(1000)
   ,@import_root  VARCHAR(1000)  = NULL
   ,@table        VARCHAR(60)    = NULL
   ,@view         VARCHAR(60)    = NULL
   ,@range        VARCHAR(100)   = N'Sheet1$'   -- POST09 for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@field_sep    VARCHAR(1)     = NULL
   ,@fields       VARCHAR(4000)  = NULL         -- for XL: comma separated list
   ,@clr_first    BIT            = 1            -- if 1 then delete the table contents first
   ,@is_new       BIT            = 0            -- if 1 then create the table - this is a double check
   ,@first_row    INT            = NULL
   ,@last_row     INT            = NULL
   ,@expect_rows  BIT            = 1            -- optional @expect_rows to assert has imported rows
   ,@row_cnt      INT            = NULL OUT     -- optional count of imported rows
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
    @fn              VARCHAR(35)= N'sp_import_file'
   ,@bckslsh         VARCHAR(1) = NCHAR(92)
   ,@tab             VARCHAR(1) = NCHAR(9)
   ,@nl              VARCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@ndx             INT
   ,@file_name       VARCHAR(128)
   ,@table_exists    BIT
   ,@is_xl_file      BIT
   ,@txt_file_ty     BIT -- 0:txt, 1: tsv
   ,@msg             VARCHAR(500)

   PRINT '';
   EXEC sp_log 1, @fn, '000: starting';

   EXEC sp_log 1, @fn, '001: parameters,
import_file:  [', @import_file,']
table:        [', @table,']
view:         [', @view,']
range:        [', @range,']
fields:       [', @fields,']
clr_first:    [', @clr_first,']
is_new        [', @is_new,']
expect_rows   [', @expect_rows,']
first_row     [', @first_row,']
last_row      [', @last_row,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '005: initial checks';
      EXEC sp_log 0, @fn, '010: checking POST01';
      ----------------------------------------------------------------------------------------------------------
      -- POST01: @import file must not be null or '' OR exception 63240, 'import_file must be specified'
      ----------------------------------------------------------------------------------------------------------
      IF @import_file IS NULL OR @import_file =''
      BEGIN
         SET @msg = 'import file must be specified';
         EXEC sp_log 4, @fn, '011 ',@msg;
         THROW 63240, @msg, 1;
      END

      IF @import_root IS NOT NULL
      BEGIN
         SET @import_file = CONCAT(@import_root, @bckslsh, @import_file);
         EXEC sp_log 1, @fn, '010: ,
modified import_file:  [', @import_file,']';
      END

      ----------------------------------------------------------------------------------------------------------
   -- POST02: @import file must exist  OR exception 63241, 'import_file must exist'
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '025: checking POST02';
      IF dbo.fnFileExists(@import_file) <> 1
      BEGIN
         EXEC sp_log 1, @fn, '030: checking POST02'
         SET @msg = CONCAT('import file [',@import_file,'] must exist');
         EXEC sp_log 4, @fn, '040 ',@msg;
         THROW 63241, @msg, 1;
      END

      EXEC sp_log 1, @fn, '050';
      SET @is_xl_file = IIF( CHARINDEX('.xlsx', @import_file) > 0, 1, 0);

      ----------------------------------------------------------------------------------------------------------
      -- Handle defaults
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '060: handle defaults';
      IF @range     IS NULL SET @range =  N'Sheet1$';
      IF @clr_first IS NULL SET @clr_first = 1;

      IF @table IS NULL
      BEGIN
         EXEC sp_log 1, @fn, '070: @table not specified so getting table';

         IF @is_xl_file = 1
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- POST06: @table: if xl import then @table must be specified or deducable from the sheet name or file name OR exception 63245
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '080: is an XL import, @range:[',@range,']';

            IF SUBSTRING(@range, 1, 7)<> 'Sheet1$'
            BEGIN
               SET @ndx   = CHARINDEX('$', @range);
               SET @table = SUBSTRING(@range, 1, @ndx-1);
               EXEC sp_log 1, @fn, '083: range is not Sheet1$, table: [',@table,']';
            END
            ELSE
            BEGIN
               IF @ndx = 1 SET @ndx = dbo.fnLen(@range);
               SET @table = dbo.fnGetFileNameFromPath(@import_file,0);
               EXEC sp_log 1, @fn, '083: range is Sheet1$, table: [',@table,']';
            END
         END
         ELSE
         BEGIN
             EXEC sp_log 1, @fn, '090: is text import';
           ----------------------------------------------------------------------------------------------------------
            -- POST07: @table: if a tsv then must specify table or the file name is the table
            ----------------------------------------------------------------------------------------------------------
            SET @table = dbo.fnGetFileNameFromPath(@import_file,0);
         END

         EXEC sp_log 1, @fn, '100: chk table exists';

         IF dbo.fnTableExists(@table)=0
         BEGIN
            EXEC sp_log 1, @fn, '110: deduced table name:[', @table,'] does not exist, setting @table NULL';
            SET @table = NULL;
         END

         EXEC sp_log 1, @fn, '120: deduced table name:[', @table,']';
      END

      EXEC sp_log 1, @fn, '130: table:[', @table,']';
      SET @table_exists = iif( @table IS NOT NULL AND dbo.fnTableExists(@table)<>0, 1, 0);

      ----------------------------------------------------------------------------------------------------------
      -- RULE03: @view:  if a tsv file then if the view is not specified then it is set as Import<table>_vw
      ----------------------------------------------------------------------------------------------------------
      IF @view IS NULL AND @table_exists = 1  AND @is_xl_file = 0 
      BEGIN
         SET @view = CONCAT('Import_',@table,'_vw');
         EXEC sp_log 1, @fn, '140: if a tsv file and the view is not specified then set view default value as Import_<table>_vw: [',@view,']'
      END

      ----------------------------------------------------------------------------------------------------------
      -- Parameter Validation
      ----------------------------------------------------------------------------------------------------------

      ----------------------------------------------------------------------------------------------------------
      -- RULE05: @fields:if an Excel file then @fields is optional
      --          if not specified then it is taken from the excel header (first row)
      -- RULE07: @is_new: if new table and is an excel file and @fields is null then the table is created with
      --         fields taken from the spreadsheet header.

      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '150: checking rule 5,11';
      IF @fields IS NULL
      BEGIN
         IF @is_xl_file = 1
         BEGIN
            EXEC sp_get_flds_frm_hdr_xl @import_file, @range=@range, @fields=@fields OUT;
            EXEC sp_log 1, @fn, '160: is xl file and the fields are not specified then defaulting @fields to: [',@fields,']'
         END
         ELSE
         BEGIN
            EXEC sp_log 1, @fn, '170: calling sp_get_flds_frm_hdr_txt';
            EXEC sp_get_flds_frm_hdr_txt
                @file            = @import_file
               ,@fields          = @fields OUT
               ,@display_tables   = 0
               ,@file_type        = @txt_file_ty OUT -- 0:txt, 1: tsv
               ;

            EXEC sp_log 1, @fn, '180: ret frm sp_get_flds_frm_hdr_txt';
            -- try by name
            IF @field_sep IS NULL
               SET @field_sep = iif(@txt_file_ty=0, 'txt','tsv');
         END
      END

      EXEC sp_log 1, @fn, '190';
      --------------------------------------------------------------------------------------------------------------------
   -- POST03: if @is_new is false then (table must exist OR exception 63242, 'table must exist if @is_new is false')
      --------------------------------------------------------------------------------------------------------------------
      IF @is_new = 0 AND @table_exists = 0
      BEGIN
         SET @msg = 'table must exist if @is_new is false';
         EXEC sp_log 4, @fn, '200 ',@msg;
         THROW 63244, @msg, 1;
      END

      EXEC sp_log 1, @fn, '210';
      -----------------------------------------------------------------------------------------------------------------
   -- POST04: if @is_new is true then (table does not exist  OR ex 63243, 'table must not exist if @is_new is true'))
      -----------------------------------------------------------------------------------------------------------------
      IF @is_new = 1 AND @table_exists = 1
      BEGIN
         SET @msg = 'table must not exist if @is_new is true';
         EXEC sp_log 4, @fn, '220 ',@msg;
         THROW 63243, @msg, 1;
      END

      --****************************************
      -- Import the file
      --****************************************
      EXEC sp_log 1, @fn, '230: Importing file';

      IF @is_xl_file = 1
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Import Excel file
         ----------------------------------------------------------------------------------------------------------
         -- Parameter Validation
         EXEC sp_log 1, @fn, '240: Importing Excel file, fixup the range:',@range,'|';

         -- Fixup the range
         SET @range = dbo.fnFixupXlRange(@range);
         EXEC sp_log 1, @fn, '250: Importing Excel file, fixed up the range:',@range,'|';

         ----------------------------------------------------------------------------------------------------------
         -- RULE05: @fields:if an Excel file then @fields is optional
         --          if not specified then it is taken from the excel header (first row)
         -- RULE07: @is_new: if new table and if an Excel file and @fields is null 
         --         then the table is created with fields taken from the spreadsheet header
         ----------------------------------------------------------------------------------------------------------
         --EXEC sp_log 1, @fn, '085: calling sp_get_fields_from_xl_hdr';
         --EXEC sp_get_fields_from_xl_hdr @import_file, @range, @fields OUT;
         --EXEC sp_log 1, @fn, '087: ret frm sp_get_fields_from_xl_hdr';

         IF @is_new = 1
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- Importing Excel file to new table
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '260: Importing Excel file to new table';
            EXEC sp_import_XL_new @import_file, @range, @table, @fields, @row_cnt=@row_cnt OUT;
         END
         ELSE
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- Importing Excel file to existing table @range,
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '270: Importing Excel file to existing table';
            EXEC sp_import_XL_existing @import_file,  @table, @clr_first, @fields, @end_row=@first_row/*,@last_row=@last_row*/, @row_cnt=@row_cnt OUT;
            EXEC sp_log 1, @fn, '280:';
         END

         EXEC sp_log 1, @fn, '290: Imported Excel file';
      END
      ELSE
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Importing txt file
         ----------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '300: Importing tsv file';

         ----------------------------------------------------------------------------------------------------------
         -- POST12: @is_new: if this is set then the table is created with fields based on the spreadsheet header
         ----------------------------------------------------------------------------------------------------------

         --EXEC sp_bulk_import_tsv @import_file, @view, @table, @clr_first, @first_row=@first_row,@last_row=@last_row, @row_cnt=@row_cnt OUT;
         EXEC sp_import_txt_file
             @table           = @table
            ,@file            = @import_file
            ,@field_terminator= @field_sep
            ,@row_terminator  = N'\r\n'
            ,@first_row       = @first_row
            ,@last_row        = @last_row
            ,@clr_first       = @clr_first
            ,@view            = @view
            ,@format_file     = NULL
            ,@expect_rows     = 1
            ,@exp_row_cnt     = NULL
            ,@non_null_flds   = NULL
            ,@display_table   = 0
            ,@row_cnt         = @row_cnt OUT
      END

      ----------------------------------------------------------------------------------------------------------
      -- Checking post conditions
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '310: Checking post conditions'

      IF @expect_rows = 1
         EXEC sp_assert_tbl_pop @table;

      ---------------------------------------------------------------------
      -- Completed processing OK
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '320: Completed processing OK'
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;

      EXEC sp_log 1, @fn, '520: parameters:
import_file:  [', @import_file,']
import_root:  [', @import_root,']
table:        [', @table,']
view:         [', @view,']
range:        [', @range,']
fields:       [', @fields,']
clr_first:    [', @clr_first,']
is_new        [', @is_new,']
expect_rows   [', @expect_rows,']
';

      EXEC sp_log 1, @fn, '530: state:
   @table_exists:  [', @table_exists,']
   @is_xl_file     [', @is_xl_file,']';

      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving OK, imported ',@row_cnt,' rows to the ',@table,'  table from ',@import_file;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_085_sp_bulk_import';
EXEC test.test_085_sp_import_file;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:         Terry Watts
-- Create date:    09-Jun-2025
-- Description:    Imports the FileActivityStaging table from a tsv
-- Design:         EA
-- Tests:          test_066_sp_Import_FileActivityStaging
-- Preconditions: 
-- Postconditions:
-- =================================================================
CREATE PROCEDURE [dbo].[sp_Import_FileActivitystaging]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = ','
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_FileActivityStaging'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'FileActivityLogStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
END
/*
EXEC test.test_066_sp_Import_FileActivityStaging;

EXEC sp_Import_FileActivitystaging 'D:\Dorsu\Data\FileActivityLog.tsv';

EXEC tSQLt.Run 'test.test_066_sp_Import_FileActivityStaging';
EXEC tSQLt.RunAll;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 23-FEB-2025
-- Description: lists the students and their courses
-- =============================================================
CREATE VIEW [dbo].[Enrollment_vw]
AS
SELECT 
    enrollment_id
   ,e.student_id
   ,s.student_nm
   ,gender
   ,course_nm
   ,section_nm
   ,major_nm
   ,c.course_id
   ,e.section_id
   ,m.major_id
FROM Student s 
LEFT JOIN Enrollment e ON s  .student_id = e.student_id
LEFT JOIN Course  c   ON c  .course_id  = e.course_id
LEFT JOIN Section sec ON sec.section_id = e.section_id
LEFT JOIN Major m     ON m.major_id     = e.major_id
;
/*
SELECT * FROM Enrollment_vw
ORDER BY student_id, course_nm, section_nm
;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports G Meet attendance
--
-- Notes: Will truncate table ClassSchedule
-- Design:         EA
-- Tests:          
-- Author:         Terry Watts
-- Create date:    14-Mar-2025
-- Preconditions:  None
-- Postconditions: AttendanceGMeetStaging populated
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_GMeetAttendance]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@date            DATE
   ,@class_start     INT -- 24 hr clock time like 0830
   ,@course_nm       NVARCHAR(20)
   ,@section_nm      NVARCHAR(20)
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              VARCHAR(35) = 'sp_ImportGMeetAttendance'
      ,@tab_str         NCHAR(5)    = iif(@sep = 0x09, '<TAB>', ',')
      ,@row_cnt         INT         = 0
      ,@class_start_str VARCHAR(4)
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting,
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
date:          [',@date          ,']
class_start:   [',@class_start   ,']
course_nm:     [',@course_nm     ,']
section_nm:    [',@section_nm    ,']
display_tables:[',@display_tables,']
';

      --------------------------------------------------------------
      -- Validation
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validation';

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------
      TRUNCATE TABLE AttendanceGMeetStaging;
      TRUNCATE TABLE AttendanceGMeet;

      --------------------------------------------------------------
      -- Process
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: process';
      SET @class_start_str = FORMAT(@class_start, '0000');

      EXEC @row_cnt = sp_import_txt_file
         @table           = 'AttendanceGMeetStaging'
        ,@file            = @file
        ,@folder          = @folder
        ,@view            = 'ImportGMeetAttendanceStaging_vw'
        ,@field_terminator= @sep
        ,@display_table   = @display_tables
        ,@non_null_flds   = NULL
       ;

      EXEC sp_log 1, @fn, '030: imported ', @row_cnt,  ' rows';

      EXEC sp_log 1, @fn, '040: performing fixup';
      EXEC sp_fixup_AttendanceGMeetStaging @course_nm, @section_nm;

      IF @display_tables = 1
         SELECT * FROM AttendanceGMeetStaging;

      -- Populate AttendanceGMeet
      EXEC sp_log 1, @fn, '050: Populate AttendanceGMeet table';

      INSERT INTO AttendanceGMeet (student_id, student_nm, [date], class_start, course_nm, section_nm)
      SELECT a.student_id, a.candidate_nm, @date, @class_start_str, course_nm, section_nm
      FROM AttendanceGMeetStaging a
      LEFT JOIN Student s ON s.student_nm = a.line
      LEFT JOIN Enrollment_vw e ON a.student_id = e.student_id
      ;

      IF @display_tables = 1
         SELECT * FROM AttendanceGMeet;

      EXEC sp_log 1, @fn, '050: fixup complete';

      --------------------------------------------------------------
      -- Process complete
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '399: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC tSQLt.Run 'test.test_011_sp_ImportGMeetAttendance';

EXEC sp_ImportGMeetAttendance 'D:\Dorsu\Data\Attendance 250314.txt', '3/15/2025', 1500, 'ITC130', 'ITC_3C';

SELECT * FROM GMeetAttendance;
EXEC test.sp__crt_tst_rtns 'sp_ImportGMeetAttendance'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Description:  Imports theGoogleNameStaging table from a tsv
-- Design:       EA
-- Tests:        test_031_sp_Import_GoogleAlias
-- Author:       Terry watts
-- Create date:  2-Apr-2025
-- Preconditions: All dependent tables have been cleared
-- ============================================================
CREATE PROCEDURE [dbo].[sp_Import_GoogleAlias]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_GoogleAlias'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'GoogleAlias'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;
      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';

      -- Camelcase
      UPDATE GoogleAlias SET google_alias = dbo.fnCamelCase(google_alias);

      EXEC sp_log 1, @fn, '020: updating the Student table';

      UPDATE Student
      SET google_alias = ga.google_alias
      FROM GoogleAlias ga JOIN Student s ON ga.student_id = s.student_id

      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
END
/*
EXEC test.test_031_sp_Import_GoogleAlias;

EXEC tSQLt.Run 'test.test_031_sp_Import_GoogleNameStaging';
DELETE FROM GoogleAlias WHERE student_id IS NULL;
EXEC sp_Import_GoogleAlias 'D:\Dorsu\Data\GoogleNames.GEC E2 2B.txt', 1, 1;
EXEC sp_Import_GoogleAlias 'D:\Dorsu\Data\GoogleNames.GEC E2 2D.txt', 1, 0;
SELECT * FROM Student;
EXEC sp_FindStudent2 '2023-0474';

SELECT Student_id, count(Student_id) 
FROM GoogleAlias
GROUP BY Student_id
ORDER BY count(Student_id) DESC


EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 17-MAY-2025
--
-- Description: splits a MC50 row into its component parts
--
-- Postconditions:
-- Post 01: 
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitMC50Row]
(
    @row VARCHAR(500) -- qualified routine name
)
RETURNS @t TABLE
(
    student_id    VARCHAR(1000)
   ,student_name  VARCHAR(1000)
   ,gender        CHAR(1)
   ,section_nm    VARCHAR(20)
   ,ordinal       INT
   ,answer        VARCHAR(10)
)
AS
BEGIN
   DECLARE
    @pos          INT
   ,@tab          CHAR = CHAR(9)
   ,@student_id   VARCHAR(9)
   ,@student_name VARCHAR(50)
   ,@gender       CHAR
   ,@section_nm   VARCHAR(20)
   ;
   SELECT 
       @student_id     = [1]
      ,@student_name   = [2]
      ,@gender         = [3]
      ,@section_nm     = [4]
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num,
         TRIM(value) as value
    FROM
     STRING_SPLIT(@row, CHAR(9))
) AS src
PIVOT (
    MAX(value) FOR row_num IN ([1], [2], [3], [4])
) AS pvt;

   SET @pos = dbo.fnFindNthOccurrence(@row, @tab, 4)+1;

   SET @row = SUBSTRING(@row, @pos, dbo.fnLen(@row)-@pos);
   INSERT INTO @t (student_id, student_name, gender, section_nm, ordinal, answer)
   SELECT         @student_id,@student_name,@gender,@section_nm, ordinal, value
   FROM string_split(@row, @tab, 1)
   ;

   RETURN;
END
/*
SELECT * FROM fnSplitMC50Row('2023-2326	Caldoza, Psyche A.	F	2D	C	AC	BCE	BCE	AC	CDE	BD	ADE	CE	AD	ADE	CE	AE	E	CE	ACE	D	ACDE	A	DE	DE	ABC	AC	C	CDE	C	BCE	E	BCD	DE	AD	BDE	ACD	ABCD	A	BCD	A	BCE	ABD	BCE	A	D	ACE	BDE	BCD	BCE	AD	BCD	AE	BC	')
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[MC50_StudentAnswer](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NOT NULL,
	[ordinal] [int] NULL,
	[answer] [varchar](8) NULL,
	[score] [float] NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[MC50_Answers](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ordinal] [int] NOT NULL,
	[answer] [varchar](10) NOT NULL,
 CONSTRAINT [PK_MC50_Answers] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 18-MAY-2025
-- Description: displays MC50 scores
-- =============================================================
CREATE VIEW [dbo].[MC50_StudentAnswer_vw]
AS
   SELECT
       sa.id
      ,sa.student_id
      ,sa.ordinal
      ,sa.answer AS act_answer
      ,e.answer AS exp_answer
      ,score
   FROM MC50_StudentAnswer sa JOIN MC50_Answers e
      ON sa.ordinal=e.ordinal;

/*
SELECT * FROM MC50_StudentAnswer_vw WHERE act_answer <> '';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[MC50_Scores](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[student_id] [varchar](9) NOT NULL,
	[score] [float] NULL,
 CONSTRAINT [PK_MC50_hdr] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 18-MAY-2025
-- Description: displays MC50 scores
-- =============================================================
CREATE VIEW [dbo].[MC50_scores_vw]
AS
   SELECT s.student_id, student_nm, score
   FROM MC50_scores m JOIN Student s
      ON m.student_id = s.student_id;

/*
SELECT * FROM MC50_scores_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[MC50_staging](
	[staging] [varchar](8000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_MC50_staging] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Author:       Tewrry Watts
-- Create date:  17-May-2025
-- Description:  Imports the Classschedule table from a tsv
-- Design:       EA
-- Tests:        test_062_sp_Import_MC50
-- Preconditions: 
-- Postconditions: 
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_MC50]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn           VARCHAR(35) = 'sp_Import_MC50'
      ,@tab          NCHAR(1)=NCHAR(9)
      ,@nl           NCHAR(1)=NCHAR(13)
      ,@row_cnt      INT = 0
      ,@sql          VARCHAR(8000)
      ,@answer_str   VARCHAR(8000)
      ,@max_score    FLOAT
   ;

   EXEC sp_log 1, @fn, '000: starting
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY

      IF @folder IS NOT NULL
         SET @file = CONCAT(@folder, '\', @file);

      IF @clr_first = 1
         TRUNCATE TABLE MC50_staging;

      -----------------------------------------------
      -- Load the staging table
      -----------------------------------------------

      SELECT @sql = CONCAT('BULK INSERT MC50_staging
FROM ''', @file, '''
WITH (
    FORMATFILE = ''D:\Dorsu\Data\MC50.fmt''
);'
);

      EXEC sp_log 1, @fn, '010: SQL ', @nl, @sql;
      EXEC (@sql);
      SELECT @row_cnt = COUNT(*) FROM MC50_staging;
      EXEC sp_log 1, @fn, '020: imported ', @row_cnt,  ' rows';

      If @display_tables = 1
         SELECT * FROM MC50_staging;

      -----------------------------------------------
      -- Pop the answer table
      -----------------------------------------------
      EXEC sp_log 1, @fn, '030: pop answer table ';
      SELECT @answer_str = SUBSTRING(staging, CHARINDEX('Answer', staging)+7, 8000)
      FROM MC50_staging
      WHERE id = 2;

      EXEC sp_log 1, @fn, '040: @answer_str ', @answer_str;
      SELECT @answer_str as answers;
      TRUNCATE TABLE MC50_answers;

      INSERT INTO MC50_answers(ordinal, answer)
      SELECT ordinal, TRIM(value)
      FROM string_split(@answer_str, @tab, 1);

      UPDATE MC50_answers
      SET answer = dbo.fnTrim(answer);

      If @display_tables = 1
         SELECT * FROM MC50_answers;

      -----------------------------------------------
      -- Pop the student answers
      -----------------------------------------------
      EXEC sp_log 1, @fn, '050: populating MC50_StudentAnswer table';
      TRUNCATE TABLE MC50_StudentAnswer;

      INSERT INTO MC50_StudentAnswer(student_id, ordinal, answer)
      SELECT     student_id, b.ordinal,TRIM(b.answer)
      FROM MC50_staging a CROSS APPLY dbo.fnSplitMC50Row(a.staging) b
      WHERE a.id>4;

      If @display_tables = 1
         SELECT * FROM MC50_studentAnswer;

      -----------------------------------------------
      -- Score the answers
      -----------------------------------------------
      EXEC sp_log 1, @fn, '060: Score the answers';

      -- Get the max score
      SELECT @max_score = SUM(dbo.fnScoreMC50Answer(answer, answer, 0.2))
      FROM MC50_Answers;

      UPDATE MC50_StudentAnswer
      SET score = dbo.fnScoreMC50Answer(e.answer, a.answer, 0.2)
      FROM MC50_StudentAnswer a JOIN MC50_Answers e ON a.ordinal = e.ordinal
      ;

      IF @display_tables = 1
         SELECT * FROM MC50_StudentAnswer_vw;

      IF EXISTS
      (
         SELECT 1
         FROM MC50_StudentAnswer
         WHERE score < -10.0 OR score > 10.0
      )
      BEGIN
         --EXEC sp_log 4, @fn, '070: ERROR bad character in question or answer @max_score: ',@max_score;
         SELECT * FROM MC50_StudentAnswer_vw
         WHERE score <-10.0 OR score > 10.0;
         THROW 51005, '080: ERROR bad character in score', 1;
      END

      -----------------------------------------------
      -- Total the scores for each student
      -----------------------------------------------
      EXEC sp_log 1, @fn, '090: Total the scores for each student, @max_score= ',@max_score;
      TRUNCATE TABLE MC50_scores;

      INSERT INTO MC50_scores(student_id, score)
      SELECT student_id, ROUND(SUM(score) / @max_score * 100.0, 2)
      FROM MC50_studentAnswer
      GROUP BY student_id;

      --EXEC sp_log 1, @fn, '060: Score the answers';

      If @display_tables = 1
         SELECT * FROM MC50_scores_vw ORDER BY score DESC;

      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
END
/*
EXEC test.test_062_sp_Import_MC50;
   Answer C AC BCE CE AC DE BCD DE ABCE CE AE CE AE E BCE AC D ABCDE A C ABC BC ACD C BCE C BCE E BCDE BCE ACD BDE ACD BC A BCD A BCE BCD BCE BE C AC BCE BCD BCE ACE BDE ABD BC 
EXEC tSQLt.Run 'test.test_062_sp_Import_MC50';
EXEC sp_importAllStudentCourses;
 C AC BCE CE AC DE BCD DE ABCE CE AE CE AE E BCE AC D ABCDE A C ABC BC ACD C BCE C BCE E BCDE BCE ACD BDE ACD BC A BCD A BCE BCD BCE BE C AC BCE BCD BCE ACE BDE ABD BC 
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_Import_MC50]';
BC --
BC --
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the Semester table from a tsv
-- Notes:
-- Design:      EA
-- Tests:       test_032_sp_Import_Semester
-- Author:      Terry Watts
-- Create date: 06-APR-2025
-- Preconditions: none
-- Postconditions: Semester popd
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Semester]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_Semester'
      ,@tab       NCHAR(1)    = NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------
      IF dbo.fnFkExists('FK_Enrollment_Semester') = 1
      BEGIN
         EXEC sp_log 1, @fn, '010: dropping FK_Enrollment_Semester';
         ALTER TABLE dbo.Enrollment DROP CONSTRAINT IF EXISTS FK_Enrollment_Semester;
      END

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'Semester'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '020: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '030: recreating FK_Enrollment_Semester';
      ALTER TABLE Enrollment WITH CHECK ADD CONSTRAINT FK_Enrollment_Semester FOREIGN KEY(semester_id)
      REFERENCES Semester(semester_id);
      ALTER TABLE Enrollment CHECK CONSTRAINT FK_Enrollment_Semester;
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;

      IF dbo.fnFkExists('FK_Enrollment_Semester') = 0
      BEGIN
         EXEC sp_log 1, @fn, '510: recreating FK_Enrollment_Semester';
         ALTER TABLE Enrollment WITH CHECK ADD CONSTRAINT FK_Enrollment_Semester FOREIGN KEY(semester_id)
         REFERENCES Semester(semester_id);
         ALTER TABLE Enrollment CHECK CONSTRAINT FK_Enrollment_Semester;
      END

      ;THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC sp_Import_Semester 'D:\Dorsu\Data\Rooms.rooms.txt', 1;
EXEC tSQLt.Run 'test.test_032_sp_Import_Semester';
SELECT * FROM Semester;
EXEC test.sp__crt_tst_rtns '[dbo].[sp_Import_Semester]';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 11-APR-2025
-- Description: determines if @s is in DORSU student id fmt 
--
-- Changes:
-- ====================================================================
CREATE proc [dbo].[sp_IsStudentId] @v VARCHAR(20)
--RETURNS BIT
AS
BEGIN
   DECLARE
       @fn     VARCHAR(35)    = N'sp_IsStudentId'
      ,@s      VARCHAR(1000)
      ,@a      VARCHAR(5)
      ,@b      VARCHAR(5)
      ,@ret    INT            = 0
      ,@n      INT
   ;

      EXEC sp_log 1, @fn ,' starting
@V    :[', @v    ,']
';

   WHILE 1=1
   BEGIN
      -- Check the length
      SET @n = dbo.fnLen(@v);
      IF @n <> 9 -- returns 0 bad length
      BEGIN
         EXEC sp_log 1, @fn, 'Len(@v) <> 9: [',@n,']';
         BREAK;
      END

      -- Check contains a - in pos 5
      IF SUBSTRING(@v, 5,1) <> '-'
      BEGIN
         EXEC sp_log 1, @fn, 'SUBSTRING(@v, 5,1) <> ''-''';
         BREAK;
      END

      -- Check both parts are ints
      SELECT 
          @a = schema_nm
         ,@b = rtn_nm
      FROM dbo.fnSplitQualifiedName(@v)
      ;

      IF dbo.fnIsInt(@a) = 0
      BEGIN
         EXEC sp_log 1, @fn, 'part 1 [', @a, '] is not int'
         BREAK;
      END

      IF dbo.fnIsInt(@b) = 0
      BEGIN
         EXEC sp_log 1, @fn, 'part 2  [', @b, '] is not int'
         BREAK;
      END

      SET @ret = 1;
      BREAK;
   END

   EXEC sp_log 1, @fn ,' leaving ret: ', @ret ;
   RETURN @ret;
END
/*
EXEC tSQLt.Run 'test.test_035_fnIsStudentId';
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[fnIsStudentId]';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceDates](
	[ordinal] [bigint] NOT NULL,
	[value] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================
-- Procedure:     sp_crt_attendance_col_map
-- Description:   populates the AttendanceDates table
-- Design:        EA: Model.Use Case Model.Attendance
-- Preconditions  Attendance table pop
-- Postconditions Post 01: AttendanceDates pop
-- Tests:         test_013_sp_pop_AttendanceDates
-- Author:        ME!
-- Create date:   18-MAR-2025
-- ================================================
CREATE PROCEDURE [dbo].[sp_pop_AttendanceDates]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn VARCHAR(35) = 'sp_pop_AttendanceDates'
   ;
   EXEC sp_log 1, @fn, '000: starting';

   --------------------------------------------------
   -- Setup
   --------------------------------------------------
   EXEC sp_log 1, @fn, '010: Setup';
   DELETE FROM AttendanceDates;

   --------------------------------------------------
   -- Process
   --------------------------------------------------
   EXEC sp_log 1, @fn, '020: process';

   -- Extract dates from the attendeance register header
   INSERT INTO AttendanceDates(ordinal, value)
   SELECT ordinal, value
   FROM AttendanceStagingHdr CROSS APPLY string_split(hdr, NCHAR(9), 1);

   SELECT  * FROM AttendanceDates;
   --------------------------------------------------
   -- Chk postconditions
   --------------------------------------------------
   EXEC sp_log 1, @fn, '030: Chk postconditions';

   -- Postconditions Post 01: AttendanceDates pop
   EXEC sp_assert_tbl_pop 'AttendanceDates';

   --------------------------------------------------
   -- Process complete
   --------------------------------------------------
   EXEC sp_log 1, @fn, '999: leaving OK';
END
/*
EXEC test.test_013_sp_pop_AttendanceDates;
EXEC tSQLt.Run 'test.test_013_sp_pop_AttendanceDates';


--EXEC test.sp__crt_tst_rtns 'dbo.sp_pop_AttendanceDates'
EXEC tSQLt.RunAll;EXEC tSQLt.Run 'test.test_013_sp_pop_AttendanceDates';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[StudentStaging](
	[student_id] [varchar](9) NOT NULL,
	[student_nm] [varchar](50) NULL,
	[gender] [char](1) NULL,
	[google_alias] [varchar](30) NULL,
	[FB_alias] [varchar](30) NULL,
	[email] [varchar](30) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================================
-- Description: Populates the student table from the EnrollmentStagings table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 22-Feb-2025
--
-- Preconditions:
--    PRE01: The relevant FKs have been dropped
--    PRE02: Section table pop     (chkd) 
--    PRE03: EnrollmentStaging pop (chkd) 
--
-- Postconditions: the following table are populated:
--    StudentStaging
--    Student
-- =====================================================================================
CREATE PROCEDURE [dbo].[sp_pop_students] @display_tables BIT = 0
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE @fn VARCHAR(35) = 'sp_pop_students'

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, validation';

      -----------------------------------------------------------
      -- Validation
      -----------------------------------------------------------

      -- PRE02: (chkd) Section table pop
      EXEC sp_assert_tbl_pop 'Section';
      -- PRE03: EnrollmentStaging pop (chkd) 
      EXEC sp_assert_tbl_pop 'EnrollmentStaging';
      EXEC sp_assert_tbl_pop 'Enrollment';

      -----------------------------------------------------------
      -- Process
      -----------------------------------------------------------
      EXEC sp_log 1, @fn, '010: process, truncating tables Student, StudentStaging';
      TRUNCATE TABLE Student;
      TRUNCATE TABLE StudentStaging;

      --EXEC sp_create_FKs;

      EXEC sp_log 1, @fn, '020: pop the StudentStaging table';

      -- Pop StudentStaging table from the Enrollment Staging table
      INSERT INTO StudentStaging(student_id, student_nm, gender)
      SELECT DISTINCT student_id, student_nm, gender
      FROM EnrollmentStaging
      ORDER BY student_nm;
      EXEC sp_log 1, @fn, '030: populated the StudentStaging table: with ', @@ROWCOUNT, ' rows';

      IF @display_tables = 1 SELECT * FROM StudentStaging order by student_nm;
      EXEC sp_assert_tbl_pop 'StudentStaging';

      EXEC sp_log 1, @fn, '040: populating the Student table';
      INSERT INTO Student(student_id, student_nm,gender)
      SELECT student_id, student_nm, gender
      FROM StudentStaging
      ORDER BY student_nm;
      EXEC sp_log 1, @fn, '050: populated the Student table: with ', @@ROWCOUNT, ' rows';

      IF @display_tables = 1 SELECT * FROM Student order by student_nm;
      EXEC sp_assert_tbl_pop 'Student';

      EXEC sp_log 1, @fn, '070: populated the StudentCourse table: with ', @@ROWCOUNT, ' rows';
      EXEC sp_log 1, @fn, '400: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      EXEC sp_create_FKs;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: OK';
END
/*
EXEC sp_drop_fks;
EXEC sp_pop_students 1;
EXEC sp_create_fks;

SELECT * FROM Student
SELECT * FROM Section
SELECT * from StudentCourseStaging
Where student_id = '2018-0429';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 13-APR-2025
-- Description: Removes double quotes
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- =============================================
CREATE PROCEDURE [dbo].[sp_RemoveDoubleQuotes]
    @table_no_brkts    VARCHAR(60)
   ,@max_len_fld       INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                 VARCHAR(35)       = N'sp_import_txt_file'
   ,@table              VARCHAR(60)
   ,@nl                 CHAR(2)           = CHAR(13)+CHAR(10)
   ,@sql                VARCHAR(4000)

   EXEC sp_log 1, @fn, '000: starting:
table_no_brkts  :[',@table_no_brkts,']
max_len_fld     :[',@max_len_fld   ,']
';

      ----------------------------------------------------------------------------------
      -- R02: Remove double quotes
      -- R03: Trim leading/trailing whitespace
      -- R04: Remove line feeds
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '135: @table_nm_no_brkts: ', @table_no_brkts;
      EXEC sp_log 1, @fn, '135: @table : ', @table ;

      WITH cte AS
      (
         SELECT dbo.fnPadRight(CONCAT('[', column_name, ']'), @max_len_fld+2) AS column_name,ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) AS row_num, ordinal_position, DATA_TYPE, is_txt
         FROM list_table_columns_vw 
         WHERE table_name = @table_no_brkts AND is_txt = 1
      )
      ,cte2 AS
      (
         SELECT CONCAT('UPDATE ',@table,' SET ') AS sql
         UNION ALL
         SELECT CONCAT( iif(row_num=1, ' ',','), column_name, ' = TRIM(REPLACE(REPLACE(',column_name, ', ''"'',''''), NCHAR(10), ''''))') 
         FROM cte
         UNION ALL
         SELECT CONCAT('FROM ',@table,';')
      )
      SELECT @sql = string_agg(sql, @NL) FROM cte2;

      EXEC sp_log 1, @fn, '150: trim replacing double quotes, @sql:', @NL, @sql;
      EXEC (@sql);

     EXEC sp_log 1, @fn, '000: leaving'

END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: sets the log level
-- =============================================
CREATE PROCEDURE [dbo].[sp_set_log_level]
   @level INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @log_level_key NVARCHAR(50) = dbo.fnGetLogLevelKey();
   EXEC sys.sp_set_session_context @key = @log_level_key, @value = @level;
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.sp_set_log_level', 79, 'C';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================
-- Description: list the tables and their counts in dbo
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 30-MAY-2025
-- ==========================================================
CREATE PROC [dbo].[spListTables]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn  VARCHAR(35) = 'spListTables'
      ,@sql VARCHAR(8000)
   ;

   EXEC sp_log 1, @fn, '000: starting';
   SELECT TABLE_NAME, CONCAT('SELECT COUNT(*) FROM [', TABLE_NAME,']') AS [sql]
   FROM [INFORMATION_SCHEMA].[TABLES] 
   --CROSS APPLY 
   WHERE TABLE_SCHEMA='dbo' AND TABLE_TYPE='BASE TABLE'
   ;
   
   EXEC sp_log 1, @fn, '000: leaving';
END
/*
EXEC tSQLt.Run 'test.test_030_sp_GetTeams';
EXEC test.test_030_sp_GetTeams;

SELECT * FROM dbo.fnGetTeams(NULL,NULL,NULL,NULL,NULL,NULL);
SELECT * FROM dbo.fnGetTeams('3B',NULL,NULL,NULL,NULL,NULL);
SELECT * FROM dbo.fnGetTeams(NULL,NULL,NULL,NULL,'2023-1531',NULL);
EXEC sp_GetTeams ;

EXEC dbo.sp_GetTeams @student_nm ='Misoles';
EXEC dbo.sp_GetTeams @student_nm ='Misoles';
EXEC dbo.sp_GetTeams @event_nm = 'Project X Requirements Presentation IT 3C';

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[ExamSchedule_vw]
AS
SELECT 
	 [days]
	,st
	,[end]
	,ex_st
	,ex_end 
	,ex_date
	,ex_day
FROM ExamSchedule
;


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================
-- Description: returns the team details for the parameters
-- Design:      EA
-- Tests:       test_030_sp_GetTeams
-- hrsw is based on the class duartion
-- Author:      Terry Watts
-- Create date: 5-APR-2025
-- ==========================================================
CREATE FUNCTION [dbo].[fnExamschedule]
(
    @days         VARCHAR(6)
   ,@st           VARCHAR(4)
)
RETURNS @t TABLE
(
    [days]        VARCHAR(4)
   ,st            VARCHAR(4)
   ,[end]         VARCHAR(4)
   ,ex_date       VARCHAR(20)
   ,ex_day        VARCHAR(20)
   ,duaration     VARCHAR(4)
)
AS
BEGIN
   INSERT INTO @t
(
    [days]
   ,st
   ,[end]
   ,ex_date
   ,ex_day
   ,duaration
)
SELECT [days], st, [end], ex_date, ex_day, FORMAT((CONVERT(INT, [end]) - CONVERT(INT, st))*2.0/100,'0.00')
FROM ExamSchedule_vw
WHERE (st = @st OR @st IS NULL)
AND ( [days] = @days OR @days  IS NULL)
ORDER BY 
[days], st;

   RETURN;
END
/*
SELECT * FROM dbo.fnExamschedule('MWF', '1500');
SELECT * FROM dbo.fnExamschedule('TTH', NULL);
SELECT * FROM dbo.fnExamschedule(NULL, NULL);
SELECT * FROM ExamSchedule_vw;
EXEC tSQLt.Run 'test.test_030_sp_GetTeams';
TTH	1030	1200	May 21	Wednesday	3.40
TTH	0730	0900	May 20	Tuesday	3.40
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Function SC: <fn_nm>
-- Description: Finds a student by likenes
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 03-MAY-2023
-- =============================================
CREATE FUNCTION [dbo].[fnFindStudent]
(
    @student_nm VARCHAR(60)
   ,@course_nm  VARCHAR(20)
   ,@section_nm VARCHAR(20)
   ,@gender     VARCHAR(20)
)
RETURNS @t TABLE
(
  srch_cls   VARCHAR(60)
 ,student_id VARCHAR(9)
 ,student_nm VARCHAR(60)
 ,gender     CHAR(1)
 ,course_nm  VARCHAR(20)
 ,section_nm VARCHAR(20)
 ,major_nm   VARCHAR(20)
 ,match_ty   INT
)
AS
BEGIN
   DECLARE
      @len     INT
     ,@count   INT
     ,@srch    VARCHAR(60)
     ,@found   BIT = 0
   ;

   SET @student_nm = dbo.fnNormalizeNm(dbo.fnTrim(@student_nm));
   SET @srch = @student_nm;

   -- First try shortening the search string from the right
   SET @len = dbo.fnLen(@student_nm);
   --WHILE @len > 4
   --BEGIN
      SET @srch = CONCAT('%', dbo.fnTrim(@student_nm), '%')

      -- Type 1 match: exact match
      INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, match_ty)
      SELECT      @student_nm, student_id, student_nm, gender, course_nm, section_nm, major_nm, 1
      FROM Enrollment_vw v
      WHERE
             (student_nm = @student_nm OR @student_nm  IS NULL)
         AND (course_nm  = @course_nm  OR @course_nm  IS NULL)
         AND (section_nm = @section_nm OR @section_nm IS NULL)
         AND (gender     = @gender     OR @gender     IS NULL)
      ORDER BY student_nm
      ;

      -- Type 2 match: substring
      INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, match_ty)
      SELECT      @student_nm, student_id, student_nm, gender, course_nm, section_nm, major_nm, 2
      FROM Enrollment_vw v
      WHERE
         v.student_nm LIKE CONCAT('%',@student_nm,'%')
         AND (course_nm  = @course_nm  OR @course_nm  IS NULL)
         AND (section_nm = @section_nm OR @section_nm IS NULL)
         AND (gender     = @gender     OR @gender     IS NULL)
         AND v.student_id NOt IN  (SELECT student_id FROM @t)
      ORDER BY student_nm
      ;

      -- Type 3 match: surname match
      IF CHARINDEX(',',@student_nm) > 0
      BEGIN
         DECLARE @surname VARCHAR(20);
         SET @surname = SUBSTRING(@student_nm, 1, CHARINDEX(',', @student_nm)-1);

         INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, match_ty)
         SELECT @student_nm, student_id, student_nm, gender, course_nm, section_nm, major_nm, 3
         FROM Enrollment_vw v
         WHERE
            SUBSTRING(v.student_nm, 1, CHARINDEX(',', v.student_nm)-1) LIKE CONCAT('%',@surname,'%')
            AND (course_nm  = @course_nm  OR @course_nm  IS NULL)
            AND (section_nm = @section_nm OR @section_nm IS NULL)
            AND (gender     = @gender     OR @gender     IS NULL)
            AND v.student_id NOt IN  (SELECT student_id FROM @t)
         ORDER BY student_nm
         ;
/*
         -- Try searching on the first 3 chars of the first word in the student name
         -- and the first 3 chars of the last word in the student name
         -- and also the first 3 letters of the LAST name if course or section is specified
         -- when we have 3 or more chars in the name
         IF (@course_nm IS NOT NULL OR @section_nm IS NOT NULL) AND @len >2
         BEGIN
            INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, match_ty)
            SELECT @student_nm, student_id, student_nm, gender, course_nm, section_nm, major_nm, 3
            FROM Enrollment_vw v
            WHERE
              (
                 student_nm LIKE CONCAT(SUBSTRING(@student_nm,1,3),'%')
              OR student_nm LIKE CONCAT(SUBSTRING(@student_nm, dbo.fnLastIndexOf(' ',@student_nm)+1,3),'%')
              )
              AND (course_nm = @course_nm  OR (@course_nm  IS NULL AND @section_nm IS NOT NULL))
              AND (section_nm= @section_nm OR (@section_nm IS NULL AND @course_nm  IS NOT NULL))
            ;
         END
*/
      END
   RETURN;
END
/*
EXEC sp_FindStudent NULL;
SELECT * FROM dbo.fnFindStudent('Mangubat, Jezryne Kaeser Duane B.', NULL, NULL, NULL );
SELECT * FROM dbo.fnFindStudent('Mangubat', NULL, NULL, NULL );
SELECT * FROM dbo.fnFindStudent('Gubalane');
SELECT * FROM dbo.fnFindStudent('Ganggangan');
SELECT * FROM dbo.fnFindStudent('John Jefferson Mondia');
SELECT * FROM dbo.fnFindStudent('Kaeser Mangubat');
SELECT * FROM dbo.fnFindStudent('Kissy Gubalane');
SELECT * FROM dbo.fnFindStudent('Kristana Ceralde Ganggangan');
SELECT * FROM dbo.fnFindStudent('Labajo, Rashelle M. - Present');
SELECT * FROM dbo.fnFindStudent('Labajo, Sunshine C. - Present');
SELECT * FROM dbo.fnFindStudent('Lagbas, Cleo Camille M.');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- Description: Finds a student by likeness
-- Design:      Uses the enrollment view
-- Tests:       test_024_sp_FindStudent2
-- =============================================
CREATE FUNCTION [dbo].[fnFindStudent2]
(
    @student_nm VARCHAR(60)
   ,@gender     VARCHAR(20)
   ,@course_nm  VARCHAR(20)
   ,@section_nm VARCHAR(20)
   ,@match_ty   INT         -- =NULL for all matches
)
RETURNS @t TABLE
(
  srch_cls   VARCHAR(60)
 ,student_id VARCHAR(9)
 ,student_nm VARCHAR(60)
 ,gender     CHAR(1)
 ,course_nm  VARCHAR(20)
 ,section_nm VARCHAR(20)
 ,major_nm   VARCHAR(20)
 ,match_ty   INT
 ,pos        INT
 ,cls1       VARCHAR(60)
 ,cls2       VARCHAR(60)
)
AS
BEGIN
   DECLARE
      @len     INT
     ,@pos     INT = 0
     ,@count   INT
     ,@srch_cls VARCHAR(60)
     ,@found   BIT = 0
     ,@cls1    VARCHAR(60)
     ,@cls2    VARCHAR(60)
   ;

   --@match_ty
   IF @match_ty IS NULL SET @match_ty = 4
   SET @srch_cls = dbo.fnTrim(@student_nm);

   -- First try shortening the search string from the right
   SET @len = dbo.fnLen(@student_nm);
   --WHILE @len > 4
   --BEGIN

   IF @srch_cls IS NOT NULL
   BEGIN
      SET @pos = CHARINDEX(' ', @srch_cls);
      IF @pos = 0 SET @pos = CHARINDEX(',', @srch_cls);
   END

   -- May be just single word no sep
   IF (@pos = 0 AND @student_nm IS NOT NULL)-- AND @match_ty >= 4
      BEGIN
      INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, pos, match_ty, cls1, cls2)--, course_nm, section_nm, major_nm, match_ty)
      SELECT         @srch_cls,student_id, student_nm, gender, course_nm, section_nm, major_nm, @pos, 4,      @cls1,@cls2
      FROM Enrollment_vw s
      WHERE
          (student_nm LIKE CONCAT( '%', @srch_cls, '%')  OR (@student_nm IS NULL))
      AND ((gender     = @gender    )                    OR (@gender     IS NULL))
      AND ((course_nm  = @course_nm )                    OR (@course_nm  IS NULL))
      AND ((section_nm = @section_nm)                    OR (@section_nm IS NULL))
      ;
      INSERT INTO @t(match_ty) VALUES (4);
      RETURN;
   END

   ---------------------------------------------------------------------------------
   --   ASSERTION: we have a multi part name with commas OR @student_nm IS NOT NULL
   ---------------------------------------------------------------------------------

   SET @cls1 = SUBSTRING(@srch_cls, 1, @pos-1);
   SET @cls2 = SUBSTRING(@srch_cls, @pos+1, 99);

   -- INSERT INTO @t(srch_cls, pos,cls1,cls2, student_nm)    VALUES(@srch_cls, @pos, @cls1, @cls2, @student_nm)   ;

   -- Type 1 match: match on both cls1 and cls2
   -- Always run this
   INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, pos, match_ty, cls1, cls2)--, course_nm, section_nm, major_nm, match_ty)
   SELECT         @srch_cls,student_id, student_nm, gender, course_nm, section_nm, major_nm, @pos, 1,      @cls1,@cls2
   FROM Enrollment_vw s
   WHERE
      ((student_nm LIKE CONCAT( '%', @cls1, '%') AND student_nm LIKE CONCAT( '%', @cls2, '%')) OR (@student_nm IS NULL))
      AND ((gender     = @gender    ) OR (@gender     IS NULL))
      AND ((course_nm  = @course_nm ) OR (@course_nm  IS NULL))
      AND ((section_nm = @section_nm) OR (@section_nm IS NULL))
      ;

   --  if found and match type = 1 EXACT
   IF (@match_ty = 1)
   BEGIN
      IF (@@ROWCOUNT  = 0)
      BEGIN
         INSERT INTO @t(match_ty) VALUES (1);
         RETURN;
      END
   END

   ---------------------------------------------------------------
   -- ASSERTION: not found an exact match
   ---------------------------------------------------------------

   -- Type 2 match on either cls1 or cls2
   INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm,  pos, match_ty, cls1, cls2)--, course_nm, section_nm, major_nm, match_ty)
   SELECT        @srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, @pos, 2,       @cls1, @cls2
   FROM Enrollment_vw s
   WHERE
       (
          (
             student_nm LIKE CONCAT( '%', @cls1, '%') OR (@student_nm IS NULL)
          )
          OR 
          (
             student_nm LIKE CONCAT( '%', @cls2, '%')
          )
       )
      AND ((gender     = @gender    ) OR (@gender     IS NULL))
      AND ((course_nm  = @course_nm ) OR (@course_nm  IS NULL))
      AND ((section_nm = @section_nm) OR (@section_nm IS NULL))
      ;

   IF (@match_ty = 2)
   BEGIN
      IF (@@ROWCOUNT  = 0)
         INSERT INTO @t(match_ty) VALUES (2);

      RETURN;
   END

   ---------------------------------------------------------------
   -- ASSERTION: not found a type 1 or 2 match
   ---------------------------------------------------------------

   INSERT INTO @t(srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm, pos, match_ty, cls1, cls2)
   SELECT        @srch_cls, student_id, student_nm, gender, course_nm, section_nm, major_nm,@pos, 3,       @cls1,@cls2
   FROM Enrollment_vw s
   WHERE
       (
             student_nm LIKE CONCAT( '%', @cls1, '%')
          OR student_nm LIKE CONCAT( '%', @cls2, '%')
          OR @student_nm IS NULL
       )
      AND ((gender     = @gender    ) OR (@gender     IS NULL))
      AND ((course_nm  = @course_nm ) OR (@course_nm  IS NULL))
      AND ((section_nm = @section_nm) OR (@section_nm IS NULL))
      ;

   SELECT @count = COUNT(*) FROM @t;

   IF (@match_ty = 3)
   BEGIN
      IF (@@ROWCOUNT  = 0)
         INSERT INTO @t(match_ty) VALUES (3);

      RETURN;
   END

   ---------------------------------------------------------------
   -- ASSERTION: not found an type 1,2,3 match
   ---------------------------------------------------------------

   -- if all else fails try the student id
   IF @count = 0 
      INSERT INTO @t(
        srch_cls
       ,student_id
       ,student_nm
       ,gender
       ,course_nm
       ,section_nm
       ,major_nm
       ,match_ty
      )
      SELECT
        @srch_cls
       ,student_id
       ,student_nm
       ,gender
       ,course_nm
       ,section_nm
       ,major_nm
       ,5
    FROM Enrollment_vw s
    WHERE s.student_id = @srch_cls

   IF (@@ROWCOUNT  = 0)
      INSERT INTO @t(match_ty) VALUES (5);

   RETURN;
END
/*
SELECT * FROM dbo.fnFindStudent2('John', NULL, NULL, NULL, NULL);
SELECT * FROM dbo.fnFindStudent2(NULL, NULL, NULL, NULL, NULL);
SELECT * FROM Student;
SELECT * FROM Enrollment_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- Author: Terry Watts
-- Date:   25-Apr-2025
-- Description: returns teh sekected row from the FindStudentInfo_vw
-- 
-- 
CREATE FUNCTION [dbo].[fnFindStudentInfo](@student_id varchar(9))
RETURNS @t TABLE
(
	student_id     VARCHAR(9) NOT NULL,
	student_nm     VARCHAR(50) NULL,
	gender         CHAR(1) NULL,
	google_alias   VARCHAR(50) NULL,
	fb_alias       VARCHAR(50) NULL,
	email          VARCHAR(30) NULL,
	photo_url      VARCHAR(150) NULL,
	srch_cls       VARCHAR(60) NULL,
	section_nm     VARCHAR(20) NULL,
	course_nm      VARCHAR(20) NULL,
	major_nm       VARCHAR(20) NULL,
	match_ty       INT NULL
)
AS
BEGIN
INSERT INTO @t(student_id, student_nm, gender, google_alias, srch_cls,section_nm, course_nm, major_nm, match_ty)
   SELECT      student_id, student_nm, gender, google_alias, srch_cls,section_nm, course_nm, major_nm, match_ty
   FROM FindStudentInfo_vw
   WHERE student_id LIKE CONCAT('%', @student_id, '%');
   RETURN;
END
/*
SELECT * FROM dbo.fnFindStudentInfo(NULL)
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: 
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- =============================================
CREATE FUNCTION [dbo].[fnFindStudentsNotInTeams]
(
    @event_nm     VARCHAR(25)
   ,@course_nm    VARCHAR(20)
   ,@section_nm   VARCHAR(20)
)
RETURNS @t TABLE
(
    student_id   VARCHAR(9)
   ,student_nm   VARCHAR(50)
)
AS
BEGIN
   DECLARE @n INT

   INSERT INTO @t (student_id, student_nm)
   SELECT e.student_id, e.student_nm
   FROM Enrollment_vw e
   JOIN Student s ON e.student_id = s.student_id
   WHERE
       e.course_nm = @course_nm
   AND e.section_nm= @section_nm
   AND e.student_id NOT IN
   (
      SELECT student_id
      FROM Team_vw
      WHERE
          event_nm   = @event_nm
      AND course_nm  = @course_nm
      AND section_nm = @section_nm
   );

   RETURN;
END
/*
SELECT * FROM dbo.fnFindStudentsNotInTeams('GEC E2 Mini Presentation', 'GEC E2','2B');
SELECT * FROM dbo.fnFindStudentsNotInTeams('GEC E2 Mini Presentation', 'GEC E2','2D');

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
SELECT * FROM Team_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--====================================================================================
-- Author:       Terry Watts
-- Create date:  02-May-2025
-- Description:  Displays the student attendance
-- Attendance_vw references the ClassSchedule to define the course, section,class
-- Attendance_vw further defines the student
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[Attendance_vw]
AS
SELECT
    a.student_id
   ,s.student_nm
   ,course_nm
   ,sec.section_nm
   ,st_time
   ,a.[date]
   ,present
   ,csv.classSchedule_id
   ,course_id
   ,sec.section_id
FROM
     Attendance a 
JOIN ClassSchedule_vw csv ON csv.classSchedule_id = a.classSchedule_id
LEFT JOIN Student     s   ON s  .student_id       = a.student_id
LEFT JOIN Section     sec ON sec.section_nm       = csv.section_nm
;
/*
SELECT * FROM Attendance_vw;
SELECT * FROM ClassSchedule_vw;
SELECT * FROM AttendanceStagingColMap;
SELECT * FROM AttendanceStaging;
SELECT * FROM AttendanceStagingCourseHdr;

SELECT TOP 100 * FROM Enrollment WHERE student_id = '2020-1309';
SELECT TOP 100 * FROM Enrollment_vw WHERE student_id = '2020-1309';
SELECT * FROM Attendance_vw WHERE student_id = '2023-1772'
SELECT TOP 100 * FROM Enrollment_vw WHERE student_id = '2023-1772';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================
-- Description: Returns the attendance record for the suppied parameters
-- Design: EA
-- Tests:  test_016_fnGetAttendance
-- Author: Terry Watts
-- Create date: 23-Mar-2025
-- ======================================================================
CREATE FUNCTION [dbo].[fnGetAttendance]
(
    @student_id  VARCHAR(9)
   ,@course_nm   VARCHAR(20)
   ,@section_nm  VARCHAR(20)
)
RETURNS @t TABLE
(
    [index]             INT
   ,student_id          VARCHAR(9)
   ,student_nm          VARCHAR(50)
   ,course_nm           VARCHAR(20)
   ,section_nm          VARCHAR(20)
   ,attendance_percent  VARCHAR(5)
   ,ordinal             INT
   ,[date]              DATE
   ,present             BIT
)
AS
BEGIN
   INSERT INTO @t
   (
--    [index]
   student_id
   ,student_nm
   ,course_nm
   ,section_nm
--   ,attendance_percent
--   ,ordinal
   ,[date]
   ,present
   )
   SELECT
--      [index]
       student_id
      ,student_nm
      ,course_nm
      ,section_nm
--      ,attendance_pc
--      ,ordinal
      ,[date]
      ,present
   FROM Attendance_vw
   WHERE
         (student_id = @student_id OR @student_id IS NULL)
     AND (course_nm  = @course_nm  OR @course_nm  IS NULL)
     AND (section_nm = @section_nm OR @section_nm IS NULL)
   ;

   RETURN;
END
/*
SELECT * FROM Attendance_vw WHERE student_id = '2023-1772'; -- Alcoser, Reallene R.

SELECT * FROM dbo.fnGetAttendance('2023-1772', 'GEC E2', NULL);
SELECT * FROM dbo.fnGetAttendance('2023-1772', 'GEC E3', NULL); -- no recs
SELECT * FROM dbo.fnGetAttendance('2018-0429', 'GEC E2', '2D');


EXEC test.hlpr_016_fnGetAttendance
    @tst_num                = '002'
   ,@display_tables         = 1
   ,@inp_student_id         = '2023-1772' -- Alcoser, Reallene R.
   ,@inp_course_nm          = NULL
   ,@inp_section_nm         = NULL
   ,@exp_row_cnt            = NULL
;
EXEC test.hlpr_016_fnGetAttendance
    @tst_num                = '001'
   ,@display_tables         = 1
   ,@inp_student_id         = NULL
   ,@inp_course_nm          = NULL
   ,@inp_section_nm         = NULL
   ,@exp_row_cnt            = NULL
;
EXEC test.hlpr_016_fnGetAttendance
    @tst_num                = '003'
   ,@display_tables         = 1
   ,@inp_student_id         = NULL
   ,@inp_course_nm          = NULL
   ,@inp_section_nm         = NULL
   ,@exp_row_cnt            = NULL
;

EXEC tSQLt.Run 'test.test_016_fnGetAttendance';
SELECT * FROM dbo.fnGetAttendance( NULL, NULL,NULL, NULL);
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE FUNCTION [dbo].[fnGetAuthActionForUser](@user_id INT)
RETURNS @t TABLE
(
    user_id     INT
   ,user_nm     VARCHAR(20)
   ,action_id   INT
   ,action_nm   VARCHAR(20)
)
AS
BEGIN
   INSERT INTO @t(user_id, user_nm, action_id, action_nm)
   SELECT user_id, user_nm, action_id, action_nm
   FROM AuthorizedActions_vw
   WHERE @user_id = user_id
   ;

   RETURN;
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE View [dbo].[UserFeatures_vw]
AS
SELECT distinct u.[user_id], r.role_id, r.role_nm, u.user_nm, r2f.feature_id, f.feature_nm
FROM [User] u
LEFT JOIN UserRole    u2r ON u.[user_id]  = u2r.[user_id]
LEFT JOIN [Role]      r   ON r.role_id    = u2r.role_id
LEFT JOIN RoleFeature r2f ON r2f.role_id  = r.role_id
LEFT JOIN Feature     f   ON f.feature_id = r2f.feature_id
;
/*
SELECT * FROM UserFeatures_vw
SELECT * FROM Feature;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 31-MAR-2025
-- Description: Gets the authorized fetures for a given user
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
--  POST 01: returns a list of features the user is authorized to perform
--
-- CHANGES:
--
-- ============================================================================================================================
CREATE FUNCTION [dbo].[fnGetAuthorizedUserFeatures](@user_id VARCHAR(8))
RETURNS
@t TABLE
(
	[feature_id] INT          NULL,
	feature_nm   VARCHAR(50)  NULL,
	[user_id]    CHAR(1)      NULL
)

AS
BEGIN
   INSERT INTO @t SELECT feature_id, feature_nm, [user_id]
   FROM UserFeatures_vw
   WHERE ([user_id] = @user_id) OR (@user_id IS NULL)
   ;

   RETURN;
END
/*
   SELECT * FROM dbo.fnGetAuthorizedUserFeatures(1);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Description: returns the teams registered for the event
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 04-APR-2025
-- ==========================================================
CREATE FUNCTION [dbo].[fnGetEventTeams]( @event_nm VARCHAR(40))
RETURNS @t TABLE
(
    event_nm      VARCHAR(100)
   ,team_nm       VARCHAR(40)
   ,section_nm    VARCHAR(20)
   ,[date]        date
   ,student_id    VARCHAR(9)
   ,student_nm    VARCHAR(50)
   ,is_lead       BIT
)
AS
BEGIN
   INSERT INTO @t(team_nm, section_nm, [date], student_id, student_nm, is_lead)
      SELECT      team_nm, section_nm, [date], student_id, student_nm, is_lead
      FROM   Team_vw
      WHERE (event_nm LIKE CONCAT('%', @event_nm, '%') OR @event_nm IS NULL)
      ORDER BY team_nm, student_nm
   ;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetEventTeams(NULL)
SELECT * FROM dbo.fnGetEventTeams('Albert')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================================
-- Function   : dbo.fnGetFksForPrimaryTable
-- Description: returns the Fkeys assocoated with
--              @@foreign_tbl as the foreign table
-- Author:      Terry Watts
-- Create date: 01-MAR-2025
--
-- Preconditions: none
--
-- Postconditions
-- (@foreign_tbl exists AND (fk_nm=forign key name 
--                      AND f_tbl= foreign table name
--                      AND p_tbl = primary table name)
-- OR
-- (@foreign_tbl exists does not exist AND no rows returned)
-- ===========================================================
CREATE FUNCTION [dbo].[fnGetFksForForeignTable](@foreign_tbl NVARCHAR(60))
RETURNS @t TABLE
(
    fk_nm VARCHAR(60)
   ,f_tbl VARCHAR(60)
   ,p_tbl VARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t(fk_nm, f_tbl, p_tbl)
   SELECT fk_constraint_name, foreign_table, primary_table
   FROM list_fks_vw
   WHERE foreign_table = @foreign_tbl OR @foreign_tbl IS NULL
   ORDER BY fk_constraint_name;

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_007_fnGetTableForFk';

SELECT * FROM dbo.fnGetFksForForeignTable(NULL);
SELECT * FROM dbo.fnGetFksForForeignTable('UserRole');

--EXEC test.sp__crt_tst_rtns 'dbo].[fnGetFksForForeignTable';
SELECT * FROM list_fks_vw
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================
-- Function   : dbo.fnGetFksForPrimaryTable
-- Description: returns the Fkeys assocoated with
--              @Primary_tbl as the primary table
-- Author:      Terry Watts
-- Create date: 01-MAR-2025
-- ===============================================
CREATE FUNCTION [dbo].[fnGetFksForPrimaryTable](@Primary_tbl NVARCHAR(60))
RETURNS @t TABLE
(
   tbl_nm VARCHAR(60),
   fk_nm  VARCHAR(60))
AS
BEGIN
   INSERT INTO @t SELECT primary_table, fk_constraint_name 
   FROM list_fks_vw WHERE primary_table = @Primary_tbl
   ORDER BY fk_constraint_name;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetFksForPrimaryTable('Course');
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================================
-- Author:        Terry watts
-- Create date:   05-APR-2024
-- Description:   gets the output columns from a table function (TF)
-- Tests:         test_042_fnGetFnOutputCols
-- Preconditions  @q_rtn_nm is a table function
-- Postconditions OUTPUT table holds the output column meta data for the given TF
-- ===============================================================================
CREATE FUNCTION [dbo].[fnGetFnOutputCols]
(
    @q_rtn_nm     VARCHAR(60)
)
RETURNS @t TABLE
(
    name          VARCHAR(50)
   ,ordinal       INT
   ,ty_nm         VARCHAR(40)
   ,[len]         INT
   ,is_nullable   BIT
   ,is_results    BIT
)
AS
BEGIN
      INSERT INTO @t (name, ordinal, ty_nm, [len], is_nullable, is_results)
      --SELECT name, column_id as ordinal, TYPE_NAME(user_type_id) as ty_nm, max_length, is_nullable
      SELECT name, column_id as ordinal, dbo.fnGetFullTypeName(TYPE_NAME(user_type_id), max_length) as ty_nm, max_length, is_nullable, 0
      FROM sys.columns
      WHERE object_id=object_id(@q_rtn_nm)
      ORDER BY column_id
      ;

   RETURN;
END
/*
EXEC test.test_042_fnGetFnOutputCols;

SELECT * FROM dbo.fnGetFnOutputCols('test.fnCrtHlprSigParams');
SELECT * FROM dbo.fnGetFnOutputCols('test.fnCrtHlprSigParams');

SELECT name, column_id as ordinal, TYPE_NAME(user_type_id) as ty_nm, max_length, is_nullable
FROM sys.columns
WHERE object_id=object_id('test.fnCrtHlprSigParams')
ORDER BY column_id
;
SELECT *, column_id as ordinal, TYPE_NAME(user_type_id) as ty_nm, dbo.fnGetFullTypeName(TYPE_NAME(user_type_id), max_length) as ty_nm_full, max_length, is_nullable
FROM sys.columns
WHERE object_id=object_id('test.fnCrtHlprSigParams')
ORDER BY column_id
;
EXEC test.sp__crt_tst_rtns '[dbo].[fnGetFnOutputCols]';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry Watts
-- Create date: 05-MAR-2025
-- Description: returns the students for a section
--
-- PRECONDITIONS:
-- PRE 01: 
--
-- POSTCONDITIONS:
-- POST01: 
--
-- CHANGES:
--
-- ===============================================================
CREATE FUNCTION [dbo].[fnGetGetStudentsForSection](@section_nm VARCHAR(20))
RETURNS @t TABLE
(
    section_nm VARCHAR(20)
   ,student_id VARCHAR(9)
   ,student_nm VARCHAR(50)
   ,gender     CHAR(1)
)
AS
BEGIN
   DECLARE
    @fn VARCHAR(35) = 'fnGetGetStudentsForSection'
   ,@desc_st_row     INT = NULL
   ,@desc_end_row    INT = NULL
   ,@schema_nm       VARCHAR(50)
   ,@ad_stp          BIT            = 0
   ,@tstd_rtn        VARCHAR(100)
   ,@qrn             VARCHAR(100)
   ;

   INSERT INTO @t(section_nm, student_id, student_nm, gender)
   SELECT section_nm, student_id, student_nm, gender
   FROM StudentSection_vw
   WHERE section_nm=@section_nm OR @section_nm IS NULL
   ORDER BY section_nm, student_nm;
   RETURN;
END
/*
SELECT * from dbo.fnGetGetStudentsForSection(NULL)
SELECT * from dbo.fnGetGetStudentsForSection('IT 3C')
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 11-NOV-2023
-- Description: take off of MS sp_helptext
-- gets the routine definition
--
-- PRECONDITIONS:
-- test.RtnDetails table pop'd
--
-- POSTCONDITIONS:
--  POST 01: if successful returns the script
--  POST 02: if not successful returns the appropriate error message along with 
--           the corresponding negatated MS error code as follows:
--    .1: if rtn is not in the current database:                     -15250, 'Error 01: rtn is not in the current database'
--    .2: if rtn does not exist:                                     -15009, 'Error 02: rtn does not exist'
--    .3: if a system object and it is not in MASTER.sys.syscomments -15197, 'Error 03: system-object check failed'
--    .4: if rtn has no script rows:                                 -15197, 'Error 04: rtn has no lines'
--    .5: if rtn has no script rows*:                                -15471, 'Error 05: rtn has no lines*'
--
-- CHANGES:
-- 17-DEC-2024: now gets the rtn details from  test.RtnDetails table
-- ============================================================================================================================
CREATE FUNCTION [dbo].[fnGetRtnDef]()
RETURNS
@rtnDef TABLE
(
    id   INT
   ,line VARCHAR(255) --collate catalog_default
)

AS
BEGIN
   DECLARE
    @qrn VARCHAR(120) -- can be [db_nm.][schema_nm.][rtn_nm]
   ,@dbname          SYSNAME
   ,@objid           INT
   ,@BlankSpaceAdded INT
   ,@BasePos         INT
   ,@CurrentPos      INT
   ,@TextLength      INT
   ,@LineId          INT
   ,@AddOnLen        INT
   ,@LFCR            INT --Lengths of line feed carriage return
   ,@DefinedLength   INT
   ,@schema_nm       VARCHAR(50)
   ,@ad_stp          BIT            = 0
   ,@tstd_rtn        VARCHAR(100)
   ,@n               INT
   ,@SyscomText      VARCHAR(4000)
   ,@Line            VARCHAR(255)

   SELECT
       @qrn       = qrn
      ,@schema_nm = schema_nm
      ,@tstd_rtn  = rtn_nm
      ,@ad_stp    = ad_stp
   FROM test.RtnDetails;

   /* NOTE: Length of @SyscomText is 4000 to replace the length of
   ** text column in syscomments.
   ** lengths on @Line, #CommentText Text column and
   ** value for @DefinedLength are all 255. These need to all have
   ** the same values. 255 was selected in order for the max length
   ** display using down level clients
   */

   SELECT @DefinedLength = 255
   SELECT @BlankSpaceAdded = 0 --Keeps track of blank spaces at end of lines. Note Len function ignores  trailing blank spaces*/

   -- Make sure the @objname is local to the current database.
   SELECT @dbname = parsename(@qrn, 3); -- 1 = Object name, 2 = Schema name, 3 = Database name, 4 = Server name

   IF @dbname IS NULL
      SELECT @dbname = db_name();
   ELSE IF @dbname <> db_name()
   BEGIN
      -- raiserror(15250,-1,-1);
     INSERT INTO @rtnDef(id, line)  VALUES (-15250, 'Error 01: rtn is not in the current database');
     RETURN;
   END

   -- See if @objname exists.
   SELECT @objid = object_id(@qrn)
   IF (@objid IS NULL)
   BEGIN
     INSERT INTO @rtnDef(id, line)  VALUES (-15009, 'Error 02: rtn does not exist');
     RETURN;
   END

   IF @objid < 0 -- Handle system-objects
   BEGIN
      -- Check count of rows with text data
      IF (SELECT count(*) from MASTER.sys.syscomments WHERE id = @objid AND text IS NOT null) = 0
      BEGIN
         --raiserror(15197,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15197, 'Error 03: system-object check failed');
         RETURN;
      END

      DECLARE ms_crs_syscom CURSOR LOCAL FOR SELECT text FROM master.sys.syscomments WHERE id = @objid
      ORDER BY number, colid FOR READ ONLY
   END
   ELSE
   BEGIN
      -- Find out how many lines of text are coming back, and return if there are none.
      IF
      (
         SELECT count(*) 
         FROM syscomments c, sysobjects o 
         WHERE ((o.xtype NOT IN ('S', 'U')) AND (o.id = c.id AND o.id = @objid))
      ) = 0
      BEGIN
         --RAISERROR(15197,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15197, 'Error 04: rtn has no lines')
         RETURN;
      END

      IF (SELECT count(*) FROM syscomments WHERE id = @objid AND encrypted = 0) = 0
      BEGIN
         -- RAISERROR(15471,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15471, 'Error 05: rtn has no lines*')
         RETURN;
      END

      DECLARE ms_crs_syscom  CURSOR LOCAL
      FOR SELECT text FROM syscomments WHERE id = @objid AND encrypted = 0
      ORDER BY number, colid
      FOR READ ONLY
   END

   -- ASSERTION: Parameters validated

   -- else get the text
   SELECT @LFCR   = 2;
   SELECT @LineId = 1;
   OPEN ms_crs_syscom;
   FETCH NEXT from ms_crs_syscom into @SyscomText;

   WHILE @@fetch_status >= 0
   BEGIN
      SELECT  @BasePos    = 1;
      SELECT  @CurrentPos = 1;
      SELECT  @TextLength = LEN(@SyscomText);

      WHILE @CurrentPos != 0
      BEGIN
         --Looking for end of line followed by carriage return
         SELECT @CurrentPos = CHARINDEX(CHAR(13)+CHAR(10), @SyscomText, @BasePos);

         --If carriage return found
         IF @CurrentPos != 0
         BEGIN
            -- If new value for @Lines length will be > then set the length 
            -- then insert current contents of @line and proceed.
            WHILE (isnull(LEN(@Line),0) + @BlankSpaceAdded + @CurrentPos - @BasePos + @LFCR) > @DefinedLength
            BEGIN
               SELECT @AddOnLen = @DefinedLength - (ISNULL(LEN(@Line),0) + @BlankSpaceAdded);

               INSERT @rtnDef (id, line) VALUES
               (
                  @LineId
                  ,ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N'')
               );

               SELECT
                   @Line            = NULL
                  ,@LineId          = @LineId + 1
                  ,@BasePos         = @BasePos + @AddOnLen
                  ,@BlankSpaceAdded = 0;

            END -- WHILE (isnull(LEN

            SELECT @Line    = ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @CurrentPos-@BasePos + @LFCR), N'')
            SELECT @BasePos = @CurrentPos+2;
            INSERT @rtnDef (id, line) VALUES( @LineId, @Line);
            SELECT @LineId  = @LineId + 1;
            SELECT @Line    = NULL;
         END  -- IF @CurrentPos != 0
         ELSE --else carriage return not found
         BEGIN
            IF @BasePos <= @TextLength
            BEGIN
               --If new value for @Lines length will be > then the defined length
               WHILE (ISNULL(LEN(@Line),0) + @BlankSpaceAdded + @TextLength-@BasePos+1 ) > @DefinedLength
               BEGIN
                  SELECT @AddOnLen = @DefinedLength - (ISNULL(LEN(@Line),0) + @BlankSpaceAdded)
                  INSERT @rtnDef (id, line) VALUES
                  (
                     @LineId
                     ,ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N'')
                  );

                  SELECT @Line = NULL, @LineId = @LineId + 1,
                  @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
               END

               SELECT @Line = isnull(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @TextLength-@BasePos+1 ), N'')

               IF LEN(@Line) < @DefinedLength and CHARINDEX(' ', @SyscomText, @TextLength+1 ) > 0
               BEGIN
                  SELECT @Line = @Line + ' ', @BlankSpaceAdded = 1
               END
            END
         END -- -- IF @CurrentPos != 0 ELSE
      END -- WHILE @CurrentPos != 0

      FETCH NEXT FROM ms_crs_syscom INTO @SyscomText
   END -- WHILE @@fetch_status >= 0

   IF @Line IS NOT NULL
      INSERT @rtnDef (id, line) VALUES( @LineId, @Line )

   --SELECT Text FROM CommentText ORDER BY LineId
   CLOSE       ms_crs_syscom;
   DEALLOCATE  ms_crs_syscom;
   --DROP TABLE  #CommentText
   RETURN;-- (0) -- sp_helptext
END
/*
   SELECT * FROM dbo.fnGetRtnDef();
   SELECT * FROM dbo.fnGetRtnDef('dbo.AsFloat');
   EXEC test.sp_crt_tst_rtns 'dbo.fnGetRtnDef'
   EXE tSQLt.Run 'test.test_015_fnGetRtnDesc';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: checks if the routine exists
--
-- Preconditions
-- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
--          but differnt schema then raise div by zero exception - delegated to fnSplitQualifiedName
--
-- Postconditions:
-- Post 01: RETURNS if @q_rtn_name exists then [schema_nm, rtn_nm, rtn_ty, ty_code,] , 0 otherwise
--
-- Changes 240723: now returns a single row table as above
--
-- Tests: test.test_029_fnChkRtnExists
-- ============================================================================================================================
CREATE FUNCTION [dbo].[fnGetRtnDetails]
(
    @qrn VARCHAR(120)
)
RETURNS @t TABLE
(
    qrn           VARCHAR(120)
   ,schema_nm     VARCHAR(32)
   ,rtn_nm        VARCHAR(60)
   ,rtn_ty        NCHAR(61)
   ,ty_code       VARCHAR(25)
   ,is_clr        BIT
)
AS
BEGIN
   DECLARE
       @schema       VARCHAR(20)
      ,@rtn_nm       VARCHAR(4000)
      ,@ty_nm        VARCHAR(20)
      ,@qrn2         VARCHAR(120)

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
      ,@qrn2   = CONCAT(schema_nm, '.', rtn_nm)
   FROM fnSplitQualifiedName(@qrn);

   SELECT @ty_nm = ty_nm FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = 'fn_CamelCase';

   INSERT INTO @t
   (
       qrn
      ,schema_nm
      ,rtn_nm
      ,rtn_ty
      ,ty_code
      ,is_clr
   )
   SELECT
       @qrn2
      ,schema_nm
      ,rtn_nm
      ,rtn_ty
      ,ty_code
      ,is_clr
   FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = @rtn_nm;

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_029_fnChkRtnExists';
SELECT * FROM [dbo].[fnGetRtnDetails]('[dbo].[fnIsCharType]');
SELECT * FROM [dbo].[fnGetRtnDetails]('sp_assert_rtn_exists');
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Function SC: <fn_nm>
-- Description: 
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- Author:      
-- Create date: 
-- =============================================
CREATE FUNCTION [dbo].[fnGetScheduleByDay]
(
   @day VARCHAR(10)
)
RETURNS @t TABLE
(
   [day] VARCHAR(10)
   ,st_time	VARCHAR(10)
   ,end_time VARCHAR(10)
   ,course_no VARCHAR(10)
   ,[description] VARCHAR(60)
   ,section VARCHAR(10)
   ,room	VARCHAR(10)
   ,has_projector BIT
   ,building VARCHAR(10)
   ,[floor] int

)
AS
BEGIN
   INSERT INTO @t 
   SELECT TOP 50 * FROM ClassSchedule_vw 
   WHERE [day] = @day
   ORDER BY st_time;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetScheduleByDay('Mon')
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 04-MAR-2025
-- Description: 
-- PRECONDITIONS:
-- 
--
-- POSTCONDITIONS:
--  POST 01: List the student det2ils
--
-- CHANGES:
-- 
-- ============================================================================================================================
CREATE FUNCTION [dbo].[fnGetStudentById](@student_id VARCHAR(8))
RETURNS
@t TABLE
(
	student_id VARCHAR(9)  NOT NULL,
	student_nm VARCHAR(50) NULL,
	gender     CHAR(1)     NULL
)

AS
BEGIN
   INSERT INTO @t SELECT * FROM Student
   WHERE student_id LIKE @student_id OR @student_id Is NULL
   ;

   RETURN;
END
/*
   SELECT * FROM dbo.fnGetStudentById('2020%');
   EXEC test.sp__crt_tst_rtns 'dbo.fnGetStudentById', 3;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



--====================================================================================
-- Author:       Terry Watts
-- Create date:  24-May-2025
-- Description:  Displays the student attendance summary
-- Attendance_vw references the ClassSchedule to define the course, section,class
-- Attendance_vw further defines the student
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceSummary_vw]
AS
SELECT TOP 1000
student_id, student_nm, is_lead, team_nm, section_nm, course_nm, FORMAT(attendance, '00.00%') as attendance_pc, tot_classes, att, attendance
FROM
(
   SELECT
       X.student_id
      ,X.student_nm
      ,is_lead
      ,X.section_nm
      ,course_nm
      ,tmv.team_nm
      ,tot_classes
      ,att
      ,att/tot_classes AS attendance
   FROM
   (
      SELECT
          student_id
         ,student_nm
         ,course_nm
         ,section_nm
         ,CAST(count(*) AS FLOAT)      AS tot_classes
         ,SUM(CAST(present AS FLOAT))  AS att
      FROM Attendance_vw 
      GROUP BY course_nm, section_nm, student_id, student_nm
   ) X
   LEFT JOIN TeamMember_vw tmv ON X.student_id = tmv.student_id
)Y
ORDER BY Section_nm, team_nm, is_lead DESC, student_nm
;
/*
SELECT * FROM AttendanceSummary_vw
WHERE section_nm IN ('IT 3B','IT 3C')
ORDER BY att DESC, student_nm, course_nm;

SELECT * FROM Attendance_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================
-- Author:      Terry Watts
-- Create date: 24-MAY-2025
-- Description: returns the team attendance (all course)
-- Design:      None
-- Tests:       None
-- =======================================================
CREATE FUNCTION [dbo].[fnGetTeamAttendance]( @team_nm VARCHAR(40))
RETURNS @t TABLE
(
    team_nm          VARCHAR(40)
   ,course_nm        VARCHAR(20)
   ,section_nm       VARCHAR(20)
   ,student_id       VARCHAR(9)
   ,student_nm       VARCHAR(50)
   ,is_lead          BIT
   ,attendance_pc    VARCHAR(8)
   ,tot_classes      INT
   ,github_project   VARCHAR(250)
)
AS
BEGIN
   INSERT INTO @t
   (
       team_nm
      ,course_nm
      ,section_nm
      ,student_id
      ,student_nm
      ,is_lead
      ,attendance_pc
      ,tot_classes
      ,github_project
   )
   SELECT
       tm.team_nm
      ,course_nm
      ,tm.section_nm
      ,tm.student_id
      ,tm.student_nm
      ,tm.is_lead
      ,attendance_pc
      ,tot_classes
      ,github_project
   FROM TeamMember_vw tm JOIN AttendanceSummary_vw a ON tm.student_id=a.student_id
   WHERE tm.team_nm LIKE @team_nm;
   RETURN;
END
/*
SELECT * FROM dbo.fnGetTeamAttendance( 'Scatt%');

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Description: returns the team members for the parameters
-- Design:      EA
-- Tests:       test_018_fnGetTeamMembers
-- Author:      Terry Watts
-- Create date: 25-MAR-2025
-- ==========================================================
CREATE FUNCTION [dbo].[fnGetTeamMembers]
(
    @team_nm     VARCHAR(40)
   ,@section_nm  VARCHAR(20)
   ,@course_nm   VARCHAR(20)
   ,@student_id  VARCHAR(9)
   ,@student_nm  VARCHAR(50)
)
RETURNS @t TABLE
(
    team_nm       VARCHAR(40)
   ,section_nm    VARCHAR(20)
   ,student_id    VARCHAR(9)
   ,student_nm    VARCHAR(50)
   ,is_lead       BIT
)
AS
BEGIN
   INSERT INTO @t(team_nm,section_nm,student_id,student_nm, is_lead)
      SELECT team_nm, section_nm, student_id, student_nm, is_lead
      FROM   Team_vw
      WHERE
          (team_nm    LIKE CONCAT('%', @team_nm   , '%') OR @team_nm    IS NULL)
      AND (section_nm LIKE CONCAT('%', @section_nm, '%') OR @section_nm IS NULL)
      AND (course_nm  LIKE CONCAT('%', @course_nm , '%') OR @course_nm  IS NULL)
      AND (student_id LIKE CONCAT('%', @student_id, '%') OR @student_id IS NULL)
      AND (student_nm LIKE CONCAT('%', @student_nm, '%') OR @student_nm IS NULL)
      ORDER BY team_nm, student_nm
   ;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetTeamMembers(NULL, NULL, NULL, NULL, NULL);
SELECT * FROM dbo.fnGetTeamMembers(NULL, NULL, NULL, NULL, 'Albert')
EXEC test.test_018_fnGetTeamMembers;
EXEC tSQLt.Run 'test.test_018_fnGetTeamMembers;';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================================
-- Function SC: <fn_nm>
-- Description: lists the students enrolled on a given course and optionally section
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      EA
-- Tests:       test.test001_fnListStudentsForcourse
-- Author:      Terry Watts
-- Create date: 23-Feb-2025
-- =====================================================================================
CREATE FUNCTION [dbo].[fnListStudentsForCourse](@course_section VARCHAR(100))
RETURNS @t TABLE
(
 course_nm  VARCHAR(20)
,section_nm VARCHAR(20)
,student_id VARCHAR(9)
,student_nm VARCHAR(50)
)
AS
BEGIN
   DECLARE
    @course_nm  VARCHAR(20)
   ,@section_nm VARCHAR(20)
   ;

   SELECT
       @course_nm  = schema_nm
      ,@section_nm = rtn_nm
   FROM dbo.fnSplitQualifiedName(@course_section)
   ;

   IF @course_nm = 'dbo'
   BEGIN
      SET @course_nm = @section_nm;
      SET @section_nm = NULL;
   END

   INSERT INTO @t(course_nm, section_nm, student_id,student_nm )
   SELECT TOP 10000 course_nm, section_nm, student_id,student_nm
   FROM   Enrollment_vw e
   WHERE  (course_nm  = @course_nm OR @course_nm   IS NULL)
   AND    (section_nm = @section_nm OR @section_nm IS NULL)
   ORDER BY course_nm, section_nm, student_nm
   ;

   RETURN;
END
/*
SELECT * FROM dbo.fnListStudentsForcourse('ITMSD4');
SELECT * FROM dbo.fnListStudentsForcourse('ITMSD3');
SELECT * FROM dbo.fnListStudentsForcourse('ITC130');

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test001_fnListStudentsForcourse;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 11-APR-2025
--
-- Description: splits a composite string of 2 parts separated by a '.' 
-- into a row containing the first part (a), and the second part (b)
--
-- Postconditions:
-- Post 01: if schema is not specifed then get it from the sys rtns PROVIDED ONLY ONE rtn named the @rtn_nm
-- 
-- Changes:
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitPair]
(
    @composit VARCHAR(150) -- qualified routine name
)
RETURNS @t TABLE
(
    a  VARCHAR(1000)
   ,b  VARCHAR(1000)
)
AS
BEGIN
   INSERT INTO @t SELECT * FROM dbo.fnSplitPair2(@composit, '.');
   RETURN;
END
/*
SELECT * FROM fnSplitQualifiedName('test.fnGetRtnNmBits')
SELECT * FROM fnSplitQualifiedName('a.b')
SELECT * FROM fnSplitQualifiedName('a.b.c')
SELECT * FROM fnSplitQualifiedName('a')
SELECT * FROM fnSplitQualifiedName(null)
SELECT * FROM fnSplitQualifiedName('')
EXEC test.sp__crt_tst_rtns '[dbo].[fnSplitQualifiedName]';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 05-Mar-2025
-- Description: debug
-- =============================================
CREATE TRIGGER [dbo].[sp_student_insert_trigger]
   ON [dbo].[Student]
   AFTER DELETE
AS 
BEGIN
   SET NOCOUNT ON;
   THROW 65525, 'student_insert_trigger alert', 1;

END

ALTER TABLE [dbo].[Student] DISABLE TRIGGER [sp_student_insert_trigger]

ALTER TABLE [dbo].[Student] DISABLE TRIGGER [sp_student_insert_trigger]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Attendance2](
	[id] [int] NOT NULL,
	[classSchedule_id] [int] NOT NULL,
	[student_id] [varchar](9) NOT NULL,
 CONSTRAINT [PK_Attendanc2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Attendance2]  WITH CHECK ADD  CONSTRAINT [FK_Attendance2_ClassSchedule] FOREIGN KEY([classSchedule_id])
REFERENCES [dbo].[ClassSchedule] ([classSchedule_id])

ALTER TABLE [dbo].[Attendance2] CHECK CONSTRAINT [FK_Attendance2_ClassSchedule]

ALTER TABLE [dbo].[Attendance2]  WITH CHECK ADD  CONSTRAINT [FK_Attendance2_Student] FOREIGN KEY([student_id])
REFERENCES [dbo].[Student] ([student_id])

ALTER TABLE [dbo].[Attendance2] CHECK CONSTRAINT [FK_Attendance2_Student]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceGMeet2StagingHdr2](
	[staging] [varchar](1000) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceStaging2](
	[index] [varchar](10) NULL,
	[student_id] [varchar](9) NULL,
	[student_nm] [varchar](50) NULL,
	[attendance_percent] [varchar](10) NULL,
	[stage] [varchar](8000) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[csv](
	[FilePath] [varchar](8000) NULL,
	[Created] [varchar](8000) NULL,
	[LastModified] [varchar](8000) NULL,
	[LastAccessed] [varchar](8000) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[csvStaging](
	[FilePath] [varchar](8000) NULL,
	[Created] [varchar](8000) NULL,
	[LastModified] [varchar](8000) NULL,
	[LastAccessed] [varchar](8000) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Documents](
	[DocumentID] [int] NOT NULL,
	[DocumentName] [nvarchar](255) NULL,
	[DocumentURL] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FileActivityLog](
	[filepath] [varchar](289) NULL,
	[created] [varchar](21) NULL,
	[lastmodified] [varchar](22) NULL,
	[lastaccessed] [varchar](21) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FileActivityLogStaging](
	[FilePath] [varchar](8000) NULL,
	[Created] [varchar](8000) NULL,
	[LastModified] [varchar](8000) NULL,
	[LastAccessed] [varchar](8000) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--====================================================================================
-- Author:      Terry Watts
-- Create date: 23-Mar-2025
-- Description: Displays the attendance for all students
-- Attendance   is references the ClassSchedule to define the course, section,class
-- Attendance   further defines the student
-- Design: EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceStaging_vw]
AS
SELECT
    [index]
   ,student_id
   ,student_nm
   ,a.course_nm
   ,a.section_nm AS a_section_nm
   ,sec.section_nm AS sec_section_nm
   ,csv.classSchedule_id
   ,attendance_percent
   ,c.course_id
   ,sec.section_id
--   ,st_time
   ,time24
   ,stage
   ,cm.ordinal
   ,cm.dt as [date]
   ,value as present
FROM
          AttendanceStaging a CROSS APPLY string_split(a.stage, NCHAR(9),1)
LEFT JOIN AttendanceStagingColMap cm  ON a.  [index]    = cm.ordinal
LEFT JOIN Course                  c   ON c.  course_nm  = a.course_nm
LEFT JOIN Section                 sec ON sec.section_nm = a.section_nm
LEFT JOIN ClassSchedule_vw        csv ON csv.classSchedule_id=cm. schedule_id AND csv.[day] = dbo.fnGetDayfromDate(dt)
--WHERE value <> '-'
;
/*
SELECT * FROM AttendanceStaging_vw;
SELECT * FROM AttendanceStaging;
SELECT * FROM AttendanceStagingColMap;
SELECT * FROM AttendanceStagingCourseHdr;
SELECT * FROM ClassSchedule_vw;

SELECT TOP 100 * FROM Enrollment WHERE student_id = '2020-1309';
SELECT TOP 100 * FROM Enrollment_vw WHERE student_id = '2020-1309';
SELECT * FROM Attendance_vw WHERE student_id = '2023-1772'
SELECT TOP 100 * FROM Enrollment_vw WHERE student_id = '2023-1772';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 11-MAY-2025
-- Description: displays the AttendanceStagingColMap
-- =============================================================
CREATE VIEW [dbo].[AttendanceStagingColMap_vw]
AS
SELECT TOP 10000 
ordinal, dt, time24, [day], st_time, end_time, schedule_id, dow
FROM
     AttendanceStagingColMap cm
LEFT JOIN Schedule_vw s ON cm.schedule_id =s.classSchedule_id
ORDER BY dt,st_time;
/*
SELECT * FROM AttendanceStagingColMap_vw;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--====================================================================================
-- Author:       Terry Watts
-- Create date:  28-May-2025
-- Description:  Displays the student attendance summary
-- Attendance_vw references the ClassSchedule to define the course, section,class
-- Attendance_vw further defines the student
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceSummaryByTeam_vw]
AS
SELECT TOP 1000 team_nm, mean_attendance, section_nm, att
FROM
(
SELECT
       tm.team_nm
      ,tm.section_nm
      ,FORMAT(avg(attendance), '00.00%') as mean_attendance, avg(attendance) as att
FROM TeamMember_vw tm JOIN AttendanceSummary_vw a ON tm.student_id=a.student_id
--WHERE tm.section_nm in ('IT 3B', 'IT 3C')
GROUP BY tm.section_nm, tm.team_nm
) X
ORDER BY att DESC;
;
/*
SELECT * FROM AttendanceSummaryByTeam_vw WHERE section_nm in ('IT 3B')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--====================================================================================
-- Author:       Terry Watts
-- Create date:  28-May-2025
-- Description:  Displays the student attendance summary
-- Attendance_vw references the ClassSchedule to define the course, section,class
-- Attendance_vw further defines the student
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceSummaryByTeamIT_3BC_vw]
AS
SELECT TOP 1000
    team_nm
   ,FORMAT(att, '00.00%') AS mean_attendance
   ,section_nm
FROM
(
SELECT
       team_nm
      ,section_nm
      ,att
FROM AttendanceSummaryByTeam_vw
WHERE section_nm in ('IT 3B', 'IT 3C')
) X
ORDER BY att DESC;
/*
SELECT * FROM AttendanceSummaryByTeamIT_3BC_vw;
SELECT * FROM AttendanceSummaryByTeam_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




CREATE view [dbo].[ClassScheduleNewStaging_vw]
AS
   WITH CTE AS
   (
   SELECT TOP 1000 A.course_id, a.description, a.major_nm, a.section_nm, a.day, a.st_time, a.ordinal
   FROM 
      (
      SELECT
       course_id
      ,[description]
      ,major_nm
      ,section_nm
      ,[day].value as [day]
      ,st_time.value AS st_time
      ,st_time.ordinal

      ,day_num = 
         CASE
            WHEN [day].value= 'Mon' THEN 1
            WHEN [day].value= 'Tue' THEN 2
            WHEN [day].value= 'Wed' THEN 3
            WHEN [day].value= 'Thu' THEN 4
            WHEN [day].value= 'Fri' THEN 5
            WHEN [day].value= 'Sat' THEN 6
            WHEN [day].value= 'Sun' THEN 7
        END
   FROM ClassScheduleNewStaging c
   CROSS Apply string_split([days], ',') as [day]
   CROSS Apply string_split(times,  ',', 1) as st_time
   ) A
   )
   SELECT cte.course_id, cte.day, cte.description, cte.major_nm, cte.section_nm, ordinal--, room
   FROM cte 
   JOIN 
   (
      SELECT
       course_id
      ,[description]
      ,major_nm
      ,section_nm
      ,[days].value as [day]
      ,rooms.value as room
      FROM
      ClassScheduleNewStaging css 
      CROSS Apply string_split([days], ',') as [days]
      CROSS Apply string_split(rooms,  ',') as rooms
   )   x ON cte.course_id=X.course_id AND cte.section_nm = X.section_nm AND cte.day = X.day --AND X.
;


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Description: Displays the Course section info
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 01-MAR-2025
-- =============================================
CREATE view .[dbo].[CourseSectionStaging_vw] as
SELECT TOP 1000 c.course_nm, s.section_nm, c.course_id as course_id, s.section_id
FROM CourseSection cs 
JOIN course c ON cs.course_id = c.course_id 
JOIN section s ON s.section_id = cs.section_id
ORDER BY c.course_nm, s.section_nm;
/*
SELECT * FROM CourseSectionStaging_vw;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE VIEW [dbo].[DorsuHours_vw]
AS
SELECT TOP 100000 DATE_BUCKET (day, 1, Created) AS Created, COUNT(*) as cnt
FROM
(
SELECT Created
FROM
(
SELECT
  DATE_BUCKET (hour, 1, Cast(Created as DateTime)) as Created
  FROM [Dorsu_Dev].[dbo].[tsvStaging]
  WHERE Cast(Created as DateTime) > '2025-02-17 07:45:00.000'
  GROUP BY DATE_BUCKET (hour, 1, Cast(Created as DateTime))
  UNION 
SELECT
  DATE_BUCKET (hour, 1, Cast(LastModified as DateTime)) as Created
  FROM [Dorsu_Dev].[dbo].[tsvStaging]
  WHERE Cast(LastModified as DateTime) > '2025-02-17 07:45:00.000'
  GROUP BY DATE_BUCKET (hour, 1, Cast(LastModified as DateTime))
  UNION
SELECT
  DATE_BUCKET (hour, 1, Cast(LastAccessed as DateTime)) as Created
  FROM [Dorsu_Dev].[dbo].[tsvStaging]
  WHERE Cast(LastAccessed as DateTime) > '2025-02-17 07:45:00.000'
  GROUP BY DATE_BUCKET (hour, 1, Cast(LastAccessed as DateTime))
) X
GROUP BY Created
) Y
GROUP BY DATE_BUCKET (day, 1, Created)
ORDER BY Created
;
/*
SELECT * FROM DorsuHours_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =========================================================
-- View:         list_fks_vw
-- Description:  List the FK fields for all FKs
-- Design:       
-- Tests:        
-- Author:       Terry Watts
-- Create date:  01-MAR-2025
-- Preconditions: none
-- =========================================================
CREATE VIEW [dbo].[fks_cols_vw]
AS
SELECT
    schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table
   ,schema_name(pk_tab.schema_id) + '.' + pk_tab.name as primary_table
   ,fk_cols.constraint_column_id as no --, 
   ,fk_col.name as fk_column_name
   ,' = ' as [join]
   ,pk_col.name as pk_column_name
   ,fk.name as fk_constraint_name
FROM sys.foreign_keys fk
    join sys.tables              fk_tab  on fk_tab.object_id = fk.parent_object_id
    join sys.tables              pk_tab  on pk_tab.object_id = fk.referenced_object_id
    join sys.foreign_key_columns fk_cols on fk_cols.constraint_object_id = fk.object_id
    join sys.columns             fk_col  on fk_col.column_id = fk_cols.parent_column_id
                                          and fk_col.object_id = fk_tab.object_id
    join sys.columns             pk_col  on pk_col.column_id = fk_cols.referenced_column_id
                                          and pk_col.object_id = pk_tab.object_id
;


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--=====================================================================
-- Author:      Terry Watts
-- Create date: 23-Mar-2025
-- Description: Displays the attendance for all students
--
-- Design: EA
-- Tests:
--=====================================================================
CREATE VIEW [dbo].[import_AttendanceGMeet2Staging_vw]
AS
SELECT
    s_no, google_alias, meet_st, Joined, [stopped], duration, gmeet_id
FROM
     AttendanceGMeet2Staging
/*
SELECT * FROM import_AttendanceGMeet2Staging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================
-- Description: used to import the ImportAttendanceGMeet2StagingHdr_vw table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 24-APR-2025
-- ==========================================================================
CREATE VIEW [dbo].[ImportAttendanceGMeet2StagingHdr_vw]
AS
SELECT 
   id
FROM AttendanceGMeet2StagingHdr;
/*
SELECT * FROM ImportAttendanceGMeet2StagingHdr_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================
-- Description: used to import the ImportAttendanceGMeet2StagingHdr_vw table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 24-APR-2025
-- ==========================================================================
CREATE VIEW [dbo].[ImportAttendanceGMeet2StagingHdr2_vw]
AS
SELECT 
   staging

  -- id,[date]
FROM AttendanceGMeet2StagingHdr2;
/*
SELECT * FROM ImportAttendanceGMeet2StagingHdr_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Description: Displays the Course section info
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 06-MAR-2025
-- =============================================
CREATE view [dbo].[ImportAttendanceStaging_vw]
AS
SELECT 
    [index]
   ,student_id
   ,student_nm
   ,attendance_percent
   ,stage
FROM AttendanceStaging;
/*
SELECT * FROM ImportAttendanceStaging_vw;
SELECT * FROM AttendanceStaging;

EXEC test.test_056_sp_Import_AttendanceStaging;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =================================================================
-- Description: used to import the AttendanceStagingCourseHdr table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 06-MAR-2025
-- =================================================================
CREATE VIEW [dbo].[ImportAttendanceStagingCourseHdr_vw]
AS
SELECT id, course_nm, section_nm, stage
FROM AttendanceStagingCourseHdr;
/*
SELECT * FROM ImportAttendanceStagingCourseHdr_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Description: used to import the ImportAttendanceStagingHdr table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 06-MAR-2025
-- =================================================================
CREATE view [dbo].[ImportAttendanceStagingHdr_vw]
AS
SELECT *
FROM AttendanceStagingHdr;
/*
SELECT * FROM ImportAttendanceStagingHdr_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--====================================================================================
-- Author:       Terry Watts
-- Create date:  10-May-2025
-- Description:  used to control teh import fields
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[ImportClassScheduleStaging_vw]
AS
SELECT
      id,
      course_nm,
      major_nm,
      section_nm,
      [day],
      times,
      room_nm
FROM
     ClassScheduleStaging
;
/*
SELECT * FROM ImportClassScheduleStaging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE VIEW [dbo].[ImportExamSchedule_vw]
AS
SELECT 
    id
	,[days]
	,st
	,[end]
	,ex_st
	,ex_end 
	,ex_date
	,ex_day
FROM ExamSchedule
;
/*
SELECT * FROM ImportExamSchedule_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[ImportGenericStaging_vw]
AS
SELECT staging
FROM GenericStaging
;
/*
SELECT * FROM ImportExamSchedule_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: Displays the Course section info
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 06-MAR-2025
-- =============================================
CREATE view [dbo].[ImportGMeetAttendanceStaging_vw]
AS
SELECT line
FROM AttendanceGMeetStaging
/*
SELECT * FROM ImportGMeetAttendanceStaging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--=====================================================================
-- Author:      Terry Watts
-- Create date: 12-Apr-2025
-- Description: Displays the dbo table relationships
--=====================================================================
CREATE VIEW [dbo].[Relationships_vw]
AS
   SELECT TOP 1000
   CONSTRAINT_NAME
   FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
   WHERE CONSTRAINT_SCHEMA='dbo'
   ORDER BY CONSTRAINT_NAME;
;
/*
   SELECT * FROM Relationships_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE VIEW [dbo].[student_vw] as
SELECT
       X.student_id
      ,X.student_nm
      ,X.gender
      ,X.google_alias
      ,X.FB_alias
      ,X.section_nm
      ,X.courses
      ,X.major_nm
      ,FORMAT(IIF(SUM(a.tot_classes) > 0, SUM(a.att)/SUM(a.tot_classes), 0), '00.00%') as attendance_pc
      ,SUM(a.tot_classes) as att_cnt
FROM
(
   SELECT
       s.student_id
      ,s.student_nm
      ,s.gender
      ,s.google_alias
      ,s.FB_alias
      ,e.section_nm
      ,string_agg(e.course_nm, ',') WITHIN GROUP (ORDER BY e.course_nm) AS courses
      ,e.major_nm
   FROM Student s
   LEFT JOIN Enrollment_vw e ON e.student_id = s.student_id
   GROUP BY s.student_id, s.student_nm, s.gender, s.google_alias, s.FB_alias, s.email
   , s.section_id, e.section_id, e.section_nm, e.major_nm
) X
LEFT JOIN AttendanceSummary_vw a ON a.student_id = X.student_id
GROUP BY X.student_id, X.student_nm, X.gender, X.google_alias, X.FB_alias, X.section_nm, X.courses, X.major_nm
;

/*
SELECT * FROM student_vw ORDER BY student_nm;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 23-FEB-2025
-- Description: lists the students and their courses
-- =============================================================
CREATE VIEW [dbo].[StudentCourse_vw]
AS
SELECT TOP 10000 s.student_id, s.student_nm, s.gender, e.course_nm, section_nm
FROM Student s
LEFT JOIN Enrollment_vw e  ON s.student_id   = e .student_id
--LEFT JOIN Section        sec ON sec.section_id = ss .section_id
--LEFT JOIN CourseSection  cs  ON cs.section_id  = sec.section_id
--LEFT JOIN Course         c   ON c.course_id    = cs .course_id
ORDER BY s.student_nm,course_nm
;
/*
SELECT * FROM StudentCourse_vw;
SELECT * FROM section
SELECT * FROM StudentSection
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 02-MAR-2025
-- Description: lists the students and their courses, sections
-- =============================================================
CREATE VIEW [dbo].[StudentSectionCourse_vw]
AS
SELECT s.student_id, student_nm, sec.section_nm, course_nm
FROM
             Enrollment     e
   LEFT JOIN Student        s   on s.  student_id = e.student_id
   LEFT JOIN Course         c   on c  .course_id  = e . course_id
   LEFT JOIN Section        sec on sec.section_id = e .section_id
   LEFT JOIN CourseSection  cs  on cs .section_id = sec.section_id
;
/*
SE
SELECT * FROM Student;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================
-- Description: Displays the student section info
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 03-MAR-2025
-- ===============================================
CREATE view .[dbo].[StudentSectionStaging_vw] as
SELECT s.student_nm, s.student_id, c.course_nm, c.course_id, sec.section_nm, sec.section_id
FROM StudentCourseStaging scs
JOIN Student s   ON s.student_id = scs.student_id
JOIN Course  c   ON c.course_nm   =  scs.course_nm
JOIN Section sec ON sec.section_nm = scs.section_nm
/*
SELECT * FROM StudentSectionStaging_vw ORDER BY student_nm, course_nm, section_nm;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
-- Description: returns the parameters
-- e.g. sysobjects xtype code 
-- ======================================================
CREATE VIEW [dbo].[SysRtnPrms_vw]
AS 
SELECT
    SCHEMA_NAME( schema_id)            AS schema_nm
   ,OBJECT_NAME(sap.object_id)         AS rtn_nm
   ,sap.name                           AS prm_nm
   ,parameter_id                       AS ordinal
   ,UPPER(TYPE_NAME(system_type_id))   AS ty_nm

   ,IIF( TYPE_NAME(system_type_id) IN ('VARCHAR', 'NVARCHAR', 'NTEXT')
      ,CONCAT( UPPER(TYPE_NAME(system_type_id)), '('
              ,iif
               ( system_type_id in (167, 231)
                ,iif(max_length= -1, 4000,max_length/2)
                , max_length
               )
              ,')'
             ) -- end concat
      ,dbo.fnGetFullTypeName(TYPE_NAME(system_type_id), max_length/2)--TYPE_NAME(system_type_id)
      )          AS ty_nm_full
   ,system_type_id                     AS ty_id
   ,iif
    (
       system_type_id in (231)
      ,max_length/2, max_length
    ) AS ty_len
    , IIF(TYPE_NAME(system_type_id) IN ('VARCHAR', 'NVARCHAR', 'NCHAR','CHAR','NTEXT'), 1, 0) AS is_chr_ty
   ,is_output
   ,is_nullable
   ,has_default_value
   ,default_value
   ,dbo.fnGetTyNmFrmTyCode([type])     AS rtn_ty_nm
   ,[type]                             AS rtn_ty_code
FROM sys.all_parameters sap
     JOIN sys.all_objects so ON sap.object_id=so.object_id
 ;

/*
SELECT * FROM SysRtnPrms_vw WHERE rtn_nm = 'sp_ImportAttendanceGMeet2Staging';
SELECT  * FROM paramsVw where param_nm ='' -- Scalar function, CLR scalar function return value
SELECT TOP 100 * FROM sys.all_parameters sap JOIN sys.all_objects so ON sap.object_id=so.object_id;
SELECT top 10 * FROM sys.sysobjects
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE   view [dbo].[timetable_vw]
AS
SELECT st_time as [start], end_time as [end],
iif(Mon is null, '', CONCAT(course_nm, ' sec: ',Mon, ', rm: ', room_nm)) AS Monday,
iif(Tue is null, '', CONCAT(course_nm, ' sec: ',Tue, ', rm: ', room_nm)) AS Tuesday,
iif(Wed is null, '', CONCAT(course_nm, ' sec: ',Wed, ', rm: ', room_nm)) AS Wednesday,
iif(Thu is null, '', CONCAT(course_nm, ' sec: ',Thu, ', rm: ', room_nm)) AS Thursday,
iif(Fri is null, '', CONCAT(course_nm, ' sec: ',Fri, ', rm: ', room_nm)) AS Friday
FROM
(
  SELECT --iif(Mon is null, '', CONCAT(course_nm, ' sec: ',Mon, ', rm: ', room_nm)) AS Monday,
  st_time, end_time, course_nm, section_nm, [day], room_nm, 6 as ndx
  FROM ClassSchedule_vw
) as sourcetable
pivot
(
MAX(/*section_nm*/ndx) for [day] in ([Mon],[Tue],[Wed],[Thu],[Fri])
) AS PVTl;
/*
SELECT * FROM timetable_vw;
SELECT * FROM ClassSchedule_vw
SELECT * FROM ClassScheduleStaging
SELECT * FROM ClassSchedule
SELECT * FROM section
*/

GO
/*
----------------------------------------------------------------------------------------------------
Summary:
----------------------------------------------------------------------------------------------------
Datbases              :   0 items items
Schemas               :   0 items items
Tables                :   0 items items
Procedures            :  92 items items
Functions             : 100 items items
Views                 :   0 items items
Table Types           :   0 items items
UserDefinedDataTypes  :   0 items items
Wanted Items          : 312 items items
Consisidered Entities : 312 items items
Different Databases   :   4 items items
Duplicate Dependencies:   2 items items
System Objects        :  10 items items
Unresolved Entities   :  10 items items
Unwanted Types        :   0 items items
Unknown Entities      :   0 items items
Bad bin               :   0 items items
*/
