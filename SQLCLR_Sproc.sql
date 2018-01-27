USE TSQL2012;
GO

/*-----------------------------------------------------
 * SQL CLR semantics
 *
 * Straight data access should be left to T-SQL. Higher-valued
 * computations are good candidates for SQL CLR integration. 
 * Examples: Regex, etc.
 *
 * A SQL CLR object automatically enlists within a current 
 * running transaction.
 *-----------------------------------------------------*/

IF EXISTS(SELECT	*
			FROM	sys.assembly_modules
			WHERE	assembly_class = N'ExSQLCLR.procTemplate'
					AND assembly_method = N'spSelect')
	DROP PROCEDURE dbo.spSelect;
GO

IF EXISTS(SELECT	*
			FROM	sys.assembly_modules
			WHERE	assembly_class = N'ExSQLCLR.funcTemplate'
					AND assembly_method = N'fnMethod1')
	DROP FUNCTION fnMethod1;
GO

IF EXISTS(SELECT	*
			FROM	sys.assembly_modules
			WHERE	assembly_class = N'ExSQLCLR.funcTemplate'
					AND assembly_method = N'fnSplit')
	DROP FUNCTION dbo.fnSplit;
GO

IF EXISTS(SELECT	*
			FROM	sys.assembly_modules
			WHERE	assembly_class = N'ExSQLCLR.BakersDozen')
	DROP AGGREGATE dbo.BakersDozen;
GO

IF EXISTS(SELECT	*
			FROM	sys.assembly_types
			WHERE	name = N'typePoint')
	DROP TYPE dbo.typePoint;
GO

IF EXISTS(SELECT	*
			FROM	sys.assemblies
			WHERE	name = N'ExSQLCLR')

	DROP ASSEMBLY ExSQLCLR;
GO

CREATE ASSEMBLY ExSQLCLR
AUTHORIZATION dbo
FROM 'C:\Users\rguzman\Desktop\Personal\IP\NETMethods\ExSQLCLR\bin\Debug\ExSQLCLR.dll'
WITH PERMISSION_SET = SAFE;
GO

CREATE PROCEDURE dbo.spSelect
-- DLL name . namespace.class . procedure name
AS EXTERNAL NAME ExSQLCLR.[ExSQLCLR.procTemplate].spSelect;
GO

EXEC dbo.spSelect;
GO