USE TSQL2012;
GO

/*-----------------------------------------------------
 * Table Expression Semantics: Derived Tables, CTE, 
 * Views, inline TVF (parameterized views).
 * Table expressions have neither positive nor negative 
 * performance impact (logical only).
 * When querying a view or an inline TVF, SQL Server 
 * expands the definition of the table expression and
 * queries the underlying objects directly, as with derived 
 * tables and CTEs
 * Avoid SELECT * in views as new columns will not be 
 * automatically added without sp_refreshview.
 * A query with an ORDER BY clause and a TOP or OFFSET-FETCH 
 * option does not guarantee presentation order only in 
 * the context of a table expression. In the context of 
 * a query that is not used to define a table expression, 
 * the ORDER BY clause serves both the filtering purpose 
 * for the TOP or OFFSET-FETCH option and the presentation 
 * purpose.
 * Creating views with the SCHEMABINDING option is a good 
 * practice.
 *-----------------------------------------------------*/

-- Implement lead without window functions.
WITH YearlyCount AS
(
	SELECT YEAR(orderdate) AS orderyear,
	COUNT(DISTINCT custid) AS numcusts
	FROM Sales.Orders
	GROUP BY YEAR(orderdate)
)
SELECT	Cur.orderyear,
		Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
		Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
	LEFT OUTER JOIN YearlyCount AS Prv
		ON Cur.orderyear = Prv.orderyear + 1;
