USE AdventureWorks2017;
GO

-- Large object data smaller than 256 KB should be stored in a database, 
-- and data that’s 1 MB or larger should be stored in the file system.
-- Check for row overflow and LOB allocation units.

/*
 Page compression provides the most benefit for I/O-bound systems, with 
 tables for which the data is written once and then read repeatedly, as  
 with data warehousing and reporting. For environments with heavy read 
 and write activity, such as online transaction processing (OLTP) applications, 
 you might want to consider enabling row compression only and avoid the costs 
 of analyzing the pages and rebuilding the CI record. In this case, 
 the CPU overhead is minimal.
 */
SELECT	'Allocation Units'
		, object_name(i.object_id) AS table_name
		, i.name AS index_name
		, i.index_id
		, i.type_desc as index_type
		, p.partition_id
		, p.partition_number
		, p.rows
		, a.allocation_unit_id
		, a.type_desc as page_type_desc
		, a.total_pages
		, a.first_page
		, a.root_page 
		, a.first_iam_page
FROM	sys.indexes AS i 
	JOIN sys.partitions AS p
		ON	i.object_id = p.object_id 
			AND i.index_id = p.index_id
	JOIN sys.system_internals_allocation_units AS a -- undocumented
		ON	p.partition_id = a.container_id
WHERE	i.object_id = object_id(N'HumanResources.Employee');
GO

/* Parition metadata */
DROP FUNCTION IF EXISTS dbo.index_name;
GO

CREATE FUNCTION dbo.index_name (@object_id int, @index_id tinyint)
RETURNS sysname
AS
BEGIN
	DECLARE @index_name sysname
	SELECT @index_name = name FROM sys.indexes
	WHERE object_id = @object_id and index_id = @index_id
	RETURN(@index_name)
END;
GO

DROP VIEW IF EXISTS dbo.Partition_Info;
GO

CREATE VIEW dbo.Partition_Info 
AS
	SELECT OBJECT_NAME(i.object_id) as ObjectName,
	dbo.INDEX_NAME(i.object_id,i.index_id) AS IndexName,
	object_schema_name(i.object_id) as SchemaName,
	p.partition_number as PartitionNumber, fg.name AS FilegroupName, rows as Rows,
	au.total_pages as TotalPages,
	CASE boundary_value_on_right
	WHEN 1 THEN 'less than'
	ELSE 'less than or equal to'
	END as 'Comparison'
	, rv.value as BoundaryValue,
	CASE WHEN ISNULL(rv.value, rv2.value) IS NULL THEN 'N/A'
	ELSE
	CASE
	WHEN boundary_value_on_right = 0 AND rv2.value IS NULL
	THEN 'Greater than or equal to'
	WHEN boundary_value_on_right = 0
	THEN 'Greater than'
	ELSE 'Greater than or equal to' END + ' ' +
	ISNULL(CONVERT(varchar(15), rv2.value), 'Min Value')
	+ ' ' +
	+
	CASE boundary_value_on_right
	WHEN 1 THEN 'and less than'
	ELSE 'and less than or equal to'
	END + ' ' +
	+ ISNULL(CONVERT(varchar(15), rv.value),
	'Max Value')
	END as 'TextComparison'
	FROM sys.partitions p
	JOIN sys.indexes i
	ON p.object_id = i.object_id and p.index_id = i.index_id
	LEFT JOIN sys.partition_schemes ps
	ON ps.data_space_id = i.data_space_id
	LEFT JOIN sys.partition_functions f
	ON f.function_id = ps.function_id
	LEFT JOIN sys.partition_range_values rv
	ON f.function_id = rv.function_id
	AND p.partition_number = rv.boundary_id
	LEFT JOIN sys.partition_range_values rv2
	ON f.function_id = rv2.function_id
	AND p.partition_number - 1= rv2.boundary_id
	LEFT JOIN sys.destination_data_spaces dds
	ON dds.partition_scheme_id = ps.data_space_id
	AND dds.destination_id = p.partition_number
	LEFT JOIN sys.filegroups fg
	ON dds.data_space_id = fg.data_space_id
	JOIN sys.allocation_units au
	ON au.container_id = p.partition_id
	WHERE i.index_id <2 AND au.type =1;

