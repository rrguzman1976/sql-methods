USE ScratchDB;
GO

-- View all locks
EXEC sp_lock;

-- Or:
SELECT	DB_NAME(resource_database_id), *
FROM	sys.dm_tran_locks;

--DBCC MEMORYSTATUS;

-- Cardinality estimate variance.
SET STATISTICS PROFILE ON;
SELECT * FROM sys.objects;
SET STATISTICS PROFILE OFF;
