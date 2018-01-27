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
-- Option 1: OPENXML
-----------------------------------------------------
DECLARE @handle INT;
DECLARE @OrdersXML VARCHAR(MAX);

SELECT	@OrdersXML = a 
FROM	OPENROWSET(BULK N'C:\Users\rguzman\Desktop\Personal\IP\SQLMethods\SQLMethods\Scratch.xml', SINGLE_CLOB) AS x(a);

--SELECT	@OrdersXML;

-- Get a handle onto the XML document - can only process un-typed XML.
EXEC sp_xml_preparedocument @handle OUTPUT, @OrdersXML;

-- Use the OPENXML rowset provider against the handle to parse/query the XML
SELECT	*
FROM	OPENXML(@handle, '/Orders/Customer/Order/OrderDetail') -- XPath expression sets the context
WITH 
(
	-- XPath expression is relative to the context ('..' means go up one level).
	CustomerName	VARCHAR(MAX)	'../../@ContactName'
	, OrderId		INT				'../OrderDetail/@OrderID'
	, ProductId		INT				'../OrderDetail/@ProductID'
	, OrderDate		DATE			'../@OrderDate'
);

-- Remove the DOM
EXEC sys.sp_xml_removedocument @handle;
GO