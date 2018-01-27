USE TSQL2012;
GO

/*-----------------------------------------------------
 * SET Semantics: UNION [ALL], EXCEPT, INTERSECT
 * A set operator considers two NULLs as equal
 *-----------------------------------------------------*/

-- INTERSECT ALL implementation (return 1 to 1 matches)
-- Notice alternative to SELECT NULL for sorting.
WITH INTERSECT_ALL
AS
(
	SELECT
		ROW_NUMBER() OVER (PARTITION BY country, region, city
							ORDER BY (SELECT 0)) AS rownum,
		country, region, city
	FROM HR.Employees
	INTERSECT
	SELECT
		ROW_NUMBER() OVER(PARTITION BY country, region, city
							ORDER BY (SELECT 0)),
	country, region, city
	FROM Sales.Customers
)
SELECT country, region, city
FROM INTERSECT_ALL;
