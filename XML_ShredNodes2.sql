USE XML_Test;
GO

DECLARE @idoc INT;
DECLARE @doc XML;

SET @doc =	(SELECT	TOP (10)
					p.[BusinessEntityID] AS [@ID] -- Controls attribute-centric
					,'Custom XML using XPATH' AS [comment()] -- Node test
					,p.[Title]
					,p.[FirstName]
					,p.[MiddleName]
					,p.[LastName]
					,p.[Suffix]
					, (	
						SELECT	e.EmailAddress
						FROM	[AdventureWorks2012].[Person].[EmailAddress] AS e
						WHERE	p.BusinessEntityID = e.BusinessEntityID
						FOR XML PATH(''), TYPE
					) AS [ContactInfo/Email]
			FROM	[AdventureWorks2012].[Person].[Person] AS p
			FOR XML PATH('Person'), TYPE, ROOT('OrgChart')
				-- XML PATH is always element-centric, this just controls whether NULLs are visible
				, ELEMENTS XSINIL); 

-- Prepare XML DOM - handle is valid for the duration of the session or until sp_xml_removedocument
-- Can parse xml type, (n)varchar(n), or (n)varchar(max) type.
EXEC sp_xml_preparedocument @hdoc = @idoc OUTPUT, @xmltext = @doc;

-- Option1: OpenXML with custom schema definition
SELECT	*
FROM	OPENXML (@idoc, '/OrgChart/Person/ContactInfo', 2)
		WITH 
		(
			[ID] INT '../@ID'
			, [Title] NVARCHAR(8) '../Title'
			, [FirstName] NVARCHAR(50) '../FirstName'
			, [MiddleName] NVARCHAR(50) '../MiddleName'
			, [LastName] NVARCHAR(50) '../LastName'
			, [Suffix] NVARCHAR(10) '../Suffix'
			, EmailAddress NVARCHAR(50) './Email'
		);

-- Option1a: OpenXML with default edge table schema
--SELECT * FROM OPENXML (@idoc, '/AllPeople/Person', 2);

-- Option1b: OpenXML using existing table schema
-- <table_name> is only used to define the schema
--SELECT * FROM OPENXML (@idoc, '/AllPeople/Person', 2)
--WITH <table_name>;

-- Remove DOM
EXEC sp_xml_removedocument @hdoc = @idoc;
--/*
-- Option2: XML type Nodes() method

-- Shred an XML variable
SELECT	'Shred an XML variable into rows'
		, X.r.query('self::node()') AS [self]
		, X.r.query('.') AS [self_abbreviation]
		, X.r.value('(./LastName)[1]', 'NVARCHAR(50)') + N', ' + X.r.value('(./FirstName)[1]', 'NVARCHAR(50)') AS [FullName]
FROM	@doc.nodes('//Person') AS X(r);
--FROM	@doc.nodes('/OrgChart/Person') AS X(r); -- Equivalent
--FROM	@doc.nodes('./OrgChart/Person') AS X(r); -- Equivalent

SELECT	'Shred an XML variable into single row'
		, X.r.query('self::node()') AS [self]
		, X.r.value('(./Person/LastName)[1]', 'NVARCHAR(50)') + N', ' + X.r.value('(./Person/FirstName)[1]', 'NVARCHAR(50)') AS [FullName]
FROM	@doc.nodes('/OrgChart') AS X(r);

-- Shred a shredded rowset
SELECT	'Shred a shredded rowset'
		, X.r.query('.') AS [root] -- abbreviation
		, Y.r.query('.') AS [current_row]
		, Y.r.value('(./LastName)[1]', 'NVARCHAR(50)') + N', ' + Y.r.value('(./FirstName)[1]', 'NVARCHAR(50)') AS [FullName]
FROM	@doc.nodes('/OrgChart') AS X(r) -- Shreds XML root
	CROSS APPLY X.r.nodes('./Person') AS Y(r); -- Shreds first level children

-- Shred a typed XML column
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions' AS MI)
SELECT	m.ProductModelID
		, X.r.value('./@LocationID', 'INT') AS [LocationID]
		, X.r.query('./..') as [parent]
		, X.r.query('.') AS [self]
		, X.r.query('./MI:step') AS [step_set]
		, X.r.query('./MI:step/node()') AS [step] -- Shred steps (1...N)
FROM	[AdventureWorks2012].Production.ProductModel AS m
	CROSS APPLY m.Instructions.nodes('/MI:root/MI:Location') AS X(r) -- Shred locations (1...N)
WHERE	m.ProductModelID = 10
ORDER BY m.ProductModelID, X.r.value('./@LocationID', 'INT');
--*/