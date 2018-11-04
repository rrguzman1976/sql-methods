USE ScratchDB;
GO
--/*
DROP TABLE IF EXISTS #P;

CREATE TABLE #P
(
	PROJ_ID INT IDENTITY(1, 1)
	, PROJ_START DATE
	, PROJ_END DATE
);

INSERT INTO #P
VALUES ('01-JAN-2005', '02-JAN-2005')
		, ('02-JAN-2005', '03-JAN-2005')
		, ('03-JAN-2005', '04-JAN-2005')
		, ('04-JAN-2005', '05-JAN-2005')
		, ('06-JAN-2005', '07-JAN-2005')
		, ('16-JAN-2005', '17-JAN-2005')
		, ('17-JAN-2005', '18-JAN-2005')
		, ('18-JAN-2005', '19-JAN-2005')
		, ('19-JAN-2005', '20-JAN-2005')
		, ('21-JAN-2005', '22-JAN-2005')
		, ('26-JAN-2005', '27-JAN-2005')
		, ('27-JAN-2005', '28-JAN-2005')
		, ('28-JAN-2005', '29-JAN-2005')
		, ('29-JAN-2005', '30-JAN-2005')
;
--*/

WITH V2
AS
(
	-- This "calculates" start of a range
	SELECT	p.*
			, LAG(PROJ_END, 1, NULL) OVER (ORDER BY PROJ_START) AS prv
			, CASE
				WHEN PROJ_START = LAG(PROJ_END, 1, NULL) OVER (ORDER BY PROJ_START) THEN 0
				ELSE 1
			END AS flag
	FROM	#P as p
)
SELECT	proj_grp, MIN(PROJ_START), MAX(PROJ_END)
FROM	(
	SELECT	*
			-- This does a "running sum" to generate group id's.
			, SUM(a.flag) OVER (ORDER BY a.PROJ_ID) AS proj_grp
			/* -- Same as
			, (
				SELECT	SUM(b.flag)
				FROM	V2 AS b
				WHERE	b.PROJ_ID <= a.PROJ_ID
			) AS proj_grp
			*/
	FROM	V2 AS a
) AS x
GROUP BY proj_grp