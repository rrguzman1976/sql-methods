-- https://sqlserverfast.com/blog/hugo/2006/09/the-prime-number-challenge-great-waste-of-time/
-- Beautiful
DECLARE @Limit INT = 545;

;WITH n1
AS
(
	SELECT	ROW_NUMBER() OVER (ORDER BY c.object_id) AS [Number]
	FROM	sys.columns AS c
)
SELECT	n1.Number
FROM	n1
WHERE	n1.Number > 1
		AND n1.Number <= @Limit
		AND NOT EXISTS (
			SELECT  *
			FROM    n1 AS n2
			WHERE   n2.Number > 1
					AND n2.Number < n1.Number
					AND n1.Number % n2.Number = 0)
;
