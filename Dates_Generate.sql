USE ScratchDB;
GO

/*-----------------------------------------------------
 * Techniques for generating number sequences
 *-----------------------------------------------------*/
/*
IF OBJECT_ID(N'dbo.Nums', N'U') IS NOT NULL
	DROP TABLE dbo.Nums;
GO

CREATE TABLE dbo.Nums
(
	[n]		INT		NOT NULL	PRIMARY KEY
);

-- Population script for dbo.Nums
INSERT INTO dbo.Nums
select	rn 
from (	select row_number() over(order by current_timestamp) as rn
		from sys.trace_event_bindings as b1
			CROSS JOIN sys.trace_event_bindings as b2) as rd 
where rn <= 1000000;

-- Technique 2: Use a pre-generated sequence of numbers
SELECT	[n]
FROM	dbo.Nums;
*/

DECLARE @START DATETIME2 = '20080101';
DECLARE @END DATETIME2 = '20201231';

-- Use T2 to generate a date sequence
SELECT	CAST(FORMAT(DATEADD(day, n-1, @START), 'yyyyMMdd') AS INT) AS [DateDimID]
		, CAST(DATEADD(day, n-1, @START) AS DATE) AS [Date]
		, NULL AS [CalendarDay]
		, DATEPART(weekday, DATEADD(day, n-1, @START)) AS [DayOfWeek]
		, DATEPART(day, DATEADD(day, n-1, @START)) AS [DayOfMonth]
		, DATEDIFF(day, DATEADD(quarter, DATEDIFF(quarter, 0, DATEADD(day, n-1, @START)), 0), DATEADD(day, n-1, @START)) + 1 AS [DayOfQuarter]
		, DATEPART(dayofyear, DATEADD(day, n-1, @START)) AS [DayOfYear]
		, CAST(DATEADD(day, n-2, @START) AS DATE) AS [PreviousDay]
		, CAST(DATEADD(day, n, @START) AS DATE) AS [NextDay]
		, CAST(DATEADD(yy, -1, DATEADD(day, n-1, @START)) AS DATE) AS [SameDayPrevYear]
		, DATEPART(week, DATEADD(day, n-1, @START)) AS [WeekOfYear]
		, DATENAME(month, DATEADD(day, n-1, @START)) AS [CalendarMonth]
		, DATEPART(month, DATEADD(day, n-1, @START)) AS [MonthOfYear]
		, FORMAT(DATEADD(day, n-1, @START), 'MMMM_yyyy') AS [Month_Year]
		, FORMAT(DATEADD(day, n-1, @START), 'MM_yyyy') AS [MM_YYYY]
		, CAST(DATEADD(month, DATEDIFF(month, DATEADD(day, n-1, @START), CURRENT_TIMESTAMP), DATEADD(day, n-1, @START)) AS DATE) AS [MonthStart]
		, CAST(EOMONTH(DATEADD(day, n-1, @START)) AS DATE) AS [MonthEnd]
		, DATEPART(quarter, DATEADD(day, n-1, @START)) AS [QuarterOfYear]
		, FORMAT(DATEPART(quarter, DATEADD(day, n-1, @START)), 'Q#') + '_' +FORMAT(DATEADD(day, n-1, @START), 'yyyy') AS [Quarter_Year]
		, CAST(DATEADD(qq, DATEDIFF(qq, 0, DATEADD(day, n-1, @START)), 0) AS DATE) AS [QuarterStart]
		, CAST(DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, DATEADD(day, n-1, @START)) +1, 0)) AS DATE) AS [QuarterEnd]
		, DATEPART(year, DATEADD(day, n-1, @START)) AS [CalendarYear]
		, CAST(DATEADD(yy, DATEDIFF(yy, 0, DATEADD(day, n-1, @START)), 0) AS DATE) AS [YearStart]
		, CAST(DATEADD (dd, -1, DATEADD(yy, DATEDIFF(yy, 0, DATEADD(day, n-1, @START)) +1, 0)) AS DATE) AS [YearEnd]
		, CASE DATEPART(weekday, DATEADD(d, @@DATEFIRST - 1, DATEADD(day, n-1, @START))) 
			WHEN 6 THEN 1
			WHEN 7 THEN 1
			ELSE 0
		END AS [IsWeekend]
		, NULL AS [IsHoliday]
		, FORMAT(DATEADD(day, n-1, @START), 'MM_dd_yyyy') AS [MM_DD_YYYY]
		, CAST(DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, DATEADD(day, n-1, @START)), DATEDIFF(dd, 0, DATEADD(day, n-1, @START)))) AS DATE) AS [WeekStart]
		, CAST(DATEADD(wk, 1, DATEADD(DAY, 0-DATEPART(WEEKDAY, DATEADD(day, n-1, @START)), DATEDIFF(dd, 0, DATEADD(day, n-1, @START)))) AS DATE) AS [WeekEnd]
		, NULL AS [ScorecardReportingDate]
FROM	dbo.Nums
WHERE	[n] <= DATEDIFF(day, @START, @END) + 1
ORDER BY [n];