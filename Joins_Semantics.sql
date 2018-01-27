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

-- INNER JOIN uses Cartesian product followed by Filter
SELECT	E.empid, E.firstname, E.lastname, O.orderid
FROM	HR.Employees AS E
	INNER JOIN Sales.Orders AS O
		ON E.empid = O.empid;

-- Equivalent to:
SELECT	E.empid, E.firstname, E.lastname, O.orderid
FROM	HR.Employees AS E
	CROSS JOIN Sales.Orders AS O -- CARTESIAN PRODUCT
WHERE	E.empid = O.empid; -- FILTER