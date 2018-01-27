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

-- Remove date component
SELECT	CAST(CURRENT_TIMESTAMP AS TIME(1));
SELECT	CAST(CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114) AS DATETIME2);
