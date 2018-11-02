USE ScratchDB;
GO

WITH r
AS
(
	-- ANCHOR (This will be the root - can be any node)
	SELECT	EMPNO
			, ENAME
			, MGR
			, 1 AS LEVEL
	FROM	EMP
	--WHERE	EMPNO = 7566
	WHERE	MGR IS NULL
	UNION ALL
	-- RECURSION
	SELECT	e.EMPNO
			, e.ENAME
			, e.MGR
			, r.LEVEL + 1
	FROM	r
		INNER JOIN EMP AS e
			ON r.EMPNO = e.MGR 
)
SELECT	*
FROM	r;

-- Pretty print
WITH r
AS
(
	-- ANCHOR (This will be the root - can be any node)
	SELECT	EMPNO
			, ENAME
			, MGR
			, 1 AS LEVEL
			, CAST(ENAME AS VARCHAR(100)) AS ENAME2
	FROM	EMP
	--WHERE	EMPNO = 7566
	WHERE	MGR IS NULL
	UNION ALL
	-- RECURSION
	SELECT	e.EMPNO
			, e.ENAME
			, e.MGR
			, r.LEVEL + 1
			, CAST(r.ENAME2 + ' > ' + e.ENAME AS VARCHAR(100)) AS ENAME2
	FROM	r
		INNER JOIN EMP AS e
			ON r.EMPNO = e.MGR 
)
SELECT	*
FROM	r;