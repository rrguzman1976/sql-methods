USE [TSQL2012]
GO

/*-----------------------------------------------------
 * XML Semantics: 
 * If the XML data is to be accessed by an OLTP system, then
 * it is more efficient to shred it into a normalized schema.
 * In cases, where the data is to stored/retrieved as XML
 * (web application, etc.), then storing the XML as an XML type
 * is more appropriate.
 *
 * Finally, the XML type can be used to implement a flexible
 * schema without using the property table "anti-pattern".
 *
 *-----------------------------------------------------*/

DECLARE @printout VARCHAR(MAX);

-- No XML
SELECT	@printout = COALESCE(@printout + ',', '') + [categoryname]
FROM	[Production].[Categories];

SELECT	@printout AS [Flattened];

-- Concatenate rows into a single column
SELECT	'Flatten' AS x
		, STUFF(
			(SELECT	',' + [categoryname] AS [data()]
			FROM	[Production].[Categories]
			FOR XML PATH('')), 1, 1, '') AS [Flattened];

-- Option 2 using XQuery FLWOR expression
SELECT
	(SELECT	[categoryname] AS [categoryname] 
	FROM	[Production].[Categories]
	FOR XML PATH('category'), ROOT('categories'), TYPE
	).query('
		for $s in /categories/category
		let $n := data($s/categoryname)
		let $p := concat($n[1], ",")
		return $p') AS [Flattened];

-- Option 3 using XQuery data() method
SELECT
	(SELECT	',' + [categoryname] AS [categoryname] 
	FROM	[Production].[Categories]
	FOR XML PATH('category'), ROOT('categories'), TYPE
	).query('data(*)') AS [Flattened];
