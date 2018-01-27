USE QR_SQL;
GO

SELECT	DISTINCT 
		object_name(object_id) as TableName
		, ISNULL(ps.name, 'Not partitioned') as PartitionScheme
FROM sys.indexes i 
	LEFT JOIN sys.partition_schemes ps
		ON	i.data_space_id = ps.data_space_id
WHERE	i.object_id = object_id('dbo.partTableTest')
		AND i.index_id IN (0,1);

-- Partition_Info 
SELECT	OBJECT_NAME(i.object_id) as ObjectName
		--, dbo.INDEX_NAME(i.object_id,i.index_id) AS IndexName
		, object_schema_name(i.object_id) as SchemaName
		, p.partition_number as PartitionNumber
		, fg.name AS FilegroupName
		, rows as Rows
		, au.total_pages as TotalPages
		, CASE boundary_value_on_right
			WHEN 1 THEN 'less than'
			ELSE 'less than or equal to'
		END as [Comparison]
		, rv.value as BoundaryValue
		, CASE 
			WHEN ISNULL(rv.value, rv2.value) IS NULL THEN 'N/A'
			ELSE
				CASE
					WHEN boundary_value_on_right = 0 AND rv2.value IS NULL
						THEN 'Greater than or equal to'
					WHEN boundary_value_on_right = 0
						THEN 'Greater than'
					ELSE 'Greater than or equal to' 
				END + ' ' +
				ISNULL(CONVERT(varchar(15), rv2.value), 'Min Value')
				+ ' ' +
				+
				CASE boundary_value_on_right
					WHEN 1 THEN 'and less than'
					ELSE 'and less than or equal to'
				END + ' ' +
				+ ISNULL(CONVERT(varchar(15), rv.value),
				'Max Value')
		END as [TextComparison]
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
WHERE	i.index_id < 2 AND au.type = 1 -- show clustered index only
		AND OBJECT_NAME(i.object_id) IN (N'partTableTest', N'partTableTest_Aux')
ORDER BY ObjectName, PartitionNumber;

-- Storage details
SELECT	convert(char(25),object_name(object_id)) AS name
		, rows
		, convert(char(15),type_desc) as page_type_desc
		, total_pages AS pages
		, first_page
		, index_id
		, partition_number
FROM	sys.partitions p 
	JOIN sys.system_internals_allocation_units a
		ON p.partition_id = a.container_id
WHERE	(object_id = object_id('dbo.partTableTest')
			OR object_id = object_id('dbo.partTableTest_Aux'))
		AND index_id = 1 
		AND partition_number <= 2;