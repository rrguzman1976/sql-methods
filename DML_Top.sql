USE TSQL2012;
GO

/*-----------------------------------------------------
 * DML Semantics: 
 *
 *-----------------------------------------------------*/

-- TOP / OFFSET FETCH DML
/*
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
custid INT NULL,
empid INT NOT NULL,
orderdate DATETIME NOT NULL,
requireddate DATETIME NOT NULL,
shippeddate DATETIME NULL,
shipperid INT NOT NULL,
freight MONEY NOT NULL
CONSTRAINT DFT_Orders_freight DEFAULT(0),
shipname NVARCHAR(40) NOT NULL,
shipaddress NVARCHAR(60) NOT NULL,
shipcity NVARCHAR(15) NOT NULL,
shipregion NVARCHAR(15) NULL,
shippostalcode NVARCHAR(10) NULL,
shipcountry NVARCHAR(15) NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
GO
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
*/
WITH C AS
(
	SELECT TOP(50) *
	FROM dbo.Orders
	ORDER BY orderid
)
DELETE FROM C;

WITH C AS
(
	SELECT *
	FROM dbo.Orders
	ORDER BY orderid DESC
	OFFSET 0 ROWS FETCH FIRST 50 ROWS ONLY
)
UPDATE C
SET freight += 10.00;
GO
