USE TSQL2012;
GO

/*-----------------------------------------------------
 * Sub-query Semantics
 * A self-contained, scalar subquery can appear anywhere 
 * in the outer query where a single-valued expression can 
 * appear (such as WHERE or SELECT).
 * Sometimes the equivalent join performs better than 
 * subqueries, and sometimes the opposite is true.
 *
 *-----------------------------------------------------*/

-- When you use the NOT IN predicate against a subquery that 
-- returns at least one NULL, the outer query always returns 
-- an empty set.
/*
INSERT INTO Sales.Orders (custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
VALUES(NULL, 1, '20090212', '20090212', '20090212', 1, 123.00, N'abc', N'abc', N'abc', N'abc', N'abc', N'abc');

DELETE FROM Sales.Orders
WHERE	custid IS NULL;

SELECT	*
FROM	Sales.Orders;
*/

-- => NOT (22 = 1 OR 22 = 2 OR ... OR 22 = NULL)
-- => NOT (FALSE OR FALSE OR UNKNOWN)
-- => NOT (UNKNOWN)
-- => UNKNOWN
SELECT	custid, companyname
FROM	Sales.Customers
WHERE	custid NOT IN (	SELECT	O.custid
						FROM	Sales.Orders AS O
						--WHERE	O.custid IS NOT NULL -- FIX
						);

-- Another work around is to use EXISTS
SELECT	custid, companyname
FROM	Sales.Customers AS c
WHERE	NOT EXISTS (	SELECT	*
						FROM	Sales.Orders AS O
						WHERE	O.custid = c.custid  -- FIX
						);
