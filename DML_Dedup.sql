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

SELECT	*
FROM	EMP
ORDER BY JOB;

ROLLBACK TRAN;

SELECT	@@TRANCOUNT, XACT_STATE();