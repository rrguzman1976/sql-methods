USE tempdb;
GO

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

SELECT	*
FROM	Employee
WHERE	Company = 'A'
ORDER BY Salary
;
GO

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