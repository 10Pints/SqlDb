CREATE VIEW EventLogImport_vw
AS
SELECT [TimeCreated]
      ,[event_id]
      ,[event_type]
      ,[LogName]
      ,[ProviderName]
      ,[MachineName]
      ,[UserId]
      ,[Message]
  FROM [dbo].[EventLog]

