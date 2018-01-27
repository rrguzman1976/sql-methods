USE TSQL2012;
GO

/*-----------------------------------------------------
 * Grouping Set Semantics: 
 *
 *-----------------------------------------------------*/

-- Whereas CUBE(a, b, c) produces all eight possible grouping sets 
-- from the three input members, ROLLUP(a, b, c) produces only four 
-- grouping sets, assuming the hierarchy a>b>c, and is the equivalent 
-- of specifying GROUPING SETS( (a, b, c), (a, b), (a), () ).
SELECT
	YEAR(orderdate) AS orderyear,
	MONTH(orderdate) AS ordermonth,
	DAY(orderdate) AS orderday,
	COUNT(*) AS [count]
FROM dbo.Orders
GROUP BY ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate))
-- Same as
--GROUP BY YEAR(orderdate), MONTH(orderdate), DAY(orderdate) WITH ROLLUP
;
