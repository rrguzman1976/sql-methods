USE Sparse_Test;
GO

IF OBJECT_ID(N'dbo.tblWide', N'U') IS NOT NULL
	DROP TABLE dbo.tblWide; 
GO
IF EXISTS(SELECT * FROM sys.types WHERE name = N'myINT')
	DROP TYPE myINT;
GO

CREATE TYPE myINT FROM INT NULL;
GO

CREATE TABLE dbo.tblWide
(
	ID INT IDENTITY NOT NULL 
	, sparseCol1 NVARCHAR(24) SPARSE NULL 
	, sparseCol2 VARCHAR(24) SPARSE NULL 
	, sparseCol3 INT SPARSE NULL 
	, sparseCol4 NUMERIC(24, 6) SPARSE NULL 
	, sparseUDT myINT SPARSE NULL
	, sparseSet XML COLUMN_SET FOR ALL_SPARSE_COLUMNS 
)
ON [PRIMARY];
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE name = N'IDX_NC_TBLWIDE_SCOL1')
	DROP INDEX IDX_NC_TBLWIDE_SCOL1 ON dbo.tblWide;
GO

-- Filtered index
CREATE NONCLUSTERED INDEX IDX_NC_TBLWIDE_SCOL1
	ON dbo.tblWide(sparseCol1)
WHERE sparseCol1 IS NOT NULL
WITH
(
	FILLFACTOR = 100
)
ON [PRIMARY];
GO

INSERT INTO dbo.tblWide(sparseCol1, sparseCol2, sparseCol3, sparseCol4, sparseUDT)
VALUES	(N'sparse val 1', 'sparse val 2', 1, 4.5, 1);
GO
INSERT INTO dbo.tblWide(sparseSet)
VALUES	('<sparseCol1>value1</sparseCol1><sparseCol2>value2</sparseCol2>')
		, ('<sparseCol1>value1</sparseCol1><sparseCol2>value2</sparseCol2><sparseCol3>1</sparseCol3><sparseCol4>2.5</sparseCol4>')
		, ('<sparseCol1>value1</sparseCol1><sparseCol2>value2</sparseCol2><sparseCol3>1</sparseCol3><sparseCol4>2.5</sparseCol4>')
		, ('<sparseUDT>5</sparseUDT>');
GO

SELECT	*
FROM	dbo.tblWide
GO
SELECT	ID, sparseCol1, sparseCol2, sparseCol3, sparseCol4, sparseUDT
		, sparseSet
		, sparseSet.query('/sparseCol1') AS [xquery_is_supported]
FROM	dbo.tblWide;
GO
SELECT	sparseCol1
FROM	dbo.tblWide
WHERE	sparseCol1 = N'sparse val 1';
GO

SELECT	name, is_sparse, is_column_set
FROM	sys.columns
WHERE	object_id = OBJECT_ID(N'dbo.tblWide', N'U')

-- Clean up
IF OBJECT_ID(N'dbo.tblWide', N'U') IS NOT NULL
	DROP TABLE dbo.tblWide; 
GO
IF EXISTS(SELECT * FROM sys.types WHERE name = N'myINT')
	DROP TYPE myINT;
GO
