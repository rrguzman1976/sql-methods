USE ScratchDB;
GO

-- Wow!
SELECT	e.EMPNO, e.SAL
		, EXP(SUM(LOG(e.SAL)) OVER (ORDER BY e.EMPNO)) AS [runningproduct]
FROM	EMP AS e
ORDER BY e.EMPNO;