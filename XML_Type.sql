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

 -- Data type
 DECLARE @XmlData AS xml = '
		<Orders>
			<Order>
				<OrderId>5</OrderId>
				<CustomerId>60</CustomerId>
				<OrderDate>2008-10-10T14:22:27.25-05:00</OrderDate>
				<OrderAmount>25.90</OrderAmount>' +
		+ '	</Order>' + -- comment to test malformed XML
		'</Orders>';

SELECT	@XmlData;

-- Table column
IF OBJECT_ID(N'tempdb.dbo.#OrdersXML', N'U') IS NOT NULL
	DROP TABLE #OrdersXML;

CREATE TABLE #OrdersXML
(
	OrdersId	INT PRIMARY KEY,
	OrdersDoc	XML NOT NULL 
		DEFAULT '<Orders />'
);

-- Only well-formed XML (including fragments) can be inserted — 
-- any attempt to insert malformed XML will result in an exception
BEGIN TRY
	INSERT INTO #OrdersXML (OrdersId, OrdersDoc) VALUES (1, @XmlData);
END TRY
BEGIN CATCH
	SELECT	ERROR_NUMBER() AS [ERROR_NUMBER]
			, ERROR_MESSAGE() AS [ERROR_MESSAGE];
END CATCH

SELECT	*
FROM	#OrdersXML;