USE master;
GO

-- Create windows authenticated login based on group.
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'WIN-J23JJU1QPF2\nt_group1')
	DROP LOGIN [WIN-J23JJU1QPF2\nt_group1];
GO

CREATE LOGIN [WIN-J23JJU1QPF2\nt_group1] FROM WINDOWS;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'WIN-J23JJU1QPF2\nt_group2')
	DROP LOGIN [WIN-J23JJU1QPF2\nt_group2];
GO

CREATE LOGIN [WIN-J23JJU1QPF2\nt_group2] FROM WINDOWS;
GO

USE MOT_Test;
GO

IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'WIN-J23JJU1QPF2\nt_guest1')
	DROP SCHEMA [WIN-J23JJU1QPF2\nt_guest1];
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'WIN-J23JJU1QPF2\nt_guest1')
	DROP USER [WIN-J23JJU1QPF2\nt_guest1];
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'group1')
	DROP USER group1;

CREATE USER group1 FROM LOGIN [WIN-J23JJU1QPF2\nt_group1];
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'group2')
	DROP USER group2;

CREATE USER group2 FROM LOGIN [WIN-J23JJU1QPF2\nt_group2];
GO

IF OBJECT_ID(N'dbo.sp_Exec1', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_Exec1;
GO
IF OBJECT_ID(N'u1_Schema.sp_Exec2', N'P') IS NOT NULL
	DROP PROCEDURE u1_Schema.sp_Exec2;
GO
IF OBJECT_ID(N'dbo.sp_Exec3', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_Exec3;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'u1_Schema')
	DROP SCHEMA u1_Schema;
GO

CREATE SCHEMA u1_Schema AUTHORIZATION user1;
GO

CREATE PROCEDURE dbo.sp_Exec1
AS
BEGIN
	SELECT CURRENT_USER AS [who sp1];

	SELECT	'From sp_Exec1', * 
	FROM	dbo.MOT_Table;
END
GO

CREATE PROCEDURE u1_Schema.sp_Exec2
WITH EXECUTE AS 'dbo' --CALLER | SELF | OWNER
AS
BEGIN
	SELECT CURRENT_USER AS [who sp2];

	SELECT	'From sp_Exec2', * 
	FROM	dbo.MOT_Table;
END
GO

CREATE PROCEDURE dbo.sp_Exec3
--WITH EXECUTE AS 'WIN-J23JJU1QPF2\nt_guest1'
AS
BEGIN
	SELECT CURRENT_USER AS [who sp3];

	SELECT	'From sp_Exec3', * 
	FROM	dbo.MOT_Table;
END
GO

-------------------------------------------------------------
-- Test ownership chaining with EXECUTE AS
-------------------------------------------------------------
--/*
GRANT EXECUTE ON OBJECT::dbo.sp_Exec1 TO user1;
GRANT IMPERSONATE ON USER::dbo TO user1;
GO
EXECUTE AS USER = 'user1';

SELECT CURRENT_USER AS [who Before];

-- No direct access allowed on dbo.MOT_Table unless dbo
EXECUTE AS USER = 'dbo'; -- nested security context

SELECT CURRENT_USER AS [who Before / nest1];

SELECT	* 
FROM	dbo.MOT_Table;

REVERT;

SELECT CURRENT_USER AS [who Revert / nest1];

-- Access allowed via Ownership Chaining (dbo)
EXEC dbo.sp_Exec1;

-- Access allowed via Ownership Chaining of EXECUTE AS context
EXEC u1_Schema.sp_Exec2;

REVERT;

SELECT CURRENT_USER AS [who Revert];
GO
--*/
-------------------------------------------------------------
-- Test EXECUTE AS with with windows user with implicit database
-- access via Windows group but without being a db principal. This
-- is allowed only when EXECUTE AS is issued by sysadmin or db_owner.
-------------------------------------------------------------
--/*
GRANT EXECUTE ON OBJECT::dbo.sp_Exec1 TO group1; -- grant to db group user
--REVOKE EXECUTE ON OBJECT::dbo.sp_Exec1 TO group1;
GO

SELECT * FROM sys.database_principals WHERE name = N'WIN-J23JJU1QPF2\nt_guest1'; -- DNE

EXECUTE AS USER = 'WIN-J23JJU1QPF2\nt_guest1';

SELECT CURRENT_USER AS [who Before];

-- Access allowed via Ownership Chaining
EXEC dbo.sp_Exec1;

REVERT;

SELECT CURRENT_USER AS [who Revert];
GO
--*/
-------------------------------------------------------------
-- Test the same except for a specified database user who is not a
-- database principal. In this case, the database user is created 
-- when the module is created.
-- Note, a schema with the same name as the user is also created.
-------------------------------------------------------------
SELECT * FROM sys.database_principals WHERE name = N'WIN-J23JJU1QPF2\nt_guest1'; -- DNE
SELECT * FROM sys.schemas WHERE name = N'WIN-J23JJU1QPF2\nt_guest1'; -- DNE

-- User and schema are created by this statement.
GRANT EXECUTE ON OBJECT::dbo.sp_Exec1 TO [WIN-J23JJU1QPF2\nt_guest1]; 
--REVOKE EXECUTE ON OBJECT::dbo.sp_Exec1 TO [WIN-J23JJU1QPF2\nt_guest1];
GO

EXECUTE AS USER = 'WIN-J23JJU1QPF2\nt_guest1';

SELECT CURRENT_USER AS [who Execute AS];

-- Access allowed via Ownership Chaining
EXEC dbo.sp_Exec1;

REVERT;

SELECT CURRENT_USER AS [who Revert];
GO

SELECT 'Should exist', * FROM sys.database_principals WHERE name = N'WIN-J23JJU1QPF2\nt_guest1';
SELECT 'Should exist', * FROM sys.schemas WHERE name = N'WIN-J23JJU1QPF2\nt_guest1';
GO
--*/
-- Cleanup
/*
USE MOT_Test;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'WIN-J23JJU1QPF2\nt_guest1')
	DROP SCHEMA [WIN-J23JJU1QPF2\nt_guest1];

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'WIN-J23JJU1QPF2\nt_guest1')
	DROP USER [WIN-J23JJU1QPF2\nt_guest1];

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'group1')
	DROP USER group1;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'group2')
	DROP USER group2;

IF OBJECT_ID(N'dbo.sp_Exec1', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_Exec1;
GO
IF OBJECT_ID(N'u1_Schema.sp_Exec2', N'P') IS NOT NULL
	DROP PROCEDURE u1_Schema.sp_Exec2;
GO
IF OBJECT_ID(N'dbo.sp_Exec3', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_Exec3;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'u1_Schema')
	DROP SCHEMA u1_Schema;
GO

USE master;
GO

-- Create windows authenticated login based on group.
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'WIN-J23JJU1QPF2\nt_group1')
	DROP LOGIN [WIN-J23JJU1QPF2\nt_group1];
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'WIN-J23JJU1QPF2\nt_group2')
	DROP LOGIN [WIN-J23JJU1QPF2\nt_group2];
GO
*/