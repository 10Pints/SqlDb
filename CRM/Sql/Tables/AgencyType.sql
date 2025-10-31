CREATE TABLE [dbo].[AgencyType] (
    [agencyType_id] INT          NOT NULL,
    [agencyType_nm] VARCHAR (15) NULL,
    CONSTRAINT [PK_AgencyType] PRIMARY KEY CLUSTERED ([agencyType_id] ASC),
    CONSTRAINT [UQ_AgencyType_nm] UNIQUE NONCLUSTERED ([agencyType_nm] ASC)
);

