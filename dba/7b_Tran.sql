USE ScratchDB;
GO

-- Ex 1: RCSI writer does not block RCSI reader (toggle READ_COMMITTED_SNAPSHOT).
-- Ex 2: RC writer does block RC reader (toggle READ_COMMITTED_SNAPSHOT).
-- Ex 3: RC/RCSI reader does not block RC/RCSI writer under RC/RCSI (because S locks 
--		 are not held until end of transaction).
/*
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRAN [TEST1b];

	SELECT	SVAL
	FROM	[dbo].[Test01]
	WHERE	NVAL = 1;

COMMIT TRAN [TEST1b];
*/
;
-- Ex 4: RU writer blocks RU writer.
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRAN [TEST2b];

	DECLARE	@NVAL AS INT;

	UPDATE [dbo].[Test01]
		SET SVAL = N'one-UPD'
	WHERE	NVAL = 1;

	SELECT	*
	FROM	[dbo].[Test01]
	WHERE	NVAL = 1;

ROLLBACK TRAN [TEST2b];

-- Ex X: Deadlock.
/*
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN [DL_TEST2];

	DECLARE	@NVAL AS INT;

	SELECT	@NVAL = [NVAL]
	FROM	[dbo].[Test01]
	WHERE	SVAL = N'1';

	SELECT	@NVAL;

	UPDATE [dbo].[Test01]
		SET NVAL = @NVAL
	WHERE	SVAL = N'3';

COMMIT TRAN [DL_TEST2];
*/

SELECT	@@TRANCOUNT, XACT_STATE();

SELECT	'dm_exec_sessions', *
FROM	sys.dm_exec_sessions
WHERE	database_id = DB_ID(N'ScratchDB')
		AND session_id IN (53, 52);

SELECT	'dm_tran_active_transactions', *
FROM	sys.dm_tran_active_transactions
WHERE	name LIKE N'UPD_TEST%';

SELECT	'dm_tran_database_transactions', *
FROM	sys.dm_tran_database_transactions
WHERE	database_id = DB_ID(N'ScratchDB');

SELECT	'dm_tran_locks', *
FROM	sys.dm_tran_locks
WHERE	resource_database_id = DB_ID(N'ScratchDB')
		AND request_session_id IN (54, 55)
ORDER BY request_session_id
; --= @@SPID

-- Shows blocker session
SELECT	'dm_exec_requests', *
FROM	sys.dm_exec_requests
WHERE	session_id IN (53, 52);

