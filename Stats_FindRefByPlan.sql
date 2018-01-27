-- In his post, Statistics used in a cached query plan, Fabiano Neves Amorim describes
-- a method to capture statistics information from the plan
-- http://blogfabiano.com/2012/07/03/statistics-used-in-a-cached-query-plan/

DBCC TRACEON (8666);
GO
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as p)
SELECT	qt.text AS SQLCommand,
		qp.query_plan,
		StatsUsed.XMLCol.value('@FieldValue','NVarChar(500)') AS StatsName
FROM	sys.dm_exec_cached_plans cp
	OUTER APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
	OUTER APPLY sys.dm_exec_sql_text (cp.plan_handle) qt
	OUTER APPLY qp.query_plan.nodes('//p:Field[@FieldName="wszStatName"]') StatsUsed(XMLCol)
WHERE	qt.text LIKE '%dbo.tblStatsTest%'
		AND qt.text NOT LIKE '%sys.dm_exec_cached_plans%'
		AND qt.text NOT LIKE '%sys.stats%';
GO
DBCC TRACEOFF(8666);

GO
