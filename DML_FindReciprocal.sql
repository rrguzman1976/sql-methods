USE ScratchDB;
GO
/*
DROP TABLE IF EXISTS #R;

CREATE TABLE #R
(
	TEST1	INT
	, TEST2	INT
);

INSERT INTO #R
VALUES (20, 20)
		,(50, 25)
		,(20, 20)
		,(60, 30)
		,(70, 90)
		,(80,130)
		,(90, 70)
		,(100, 50)
		,(110, 55)
		,(120, 60)
		,(130, 80)
		,(140, 70);
*/
;

SELECT	*
FROM	#R;

-- Find records with reciprocals
select	distinct v1.*
from	#R v1, #R v2
where	v1.test1 = v2.test2
		and v1.test2 = v2.test1
			-- Only check for forward reciprocals
		and v1.test1 <= v1.test2
;