USE TSQL2012;
GO

/*-----------------------------------------------------
 * Grouping Set Semantics: 
 *
 *-----------------------------------------------------*/

-- If a grouping column is defined as allowing NULL marks in the table, 
-- you cannot tell for sure whether a NULL in the result set originated 
-- from the data or is a placeholder for a nonparticipating member in 
-- a grouping set unless you use the GROUPING function.
SELECT
	GROUPING(empid) AS grpemp,
	GROUPING(custid) AS grpcust,
	empid, custid, COUNT(*) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

SELECT
	CASE 
		WHEN GROUPING(empid) = 1 THEN '(all)' 
		ELSE CAST(empid AS VARCHAR(32))
	END AS empid
	, CASE 
		WHEN GROUPING(custid) = 1 THEN '(all)' 
		ELSE CAST(custid AS VARCHAR(32))
	END AS custid
	, COUNT(*) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

-- As bitmap
SELECT
	-- empid x 2^1 + custid x 2^0
	GROUPING_ID(empid, custid) AS groupingset,
	empid, custid, COUNT(*) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);