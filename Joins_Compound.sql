USE TSQL2012;
GO

/*-----------------------------------------------------
 * Join semantics
 * The ON clause accepts TRUE (rejects UNKNOWN).
 * Table operators are logically processed from left to 
 * right. 
 * The result table of the first table operator is treated 
 * as the left input to the second table operator; the 
 * result of the second table operator is treated as the left 
 * input to the third table operator; and so on.
 *
 * CROSS JOIN: Cartesian product
 * INNER JOIN: Cartesian product > Filter
 * OUTER JOIN: Cartesian product > Filter > Add Outer Rows
 *	- i.e. an outer join returns both inner and outer rows	
 *-----------------------------------------------------*/

-- Use a compound filter to specify conditions in an
-- outer join without removing the outer rows.
SELECT	C.custid, C.companyname, O.orderid, O.orderdate
FROM	Sales.Customers AS C
	LEFT OUTER JOIN Sales.Orders AS O
		ON	O.custid = C.custid
			-- If the criteria is in the where, then it
			-- becomes "FINAL" and removes outer rows.
			-- By using the criteria in the ON clause,
			-- it only influences the filter conditions
			-- and still allows outer rows to be returned.
			AND O.orderdate = '20070212';
