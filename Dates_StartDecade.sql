USE ScratchDB;

-- Find beginning of a decade for a give date

DECLARE @DT1 DATETIME2(2) = '20181031';

SELECT	YEAR(@DT1) - YEAR(@DT1)%10;