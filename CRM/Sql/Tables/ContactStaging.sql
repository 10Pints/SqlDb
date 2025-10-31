CREATE TABLE [dbo].[ContactStaging] (
    [contact_id]             INT           IDENTITY (1, 1) NOT NULL,
    [contact_nm]             VARCHAR (300) NULL,
    [role]                   VARCHAR (50)  NULL,
    [phone]                  VARCHAR (50)  NULL,
    [viber]                  VARCHAR (50)  NULL,
    [whatsApp]               VARCHAR (50)  NULL,
    [facebook]               VARCHAR (50)  NULL,
    [messenger]              VARCHAR (50)  NULL,
    [primary_contact_type]   VARCHAR (50)  NULL,
    [primary_contact_detail] VARCHAR (50)  NULL,
    [last_contacted]         DATE          NULL,
    [is_active]              BIT           NULL,
    [sex]                    CHAR (1)      NULL,
    [age]                    INT           NULL,
    CONSTRAINT [PK_ContactStaging] PRIMARY KEY CLUSTERED ([contact_id] ASC)
);

