USE master;
GO

IF DB_ID(N'Sec_Test') IS NULL
BEGIN
	CREATE DATABASE Sec_Test;
END;
GO

USE Sec_Test;
GO

IF OBJECT_ID(N'dbo.secTable3', N'U') IS NOT NULL DROP TABLE dbo.secTable3;
GO

CREATE TABLE dbo.secTable3
(
	ID INT NOT NULL
		PRIMARY KEY
	, strVal NVARCHAR(25) NULL
);
GO

INSERT INTO dbo.secTable3(ID, strVal)
VALUES (1, N'1'), (2, N'2');
GO

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = N'user3')
BEGIN
	CREATE USER user3 FROM LOGIN login3;
END;

-- Grants permission at the database level. Without this permission, user 3 cannot create tables
-- even with schema permissions below. (note, drop table is allowed)
-- However, any schema modification, even on dbo, is denied so tables still can't be created.
GRANT CREATE TABLE TO user3;
--REVOKE CREATE TABLE TO user3;
GO

-- CREATE SCHEMA implies ALTER SCHEMA on any schemas created by user so tables within the
-- owned schema can be created.
-- However, access to dbo schema is still restricted as it already exists.
GRANT CREATE SCHEMA TO user3;
GO

-- Grant permission to alter the dbo schema (schema level permission).
-- This allows user3 to create tables in the dbo schema.
GRANT CONTROL ON SCHEMA::dbo TO user3;
GO

-- Grant permissions at the object level.
DENY SELECT ON OBJECT::dbo.secTable3 TO user3;
GO

/*
USE Sec_Test;
GO

EXECUTE AS user3;
GO

IF OBJECT_ID(N'tmpSchema.secTable', N'U') IS NOT NULL DROP TABLE tmpSchema.secTable;
GO
IF OBJECT_ID(N'dbo.secTable2', N'U') IS NOT NULL DROP TABLE dbo.secTable2;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'tmpSchema') DROP SCHEMA tmpSchema;
GO

-- Fails until CREATE SCHEMA is granted.
CREATE SCHEMA tmpSchema AUTHORIZATION user3;
GO

CREATE TABLE tmpSchema.secTable
(
	ID INT NOT NULL
		PRIMARY KEY
	, strVal NVARCHAR(25) NULL
);
GO

-- Fails until CONTROL ON SCHEMA::dbo is granted
CREATE TABLE dbo.secTable2
(
	ID INT NOT NULL
		PRIMARY KEY
	, strVal NVARCHAR(25) NULL
);
GO

-- Fails when DENY SELECT is granted
SELECT	*
FROM	dbo.secTable3;

REVERT;
GO
*/