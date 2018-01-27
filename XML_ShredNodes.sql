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

/*
 * The nodes method of the XML data type is more efficient for 
 * shredding an XML document only once and is therefore the
 * preferred way of shredding XML documents in such a case. 
 * However, if you need to shred the same document multiple 
 * times, then preparing the DOM presentation once, using 
 * OPENXML multiple times, and removing the DOM presentation 
 * might be faster.
 */

-----------------------------------------------------
-- Option 2: XQuery via xml.nodes(), xml.value()
-- The nodes() method prepares the DOM internally
-- XQuery runs more efficiently when there is an XML index on the XML column.
-- XQuery works more efficiently if it is strongly typed, so always use a 
-- schema (XSD) on the XML column for the best performance.
-----------------------------------------------------

-----------------------------------------------------
-- Restart
-----------------------------------------------------

IF OBJECT_ID('dbo.OrdersXML', 'U') IS NOT NULL
	DROP TABLE dbo.OrdersXML;
GO

IF EXISTS(	SELECT	*
			FROM	sys.xml_schema_collections
			WHERE	name = N'OrdersXSD')
	DROP XML SCHEMA COLLECTION OrdersXSD;
GO

DECLARE @OrdersXSD XML;

-----------------------------------------------------
-- Load XSD
-----------------------------------------------------

SELECT	@OrdersXSD = a 
FROM	OPENROWSET(BULK N'C:\Users\rguzman\Desktop\Personal\IP\SQLMethods\SQLMethods\Scratch2.xsd', SINGLE_BLOB) AS x(a);

SELECT	'XSD' AS [1], @OrdersXSD;

-- An XSD schema can be used on any xml type, including variables,
-- parameters, return values, and columns in tables.
CREATE XML SCHEMA COLLECTION OrdersXSD AS @OrdersXSD;
GO

-----------------------------------------------------
-- Create stage table
-----------------------------------------------------

CREATE TABLE dbo.OrdersXML
(
	OrdersId	INT PRIMARY KEY,
	OrdersDoc	XML(OrdersXSD) NOT NULL -- WITH XSD VALIDATION
);

-----------------------------------------------------
-- Create XML indexes
-----------------------------------------------------

CREATE PRIMARY XML INDEX ix_orders
	ON dbo.OrdersXML(OrdersDoc);
GO

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

-----------------------------------------------------
-- Load XML data
-----------------------------------------------------

DECLARE @OrdersXML2 XML;

SELECT	@OrdersXML2 = a 
FROM	OPENROWSET(BULK N'C:\Users\rguzman\Desktop\Personal\IP\SQLMethods\SQLMethods\Scratch3.xml', SINGLE_BLOB) AS x(a);

BEGIN TRY
	-- Note subquery syntax is allowed in INSERT INTO.
	INSERT INTO dbo.OrdersXML 
	VALUES(1,	(SELECT	a 
				FROM	OPENROWSET(BULK N'C:\Users\rguzman\Desktop\Personal\IP\SQLMethods\SQLMethods\Scratch2.xml', SINGLE_BLOB) AS x(a)));
	
	INSERT INTO dbo.OrdersXML 
	VALUES(2, @OrdersXML2);
END TRY
BEGIN CATCH
	SELECT	ERROR_NUMBER() AS [ERROR_NUMBER()]
			, ERROR_MESSAGE() AS [ERROR_MESSAGE()]
END CATCH

SELECT	'Stage' AS [2], *
FROM	dbo.OrdersXML;

-- Note how CROSS APPLY will work on 1 to many records and 
-- union the results.
SELECT	'Shred It Baby' AS [Yeah!]
		-- XPath is relative to context
		, c.value('OrderId[1]', 'INT') AS [Order Id]
		, c.value('CustomerId[1]', 'INT') AS [Order Date]
		, c.value('OrderDate[1]', 'DATETIME2') AS [Order Date]
		-- Note ./ is equivalent to current context
		, c.value('./OrderAmount[1]', 'FLOAT') AS [Order Date]
FROM	dbo.OrdersXML AS x
	CROSS APPLY x.OrdersDoc.nodes('//Order') AS T(c); -- sets context