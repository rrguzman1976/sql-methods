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

-- Using a parameterized TOP expression.
IF OBJECT_ID('dbo.TopOrders') IS NOT NULL
	DROP FUNCTION dbo.TopOrders;
GO

CREATE FUNCTION dbo.TopOrders
(@custid AS INT, @n AS INT)
RETURNS TABLE
AS
RETURN
	-- TOP can be parameterized
	SELECT	TOP (@n) 
			orderid, empid, orderdate, requireddate
	FROM Sales.Orders
	WHERE custid = @custid
	ORDER BY orderdate DESC, orderid DESC
	-- Equivalently:
	--OFFSET 0 ROWS FETCH NEXT @n ROWS ONLY
	;
GO

SELECT
	C.custid, C.companyname,
	A.orderid, A.empid, A.orderdate, A.requireddate
FROM Sales.Customers AS C
	CROSS APPLY dbo.TopOrders(C.custid, 3) AS A;

