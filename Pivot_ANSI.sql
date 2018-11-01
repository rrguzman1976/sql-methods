USE TSQL2012;
GO

/*-----------------------------------------------------
 * Pivot Semantics: 
 * The PIVOT operator figures out the grouping elements 
 * implicitly as all attributes from the source table 
 * (or table expression) that were not specified as either 
 * the spreading element or the aggregation element.
 *
 *
 *-----------------------------------------------------*/
/*
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE dbo.Orders
(
	orderid INT NOT NULL,
	orderdate DATE NOT NULL,
	empid INT NOT NULL,
	custid VARCHAR(5) NOT NULL,
	qty INT NOT NULL,
	CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
(30001, '20070802', 3, 'A', 10),
(10001, '20071224', 2, 'A', 12),
(10005, '20071224', 1, 'B', 20),
(40001, '20080109', 2, 'A', 40),
(10006, '20080118', 1, 'C', 14),
(20001, '20080212', 2, 'B', 12),
(40005, '20090212', 3, 'A', 10),
(20002, '20090216', 1, 'C', 20),
(30003, '20090418', 2, 'B', 15),
(30004, '20070418', 3, 'C', 22),
(30007, '20090907', 3, 'D', 30);
*/

-- ANSI-standard pivot using GROUP BY
SELECT	empid,
		-- Use case to spread values.
		SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
		SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
		SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
		SUM(CASE WHEN custid = 'D' THEN qty END) AS D
FROM dbo.Orders
GROUP BY empid; -- grouping

-- PIVOT non-numeric values
select	rn
		, MAX(case when job='CLERK'
              then ename else null end) as clerks,
        MAX(case when job='ANALYST'
              then ename else null end) as analysts,
        MAX(case when job='MANAGER'
              then ename else null end) as mgrs,
        MAX(case when job='PRESIDENT'
              then ename else null end) as prez,
        MAX(case when job='SALESMAN'
                 then ename else null end) as sales
from	(
	select	job,
			ename,
			row_number()over(partition by job order by ename) rn
	from	ScratchDB.dbo.emp
	) x
group by rn
ORDER BY rn

-- Crosstab 2
select	deptno, job, rn_deptno, rn_job,
	       MAX(case when deptno=10
	             then ename else null end) as d10,
	       MAX(case when deptno=20
	             then ename else null end) as d20,
	       MAX(case when deptno=30
	             then ename else null end) as d30,
	       MAX(case when job='CLERK'
	             then ename else null end) as clerks,
	       MAX(case when job='ANALYST'
	             then ename else null end) as anals,
	       MAX(case when job='MANAGER'
	             then ename else null end) as mgrs,
	       MAX(case when job='PRESIDENT'
	             then ename else null end) as prez,
	       MAX(case when job='SALESMAN'
	                then ename else null end) as sales
from	(
		Select deptno,
			job,
			ename,
			row_number()over(partition by job order by ename) rn_job,
			row_number()over(partition by job order by ename) rn_deptno
		from ScratchDB.dbo.emp
	) x
	 group by deptno, job, rn_deptno, rn_job
order by deptno, job, rn_deptno, rn_job

