USE ScratchDB;
GO

DECLARE @year INT = 2018
DECLARE @start DATETIME2(2) = DATEFROMPARTS(1900, 2, 1)

-- Takes into account leap years
select	datediff(d, curr_year, dateadd(yy, 1, curr_year))
		, curr_year
		, getdate()
from (
	select	dateadd(d
					, -datepart(dy, DATEADD(yy, ID, @start)) + 1 -- subtract days up until cur date
					, DATEADD(yy, ID, @start)) curr_year
	from	t100
) x