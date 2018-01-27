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

-- String padding (Option 1)
SELECT	supplierid,
		RIGHT(REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)), 10) AS strsupplierid
FROM	Production.Suppliers;

-- String padding (Option 2)
-- Uses standard .NET format strings.
SELECT	supplierid,
		FORMAT(supplierid, 'd10') AS strsupplierid
FROM	Production.Suppliers;