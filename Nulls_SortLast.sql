USE TSQL2012;
GO

/*-----------------------------------------------------
 * NULL semantics
 * CHECK constraints reject FALSE (accept UNKNOWN), all 
 * predicates accept TRUE (reject UNKNOWN).
 * UNIQUE allows a single NULL, PRIMARY KEY doesn't allow
 * NULL.
 * GROUP BY, ORDER BY treat NULL as equal, in all other
 * cases NULL = NULL is UNKNOWN.
 *-----------------------------------------------------*/

-- By default, SQL Server sorts NULL marks before non-NULL values
-- Use the following to sort NULL last.

SELECT	custid, region
FROM	Sales.Customers
ORDER BY
	CASE WHEN region IS NULL THEN 1 ELSE 0 END, region;
