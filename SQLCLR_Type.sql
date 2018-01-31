USE ScratchDB;
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
FROM 'C:\Users\rguzman\Desktop\Personal\IP_2\NETMethods\ExSQLCLR\bin\Debug\ExSQLCLR.dll'
WITH PERMISSION_SET = SAFE;
GO

-- SQL CLR types have certain indexing limitations, and their entire value 
-- must be updated when any of their individual property/field values is updated.
CREATE TYPE dbo.typePoint
EXTERNAL NAME ExSQLCLR.[ExSQLCLR.typePoint];
GO

/*
 * You should think of CLR UDTs less as objects stored in the database
 * and more as classes that wrap one or a set of scalar values and provide 
 * services and conversion functions for manipulating them. This is why Microsoft 
 * implemented the geometry and geography data types as SQL CLR UDTs. These types 
 * don’t store complex objects, but they do manage entities that cannot be thought 
 * of as simple, single values.
 * 
 * You should not think of SQL CLR UDTs as object-relational entities.
 */
DECLARE @t AS dbo.typePoint;

SET @t = '3:5'; -- typePoint.Parse()

PRINT @t.X; -- getter
PRINT @t.Y; -- getter

SET @t.X = 44; -- setter
SET @t.Y = 88; -- setter

PRINT @t.X;
PRINT @t.Y;

PRINT CONVERT(NVARCHAR, @t); -- ToString()
--PRINT @t; -- Not allowed

PRINT typePoint::Sum(@t); -- Method call

