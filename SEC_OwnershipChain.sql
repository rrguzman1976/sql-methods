SET NOCOUNT ON;
GO

-- Example 1: Basic ownership chaining.
-- Assumes login1 and login2 server principals exist.
USE Scratch_Test;
GO

IF OBJECT_ID(N'ochain.view1', N'V') IS NOT NULL DROP VIEW ochain.view1;
IF OBJECT_ID(N'ochain.view2', N'V') IS NOT NULL DROP VIEW ochain.view2;
IF OBJECT_ID(N'ochain2.view3', N'V') IS NOT NULL DROP VIEW ochain2.view3;
IF OBJECT_ID(N'ochain.view4', N'V') IS NOT NULL DROP VIEW ochain.view4;
IF OBJECT_ID(N'ochain2.viewX', N'V') IS NOT NULL DROP VIEW ochain2.viewX;
IF OBJECT_ID(N'ochain3.Color2', N'U') IS NOT NULL DROP TABLE ochain3.Color2;
GO
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'ochain') DROP SCHEMA ochain;
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'ochain2') DROP SCHEMA ochain2;
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'ochain3') DROP SCHEMA ochain3;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'user1') DROP USER user1;
GO
CREATE USER user1 FROM LOGIN login1;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'user2') DROP USER user2;
GO
CREATE USER user2 FROM LOGIN login2;
GO

CREATE SCHEMA ochain AUTHORIZATION dbo;
GO

CREATE SCHEMA ochain2 AUTHORIZATION user2;
GO

CREATE SCHEMA ochain3 AUTHORIZATION user2;
GO

CREATE TABLE ochain3.Color2
(
	[ColorID] [int] NOT NULL,
	[ColorName] [nvarchar](25) NOT NULL,
);
GO

INSERT INTO ochain3.Color2 (ColorID, [ColorName])
VALUES (1, N'Pink');
GO

-- This view has an unbroken ownership chain. 
CREATE VIEW ochain2.viewX
AS
	SELECT	*
	FROM	ochain3.Color2;
GO

-- This view has a broken ownership chain. 
CREATE VIEW ochain.view4
AS
	SELECT	*
	FROM	ochain3.Color2;
GO

-- This view has a broken ownership chain even though ochain is the start of the
-- ownership chain.
CREATE VIEW ochain2.view3
AS
	SELECT	*
	FROM	ochain.view4;
GO

-- This view has a broken ownership chain. Permissions for ochain2.view3 will be checked.
CREATE VIEW ochain.view2
AS
	SELECT	*
	FROM	ochain2.view3;
GO

-- This view has an unbroken ownership chain. Permissions for ochain.view2 will be not checked and allows
-- a SELECT grant on the view to view the data in ochain.view2 even if the principal does not have permssions on
-- ochain.view2.
CREATE VIEW ochain.view1
AS
	SELECT	*
	FROM	ochain.view2;
GO

GRANT SELECT ON ochain.view1 TO [user1];
GRANT SELECT ON ochain2.view3 TO [user1];
GO

-- This will FAIL due to broken ownership chain:
-- To Fix: Alter authorization to create an unbroken ownership chain.
--ALTER AUTHORIZATION ON SCHEMA::ochain2 TO dbo;
/*
EXECUTE AS USER = 'user1';
GO

SELECT CURRENT_USER AS 'Current User Name';

BEGIN TRY
	SELECT	*
	FROM	ochain.view1;
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH
GO

REVERT;
*/
SELECT CURRENT_USER AS 'Reverted';
GO

-- Schema ownership implies control on that schema. To test, ochaining
-- transfer ownership
ALTER AUTHORIZATION ON SCHEMA::ochain2 TO user1;
ALTER AUTHORIZATION ON SCHEMA::ochain3 TO user1;
GO
GRANT SELECT ON ochain2.viewX TO user2;
GO
EXECUTE AS USER = 'user2';
GO
SELECT CURRENT_USER AS 'Current User Name';

BEGIN TRY
	SELECT	*
	FROM	ochain2.viewX;
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH
GO

REVERT;

SELECT CURRENT_USER AS 'Reverted';
ALTER AUTHORIZATION ON SCHEMA::ochain2 TO user2;
ALTER AUTHORIZATION ON SCHEMA::ochain3 TO user2;
GO
REVOKE SELECT ON ochain2.viewX TO user2;
GO

-- Show permissions
SELECT	p.name, OBJECT_NAME(g.major_id) AS [object], g.*
FROM	sys.database_permissions AS g
	LEFT JOIN sys.database_principals AS p
		ON g.grantee_principal_id = p.principal_id
WHERE	p.name = N'user2';

-- Clean up
IF OBJECT_ID(N'ochain.view1', N'V') IS NOT NULL DROP VIEW ochain.view1;
IF OBJECT_ID(N'ochain.view2', N'V') IS NOT NULL DROP VIEW ochain.view2;
IF OBJECT_ID(N'ochain2.view3', N'V') IS NOT NULL DROP VIEW ochain2.view3;
IF OBJECT_ID(N'ochain.view4', N'V') IS NOT NULL DROP VIEW ochain.view4;
IF OBJECT_ID(N'ochain2.viewX', N'V') IS NOT NULL DROP VIEW ochain2.viewX;
IF OBJECT_ID(N'ochain3.Color2', N'U') IS NOT NULL DROP TABLE ochain3.Color2;
GO
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'ochain') DROP SCHEMA ochain;
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'ochain2') DROP SCHEMA ochain2;
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'ochain3') DROP SCHEMA ochain3;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'user1') DROP USER user1;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'user2') DROP USER user2;
GO

-- Example 2: Dynamic SQL always breaks an ownership chain.
USE Sec_Test;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'user4')
	DROP USER user4;

CREATE USER user4 FROM LOGIN login4;
GO

IF OBJECT_ID(N'dbo.sp_OChainTest2', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_OChainTest2;
GO

-- Ownership chain is broken here because of dynamic sql.
CREATE PROCEDURE dbo.sp_OChainTest2
AS
BEGIN
	DECLARE @stmt NVARCHAR(MAX) = N'SELECT * FROM [dbo].[secTable3]';
	
	EXEC sp_executesql @stmt = @stmt;
END;
GO

IF OBJECT_ID(N'dbo.sp_OChainTest', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_OChainTest;
GO

CREATE PROCEDURE dbo.sp_OChainTest
AS
BEGIN
	EXEC dbo.sp_OChainTest2;
END;
GO

GRANT EXECUTE ON OBJECT::dbo.sp_OChainTest TO user4;
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
WHERE p.name = N'user4';
GO

EXECUTE AS USER = 'user4';

SELECT	CURRENT_USER AS [current];

BEGIN TRY
	EXEC dbo.sp_OChainTest;
END TRY
BEGIN CATCH
	-- Catch all
	PRINT ERROR_MESSAGE();

END CATCH

REVERT;
GO

SELECT	CURRENT_USER AS [reverted];

GO

-- Clean up
IF OBJECT_ID(N'dbo.sp_OChainTest2', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_OChainTest2;
IF OBJECT_ID(N'dbo.sp_OChainTest', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_OChainTest;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'user4')
	DROP USER user4;

SET NOCOUNT OFF;
GO
