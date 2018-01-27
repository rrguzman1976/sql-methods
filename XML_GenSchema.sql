USE XML_Test;
GO

IF OBJECT_ID(N'xmlTyped', N'U') IS NOT NULL 
	DROP TABLE dbo.xmlTyped;
IF OBJECT_ID(N'xmlUntyped', N'U') IS NOT NULL 
	DROP TABLE dbo.xmlUntyped;
IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = N'PeopleSchema') 
	DROP XML SCHEMA COLLECTION dbo.PeopleSchema;

----------------------------------------------------------------
-- Create XML SCHEMA COLLECTION
----------------------------------------------------------------
DECLARE @schema XML =	(SELECT	[Person].[BusinessEntityID]
								, [Person].[Title]
								, [Person].[FirstName]
								, [Person].[MiddleName]
								, [Person].[LastName]
								, [Person].[Suffix]
								, [Email].EmailAddress
						FROM	[AdventureWorks2012].[Person].[Person] AS [Person]
							LEFT JOIN [AdventureWorks2012].[Person].[EmailAddress] AS [Email]
								ON [Person].BusinessEntityID = [Email].BusinessEntityID
						WHERE	1 = 2
						FOR XML AUTO, TYPE, XMLSCHEMA('RKO'));

CREATE XML SCHEMA COLLECTION dbo.PeopleSchema AS @schema;
GO

-- Create Typed XML column
CREATE TABLE dbo.xmlTyped
(
	ID INT IDENTITY NOT NULL
		PRIMARY KEY
	, xmlData XML(dbo.PeopleSchema) NOT NULL
);

-- Create Untyped XML column
CREATE TABLE dbo.xmlUntyped
(
	ID INT IDENTITY NOT NULL
		PRIMARY KEY
	, xmlData XML NOT NULL
);

-- Load data
INSERT INTO dbo.xmlTyped(xmlData)
VALUES	(N'	<r:Person xmlns:r="RKO" BusinessEntityID="1" Title="01234567" FirstName="Ken" MiddleName="J" LastName="Sánchez">
			  <r:Email EmailAddress="ken0@adventure-works.com" />
			  <r:Email EmailAddress="ken0@adventure-works.com" />
			</r:Person>');

INSERT INTO dbo.xmlUntyped(xmlData)
VALUES	(N'	<Person BusinessEntityID="1" Title="01234567" FirstName="Ken" MiddleName="J" LastName="Sánchez">
			  <Email EmailAddress="ken0@adventure-works.com" />
			  <Email EmailAddress="ken0@adventure-works.com" />
			</Person>');

----------------------------------------------------------------
-- Create primary XML index
----------------------------------------------------------------
--/*
IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IDX_XMLPRI_XMLUNTYPE')
	DROP INDEX IDX_XMLPRI_XMLUNTYPE ON dbo.xmlUntyped;
IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IDX_XMLVAL_XMLUNTYPE')
	DROP INDEX IDX_XMLVAL_XMLUNTYPE ON dbo.xmlUntyped;
IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IDX_XMLPAT_XMLUNTYPE')
	DROP INDEX IDX_XMLPAT_XMLUNTYPE ON dbo.xmlUntyped;
IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IDX_XMLPRO_XMLUNTYPE')
	DROP INDEX IDX_XMLPRO_XMLUNTYPE ON dbo.xmlUntyped;

CREATE PRIMARY XML INDEX IDX_XMLPRI_XMLUNTYPE
ON dbo.xmlUntyped (xmlData);

-- Create secondary XML indexes
CREATE XML INDEX IDX_XMLVAL_XMLUNTYPE
ON dbo.xmlUntyped (xmlData)
USING XML INDEX IDX_XMLPRI_XMLUNTYPE
FOR VALUE;

CREATE XML INDEX IDX_XMLPAT_XMLUNTYPE
ON dbo.xmlUntyped (xmlData)
USING XML INDEX IDX_XMLPRI_XMLUNTYPE
FOR PATH;

CREATE XML INDEX IDX_XMLPRO_XMLUNTYPE
ON dbo.xmlUntyped (xmlData)
USING XML INDEX IDX_XMLPRI_XMLUNTYPE
FOR PROPERTY;

-- Load sample data
DECLARE @doc XML =	(SELECT	TOP (10000)
							[Person].[BusinessEntityID]
							, [Person].[Title]
							, [Person].[FirstName]
							, [Person].[MiddleName]
							, [Person].[LastName]
							, [Person].[Suffix]
							, [Email].EmailAddress
					FROM	[AdventureWorks2012].[Person].[Person] AS [Person]
						LEFT JOIN [AdventureWorks2012].[Person].[EmailAddress] AS [Email]
							ON [Person].BusinessEntityID = [Email].BusinessEntityID
					FOR XML AUTO, TYPE);

INSERT INTO dbo.xmlUntyped(xmlData)
SELECT	X.r.query('.')
FROM	@doc.nodes('./Person') AS X(r);

-- Verify indexing
SELECT	'Value()'
		, X.r.value('(./@BusinessEntityID)[1]', 'INT') AS [ID]
		, X.r.query('.')
FROM	dbo.xmlUntyped
	CROSS APPLY xmlData.nodes('./Person') AS X(r)
WHERE	X.r.exist('/node()[@BusinessEntityID ="2"]') = 1; -- more efficient
--WHERE	X.r.value('(./@BusinessEntityID)[1]', 'INT') > 10000;

SELECT	'Exist()'
		, r.value('(./@BusinessEntityID)[1]', 'INT') AS [ID]
		, r.value('(./@Suffix)[1]', 'NVARCHAR(10)') AS [Suffix]
		, r.query('//Person/node()')
FROM	dbo.xmlUntyped
	CROSS APPLY xmlData.nodes('./Person') AS X(r)
WHERE	r.exist('//Person[@Suffix]') = 1;

SELECT	'Query()'
		, r.value('(./@BusinessEntityID)[1]', 'INT') AS [ID]
		, r.query('.')
		, r.value('(./@FirstName)[1]', 'NVARCHAR(50)') AS [FirstName]
		, r.value('(./@MiddleName)[1]', 'NVARCHAR(50)') AS [MiddleName]
		, r.value('(./@LastName)[1]', 'NVARCHAR(50)') AS [LastName]
		, r.query('//Person[@BusinessEntityID=3]')
FROM	dbo.xmlUntyped
	CROSS APPLY xmlData.nodes('./Person') AS X(r)
WHERE	r.exist('//Person[@MiddleName]') = 0;
--*/
-- Clean up
/*
IF OBJECT_ID(N'dbo.xmlUntyped', N'U') IS NOT NULL
	DROP TABLE dbo.xmlUntyped;
IF OBJECT_ID(N'dbo.xmlTyped', N'U') IS NOT NULL
	DROP TABLE dbo.xmlTyped;
IF OBJECT_ID(N'xmlTyped', N'U') IS NOT NULL 
	DROP TABLE dbo.xmlTyped;
IF OBJECT_ID(N'xmlUntyped', N'U') IS NOT NULL 
	DROP TABLE dbo.xmlUntyped;
IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = N'PeopleSchema') 
	DROP XML SCHEMA COLLECTION dbo.PeopleSchema;
*/