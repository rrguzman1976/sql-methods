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

-- GROUPING_ID indicates if the value is part of the grouping (negated!)
SELECT	GROUPING_ID(DEPTNO) AS GRPID_DEPT
		, DEPTNO
		, GROUPING_ID(JOB) AS GRPID_JOB
		, JOB
		, CASE
			WHEN GROUPING_ID(DEPTNO) = 0 AND GROUPING_ID(JOB) != 0 THEN 'DEPTNO GROUP'
			WHEN GROUPING_ID(DEPTNO) != 0 AND GROUPING_ID(JOB) = 0 THEN 'JOB GROUP'
			WHEN GROUPING_ID(DEPTNO) = 0 AND GROUPING_ID(JOB) = 0 THEN 'DEPTNO and JOB GROUP'
			ELSE 'NO GROUPS / TOTAL'
		END AS CATEGORY
		, SUM(SAL)
FROM	ScratchDB.dbo.EMP
GROUP BY GROUPING SETS((DEPTNO, JOB), (JOB), (DEPTNO), ()) -- SAME AS GROUP BY CUBE
ORDER BY GRPID_DEPT, GRPID_JOB, DEPTNO, JOB