USE TSQL2012;
GO

/*-----------------------------------------------------
 * SET Semantics: UNION [ALL], EXCEPT, INTERSECT
 * A set operator considers two NULLs as equal
 *-----------------------------------------------------*/

 -- Use INTERSECT in place of INNER JOIN or EXISTS when
 -- the special NULL behavior is desired.
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Use EXCEPT over OUTER JOIN or NOT EXISTS when
-- special NULL comparison behavior is desired.
SELECT country, region, city FROM Sales.Customers
EXCEPT
SELECT country, region, city FROM HR.Employees;
