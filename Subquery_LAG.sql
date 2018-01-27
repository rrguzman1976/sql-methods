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

-- Implement LAG without window functions.
SELECT	orderid, orderdate, empid, custid
		-- Get the maximum value that is smaller than the current
		, (	SELECT MAX(O2.orderid)
			FROM Sales.Orders AS O2
			WHERE O2.orderid < O1.orderid) AS prevorderid
FROM	Sales.Orders AS O1;
