USE TSQL2012;
GO

/*-----------------------------------------------------
 * SET Semantics: UNION [ALL], EXCEPT, INTERSECT
 * A set operator considers two NULLs as equal
 *-----------------------------------------------------*/

-- APPEND 2 sets
WITH x
AS
(
	SELECT country, region, city, 1 AS sorter
	FROM HR.Employees
	UNION ALL
	SELECT country, region, city, 2
	FROM Production.Suppliers
)
SELECT	country, region, city, sorter
FROM	x
ORDER BY sorter, country, region, city;