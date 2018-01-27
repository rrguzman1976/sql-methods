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
 * 
 * Although ROWS treats each row in the window distinctly, 
 * RANGE will merge rows containing duplicate ORDER BY values
 * (ties).
 *-----------------------------------------------------*/

-- Running total
SELECT	empid, ordermonth, val
		, SUM(val) OVER (PARTITION BY empid
						ORDER BY ordermonth
						--ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
						ROWS UNBOUNDED PRECEDING
						) AS runval
FROM	Sales.EmpOrders;

-- Percent total
SELECT orderid, custid, val
		, 100. * val / SUM(val) OVER() AS pctall
		, 100. * val / SUM(val) OVER(PARTITION BY custid) AS pctcust
FROM Sales.OrderValues;

-- Ranking
SELECT orderid, custid, val,
		ROW_NUMBER() OVER(ORDER BY val) AS rownum,
		RANK() OVER(ORDER BY val) AS rank, -- same rank for same val
		DENSE_RANK() OVER(ORDER BY val) AS dense_rank, -- same rank for same val (distinct)
		NTILE(100) OVER(ORDER BY val) AS ntile
FROM Sales.OrderValues
ORDER BY val;

-- Offset
SELECT custid, orderid, val,
		-- No frame
		LAG(val /*, offset, default*/) OVER(PARTITION BY custid
											ORDER BY orderdate, orderid) AS prevval,
		LEAD(val) OVER(PARTITION BY custid
						ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues;

SELECT custid, orderid, val
		, FIRST_VALUE(val) OVER(PARTITION BY custid
								ORDER BY orderdate, orderid
								ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS firstval
		-- The default window is ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW so override
		-- it to get the proper last value.
		, LAST_VALUE(val) OVER(PARTITION BY custid
								ORDER BY orderdate, orderid
								ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS lastval
FROM Sales.OrderValues
ORDER BY custid, orderdate, orderid;


