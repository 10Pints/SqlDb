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
