CREATE TABLE [dbo].[ContactAgency] (
    [contact_id] INT           NOT NULL,
    [agency_id]  INT           NOT NULL,
    [role_nm]    NVARCHAR (50) NULL,
    CONSTRAINT [PK_ContactAgency] PRIMARY KEY CLUSTERED ([contact_id] ASC, [agency_id] ASC),
    CONSTRAINT [FK_ContactAgency_Agency] FOREIGN KEY ([agency_id]) REFERENCES [dbo].[Agency] ([agency_id]),
    CONSTRAINT [FK_ContactAgency_Contact] FOREIGN KEY ([contact_id]) REFERENCES [dbo].[Contact] ([contact_id]),
    CONSTRAINT [UQ_ContactAgency] UNIQUE NONCLUSTERED ([contact_id] ASC, [agency_id] ASC)
);

