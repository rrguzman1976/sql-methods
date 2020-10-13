USE ScratchDB;
GO
/*
-- No active connections to the database can exist.
-- KILL 55;
ALTER DATABASE ScratchDB
	SET READ_COMMITTED_SNAPSHOT OFF;
GO
*/
;
-- Ex 1: RCSI writer does not block RCSI reader (toggle READ_COMMITTED_SNAPSHOT).
-- Ex 2: RC writer does block RC reader (toggle READ_COMMITTED_SNAPSHOT).
-- Ex 3: RC/RCSI reader does not block RC/RCSI writer under RC/RCSI (because S locks 
--		 are not held until end of transaction).
/*
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRAN [TEST1a];

	DECLARE	@NVAL AS INT;

	UPDATE [dbo].[Test01]
		SET SVAL = N'one-UPD'
	WHERE	NVAL = 1;

	SELECT	*
	FROM	[dbo].[Test01];

ROLLBACK TRAN [TEST1a];
*/
;
-- Ex 4: RU writer blocks RU writer
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRAN [TEST2a];

	DECLARE	@NVAL AS INT;

	UPDATE [dbo].[Test01]
		SET SVAL = N'one-UPD'
	WHERE	NVAL = 1;

	SELECT	*
	FROM	[dbo].[Test01];

ROLLBACK TRAN [TEST2a];

-- Ex X: Deadlock.
/*
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN [DL_TEST1];

	DECLARE	@NVAL AS INT;

	SELECT	@NVAL = [NVAL]
	FROM	[dbo].[Test01]
	WHERE	SVAL = N'3';

	UPDATE [dbo].[Test01]
		SET NVAL = @NVAL
	WHERE	SVAL = N'1';

COMMIT TRAN [DL_TEST1];
*/

SELECT	'dm_exec_sessions', *
FROM	sys.dm_exec_sessions
WHERE	database_id = DB_ID(N'IMData')
		AND session_id IN (53, 57);

SELECT	'dm_tran_active_transactions', *
FROM	sys.dm_tran_active_transactions
WHERE	name LIKE N'UPD_TEST%';

SELECT	'dm_tran_database_transactions', *
FROM	sys.dm_tran_database_transactions
WHERE	database_id = DB_ID(N'IMData');

-- Best way to view locks and lock metadata.
SELECT	'dm_tran_locks', *
FROM	sys.dm_tran_locks
WHERE	resource_database_id = DB_ID(N'IMData')
		AND request_session_id IN (54, 55)
ORDER BY request_session_id
; --= @@SPID

-- Shows blocker session
SELECT	'dm_exec_requests'
		, SUBSTRING(sql.text, (r.statement_start_offset/2) + 1,
				((CASE r.statement_end_offset
					WHEN -1
					THEN DATALENGTH(sql.text)
					ELSE r.statement_end_offset
				END - r.statement_start_offset)/2) + 1) AS query_text
		, r.*
		, sql.*
FROM	sys.dm_exec_requests AS r
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sql
WHERE	r.session_id <> @@SPID;

SELECT	'DBlocks', *
FROM	dbo.DBlocks;

/*
DROP VIEW IF EXISTS dbo.DBlocks;
GO

-- Returns all locks in the current database
CREATE VIEW dbo.DBlocks 
AS
	SELECT	request_session_id as spid
			, db_name(resource_database_id) as dbname
			, CASE
				WHEN resource_type = 'OBJECT' THEN object_name(resource_associated_entity_id)
				WHEN resource_associated_entity_id = 0 THEN 'n/a'
				ELSE object_name(p.object_id)
			END as entity_name
			, index_id
			, resource_type
			, resource_description
			, request_mode
			, request_status
FROM	sys.dm_tran_locks t 
	LEFT JOIN sys.partitions p
		ON p.partition_id = t.resource_associated_entity_id
WHERE	resource_database_id = db_id();
GO

IF OBJECT_ID(N'[dbo].[Test01]', N'U') IS NOT NULL
	DROP TABLE [dbo].[Test01];
GO

CREATE TABLE [dbo].[Test01]
(
	NVAL	INT				NOT NULL
		PRIMARY KEY
	, SVAL	NVARCHAR(128)	NOT NULL
);

INSERT INTO [dbo].[Test01] ([NVAL], [SVAL])
VALUES (1, N'one'), (2, N'two'), (3, N'three');
*/
