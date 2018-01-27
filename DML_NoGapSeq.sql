USE TSQL2012;
GO

/*-----------------------------------------------------
 * DML Semantics: 
 *
 *-----------------------------------------------------*/

-- No gap sequence (uses assignment/update syntax)
IF OBJECT_ID('dbo.Sequences', 'U') IS NOT NULL DROP TABLE dbo.Sequences;
CREATE TABLE dbo.Sequences
(
	id VARCHAR(10) NOT NULL
		CONSTRAINT PK_Sequences PRIMARY KEY(id),
	val INT NOT NULL
);

INSERT INTO dbo.Sequences VALUES('SEQ1', 0);
GO

-- Get next seq
DECLARE @nextval AS INT;

UPDATE dbo.Sequences
	SET @nextval = val += 1 -- update + var assignment (atomic)
WHERE id = 'SEQ1';

SELECT @nextval;
GO
