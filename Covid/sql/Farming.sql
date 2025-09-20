/*
Parameters:

--------------------------------------------------------------------------------
 Type            : Params
--------------------------------------------------------------------------------
 CreateMode      : Create
 Database        : Covid
 DisplayLog      : True
 DisplayScript   : True
 IndividualFiles              : False
 Instance                     : 
 IsExprtngData                : False
 LogFile                      : D:\Logs\Farming.log
 LogLevel                     : Info
 Name                         : DbScripterApp config
 RequiredAssemblies           : System.Collections.Generic.List`1[System.String]
 RequiredSchemas              : System.Collections.Generic.List`1[System.String]
 RequiredFunctions            : System.Collections.Generic.List`1[System.String]
 RequiredProcedures           : System.Collections.Generic.List`1[System.String]
 RequiredTables               : System.Collections.Generic.List`1[System.String]
 RequiredViews                : System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedTypes     : System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedDataTypes : System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedTableTypes: System.Collections.Generic.List`1[System.String]
 Want All:                  : Assembly
 Want All:                  : Database
 Want All:                  : Function
 Want All:                  : Procedure
 Want All:                  : Schema
 Want All:                  : Table
 Want All:                  : View
 Want All:                  : UserDefinedType
 Want All:                  : UserDefinedDataType
 Want All:                  : UserDefinedTableType
 Script Dir                   : D:\Dev\SqlDb\Covid\sql
 Script File                  : D:\Dev\SqlDb\Covid\sql\Farming.sql
 ScriptUseDb                  : True
 Server                       : DevI9
 AddTimestamp                 : False
 Timestamp                    : 250720-2131

 RequiredSchemas : 1
	dbo

*/

USE [Covid]
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if 2 floats are approximately equal
-- Returns    : 1 if a significantly gtr than b
--              0 if a = b with the signifcance of epsilon 
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise
-- DROP FUNCTION [dbo].[fnCompareFloats2]
-- ============================================================
CREATE FUNCTION [dbo].[fnCompareFloats2](@a FLOAT, @b FLOAT, @epsilon FLOAT = 0.00001)
RETURNS INT
AS
BEGIN
   DECLARE   @v      FLOAT
            ,@res    INT

   SET @v   = abs(@a - @b);

   IF(@v < @epsilon)
      RETURN 0;  -- a = b within the tolerance of epsilon

   -- ASSERTION  a is signifcantly different to b

   -- 10-7 is the tolerance for floats
   SET @v   = round(@a - @b, 7);
   SET @res = IIF( @v>0.0, 1, -1);
   RETURN @res;
END
/*
EXEC test.sp_crt_tst_rtns 'dbo].[fnCompareFloats2', 80
-- Test
-- cmp > tolerance
PRINT CONCAT('[dbo].[fnCompareFloats2](1.2, 1.3, 0.00001)          : ', [dbo].[fnCompareFloats2](1.2, 1.3, 0.00001),       ' T01: EXP -1')
PRINT CONCAT('[dbo].[fnCompareFloats2](1.2, 1.2, 0.00001)          : ', [dbo].[fnCompareFloats2](1.2, 1.2, 0.00001),       '  T02: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](1.3, 1.2, 0.00001)          : ', [dbo].[fnCompareFloats2](1.3, 1.2, 0.00001),       '  T03: EXP  1')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,      0.1 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,       0.1, 0.00001), '  T04: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.10001,  0.1 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.10001,   0.1, 0.00001), '  T05: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.000009, 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.100009, 0.00001), '  T06 in tolerance: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.10001 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.10001 , 0.00001), '  T07 exact: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.000011, 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.100011, 0.00001), ' T08 out of tolerance: EXP -1')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.100011, 0.1, 0.00001)     : ', [dbo].[fnCompareFloats2](0.100011, 0.1, 0.00001) , '  T09 out of tolerance: EXP  1')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if 2 floats are approximately equal
-- Returns    : 1 if a significantly gtr than b
--              0 if a = b with the signifcance of epsilon 
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise
-- =================================================================
CREATE FUNCTION [dbo].[fnCompareFloats](@a FLOAT, @b FLOAT)
RETURNS INT
AS
BEGIN
   RETURN
      dbo.fnCompareFloats2(@a, @b, 0.00001);
END
/*
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================
-- Author:      Terry Watts
-- Create date: 23-Jul-2024
-- Description: creates the script file name based on 
--    rtn_nm, server name and DB name
--
--- Changes:
-- =========================================================================
CREATE FUNCTION [test].[fnCrtScriptFileName](@rtn_nm NVARCHAR(60))
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE @ret NVARCHAR(MAX)
   SELECT @ret = CONCAT(@@SERVERNAME, '.', DB_NAME(), '.', @rtn_nm,'.sql');

RETURN @ret;
END
/*
PRINT test.fnCrtScriptFileName('MyRtn','D:\tmp');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [test].[RtnDetails](
	[qrn] [nvarchar](90) NULL,
	[schema_nm] [nvarchar](60) NULL,
	[rtn_nm] [nvarchar](60) NULL,
	[trn] [int] NULL,
	[cora] [nchar](1) NULL,
	[ad_stp] [bit] NULL,
	[tst_mode] [bit] NULL,
	[stop_stage] [int] NULL,
	[rtn_ty] [nvarchar](50) NULL,
	[rtn_ty_code] [nvarchar](2) NULL,
	[is_clr] [bit] NULL,
	[tst_rtn_nm] [nvarchar](50) NULL,
	[hlpr_rtn_nm] [nvarchar](50) NULL,
	[max_prm_len] [int] NULL,
	[sc_fn_ret_ty] [nvarchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [test].[HlprDef](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[line] [nvarchar](4000) NULL,
 CONSTRAINT [PK_test.HlprDef] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
