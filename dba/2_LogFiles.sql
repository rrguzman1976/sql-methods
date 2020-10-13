USE AdventureWorks2017;
GO

-- Database should have multiple data files in proportion to the number of processors.
-- Each file should be identical in initial size and growth increments.
SELECT	*
FROM	sys.database_files;

SELECT	name, recovery_model_desc
FROM	sys.databases;
GO

ALTER DATABASE SSISDB
	SET RECOVERY SIMPLE;
GO

-- Open transactions?
DBCC OPENTRAN;

-- View log size.
DBCC SQLPERF('logspace');
GO

-- Or:
SELECT	instance_name as [Database]
		, cntr_value as "LogFullPct"
FROM	sys.dm_os_performance_counters
WHERE	counter_name LIKE 'Percent Log Used%'
		AND instance_name not in ('_Total', 'mssqlsystemresource')
		AND cntr_value > 0;
GO

-- View log file VLFs. A status of 2 means that it’s either active or recoverable; 
-- a status of 0 indicates that it’s reusable or completely unused.
-- Try to keep the number of VLFs to no more than a few hundred, with possibly 
-- 1,000 as an upper limit.
DROP TABLE IF EXISTS dbo.sp_LOGINFO;
GO

CREATE TABLE dbo.sp_LOGINFO
(
	RecoveryUniteID int,
	FileId tinyint,
	FileSize bigint,
	StartOffset bigint,
	FSeqNo int,
	Status tinyint,
	Parity tinyint,
	CreateLSN numeric(25,0) 
);
GO

INSERT INTO sp_LOGINFO
EXEC ('DBCC LOGINFO');
GO

SELECT	'DBCC LOGINFO', *
FROM	dbo.sp_LOGINFO
ORDER BY CASE FSeqNo 
			WHEN 0 THEN 9999999 
		ELSE FSeqNo END;