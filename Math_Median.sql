USE tempdb;
GO

-- Median salary
select avg(sal)
   from (
 select sal,
        count(*) over() total,
        count(*) over()/2.0 mid,
        CEILING(count(*) over()/2.0) next,
        row_number() over (order by sal) rn
   from ScratchDB.dbo.emp
  where deptno = 20
        ) x
 where ( total%2 = 0
			-- Average middle values
         and rn in ( mid, mid+1 )
       )
    or ( total%2 = 1
         and rn = next -- middle
       )

-- Inspiration:
-- https://sqlperformance.com/2012/08/t-sql-queries/median

IF OBJECT_ID(N'dbo.Employee', N'U') IS NOT NULL
       DROP TABLE Employee;

SELECT *
       INTO Employee
FROM   (
       VALUES 

(1 , 'A', 2341 )
, (2 , 'A', 341  )
, (3 , 'A', 15   )
, (4 , 'A', 15314)
, (5 , 'A', 451  )
, (6 , 'A', 513  )
, (7 , 'B', 15   )
, (8 , 'B', 13   )
, (9 , 'B', 1154 )
, (10, 'B', 1345 )
, (11, 'B', 1221 )
, (12, 'B', 234  )
, (13, 'C', 2345 )
, (14, 'C', 2645 )
, (15, 'C', 2645 )
, (16, 'C', 2652 )
, (17, 'C', 65   )

) AS s(Id, Company, Salary);

SELECT	lo.Id, lo.Company, lo.Salary
		--, lo.Company, lo.Salary
		--, CEILING(t.count1 / 2.0)
		--, t.count1 / 2 + 1
FROM	(
		SELECT	Company, COUNT(*) AS count1
		FROM	Employee
		GROUP BY Company
	) AS t
	CROSS JOIN (
		SELECT	ROW_NUMBER() OVER (PARTITION BY Company
									ORDER BY Salary) AS Id2
				, *
		FROM	Employee AS s
		--WHERE	s.Company = t.Company
	) AS lo
WHERE	(lo.id2 = CEILING(t.count1 / 2.0)
		OR lo.id2 = t.count1 / 2 + 1)
		AND t.Company = lo.Company
		--AND t.Company = 'A'
ORDER BY lo.Company, lo.Salary;

-- Not sure how this works?
SELECT
    MIN(Employee.Id), Employee.Company, Employee.Salary
FROM
    Employee,
    Employee alias
WHERE
    Employee.Company = alias.Company
GROUP BY Employee.Company , Employee.Salary
HAVING SUM(CASE
    WHEN Employee.Salary = alias.Salary THEN 1
    ELSE 0
END) >= ABS(SUM(SIGN(Employee.Salary - alias.Salary)))
ORDER BY MIN(Employee.Id)
;

-- "Decompress" version
 IF OBJECT_ID(N'dbo.Numbers', N'U') IS NOT NULL
	DROP TABLE Numbers;

SELECT *
	INTO Numbers
FROM   (
       VALUES 

		(0 , 7)
		, (1 , 1)
		, (2 , 3)
		, (3 , 1)

) AS s(Number, Frequency);

WITH seq
AS
(
	SELECT	ROW_NUMBER() OVER (ORDER BY c.object_id) AS row
	FROM	sys.all_columns AS c
)
, nums
AS
(
	SELECT	n.Number, n.Frequency
			, seq.row AS rowInner
			, ROW_NUMBER() OVER (ORDER BY n.Number) AS rowOuter
			, COUNT(*) OVER () AS fullCount
	FROM	Numbers AS n
		INNER JOIN seq
			ON n.Frequency >= seq.row
)
SELECT	AVG(n.Number) AS median
FROM	nums AS n
WHERE	n.rowOuter = CEILING(n.fullCount / 2.0)
		OR n.rowOuter = n.fullCount / 2 + 1
--ORDER BY n.rowOuter, n.rowInner;

-- "A Beautiful mind" version:
/*
Suppose number x has frequency of n, and total frequency of other numbers 
that are on its left is l, on its right is r. The equation becomes: 
(n+l) - (n+r) = l - r, x is median if l==r, of course.

When l != r, as long as n can cover the difference, x is the median.
 */
SELECT	AVG(n.Number) AS median
FROM	Numbers AS n
where	n.Frequency >= abs(
	-- Left side
	(select sum(Frequency) from Numbers where Number <= n.Number)
	 -
	-- Right side
	(select sum(Frequency) from Numbers where Number >= n.Number)
						);