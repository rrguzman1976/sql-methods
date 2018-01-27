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

IF OBJECT_ID('dbo.OrdersXML', 'U') IS NOT NULL
	DROP TABLE dbo.OrdersXML;

IF EXISTS(	SELECT	*
			FROM	sys.xml_schema_collections
			WHERE	name = N'OrdersXSD')
	DROP XML SCHEMA COLLECTION OrdersXSD;

-- An XSD schema can be used on any xml type, including variables,
-- parameters, return values, and columns in tables.
CREATE XML SCHEMA COLLECTION OrdersXSD 
AS '
<xsd:schema
		xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		xmlns:sql="urn:schemas-microsoft-com:mapping-schema">
	<xsd:simpleType name="OrderAmountFloat" >
		<xsd:restriction base="xsd:float" >
			<xsd:minExclusive value="1.0" />
			<xsd:maxInclusive value="5000.0" />
		</xsd:restriction>
	</xsd:simpleType>
	<xsd:element name="Orders">
		<xsd:complexType>
			<xsd:sequence>
				<xsd:element name="Order">
					<xsd:complexType>
						<xsd:sequence>
						<xsd:element name="OrderId" type="xsd:int" />
						<xsd:element name="CustomerId" type="xsd:int" />
						<xsd:element name="OrderDate" type="xsd:dateTime" />
						<xsd:element name="OrderAmount" type="OrderAmountFloat" />
						</xsd:sequence>
					</xsd:complexType>
				</xsd:element>
			</xsd:sequence>
		</xsd:complexType>
	</xsd:element>
</xsd:schema>';
GO

-- Can also be applied to variables
--DECLARE @OrdersDoc	XML(OrdersXSD);
CREATE TABLE dbo.OrdersXML
(
	OrdersId	INT PRIMARY KEY,
	OrdersDoc	XML(OrdersXSD) NOT NULL -- WITH XSD VALIDATION
)
;

-- Works because all XSD validations succeed
INSERT INTO dbo.OrdersXML VALUES(5, '
<Orders>
	<Order>
		<OrderId>5</OrderId>
		<CustomerId>60</CustomerId>
		<OrderDate>2011-10-10T14:22:27.25-05:00</OrderDate>
		<OrderAmount>25.90</OrderAmount>
	</Order>
</Orders>');
GO

-- Schema validation returns granular error info.
BEGIN TRY
	-- Won't work because 6.0 is not a valid int for CustomerId
	UPDATE dbo.OrdersXML 
		SET OrdersDoc = '
			<Orders>
				<Order>
					<OrderId>5</OrderId>
					<CustomerId>6.0</CustomerId>
					<OrderDate>2011-10-10T14:22:27.25-05:00</OrderDate>
					<OrderAmount>25.9O</OrderAmount>
				</Order>
			</Orders>'
	WHERE OrdersId = 5;
END TRY
BEGIN CATCH
	SELECT	ERROR_NUMBER() AS [ERROR_NUMBER()]
			, ERROR_MESSAGE() AS [ERROR_MESSAGE()]
END CATCH
GO

BEGIN TRY
	-- Won't work because 25.9O uses an O for a 0 in the OrderAmount
	UPDATE dbo.OrdersXML 
		SET OrdersDoc = '
			<Orders>
				<Order>
					<OrderId>5</OrderId>
					<CustomerId>60</CustomerId>
					<OrderDate>2011-10-10T14:22:27.25-05:00</OrderDate>
					<OrderAmount>25.9O</OrderAmount>
				</Order>
			</Orders>'
	WHERE OrdersId = 5
END TRY
BEGIN CATCH
	SELECT	ERROR_NUMBER() AS [ERROR_NUMBER()]
			, ERROR_MESSAGE() AS [ERROR_MESSAGE()]
END CATCH
GO

BEGIN TRY
	-- Won't work because 5225.75 is too large a value for OrderAmount
	UPDATE dbo.OrdersXML 
		SET OrdersDoc = '
			<Orders>
				<Order>
					<OrderId>5</OrderId>
					<CustomerId>60</CustomerId>
					<OrderDate>2011-10-10T14:22:27.25-05:00</OrderDate>
					<OrderAmount>5225.75</OrderAmount>
				</Order>
			</Orders>'
	WHERE OrdersId = 5
END TRY
BEGIN CATCH
	SELECT	ERROR_NUMBER() AS [ERROR_NUMBER()]
			, ERROR_MESSAGE() AS [ERROR_MESSAGE()]
END CATCH
GO

-- Note: Does not report cumulative schema validations (only the first)
-- Use .NET for cumulative error reporting.
BEGIN TRY
	-- Union of errors above
	UPDATE dbo.OrdersXML 
		SET OrdersDoc = '
			<Orders>
				<Order>
					<OrderId>5o</OrderId>
					<CustomerId>6.0</CustomerId>
					<OrderDate>2011-10-10T14:22:27.25-05:00</OrderDate>
					<OrderAmount>5225.75</OrderAmount>
				</Order>
			</Orders>'
	WHERE OrdersId = 5
END TRY
BEGIN CATCH
	SELECT	ERROR_NUMBER() AS [ERROR_NUMBER()]
			, ERROR_MESSAGE() AS [ERROR_MESSAGE()]
END CATCH
GO

SELECT	*
FROM	dbo.OrdersXML;