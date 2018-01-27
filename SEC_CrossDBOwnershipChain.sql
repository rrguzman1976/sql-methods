SET NOCOUNT ON;
GO

USE master;
GO

IF DB_ID(N'CrossDBChain_Test1') IS NOT NULL
BEGIN
	ALTER DATABASE CrossDBChain_Test1
	SET SINGLE_USER
	WITH ROLLBACK IMMEDIATE;

	DROP DATABASE CrossDBChain_Test1;
END
GO

IF DB_ID(N'CrossDBChain_Test2') IS NOT NULL
BEGIN
	ALTER DATABASE CrossDBChain_Test2
	SET SINGLE_USER
	WITH ROLLBACK IMMEDIATE;

	DROP DATABASE CrossDBChain_Test2;
END
GO

CREATE DATABASE CrossDBChain_Test1
WITH DB_CHAINING ON;
GO
CREATE DATABASE CrossDBChain_Test2
WITH DB_CHAINING ON;
--ALTER AUTHORIZATION ON DATABASE::CrossDBChain_Test2 TO [WIN-J23JJU1QPF2\nt_guest1];
GO

USE CrossDBChain_Test1;
GO

IF OBJECT_ID(N'dbo.crossDBTest', N'U') IS NOT NULL 
	DROP TABLE dbo.crossDBTest;
GO

CREATE TABLE dbo.crossDBTest
(
	[ID] [int] NOT NULL,
	[VAL] NVARCHAR(25) NOT NULL,
);
GO
CREATE USER user1 FOR LOGIN [login1];
GO
CREATE USER user2 FOR LOGIN [login2];
GO

ALTER AUTHORIZATION ON dbo.crossDBTest
	TO user2;
GO
SELECT	'crossDBTest owner', p.name, o.*
FROM	CrossDBChain_Test1.sys.objects AS o
	LEFT JOIN CrossDBChain_Test1.sys.database_principals AS p
		ON o.principal_id = p.principal_id
WHERE	o.name = 'crossDBTest'

USE CrossDBChain_Test2;
GO

IF OBJECT_ID(N'dbo.sp_CrossDb', N'U') IS NOT NULL 
	DROP PROCEDURE dbo.sp_CrossDb;
GO

CREATE PROCEDURE dbo.sp_CrossDb
AS
BEGIN
	SELECT SUSER_NAME(), USER_NAME() AS [who sp_CrossDb];

	SELECT	'From sp_CrossDb', * 
	FROM	CrossDBChain_Test1.dbo.crossDBTest;
END
GO

CREATE USER user1 FOR LOGIN [login1];
GO
CREATE USER user2 FOR LOGIN [login2];
GO
ALTER AUTHORIZATION ON dbo.sp_CrossDb
	TO user2;
GO
SELECT	'sp_CrossDb owner', p.name, o.*
FROM	CrossDBChain_Test2.sys.objects AS o
	LEFT JOIN CrossDBChain_Test2.sys.database_principals AS p
		ON o.principal_id = p.principal_id
WHERE	o.name = 'sp_CrossDb'

GRANT EXECUTE ON dbo.sp_CrossDb TO user1;
GO
EXECUTE AS LOGIN = 'login1'
GO

BEGIN TRY
	EXEC dbo.sp_CrossDb;
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH
GO

REVERT;
GO

USE master;
GO
SELECT	p.name, d.*
FROM	sys.databases AS d
	LEFT JOIN sys.server_principals AS p
		ON d.owner_sid = p.sid
WHERE	d.name IN (N'CrossDBChain_Test1', N'CrossDBChain_Test2');

DROP DATABASE CrossDBChain_Test1;
DROP DATABASE CrossDBChain_Test2;
GO

SET NOCOUNT OFF;
GO
