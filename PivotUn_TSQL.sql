USE TSQL2012;
GO

/*-----------------------------------------------------
 * Pivot Semantics: 
 * The PIVOT operator figures out the grouping elements 
 * implicitly as all attributes from the source table 
 * (or table expression) that were not specified as either 
 * the spreading element or the aggregation element.
 *
 *
 *-----------------------------------------------------*/

/*
IF OBJECT_ID('dbo.EmpCustOrders', 'U') IS NOT NULL DROP TABLE dbo.EmpCustOrders;
CREATE TABLE dbo.EmpCustOrders
(
	empid INT NOT NULL
	CONSTRAINT PK_EmpCustOrders PRIMARY KEY,
	A VARCHAR(5) NULL,
	B VARCHAR(5) NULL,
	C VARCHAR(5) NULL,
	D VARCHAR(5) NULL
);
INSERT INTO dbo.EmpCustOrders(empid, A, B, C, D)
SELECT empid, A, B, C, D
FROM (SELECT empid, custid, qty
FROM dbo.Orders) AS D
PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;
*/

-- Unpivot using native T-SQL
SELECT empid, custid, qty
FROM dbo.EmpCustOrders
	UNPIVOT(qty FOR custid IN(A, B, C, D)) AS U;