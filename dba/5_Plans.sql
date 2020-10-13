USE AdventureWorks2017;
GO

-- Use to save an initial plan stub for ad hoc queries. Can save proc cache space
-- when most ad hoc queries have one time use.
-- In general, you have no reason not to keep this option set to 1.
/*
EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;
GO
EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE;
GO
*/

-- Clear plan cache
DBCC FREEPROCCACHE;
GO
-- Plan reuse example.
GO

SELECT * FROM Person.Person WHERE LastName = 'Raheem';
GO

SELECT * FROM Person.Person WHERE LastName = 'Raheem';
GO

SELECT * FROM Person.Person WHERE LastName = 'Raheem';
GO

SELECT * FROM Person.Person WHERE LastName = 'Garcia';
GO

-- View plan cache
-- For the reuse of ad hoc query plans, the entire batch must be identical (whitespace, case, etc.).
SELECT	DB_NAME(t.dbid) AS [database], p.usecounts, p.cacheobjtype, p.objtype
		, p.[size_in_bytes], t.[text]
FROM	sys.dm_exec_cached_plans AS p
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
WHERE	p.cacheobjtype LIKE 'Compiled Plan%'
		AND t.[text] NOT LIKE '%dm_exec_cached_plans%';
GO

-- Simple parameterization
DBCC FREEPROCCACHE;
GO
SELECT FirstName, LastName, Title FROM Person.Person WHERE BusinessEntityID = 6;
GO
SELECT FirstName, LastName, Title FROM Person.Person WHERE BusinessEntityID = 2;
GO

SELECT	DB_NAME(t.dbid) AS [database], p.usecounts, p.cacheobjtype, p.objtype
		, p.[size_in_bytes], t.[text]
FROM	sys.dm_exec_cached_plans AS p
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
WHERE	p.cacheobjtype LIKE 'Compiled Plan%'
		AND t.[text] NOT LIKE '%dm_exec_cached_plans%';
GO

IF OBJECT_ID(N'dbo.P_Type_Customers', N'P') IS NOT NULL
	DROP PROCEDURE dbo.P_Type_Customers;
GO

-- Force plan recompilation (mitigate against parameter sniffing)
-- FYI: Running sp_recompile on a procedure, trigger, or function clears all the 
-- plans for the executable object out of cache to guarantee that the next time 
-- it’s executed, it will be recompiled.
CREATE PROCEDURE dbo.P_Type_Customers
	@custtype nchar(2)
AS
	SELECT BusinessEntityID, Title, FirstName, Lastname
	FROM Person.Person
	WHERE PersonType = @custtype;
GO
DBCC FREEPROCCACHE;
GO
SET STATISTICS IO ON;
GO
EXEC dbo.P_Type_Customers 'EM';
GO
EXEC dbo.P_Type_Customers 'IN';
GO
EXEC dbo.P_Type_Customers 'IN' WITH RECOMPILE;
GO
SET STATISTICS IO OFF;
GO
SELECT	DB_NAME(t.dbid) AS [database], p.usecounts, p.cacheobjtype, p.objtype
		, p.[size_in_bytes], t.[text]
FROM	sys.dm_exec_cached_plans AS p
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
WHERE	p.cacheobjtype LIKE 'Compiled Plan%'
		AND t.[text] NOT LIKE '%dm_exec_cached_plans%';
GO
