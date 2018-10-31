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

-- Use correlated sub-query to calculate an avg.
SELECT	orderid, custid, val,
		CAST(100. * val / (	SELECT	SUM(O2.val)
							FROM	Sales.OrderValues AS O2
							WHERE	O2.custid = O1.custid)
		AS NUMERIC(5,2)) AS pct
FROM	Sales.OrderValues AS O1
ORDER BY custid, orderid;

-- Exclude high and low!
USE ScratchDB;

select avg(sal)
 from emp
where sal not in (
   (select min(sal) from emp),
   (select max(sal) from emp)
)
