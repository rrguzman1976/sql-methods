USE [ScratchDB]
GO

IF OBJECT_ID(N'[CompanyTablesLoad].RKOTMP_Profile', N'U') IS NOT NULL
	DROP TABLE [CompanyTablesLoad].RKOTMP_Profile;

CREATE TABLE [CompanyTablesLoad].RKOTMP_Profile
(
	Id				INT IDENTITY(1, 1)	NOT NULL
		PRIMARY KEY
	, Comment		VARCHAR(128)		NOT NULL
	, ProcessTime	DATETIME2(2)		NOT NULL
		DEFAULT SYSDATETIME()
	, PassedDate	DATETIME			NULL
	, Package_GUID	VARCHAR(50)			NULL
);

INSERT INTO [CompanyTablesLoad].RKOTMP_Profile (Comment) VALUES ('Before query');

WAITFOR DELAY '00:00:03';

INSERT INTO [CompanyTablesLoad].RKOTMP_Profile (Comment) VALUES ('After query');

SELECT	*
FROM	[CompanyTablesLoad].RKOTMP_Profile;