SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE VIEW [dbo].[sys_objs_vw]
AS
-- https://social.msdn.microsoft.com/Forums/sqlserver/en-US/9d0b5f32-e413-403f-9a40-b876663132b9/how-to-tell-system-stored-procedures-from-user-stored-procedures-in-sysprocedures?forum=transactsql
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver15
-- ET = External Table
-- FN = SQL scalar function
-- FS = Assembly (CLR) scalar-function
-- FT = Assembly (CLR) table-valued function
-- IF = SQL inline table-valued function
-- P  = SQL Stored Procedure
-- PC = Assembly (CLR) stored-procedure
-- PK = PRIMARY KEY constraint
-- RF = Replication-filter-procedure
-- TF = SQL table-valued-function
-- TT = Table type
-- U  = table
-- UQ = Unique Key
-- PK = primary key
-- P  = procedure
-- V: = View
-- X  = Extended procedure
SELECT * FROM
(
SELECT
  sp.name AS [name]
 ,sp.type AS [ty]
 , (CASE 
   WHEN sp.type = 'AF' THEN 'CLR aggregate function'
   WHEN sp.type = 'C'  THEN 'CHECK constraint'
   WHEN sp.type = 'D'  THEN 'DEFAULT'
   WHEN sp.type = 'EC' THEN 'Edge constraint'
   WHEN sp.type = 'ET' THEN 'External tbl'
   WHEN sp.type = 'F'  THEN 'Foreign key'
   WHEN sp.type = 'FN' THEN 'SQL scalar fn'
   WHEN sp.type = 'FS' THEN 'CLR scalar fn'
   WHEN sp.type = 'FT' THEN 'CLR tbl fn'
   WHEN sp.type = 'IF' THEN 'SQL inline tbl fn'
   WHEN sp.type = 'IT' THEN 'Intrnl tbl'
   WHEN sp.type = 'P'  THEN 'SQL Proc'
   WHEN sp.type = 'PC' THEN '(CLR) proc'
   WHEN sp.type = 'PG' THEN 'Plan guide'
   WHEN sp.type = 'P'  THEN 'Procedure'
   WHEN sp.type = 'PK' THEN 'Primary key'
   WHEN sp.type = 'R'  THEN 'Rule'
   WHEN sp.type = 'RF' THEN 'Repl fltr proc'
   WHEN sp.type = 'S'  THEN 'Sys base tbl'
   WHEN sp.type = 'SN' THEN 'Synonym'
   WHEN sp.type = 'SO' THEN 'Sequence object'
   WHEN sp.type = 'SQ' THEN 'Service queue'
   WHEN sp.type = 'TA' THEN 'CLR DML trigger'
   WHEN sp.type = 'TF' THEN 'SQL tbl fn'
   WHEN sp.type = 'TR' THEN 'SQL DML trigger'
   WHEN sp.type = 'TT' THEN 'Table type'
   WHEN sp.type = 'U'  THEN 'Table'
   WHEN sp.type = 'UQ' THEN 'Unique Key'
   WHEN sp.type = 'V'  THEN 'View'
   WHEN sp.type = 'X'  THEN 'Extended proc'
   ELSE '???'
   END
   ) AS [type]
,CAST( CASE 
    WHEN sp.is_ms_shipped = 1 THEN 1
    WHEN (
        SELECT major_id 
        FROM sys.extended_properties 
        WHERE 
            major_id = sp.object_id
AND         minor_id = 0
AND         class    = 1
AND         [name]   = N'microsoft_database_tools_support'
        ) IS NOT NULL THEN 1
    ELSE 0
END AS BIT) AS is_system_object
,SCHEMA_NAME(sp.schema_id) AS [schema]
FROM
sys.all_objects                           AS sp
LEFT OUTER JOIN sys.sql_modules           AS smsp  ON smsp.object_id   = sp.object_id
LEFT OUTER JOIN sys.system_sql_modules    AS ssmsp ON ssmsp.object_id  = sp.object_id
) X
--WHERE is_system_object=0



GO
