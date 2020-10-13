USE AdventureWorks2017;
GO

-- View cache store bucket count - each bucket can contain 0 to many cached plans.
SELECT	type as 'plan cache store', buckets_count
FROM	sys.dm_os_memory_cache_hash_tables
WHERE	type IN ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP',
				'CACHESTORE_PHDR', 'CACHESTORE_XPROC');

-- Cache store sizes
SELECT	type AS Store, SUM(pages_in_bytes/1024.) AS KB_used
FROM	sys.dm_os_memory_objects
WHERE	type IN ('MEMOBJ_CACHESTOREOBJCP', 'MEMOBJ_CACHESTORESQLCP',
				'MEMOBJ_CACHESTOREXPROC', 'MEMOBJ_SQLMGR')
GROUP BY type;
GO

-- The relationship between sql_handle and plan_handle is 1:N.
SELECT	plan_handle, pvt.set_options, pvt.object_id, pvt.sql_handle
FROM	(SELECT plan_handle, epa.attribute, epa.value
		FROM sys.dm_exec_cached_plans
			OUTER APPLY sys.dm_exec_plan_attributes(plan_handle) AS epa
		WHERE cacheobjtype = 'Compiled Plan'
) AS ecpa
	PIVOT (MAX(ecpa.value) FOR ecpa.attribute
		IN ("set_options", "object_id", "sql_handle")) AS pvt;
GO

DBCC FREEPROCCACHE;
SET QUOTED_IDENTIFIER OFF; -- non-default
GO
-- this is an example of the relationship between
-- sql_handle and plan_handle
SELECT LastName, FirstName, Title
FROM Person.Person
WHERE PersonType = 'EM';
GO
SET QUOTED_IDENTIFIER ON; -- default
GO
-- this is an example of the relationship between
-- sql_handle and plan_handle
SELECT LastName, FirstName, Title
FROM Person.Person
WHERE PersonType = 'EM';
GO
SELECT st.text, qs. sql_handle, qs.plan_handle
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(sql_handle) st;
GO

-- Inspect all plan text:
SELECT	st.text, cp.plan_handle, cp.usecounts, cp.size_in_bytes,
		cp.cacheobjtype, cp.objtype
FROM	sys.dm_exec_cached_plans cp
	CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
ORDER BY cp.usecounts DESC;

-- Find dependent plans:
SELECT	text, plan_handle, d.usecounts, d.cacheobjtype
FROM	sys.dm_exec_cached_plans
	CROSS APPLY sys.dm_exec_sql_text(plan_handle)
	CROSS APPLY sys.dm_exec_cached_plan_dependent_objects(plan_handle) d;
GO

/************************************************************************
-- Use sys.dm_exec_requests to view plans for currently executing requests
-- and track down long-running queries.
 ************************************************************************/
SELECT	TOP (10)
		'Currently executing!'
		, SUBSTRING(text, (statement_start_offset/2) + 1,
				((CASE statement_end_offset
					WHEN -1
					THEN DATALENGTH(text)
					ELSE statement_end_offset
				END - statement_start_offset)/2) + 1) AS query_text
		, *
FROM	sys.dm_exec_requests
	CROSS APPLY sys.dm_exec_sql_text(sql_handle)
WHERE	session_id <> @@SPID
ORDER BY total_elapsed_time DESC;

/************************************************************************
-- Use sys.dm_exec_query_stats to return performance information for individual 
-- queries within a batch. This view returns performance statistics for queries, 
-- aggregated across all executions of the same query.
-- Use sys.dm_exec_procedure_stats for stored procedure plans.
 ************************************************************************/
SELECT	TOP (10)
		'Most expensive!'
		, total_elapsed_time/execution_count AS [Rank]
		, SUBSTRING(text, (statement_start_offset/2) + 1,
			((CASE statement_end_offset
				WHEN -1
				THEN DATALENGTH(text)
				ELSE statement_end_offset
			END - statement_start_offset)/2) + 1) AS query_text
		, *
FROM	sys.dm_exec_query_stats
	CROSS APPLY sys.dm_exec_sql_text(sql_handle)
	CROSS APPLY sys.dm_exec_query_plan(plan_handle)
ORDER BY total_elapsed_time/execution_count DESC;
GO

-- Any objects with a name starting with sp_, created in the master database, 
-- can be accessed from any database without having to qualify the object name fully.
USE master
GO

IF OBJECT_ID(N'dbo.sp_cacheobjects', N'V') IS NOT NULL
	 DROP VIEW dbo.sp_cacheobjects;
GO

CREATE VIEW dbo.sp_cacheobjects
AS
SELECT pvt.bucketid,
CONVERT(nvarchar(18), pvt.cacheobjtype) AS cacheobjtype,
pvt.objtype,
CONVERT(int, pvt.objectid) AS objid,
CONVERT(smallint, pvt.dbid) AS dbid,
CONVERT(smallint, pvt.dbid_execute) AS dbidexec,
CONVERT(smallint, pvt.user_id) AS uid,
pvt.refcounts, pvt.usecounts,
pvt.size_in_bytes / 8192 AS pagesused,
CONVERT(int, pvt.set_options) AS setopts,
CONVERT(smallint, pvt.language_id) AS langid,
CONVERT(smallint, pvt.date_format) AS dateformat,
CONVERT(int, pvt.status) AS status,
CONVERT(bigint, 0) as lasttime,
CONVERT(bigint, 0) as maxexectime,
CONVERT(bigint, 0) as avgexectime,
CONVERT(bigint, 0) as lastreads,
CONVERT(bigint, 0) as lastwrites,
CONVERT(int, LEN(CONVERT(nvarchar(max), fgs.text)) * 2) as sqlbytes,
CONVERT(nvarchar(3900), fgs.text) as sql
FROM (SELECT ecp.*, epa.attribute, epa.value
FROM sys.dm_exec_cached_plans ecp
OUTER APPLY
sys.dm_exec_plan_attributes(ecp.plan_handle) epa) AS ecpa
PIVOT (MAX(ecpa.value) for ecpa.attribute IN
("set_options", "objectid", "dbid",
"dbid_execute", "user_id", "language_id",
"date_format", "status")) AS pvt
OUTER APPLY sys.dm_exec_sql_text(pvt.plan_handle) fgs;
GO

SELECT	*
FROM	dbo.sp_cacheobjects;

USE AdventureWorks2017;
GO

-- To determine that plan-caching behavior is causing problems, one of the first things 
-- to look at is wait statistics.
/* Look for 
	CMEMTHREAD, 
	SOS_RESERVEDMEMBLOCKLIST: convert IN lists to temp table joins, 
	RESOURCE_SEMAPHORE_QUERY_COMPILE */
SELECT	*
FROM	sys.dm_os_wait_stats
ORDER BY waiting_tasks_count DESC;
GO

/************************************************************************
-- A variable isn’t the same as a parameter, even though they are written the same way. 
-- Because a procedure is compiled only when it’s being executed, SQL Server always uses 
-- a specific parameter value. Problems arise when the previously compiled plan is then 
-- used for different parameters. However, for a local variable, the value is never 
-- known when the statements using the variable are compiled, unless the RECOMPILE hint 
-- is used.
-- Avoid local variables when passing values to a query in a sproc. Try to use the
-- sproc parameters or use OPTION (RECOMPILE) on the query itself.
************************************************************************/

-- Plan guides, introduced in SQL Server 2005, provide a solution by giving you a 
-- mechanism to add hints to a query without changing the query itself.

-- Plan freezing: the procedure sp_create_plan_guide_from_handle creates a plan guide using 
-- the execution plan stored in cache for that plan_handle value. The capability is called 
-- plan freezing because it allows you to ensure that a well-performing plan is reused 
-- every time the associated query is executed.
