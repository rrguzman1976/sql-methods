USE ScratchDB;
GO

--DROP TABLE IF EXISTS #N;

SELECT	COUNT(*) OVER ()
		, DATEADD(d, Num, '19760517')
		, DATENAME(dw, DATEADD(d, Num, '19760517'))
FROM	#N -- Use a numbers utility table
WHERE	DATEADD(d, Num, '19760517') < '19770101' 
		AND DATENAME(dw, DATEADD(d, Num, '19760517')) NOT IN ('Saturday', 'Sunday')
ORDER BY Num;