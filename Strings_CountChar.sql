USE TSQL2012;
GO

/*-----------------------------------------------------
 * String semantics
 * A collation is a set of rules that defines how character data is sorted 
 * and compared, and how language-dependent functions such as UPPER and 
 * LOWER work. The collation also determines the character repertoire for 
 * the single-byte data types: char, varchar, and text. Metadata in SQL 
 * Server—that is, names of tables, variables, and so forth—are also 
 * subject to collation rules.
 *-----------------------------------------------------*/

-- Count character occurrences.
SELECT	empid, lastname,
		LEN(lastname) - LEN(REPLACE(lastname, 'e', '')) AS numEoccur
FROM	HR.Employees;

-- Count multichar occurrences.
SELECT	empid, lastname,
		(LEN(lastname) - LEN(REPLACE(lastname, 'gopy', '')))/len('gopy') AS numEoccur
FROM	HR.Employees;