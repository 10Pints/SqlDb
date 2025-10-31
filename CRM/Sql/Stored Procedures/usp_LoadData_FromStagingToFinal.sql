-- =============================================
-- Procedure:   <proc_nm>
-- Description: 
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- Author:      
-- Create date: 
-- =============================================
CREATE PROCEDURE dbo.usp_LoadData_FromStagingToFinal
AS
BEGIN
    SET NOCOUNT ON;
    CREATE Table MainTable(id int, name VARCHAR(100), [Status] VARCHAR(20), Date_Added_Clean DATE);

    -- 1. Cleanse and insert the good data in a single, set-based operation
    INSERT INTO dbo.MainTable (
        [Name],
        [Phone_Clean], -- Cleaned version of the phone column
        [Status],
        [Date_Added_Clean] -- Properly typed date
    )
    SELECT
        -- Use TRIM and REPLACE to clean text
        TRIM([Name]) AS [Name],
        
        -- Cleanse phone numbers: remove non-numeric characters
        -- Use NULLIF to turn empty strings into NULLs
        NULLIF(REPLACE(REPLACE(REPLACE([phone], ' ', ''), '-', ''), '.', ''), '') AS Phone_Clean,
        
        -- Standardize status values with a CASE statement
        CASE
            WHEN UPPER(TRIM([Status])) IN ('OK', 'ACTIVE', 'ACCEPTED') THEN 'Active'
            WHEN UPPER(TRIM([Status])) IN ('DEAD', 'CLOSED', 'OS') THEN 'Closed'
            ELSE 'Unknown'
        END AS [Status],
        
        -- Safely attempt to convert a date. If it fails, it will be NULL.
        TRY_CAST([date_1] AS DATE) AS Date_Added_Clean
    FROM
        dbo.MainTable
    WHERE
        -- Optional: Add a WHERE clause to filter out obviously bad data *before* the insert
        -- This is not the error logging step, just pre-filtering.
        1 = 1;

   CREATE TABLE ImportErrorLog
   (
     ErrorTime    VARCHAR(100)
   , SourceTable  VARCHAR(100)
   , ColumnName   VARCHAR(100)
   , ProblemValue VARCHAR(100)
   , RejectedRow  VARCHAR(100)
   )
    -- 2. Now, find and log the rows that failed our quality checks (set-based logging!)
    INSERT INTO dbo.ImportErrorLog (ErrorTime, SourceTable, ColumnName, ProblemValue, RejectedRow)
    SELECT
        GETDATE(),
        'MainTable',
        'date_1',
        Date_Added_Clean,
        -- This is a simple way to log the entire problematic row as JSON
        (SELECT [Name], [Status], Date_Added_Clean FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM
        dbo.MainTable
    WHERE
        -- This condition finds rows where our date conversion failed
        TRY_CAST(Date_Added_Clean AS DATE) IS NULL
        AND Date_Added_Clean IS NOT NULL -- This ensures we don't log legitimate NULLs as errors
        -- Add other conditions for other columns here with OR...

END;
