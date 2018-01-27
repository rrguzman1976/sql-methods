USE MOT_Test;
GO

IF OBJECT_ID(N'dbo.MOT_Table', N'U') IS NOT NULL
	DROP TABLE dbo.MOT_Table;
GO
IF OBJECT_ID(N'rko.fn_AddTen', 'FN') IS NOT NULL
	DROP FUNCTION rko.fn_AddTen;
GO
IF EXISTS(SELECT * FROM sys.schemas WHERE name = N'rko') 
	DROP SCHEMA rko;
GO
IF EXISTS(SELECT * FROM sys.database_principals WHERE name = N'user1')
	DROP USER user1;
GO
CREATE USER user1 FROM LOGIN login1;
GO

-- Create schema with different owner than dbo.
CREATE SCHEMA rko AUTHORIZATION user1;
GO

-- Create UDF to be referenced in computed column.
CREATE FUNCTION rko.fn_AddTen
(
	@n INT
)
RETURNS INT
AS
BEGIN
	RETURN @n + 10;
END
GO

IF EXISTS(SELECT * FROM sys.types WHERE name = N'myINT')
	DROP TYPE myINT;
GO

CREATE TYPE myINT
FROM INT NOT NULL;
GO

-- MOT: Mother of all tables.
CREATE TABLE dbo.MOT_Table
(
	ID INT IDENTITY NOT NULL
	, sVAL NVARCHAR(48) NULL
	, rVAL REAL NULL
	, customTP myINT NULL
	-- ROWVERSION: For full treatment see /DataTypes/rowversion.sql
	, deltaCheck ROWVERSION NOT NULL
	-- Computed column, precise, deterministic
	, sVALCopy AS sVal + N' derived'
	-- Computed column, imprecise, deterministic
	, rVALCopy AS rVAL * 2 PERSISTED
	-- Computed column, imprecise, deterministic
	, rVALCopy2 AS rVAL * 2 
	-- Computed column, precise, non-deterministic
	, dtVALCopy AS CURRENT_TIMESTAMP
	-- Computed column can include alias types
	, customCopy AS customTP + 3
	-- Computed column can reference functions with different owner
	, fnCopy AS rko.fn_AddTen(10)
) ON [PRIMARY];
GO

-- Create indexed computed column. Must be deterministic, precise.
CREATE UNIQUE NONCLUSTERED INDEX IDX_MOT_SVALCP
ON dbo.MOT_Table(sVALCopy);
GO
-- If not precise, must be PERSISTED.
CREATE UNIQUE NONCLUSTERED INDEX IDX_MOT_RVALCP
ON dbo.MOT_Table(rVALCopy);
GO
-- Can index computed columns with alias types
CREATE UNIQUE NONCLUSTERED INDEX IDX_MOT_CUSTOM
ON dbo.MOT_Table(customCopy);
GO

-- If non-deterministic, cannot be indexed.
/*
CREATE UNIQUE NONCLUSTERED INDEX IDX_MOT_DTVALCP -- FAILS
ON dbo.MOT_Table(dtVALCopy);
GO
*/

-- Only PERSISTED computed columns can be used in FK or CHECK
ALTER TABLE dbo.MOT_Table
	ADD CONSTRAINT DFT_MOT_RVALCP CHECK (rVALCopy > 0); -- Succeeds
	--ADD CONSTRAINT DFT_MOT_RVALCP CHECK (rVALCopy2 > 0); -- Fails
GO

INSERT INTO dbo.MOT_Table (sVAL, customTP, rVAL)
VALUES	(N'Test computed column', 7, 1.0)
		--, (N'Test computed column', 7, -1.0); -- Test CHECK
GO

SELECT	*
FROM	dbo.MOT_Table;