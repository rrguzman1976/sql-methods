USE TSQL2012;
GO

/*-----------------------------------------------------
 * DML Semantics: 
 *
 *-----------------------------------------------------*/

-- Use CTE to update based on a window function
/*
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
CREATE TABLE dbo.T1(col1 INT, col2 INT);
GO
INSERT INTO dbo.T1(col1) VALUES(10),(20),(30);
*/
WITH C AS
(
	SELECT col1, col2, ROW_NUMBER() OVER(ORDER BY col1) AS rownum
	FROM dbo.T1
)
UPDATE C
	SET col2 = rownum;
GO

-- OR
UPDATE C
	SET col2 = rownum
FROM
(
	SELECT col1, col2, ROW_NUMBER() OVER(ORDER BY col1) AS rownum
	FROM dbo.T1
) AS C
;
