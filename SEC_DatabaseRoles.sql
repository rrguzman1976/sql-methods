USE Sec_Test;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'user4')
	DROP USER user4;
GO
IF OBJECT_ID(N'schemaY.secTable4', N'U') IS NOT NULL
	DROP TABLE schemaY.secTable4;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'schemaX')
	DROP SCHEMA schemaX;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'schemaY')
	DROP SCHEMA schemaY;
GO

IF EXISTS(SELECT * FROM sys.database_principals WHERE name = N'db_roleX')
BEGIN
	ALTER ROLE db_roleX DROP MEMBER [user3];
	DROP ROLE db_roleX;
END;
GO

CREATE USER user4 FROM LOGIN login4;
GO

CREATE ROLE db_roleX;
GO

-- Create schema owned by database role
-- Schema owner always retains CONTROL permission on objects within the schema.
CREATE SCHEMA schemaX AUTHORIZATION db_roleX;
GO

-- Create schema owned by different principal
CREATE SCHEMA schemaY AUTHORIZATION dbo;
GO

-- Grant database level permissions.
GRANT CREATE TABLE TO db_roleX;
--REVOKE CREATE TABLE TO db_roleX;
--GRANT VIEW DATABASE STATE TO db_roleX;
--REVOKE VIEW DATABASE STATE TO db_roleX;
GO

-- Grant schema-level permissions.
GRANT ALTER ON SCHEMA::schemaY TO db_roleX;
--GRANT CONTROL ON SCHEMA::schemaY TO db_roleX;
--REVOKE CONTROL ON SCHEMA::schemaY TO db_roleX;
GO

-- Grant object-level permission. Doesn't require SELECT on dbo.
GRANT SELECT ON SCHEMA::dbo TO db_roleX;
--GRANT SELECT ON OBJECT::dbo.secTable3 TO db_roleX;
--REVOKE SELECT ON OBJECT::dbo.secTable3 TO db_roleX;
GO

-- Update membership
ALTER ROLE db_roleX ADD MEMBER [user4];
GO
ALTER ROLE db_backupoperator ADD MEMBER db_RoleX; -- allowed
--ALTER ROLE db_backupoperator ADD MEMBER db_denydatareader; -- not allowed
--ALTER ROLE db_RoleX ADD MEMBER db_backupoperator; -- not allowed

EXECUTE AS USER = 'user4';
GO

SELECT	CURRENT_USER AS [current];
GO

CREATE TABLE schemaY.secTable4
(
	ID INT IDENTITY NOT NULL
	, sVAL NVARCHAR(24) NULL
);
GO

SELECT	'dbo.secTable3', *
FROM	dbo.secTable3;
GO

REVERT;
GO

SELECT	CURRENT_USER AS [after];
GO

-- Check permissions and membership
SELECT	p.name, p.principal_id, p.type_desc, p.create_date
		, q.class_desc, q.[permission_name], q.state_desc
		, m.member_principal_id, p2.name AS [member_name]
FROM	sys.database_principals AS p
	LEFT JOIN sys.database_permissions AS q
		ON p.principal_id = q.grantee_principal_id
	LEFT JOIN sys.database_role_members AS m
		ON p.principal_id = m.role_principal_id
	LEFT JOIN sys.database_principals AS p2
		ON m.member_principal_id = p2.principal_id
WHERE p.name IN (N'db_roleX', N'user4');

-- Cleanup
IF OBJECT_ID(N'schemaY.secTable4', N'U') IS NOT NULL
	DROP TABLE schemaY.secTable4;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'schemaX')
	DROP SCHEMA schemaX;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'schemaY')
	DROP SCHEMA schemaY;
GO

IF EXISTS(SELECT * FROM sys.database_principals WHERE name = N'db_roleX')
BEGIN
	ALTER ROLE db_roleX DROP MEMBER [user4];
	ALTER ROLE db_backupoperator DROP MEMBER db_RoleX; -- allowed
	DROP ROLE db_roleX;
END;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'user4')
	DROP USER user4;
GO
