USE TSQL2012;
GO

/*-----------------------------------------------------
 * XML Semantics: 
 * If the XML data is to be accessed by an OLTP system, then
 * it is more efficient to shred it into a normalized schema.
 * In cases, where the data is to stored/retrieved as XML
 * (web application, etc.), then storing the XML as an XML type
 * is more appropriate.
 *
 * Finally, the XML type can be used to implement a flexible
 * schema without using the property table "anti-pattern".
 *
 *-----------------------------------------------------*/

-- Consider indexing input XML via the use of a stage table
-- with an XML column.
-- This column can then be indexed to support XQUERY shredding.
IF OBJECT_ID(N'dbo.OrdersXML', N'U') IS NOT NULL
	DROP TABLE dbo.OrdersXML;
GO

CREATE TABLE dbo.OrdersXML
(
	OrdersId	INT PRIMARY KEY,
	OrdersDoc	XML NOT NULL
);
GO

CREATE PRIMARY XML INDEX ix_orders
	ON dbo.OrdersXML(OrdersDoc);
GO

-- Display the columns in the node table (primary XML clustered index)
SELECT
	c.column_id, c.name, t.name AS data_type
FROM
	sys.columns AS c
	INNER JOIN sys.indexes AS i ON i.object_id = c.object_id
	INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
WHERE
	i.name = 'ix_orders' AND i.type = 1
ORDER BY
	c.column_id;

-- All secondary indexes require a primary index to be defined.

-- A path index speeds up XQuery XPath expressions that reference a particular 
-- node in the XML data with an explicit value.
CREATE XML INDEX ix_orders_path 
	ON dbo.OrdersXML(OrdersDoc)
USING XML INDEX ix_orders FOR PATH;
GO

-- A value index speeds up XQuery XPath expressions that reference nodes queried
-- with wildcards.
CREATE XML INDEX ix_orders_val 
	ON dbo.OrdersXML(OrdersDoc)
USING XML INDEX ix_orders FOR VALUE;
GO

-- The property type index optimizes hierarchies of elements or attributes that 
-- are name/value pairs (via the value() method)
CREATE XML INDEX ix_orders_prop 
	ON dbo.OrdersXML(OrdersDoc)
USING XML INDEX ix_orders FOR PROPERTY;
GO

/*
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
*/