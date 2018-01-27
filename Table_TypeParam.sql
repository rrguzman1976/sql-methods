USE TSQL2012;
GO

/*-----------------------------------------------------
 * Temp Table Semantics: 
 *-----------------------------------------------------*/

IF OBJECT_ID(N'dbo.spTypeParam', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spTypeParam;
GO

CREATE PROCEDURE dbo.spTypeParam
(
	@pTableType AS dbo.OrderTotalsByYear READONLY
	, @pCount AS INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT	*
	FROM	@pTableType;

	SET @pCount = (SELECT	COUNT(*)
					FROM	@pTableType);
END
GO

DECLARE @MyOrderTotalsByYear AS dbo.OrderTotalsByYear;
DECLARE @Count AS INT = 0;

INSERT INTO @MyOrderTotalsByYear(orderyear, qty)
SELECT
	YEAR(O.orderdate) AS orderyear,
	SUM(OD.qty) AS qty
FROM Sales.Orders AS O
	JOIN Sales.OrderDetails AS OD
		ON OD.orderid = O.orderid
GROUP BY YEAR(orderdate);

EXEC dbo.spTypeParam
	@MyOrderTotalsByYear
	, @Count OUTPUT;

SELECT	@Count;
GO