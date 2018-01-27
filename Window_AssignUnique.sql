USE TSQL2012;
GO

/*-----------------------------------------------------
 * Window Function Semantics: 
 * Because the starting point of a window function is the 
 * underlying query’s result set, and the underlying query’s 
 * result set is generated only when you reach the SELECT 
 * phase, window functions are allowed only in the SELECT 
 * and ORDER BY clauses of a query.
 *
 * Window functions are evaluated as part of the evaluation
 * of the expressions in the SELECT list, before the 
 * DISTINCT clause is evaluated.
 *-----------------------------------------------------*/

-- Assign row numbers to unique values.
SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;