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

-- Implement LEAD without window functions.
SELECT	orderid, orderdate, empid, custid
		-- Get the minimum value that is greater than the current
		, (	SELECT MIN(O2.orderid)
			FROM Sales.Orders AS O2
			WHERE O2.orderid > O1.orderid) AS nextorderid
FROM	Sales.Orders AS O1;
