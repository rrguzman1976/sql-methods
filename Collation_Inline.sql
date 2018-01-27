USE TSQL2012;
GO

/*-----------------------------------------------------
 * Collation semantics
 *-----------------------------------------------------*/

SELECT	empid, firstname, lastname
FROM	HR.Employees
WHERE	lastname = N'davis';

-- Override CI collation at the database level.
SELECT	empid, firstname, lastname
FROM	HR.Employees
WHERE	lastname COLLATE Latin1_General_CS_AS = N'davis';