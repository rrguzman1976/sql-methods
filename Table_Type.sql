USE TSQL2012;
GO

/*-----------------------------------------------------
 * Temp Table Semantics: 
 *
 *
 *-----------------------------------------------------*/

-- Table type (can be used as sproc/function parameter)
IF TYPE_ID('dbo.OrderTotalsByYear') IS NOT NULL
	DROP TYPE dbo.OrderTotalsByYear;
GO

CREATE TYPE dbo.OrderTotalsByYear AS TABLE
(
	orderyear	INT		NOT NULL PRIMARY KEY,
	qty			INT		NOT NULL
);
GO

DECLARE @MyOrderTotalsByYear AS dbo.OrderTotalsByYear;

INSERT INTO @MyOrderTotalsByYear(orderyear, qty)
SELECT
YEAR(O.orderdate) AS orderyear,
SUM(OD.qty) AS qty
FROM Sales.Orders AS O
JOIN Sales.OrderDetails AS OD
ON OD.orderid = O.orderid
GROUP BY YEAR(orderdate);

SELECT	*
FROM	@MyOrderTotalsByYear;