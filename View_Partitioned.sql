USE PView_Test;
GO

IF OBJECT_ID(N'dbo.sp_GetData', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_GetData;
GO

CREATE PROCEDURE dbo.sp_GetData
(
	@start INT
	, @end INT
)
WITH RECOMPILE, ENCRYPTION, EXECUTE AS SELF
AS
BEGIN
	WITH d
	AS
	(
		SELECT	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
				, CAST(NEWID() AS NVARCHAR(50)) AS VAL1
		FROM	sys.all_columns AS c1
			CROSS JOIN sys.all_columns AS c2
	)
	SELECT	*
	FROM	d
	WHERE	d.ID >= @start AND d.ID <= @end;
END
GO

IF OBJECT_ID(N'dbo.pView', N'V') IS NOT NULL
	DROP VIEW dbo.pView;
IF OBJECT_ID(N'dbo.pTable1', N'U') IS NOT NULL
	DROP TABLE dbo.pTable1;
IF OBJECT_ID(N'dbo.pTable2', N'U') IS NOT NULL
	DROP TABLE dbo.pTable2;
IF OBJECT_ID(N'dbo.pTable3', N'U') IS NOT NULL
	DROP TABLE dbo.pTable3;

-- CHECK constraints are required for optimizer to use the partitioned view.
CREATE TABLE dbo.pTable1
(
	ID INT NOT NULL
		PRIMARY KEY
	, VAL1 NVARCHAR(50) NULL
	, CHECK (ID >= 0 AND ID <= 10000)
);
GO

CREATE TABLE dbo.pTable2
(
	ID INT NOT NULL
		PRIMARY KEY
	, VAL1 NVARCHAR(50) NULL
	, CHECK (ID >= 10001 AND ID <= 20000)
);
GO

CREATE TABLE dbo.pTable3
(
	ID INT NOT NULL
		PRIMARY KEY
	, VAL1 NVARCHAR(50) NULL
	, CHECK (ID >= 20001 AND ID <= 30000)
);
GO

CREATE VIEW dbo.pView
--WITH SCHEMABINDING -- Not required
AS
	SELECT	ID, VAL1
	FROM	dbo.pTable1
	UNION ALL
	SELECT	ID, VAL1
	FROM	dbo.pTable2
	UNION ALL
	SELECT	ID, VAL1
	FROM	dbo.pTable3;
GO

INSERT INTO dbo.pTable1 (ID, VAL1)
EXEC dbo.sp_GetData @start = 1, @end = 10000;

INSERT INTO dbo.pTable2 (ID, VAL1)
EXEC dbo.sp_GetData @start = 10001, @end = 20000;

INSERT INTO dbo.pTable3 (ID, VAL1)
EXEC dbo.sp_GetData @start = 20001, @end = 30000;
GO

SET SHOWPLAN_ALL ON;
GO

SELECT	*
FROM	dbo.pView
WHERE	ID = 2345
;
GO
SET SHOWPLAN_ALL OFF;
