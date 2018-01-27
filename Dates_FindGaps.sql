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

-- Include missing values (gaps) with an outer join.
SELECT	DATEADD(day, Nums.n - 1, '20060101') AS orderdate,
		O.orderid, O.custid, O.empid
FROM	dbo.Nums
	LEFT OUTER JOIN Sales.Orders AS O
		ON DATEADD(day, Nums.n - 1, '20060101') = O.orderdate
WHERE	Nums.n <= DATEDIFF(day, '20060101', '20081231') + 1
		--AND O.orderid IS NULL
ORDER BY orderdate;
