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

-- When using offset aware data types, SQL Server incorporates
-- timezones in calculations automatically.
DECLARE @Time1 datetimeoffset;
DECLARE @Time2 datetimeoffset;
DECLARE @MinutesDiff int;

SET @Time1 = '2012-02-10 09:15:00-05:00' -- NY time is UTC -05:00
SET @Time2 = '2012-02-10 09:15:00-08:00' -- LA time is UTC -08:00

SET @MinutesDiff = DATEDIFF(minute, @Time1, @Time2);

SELECT @MinutesDiff AS [tzDiff];