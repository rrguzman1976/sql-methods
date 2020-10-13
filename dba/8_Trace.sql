USE ScratchDB;
GO

/************************************************************************
-- Use sys.dm_exec_requests to view plans for currently executing requests
-- and track down long-running queries.
-- Shows blocker session
 ************************************************************************/
SELECT	'Currently executing!'
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

SELECT	'dm_exec_sessions', *
FROM	sys.dm_exec_sessions
WHERE	database_id = DB_ID(N'ScratchDB');

-- View plan cache
-- For the reuse of ad hoc query plans, the entire batch must be identical (whitespace, case, etc.).
SELECT	DB_NAME(t.dbid) AS [database], p.usecounts, p.cacheobjtype, p.objtype
		, p.[size_in_bytes], t.[text]
FROM	sys.dm_exec_cached_plans AS p
	CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE	p.cacheobjtype LIKE 'Compiled Plan%'
		AND t.[text] NOT LIKE '%dm_exec_cached_plans%'
		AND t.dbid = DB_ID(N'ScratchDB');

IF OBJECT_ID(N'tempdb..#RKO_temp_trc', N'U') IS NOT NULL
	DROP TABLE #RKO_temp_trc;

-- Don't use underscore in trace file.
SELECT	* 
	INTO #RKO_temp_trc
FROM	fn_trace_gettable('C:\Users\rguzman\Documents\GitHub\sql-tuning\Sample004.trc', default) AS t; 

SELECT	*
FROM	#RKO_temp_trc;