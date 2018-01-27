USE TSQL2012;
GO

/*-----------------------------------------------------
 * TOP semantics
 *-----------------------------------------------------*/

SELECT	TOP (10) PERCENT -- Rounds up
		orderid, orderdate, custid, empid
FROM	Sales.Orders
ORDER BY orderdate DESC; -- optional

SELECT	TOP (10) PERCENT WITH TIES -- Returns all tied rows
		orderid, orderdate, custid, empid
FROM	Sales.Orders
ORDER BY orderdate DESC; -- or use deterministic ordering +orderid