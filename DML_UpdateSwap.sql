USE TSQL2012;
GO

/*-----------------------------------------------------
 * DML Semantics: 
 *
 *-----------------------------------------------------*/

-- Swap elements (relies on all at once evaluation property)
DECLARE @tmp AS TABLE
(
	VAL1	VARCHAR(10)
	, VAL2	VARCHAR(10)
);

INSERT INTO @tmp VALUES ('A', 'B'), ('C', 'D');

UPDATE	@tmp
	SET VAL1 = VAL2
		, VAL2 = VAL1;
GO
