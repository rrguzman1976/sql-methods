USE TSQL2012;
GO

SELECT	*
FROM	sys.databases
WHERE	name = N'TSQL2012'; -- SIMPLE

SELECT	*
FROM	sys.database_recovery_status
WHERE	database_id = DB_ID(N'TSQL2012'); -- last_log_backup_lsn IS NULL => autotruncate mode

-- Check any open txns.
DBCC OPENTRAN;

-- 1. View current log size
DBCC SQLPERF('logspace'); 

-- 2. Check VLFs: Status 0 indicates reusable, 2 indicates active.
DBCC LOGINFO(N'TSQL2012'); -- 1 per VLF

/*
 * If a log is truncated without any shrink command issued, SQL Server 
 * marks the space used by the truncated records as available for reuse but 
 * doesn’t change the size of the physical file.
 */
-- 3. "TRUNCATES" - writes dirty pages and truncates the log (set VLFs to reusable)
CHECKPOINT; 

-- 4. !!!This physically truncates the log (VLF with status 0)!!!
DBCC SHRINKFILE([TSQL2012_log]);