USE TSQL2012;
GO

/*-----------------------------------------------------
 * Built-in Function Semantics: 
 *
 * Use PARSE only for converting from string to date/time and number types. 
 * For general type conversions, continue to use CAST or CONVERT.
 *
 * All conversion functions have safe-versions TRY_CAST, TRY_CONVERT,
 * and TRY_PARSE.
 *-----------------------------------------------------*/

 -- The difference between cast and convert is that the latter
 -- accepts a style parameter that can be used with date,
 -- numeric, and xml types to interpret the expression using
 -- a format style.
SELECT 
   SYSDATETIME() AS UnconvertedDateTime,
   CAST(SYSDATETIME() AS nvarchar(30)) AS UsingCast,
   CONVERT(nvarchar(30), SYSDATETIME(), 126) AS UsingConvertTo_ISO8601;

-- Parse takes a string and converts to a specified data
-- type. It also accepts a culture parameter for locale
-- sensitivity.
SELECT PARSE('€345,98' AS money USING 'de-DE') AS Result;

-- Format is the opposite of parse and takes a data type
-- and returns a string representation in a specific format
-- and optionally according to a culture.
SELECT FORMAT($345.98, 'C', 'de-de') AS 'Currency Format'