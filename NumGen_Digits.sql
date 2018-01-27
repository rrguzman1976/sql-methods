USE TSQL2012;
GO

/*-----------------------------------------------------
 * Techniques for generating number sequences
 *-----------------------------------------------------*/

-- Technique 1: Use a digits table to generate an arbitrary
-- sequence of numbers.
IF OBJECT_ID('dbo.Digits', 'U') IS NOT NULL DROP TABLE dbo.Digits;
GO

CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);
GO

INSERT INTO dbo.Digits(digit)
VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

-- Produce sequence of 1000 integers.
SELECT	D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS n
FROM	dbo.Digits AS D1
	CROSS JOIN dbo.Digits AS D2
	CROSS JOIN dbo.Digits AS D3
ORDER BY n;

-- Produce sequence of 10000 integers.
SELECT	D4.digit * 1000 + D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS n
FROM	dbo.Digits AS D1
	CROSS JOIN dbo.Digits AS D2
	CROSS JOIN dbo.Digits AS D3
	CROSS JOIN dbo.Digits AS D4
ORDER BY n;