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

-- The resolution of nonprefixed column names works in the 
-- context of a subquery from the current/inner scope outward.
/* 
IF OBJECT_ID('Sales.MyShippers', 'U') IS NOT NULL DROP TABLE Sales.MyShippers;
GO

CREATE TABLE Sales.MyShippers
(
	shipper_id INT NOT NULL,
	companyname NVARCHAR(40) NOT NULL,
	phone NVARCHAR(24) NOT NULL,
	CONSTRAINT PK_MyShippers PRIMARY KEY(shipper_id)
);

INSERT INTO Sales.MyShippers(shipper_id, companyname, phone)
VALUES (1, N'Shipper GVSUA', N'(503) 555-0137'),
		(2, N'Shipper ETYNR', N'(425) 555-0136'),
		(3, N'Shipper ZHISN', N'(415) 555-0138');

DROP TABLE Sales.MyShippers;
*/

SELECT	shipper_id, companyname
FROM	Sales.MyShippers
WHERE	shipper_id IN
		-- shipper_id correlated to Sales.MyShippers!
		-- Lesson: Always use aliases!
		(	SELECT	shipper_id
			FROM	Sales.Orders
			WHERE	custid = 43);

