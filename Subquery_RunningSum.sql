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

-- Running total without window functions.
SELECT	orderyear, qty
		,(	SELECT	SUM(O2.qty)
			FROM	Sales.OrderTotalsByYear AS O2
			WHERE	O2.orderyear <= O1.orderyear) AS runqty
FROM	Sales.OrderTotalsByYear AS O1
ORDER BY orderyear;
