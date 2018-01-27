USE TSQL2012;
GO

/*-----------------------------------------------------
 * Grouping Set Semantics: 
 *
 *-----------------------------------------------------*/

SELECT empid, custid, COUNT(*) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid
UNION ALL
SELECT empid, NULL, COUNT(*) AS sumqty
FROM dbo.Orders
GROUP BY empid
UNION ALL
SELECT NULL, custid, COUNT(*) AS sumqty
FROM dbo.Orders
GROUP BY custid
UNION ALL
SELECT NULL, NULL, COUNT(*) AS sumqty
FROM dbo.Orders;

-- Equivalent to: much more efficient
SELECT empid, custid, COUNT(*) AS sumqty
FROM dbo.Orders
GROUP BY
GROUPING SETS
(
	(empid, custid),
	(empid),
	(custid),
	()
);