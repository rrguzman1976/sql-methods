USE XML_Test;
GO

-- USE RAW mode (no nesting)
SELECT	TOP (10)
		p.[BusinessEntityID]
		,p.[PersonType]
		,p.[Title]
		,p.[FirstName]
		,p.[MiddleName]
		,p.[LastName]
		,p.[Suffix]
		,p.[EmailPromotion]
		,p.[AdditionalContactInfo]
		,p.[Demographics]
		,ph.PhoneNumber
		,pt.Name
FROM	[AdventureWorks2017].[Person].[Person] AS p
	LEFT JOIN [AdventureWorks2017].[Person].[PersonPhone] AS ph
		ON p.BusinessEntityID = ph.BusinessEntityID
	LEFT JOIN [AdventureWorks2017].[Person].[PhoneNumberType] AS pt
		ON ph.PhoneNumberTypeID = pt.PhoneNumberTypeID
FOR XML RAW('Rowname')
	, ROOT('AllPeople'), TYPE, BINARY BASE64 -- Common directives
	--, XMLSCHEMA('mySchema') -- Inline schema directive
	, ELEMENTS XSINIL -- ABSENT removes NULLs (default)
GO

-- USE AUTO mode with simple nesting
-- Nesting is based on order of columns
WITH XMLNAMESPACES('rrguzman' as rko) -- with custom namespace (valid for all FOR XML options)
SELECT	TOP (10)
		[rko:p].[BusinessEntityID]
		,[rko:p].[PersonType]
		,[rko:p].[Title]
		,[rko:p].[FirstName]
		,[rko:p].[MiddleName]
		,[rko:p].[LastName]
		,[rko:p].[Suffix]
		,[rko:p].[EmailPromotion]
		,[rko:p].[AdditionalContactInfo]
		,[rko:p].[Demographics]
		,ph.PhoneNumber
		,pt.Name
FROM	[AdventureWorks2012].[Person].[Person] AS [rko:p]
	LEFT JOIN [AdventureWorks2012].[Person].[PersonPhone] AS ph
		ON [rko:p].BusinessEntityID = ph.BusinessEntityID
	LEFT JOIN [AdventureWorks2012].[Person].[PhoneNumberType] AS pt
		ON ph.PhoneNumberTypeID = pt.PhoneNumberTypeID
FOR XML AUTO
	, ROOT('AllPeople'), TYPE, BINARY BASE64 -- Common directives
	--, XMLSCHEMA('mySchema') -- Inline schmea directive
	, ELEMENTS XSINIL -- ABSENT removes NULLs (default)
GO

-- USE PATH mode for high fidelity XML output
SELECT	TOP (10) 
		p.[BusinessEntityID] AS [@ID] -- Controls attribute-centric
		,p.[PersonType] AS [@Type]
		,'Custom XML using XPATH' AS [comment()] -- Node test
		,p.[Title]
		,p.[FirstName] --AS [text()] -- Inlined
		,p.[MiddleName]
		,p.[LastName]
		,p.[Suffix]
		--,p.[EmailPromotion] AS [data()] -- returns atomic value
		,p.[AdditionalContactInfo]
		,p.[Demographics]
		-- Create nesting using subqueries as XML TYPE, otherwise returns an entitized string
		, (	
			SELECT	a.AddressLine1
					, a.AddressLine2
					, a.City
					, s.Name AS [State]
					, a.PostalCode
			FROM	[AdventureWorks2012].[Person].[BusinessEntityAddress] AS ba
				LEFT JOIN [AdventureWorks2012].[Person].[Address] AS a
					ON ba.AddressID = a.AddressID
				LEFT JOIN [AdventureWorks2012].[Person].[StateProvince] AS s
					ON a.StateProvinceID = s.StateProvinceID
			WHERE	p.BusinessEntityID = ba.BusinessEntityID
			FOR XML PATH(''), TYPE
		) AS [ContactInfo/Address] -- Slash creates a hierarchy
		, (	
			SELECT	pt.Name AS [@Type]
					, ph.PhoneNumber
			FROM	[AdventureWorks2012].[Person].[PersonPhone] AS ph
				LEFT JOIN [AdventureWorks2012].[Person].[PhoneNumberType] AS pt
					ON ph.PhoneNumberTypeID = pt.PhoneNumberTypeID
			WHERE	p.BusinessEntityID = ph.BusinessEntityID
			FOR XML PATH('Phone'), TYPE
		) AS [ContactInfo]
		, (	
			SELECT	e.EmailAddress
			FROM	[AdventureWorks2012].[Person].[EmailAddress] AS e
			WHERE	p.BusinessEntityID = e.BusinessEntityID
			FOR XML PATH(''), TYPE
		) AS [ContactInfo/Email]
FROM	[AdventureWorks2012].[Person].[Person] AS p
FOR XML PATH('Person')
	, ROOT('AllPeople'), TYPE, BINARY BASE64 -- Common directives
	-- Every column is an element by default so directive below is redundant except for XSINIL
	, ELEMENTS XSINIL -- ABSENT removes NULLs (default)

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
