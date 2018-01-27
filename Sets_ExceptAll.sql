USE TSQL2012;
GO

/*-----------------------------------------------------
 * SET Semantics: UNION [ALL], EXCEPT, INTERSECT
 * A set operator considers two NULLs as equal
 *-----------------------------------------------------*/

-- EXCEPT ALL implementation.
WITH EXCEPT_ALL
AS
(
	SELECT
	ROW_NUMBER() OVER (PARTITION BY country, region, city
						ORDER BY (SELECT 0)) AS rownum,
	country, region, city
	FROM HR.Employees
	EXCEPT
	SELECT
	ROW_NUMBER() OVER (PARTITION BY country, region, city
						ORDER BY (SELECT 0)),
	country, region, city
	FROM Sales.Customers
)
SELECT country, region, city
FROM EXCEPT_ALL;
