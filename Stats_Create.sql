USE master;
GO

-- Applies only to single column statistics used as SARGs
ALTER DATABASE Stats_Test
SET	AUTO_CREATE_STATISTICS ON 
	, AUTO_UPDATE_STATISTICS ON 
	-- Wait/Don't for latest statistics updates on recompilations
	, AUTO_UPDATE_STATISTICS_ASYNC OFF 
;
GO

SELECT	is_auto_create_stats_on, is_auto_update_stats_on, is_auto_update_stats_async_on
FROM	sys.databases
WHERE	name = N'Stats_Test';

USE Stats_Test;
GO
/*
IF OBJECT_ID(N'dbo.tblStatsTest', N'U') IS NOT NULL
	DROP TABLE dbo.tblStatsTest;
GO

CREATE TABLE dbo.tblStatsTest
(
	ID INT NOT NULL
	, sVal1 NVARCHAR(64) NULL
	, sValCorrelated NVARCHAR(64) NULL
);
GO

INSERT INTO dbo.tblStatsTest (ID, sVal1, sValCorrelated)
EXEC sp_GenData @n = 600;
GO
*/
----------------------------------------------------------------------------------------
-- Example 1: Verify creation of single column (SARG) stats objects.
----------------------------------------------------------------------------------------

-- This query generates a statistic on sVal1.
-- The cached plan for this query references the single column stat. Therefore,
-- change thresholds will trigger auto stats updates when this query is re-executed.
SELECT	ID, sVal1, sValCorrelated
FROM	dbo.tblStatsTest
WHERE	sVal1 IS NOT NULL;

----------------------------------------------------------------------------------------
-- Example 2: Insert threshold rows and verify auto update of stats objects.
-- On index creation, statistics on the key columns are created automatically. If more
-- than one column is indexed, correlation statistics (densities) are also created.
-- They are automatically maintained and kept up to date subject to:
--		STATISTICS_NORECOMPUTE Index option
--		NORECOMPUTE Statistics option
-- And:
-- Auto-update is triggered if the stats object is referenced in a plan during
-- recompilation and the stats object is out of date.
----------------------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX IDX_C_STATSTEST_ID
	ON dbo.tblStatsTest (ID)
WITH
(
	STATISTICS_NORECOMPUTE = OFF
)
ON [PRIMARY];
GO

-- The plan for this UPDATE references the IDX_C_STATSTEST_ID auto-created statistics
-- object and therefore it will trigger an auto-stats update if change thresholds are
-- reached.
UPDATE dbo.tblStatsTest
SET ID = 21
WHERE	ID = 1;

----------------------------------------------------------------------------------------
-- Example 3: Create manual stats, and update manually.
----------------------------------------------------------------------------------------

-- Manually create statistics when columns are correlated and are not contained
-- in a composite index.
CREATE STATISTICS STA_STATS_VALCORR
	ON dbo.tblStatsTest (sVal1, sValCorrelated)
WITH FULLSCAN;
GO
-- Manually create statistics when a table is partitioned. Use filtered statistics
-- to match the subset of data in a single partition so that they are tailored to
-- the specific data distribution for each partition.
-- Also, manually create statistics to match any unique data distributions that are
-- not captured by index or single-column statistics
CREATE STATISTICS STA_STATS_FILTER
	ON dbo.tblStatsTest (sValCorrelated)
WHERE sVal1 = N'Janet';
GO
-- Update statistics if changes have been made to the underlying tables but not enough
-- to trigger automatic statistics updates (1, 500 rows, 500 + 20%)
-- Also, update statistics manually to avoid plan recompilations having to wait for the
-- stats update (assuming change thresholds are reached).

UPDATE STATISTICS dbo.tblStatsTest
WITH RESAMPLE
	, ALL;
GO
-- Updates both SARG stats and manually created stats.
UPDATE STATISTICS dbo.tblStatsTest
WITH RESAMPLE
	, COLUMNS
GO
UPDATE STATISTICS dbo.tblStatsTest
WITH RESAMPLE
	, INDEX
GO
UPDATE STATISTICS dbo.tblStatsTest ( IDX_C_STATSTEST_ID ) -- index
WITH SAMPLE 100 PERCENT;
GO
UPDATE STATISTICS dbo.tblStatsTest ( [_WA_Sys_00000002_300424B4] ) -- stats object
WITH FULLSCAN;
GO

-- Check statistics
SELECT	s.name, u.*
FROM	sys.stats AS s
	OUTER APPLY sys.dm_db_stats_properties (s.object_id, s.stats_id) AS u
WHERE	u.object_id = OBJECT_ID(N'dbo.tblStatsTest', N'U');
GO

SELECT	t.name AS [table]
		, s.name, s.stats_id, s.auto_created, s.user_created
		, s.no_recompute, s.has_filter, s.filter_definition
		, c.name, STATS_DATE(s.object_id, s.stats_id) AS Last_Update
FROM	sys.stats AS s
	LEFT JOIN sys.stats_columns AS sc
		ON	s.object_id = sc.object_id
			AND s.stats_id = sc.stats_id
	LEFT JOIN sys.columns AS c
		ON	sc.object_id = c.object_id
			AND sc.column_id = c.column_id
	LEFT JOIN sys.tables AS t
		ON	s.object_id = t.object_id
WHERE	t.type = N'U'; -- only user tables
GO

-- Target can be column, statistic, or index
/*
DBCC SHOW_STATISTICS ([dbo.tblStatsTest], ID) 
WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM;
GO
DBCC SHOW_STATISTICS ([dbo.tblStatsTest], [_WA_Sys_00000002_300424B4])
WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM;
GO
DBCC SHOW_STATISTICS ([dbo.tblStatsTest], IDX_NC_STATSTEST_ID) 
WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM;
GO

-- Utility function
IF OBJECT_ID(N'dbo.sp_GenData', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_GenData;
GO

CREATE PROCEDURE dbo.sp_GenData
(
	@n INT
)
AS
BEGIN
	SELECT	TOP (@n)
			ROW_NUMBER() OVER (ORDER BY c.object_id) AS ID
			, CASE ROW_NUMBER() OVER (ORDER BY c.object_id) % 10
				WHEN 1 THEN N'Ricardo'
				WHEN 2 THEN N'John'
				WHEN 3 THEN N'Steve'
				WHEN 4 THEN N'Robert'
				WHEN 5 THEN N'Daniel'
				ELSE N'Janet'
			END AS sVal1
			, CASE ROW_NUMBER() OVER (ORDER BY c.object_id) % 10
				WHEN 1 THEN N'Guzman'
				WHEN 2 THEN N'Elway'
				WHEN 3 THEN N'McNair'
				WHEN 4 THEN N'McNamara'
				WHEN 5 THEN N'Steele'
				ELSE N'Evans'
			END AS sValCorrelated
	FROM	sys.all_columns AS c
		CROSS JOIN sys.all_columns AS c2
	ORDER BY c.object_id
END
GO
*/