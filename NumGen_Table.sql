USE TSQL2012;
GO

/*-----------------------------------------------------
 * Techniques for generating number sequences
 *-----------------------------------------------------*/

-- Technique 2: Use a pre-generated sequence of numbers
SELECT	[n]
FROM	dbo.Nums;

-- Use T2 to generate a date sequence
SELECT	DATEADD(day, n-1, '20060101') AS orderdate
FROM	dbo.Nums
WHERE	n <= DATEDIFF(day, '20060101', '20081231') + 1
ORDER BY orderdate;

-- Population script for dbo.Nums
select	rn 
from (	select row_number() over(order by current_timestamp) as rn
		from sys.trace_event_bindings as b1
			CROSS JOIN sys.trace_event_bindings as b2) as rd 
where rn <= 5000000