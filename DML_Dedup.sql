USE ScratchDB;
GO

BEGIN TRAN;

SELECT	*
FROM	EMP
ORDER BY JOB;

-- Alternative to window function
DELETE
from	emp
	OUTPUT deleted.*
WHERE	EMPNO NOT IN (SELECT	MIN(EMPNO) -- can keep first or last dup (max) in each group
					FROM	EMP AS e2
					GROUP BY e2.JOB
					)
;

-- Alternative 2
SELECT	e.EMPNO, e.JOB
FROM	EMP AS e
WHERE	EXISTS (
	SELECT	*
	FROM	EMP AS e2
	WHERE	e2.JOB = e.JOB
			AND e2.EMPNO > e.EMPNO
)
ORDER BY JOB;

SELECT	*
FROM	EMP
ORDER BY JOB;

ROLLBACK TRAN;

SELECT	@@TRANCOUNT, XACT_STATE();