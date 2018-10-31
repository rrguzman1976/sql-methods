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


-- Get first day of current month.
SELECT	DATEADD(
			month,
			DATEDIFF(month, '20010101', CURRENT_TIMESTAMP), '20010101')
		-- OR
		, dateadd(day, -day(getdate()) + 1, getdate());
