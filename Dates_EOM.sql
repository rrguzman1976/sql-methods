USE TSQL2012;
GO

/*-----------------------------------------------------
 * Date semantics
 * The date, time, datetime2, and datetimeoffset types 
 * are four date and time data types that were introduced 
 * in SQL Server 2008 and should be used for all new 
 * database development in lieu of datetime and smalldatetime 
 * data types.
 * Also, always use SYSDATETIME, SYSUTCDATE, and SYSDATETIMEOFFSET
 * functions.
 *-----------------------------------------------------*/

-- Get last day of current month (or EOMONTH).
SELECT	DATEADD(
			month,
			DATEDIFF(month, '19991231', CURRENT_TIMESTAMP), '19991231');

-- Get number of days in a month.
SELECT DATEPART(day, EOMONTH('2/1/2012')) AS DaysInFeb2012

