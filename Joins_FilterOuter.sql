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

-- Filter outer rows
-- If a row has a NULL in the join column, that row is 
-- filtered out by the second phase of the join, so a 
-- NULL in such a column can only mean that it’s an outer 
-- row.
SELECT	C.custid, C.companyname
FROM	Sales.Customers AS C
	LEFT OUTER JOIN Sales.Orders AS O
		ON C.custid = O.custid
WHERE	O.orderid IS NULL; -- must be non-NULL or join column!
