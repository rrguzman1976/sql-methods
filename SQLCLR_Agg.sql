USE [ScratchDB]
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
			WHERE	assembly_class = N'ExSQLCLR.BakersDozen')
	DROP AGGREGATE dbo.BakersDozen;
GO

IF EXISTS(SELECT	*
			FROM	sys.assemblies
			WHERE	name = N'ExSQLCLR')

	DROP ASSEMBLY ExSQLCLR;
GO

CREATE ASSEMBLY ExSQLCLR
AUTHORIZATION dbo
FROM 'C:\Users\rguzman\Desktop\Personal\IP_2\NETMethods\ExSQLCLR\bin\Debug\ExSQLCLR.dll'
WITH PERMISSION_SET = SAFE;
GO

-- Scalar
CREATE AGGREGATE dbo.BakersDozen (@value int) 
RETURNS INT
EXTERNAL NAME ExSQLCLR.[ExSQLCLR.BakersDozen];
GO

IF OBJECT_ID(N'dbo.TestCLRAgg', N'U') IS NOT NULL
	DROP TABLE dbo.TestCLRAgg;
GO

CREATE TABLE dbo.TestCLRAgg
(
	ID		INT	IDENTITY(1, 1)	NOT NULL
	, VAL	INT					NOT NULL
);
GO

INSERT INTO dbo.TestCLRAgg
VALUES (13), (13), (13), (13);

SELECT	dbo.BakersDozen(VAL) OVER () AS custAgg
		, *
FROM	dbo.TestCLRAgg;
GO