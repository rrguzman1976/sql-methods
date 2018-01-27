USE XML_Test;
GO

DECLARE @ID INT;
DECLARE @doc XML;
DECLARE @doc2 XML;

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
			FOR XML PATH('Person'), TYPE, ROOT('OrgChart'), ELEMENTS XSINIL);

---------------------------------------------
-- XQuery value() method
---------------------------------------------
SELECT	'XQuery value()'
		, @doc.value('(/OrgChart/Person/@ID)[1]', 'INT')
		--, @doc.value('/OrgChart/Person/@ID[1]', 'INT') -- not a singleton so error raised
;

WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS SU)
SELECT	'XQuery value() of typed XML column'
		, BusinessEntityID
		, Demographics.value( '(/SU:IndividualSurvey/SU:TotalPurchaseYTD)[1]', 'MONEY') AS [TotalPurchaseYTD]
		, Demographics.query('	<myxml>
									{/SU:IndividualSurvey/node()[6]}
									<Name>{sql:column("LastName")}, {sql:column("FirstName")}</Name>
								</myxml>') AS [custom_xml]
		, Demographics
FROM	[AdventureWorks2012].[Person].[Person]
WHERE	Demographics.value( '(/SU:IndividualSurvey/SU:TotalPurchaseYTD)[1]', 'MONEY') > $13000;

---------------------------------------------
-- XQuery exist() method
---------------------------------------------

-- Does person with ID = 10 exist?
SELECT	'XQuery exist(): @test', @doc.exist('/OrgChart/Person[@ID = 10]')

-- Element check
SELECT	'XQuery exist(): element test', @doc.exist('/OrgChart/Person/LastName[text() = "Duffy"]');
SELECT	'XQuery exist(): element test', @doc.exist('//*[text() = "ken0@adventure-works.com"]');

-- Test existance of a typed XML (attribute)
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions' AS SU)
SELECT	'XQuery exist() of typed XML column'
		, m.ProductModelID
		, m.Instructions
		, n.r.value('./@LocationID', 'INT') AS [LocationID]
		, Instructions.query('/SU:root/SU:Location[@LocationID=50]/node()') AS [found50]
		, Instructions.query('(//SU:Location[@LocationID=50]/SU:step)[1]/node()') AS [firstStep]
FROM	[AdventureWorks2012].Production.ProductModel AS m
	CROSS APPLY m.Instructions.nodes('/SU:root/SU:Location') AS n(r)
WHERE	Instructions.exist('	declare namespace AWMI="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions";
								/AWMI:root/AWMI:Location[@LocationID=50]') = 1
ORDER BY m.ProductModelID, [LocationID]

---------------------------------------------
-- XQuery query() method
---------------------------------------------

-- Any principal node
SELECT	'Any principal node', @doc.query('(OrgChart/Person/ContactInfo/Email)[1]/*');

-- Attribute node test
SELECT	'Attribute node test', @doc.query('OrgChart/Person[attribute::ID=1]');

-- Attribute node test using variable
SET @ID = 7;
SELECT	'Attribute node test / variable', @doc.query('OrgChart/Person[attribute::ID=sql:variable("@ID")]');

-- Transform XML structure
SELECT	'Transform XML structure', @doc.query('<Email-Container>{(OrgChart/Person/ContactInfo/Email/EmailAddress)[1]}</Email-Container>');

-- Numeric predicate (3rd person)
SELECT	'Numeric predicate / sequence', @doc.query('//Person[3]'); -- sequence
SELECT	'Numeric predicate / singleton', @doc.query('(//Person)[3]'); -- singleton

-- Numeric predicate (3rd person) with any type of child
SELECT	'Numeric predicate (3rd person) with any child', @doc.query('//Person[3]/ContactInfo/node()');

-- Numeric predicate (3rd person) with comment child
SELECT	'Numeric predicate (3rd person) with comment', @doc.query('//Person[3]/comment()');

-- Descendant or self with attribute node test
SELECT	'Descendant or self with attribute node test / sequence', @doc.query('//Person[attribute::ID > 5]'); -- sequence comparison operator
SELECT	'Descendant or self with attribute node test / atomic', @doc.query('//Person[attribute::ID gt 5]'); -- atomic value comparison operator

-- FLWOR Expression
SELECT 'FLWOR Expression',	@doc.query(' for $i in OrgChart/Person 
										 let $j := $i/@ID 
										 where $i/@ID > 5 
										 order by ($j)[1] 
										 return 
										 <xform-element> 
										 <PersonID>{data($j)}</PersonID> 
										 {$i/Title} 
										 <FullName>{concat(($i/FirstName)[1], " ",  ($i/LastName)[1])}</FullName> 
										 </xform-element>');

---------------------------------------------
-- XQuery modify() method
---------------------------------------------
-- insert person with ID 0 as first
SET @doc.modify('	insert 	<Person ID="0">
							</Person>
					as first
					into (/OrgChart)[1]'); -- target must be sigle node

-- insert person with ID 0 as last
SET @doc.modify('	insert 	<Person ID="11">
							</Person>
					as last
					into (/OrgChart)[1]');

-- insert person with ID 0 as sibling
SET @doc.modify('	insert 	<Person ID="12">
							</Person>
					after (/OrgChart/Person)[5]');

-- insert using variable
SET @doc2 = '<Person><Title/></Person>';

SET @doc.modify('	insert 	sql:variable("@doc2")
					as first
					into (/OrgChart)[1]');

-- insert attribute
SET @doc.modify('	insert 	attribute ID {"14"}
					into (/OrgChart/Person)[1]');

-- delete an element
SET @doc.modify('delete (/OrgChart/Person)[1]');

-- delete all comments
SET @doc.modify('delete //comment()');

-- update text in the 3rd person
SET @doc.modify('	replace value of (/OrgChart/Person/FirstName/text())[3]
					with "Ricardo"');

-- update attribute value
SET @doc.modify('	replace value of (/OrgChart/Person/@ID)[1] 
					with "-1"')

SELECT	'After modify()', @doc

---------------------------------------------
-- XQuery nodes() method: See ShredXML.sql
---------------------------------------------