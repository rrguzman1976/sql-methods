USE TSQL2012;
GO

/*-----------------------------------------------------
 * Sub-query Semantics
 * A self-contained, scalar subquery can appear anywhere 
 * in the outer query where a single-valued expression can 
 * appear (such as WHERE or SELECT).
 * Sometimes the equivalent join performs better than 
 * subqueries, and sometimes the opposite is true.
 *
 *-----------------------------------------------------*/

-- Find missing order ids
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
GO

CREATE TABLE dbo.Orders(orderid INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY);
GO

-- Contains only even numbered orders.
INSERT INTO dbo.Orders(orderid)
SELECT	orderid
FROM	Sales.Orders
WHERE	orderid % 2 = 0;
GO

-- Returns odd numbered orders.
SELECT	n
FROM	dbo.Nums
WHERE	n BETWEEN -- Get range of order ids.
			(SELECT MIN(O.orderid) FROM dbo.Orders AS O)
			AND (SELECT MAX(O.orderid) FROM dbo.Orders AS O)
		-- Filter out orders present
		AND n NOT IN (SELECT O.orderid FROM dbo.Orders AS O);

DROP TABLE dbo.Orders;
GO
