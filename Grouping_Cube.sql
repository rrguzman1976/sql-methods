USE TSQL2012;
GO

/*-----------------------------------------------------
 * Grouping Set Semantics: 
 *
 *-----------------------------------------------------*/

-- Equivalent to: Cube returns all possible grouping sets that can be 
-- defined based on the input members.
SELECT empid, custid, COUNT(*) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid)
-- Equivalent to:
--GROUP BY empid, custid WITH CUBE
;
