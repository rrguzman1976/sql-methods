USE master;
GO

IF EXISTS(	SELECT	*
			FROM	sys.server_principals
			WHERE	name = N'ssislogin')
	DROP LOGIN ssislogin;
GO

CREATE LOGIN ssislogin
	WITH PASSWORD = N'*********';
GO

SELECT	'server_principals' AS x
		, *
FROM	sys.server_principals
WHERE	name = N'ssislogin'

SELECT	p.name
		, p.type_desc
		, p.principal_id
		, g.[permission_name]
		, g.state_desc
		, r.role_principal_id
		, p2.name
		, p2.type_desc
FROM	sys.server_principals AS p
	LEFT JOIN sys.server_permissions AS g
		ON p.principal_id = g.grantee_principal_id
	LEFT JOIN sys.server_role_members AS r
		ON p.principal_id = r.member_principal_id
	LEFT JOIN sys.server_principals AS p2
		ON r.role_principal_id = p2.principal_id
WHERE	p.name = N'ssislogin'

USE [SSISDB]
GO

IF EXISTS(	SELECT	*
			FROM	sys.database_principals
			WHERE	name = N'ssisuser')
	DROP USER ssisuser;
GO

CREATE USER ssisuser
	FOR LOGIN ssislogin;
GO

SELECT	'database_principals'
		, *
FROM	sys.database_principals
WHERE	name = N'ssisuser'

ALTER ROLE ssis_admin
	ADD MEMBER ssisuser;
GO

SELECT	p.name
		, p.type_desc
		, g.[permission_name]
		, g.state_desc
		, p2.name
		, p2.type_desc
FROM	sys.database_principals AS p
	LEFT JOIN sys.database_permissions AS g
		ON p.principal_id = g.grantee_principal_id
	LEFT JOIN sys.database_role_members AS r
		ON p.principal_id = r.member_principal_id
	LEFT JOIN sys.database_principals AS p2
		ON r.role_principal_id = p2.principal_id
WHERE	p.name = N'ssisuser'