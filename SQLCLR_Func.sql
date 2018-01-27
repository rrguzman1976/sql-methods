USE TSQL2012;
GO

/*-----------------------------------------------------
 * SQL CLR semantics
 *
 * Straight data access should be left to T-SQL. Higher-valued
 * computations are good candidates for SQL CLR integration. 
 * Examples: Regex, etc.
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
	DROP FUNCTION dbo.fnMethod1;
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

-- Scalar
CREATE FUNCTION dbo.fnMethod1(@pFahrenheit AS INT)
RETURNS DECIMAL(38, 18)
-- DLL name . namespace.class . procedure name
AS EXTERNAL NAME ExSQLCLR.[ExSQLCLR.funcTemplate].fnMethod1;
GO

SELECT	dbo.fnMethod1(100);
GO

-- TVF
CREATE FUNCTION dbo.fnSplit(@pValues AS NVARCHAR(4000), @pDelimiter AS NVARCHAR(4000))
RETURNS TABLE
(
	[SplitValue]	NVARCHAR(100)
	, OriginalValue NVARCHAR(4000)
)
WITH EXECUTE AS CALLER
--ORDER ([SplitValue]) -- INDEX HINT (result set must be in order)
-- DLL name . namespace.class . procedure name
AS EXTERNAL NAME ExSQLCLR.[ExSQLCLR.funcTemplate].fnSplit;
GO

SELECT	*
FROM	dbo.fnSplit(N'test1|test2|test3', N'|');