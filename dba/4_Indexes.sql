USE AdventureWorks2017;
GO

/*
	The clustered key ordering of the rows is indicated by the slot number 
	of the row, not by the physical position on the page. If a table has a 
	clustered index, the row at slot 1 always has a key value less than the 
	row at slot 2 and greater than the row at slot 0. Only the slot numbers 
	are rearranged, not the data. This is an optimization, so only a small 
	number of offsets are rearranged instead of the entire page’s contents. 
	That rows in an index are always stored in the exact same physical order 
	as their keys is a myth—in fact, SQL Server can store the rows anywhere 
	on a page so long as the slot array provides the correct logical ordering.
*/
--EX: PRIMARY KEY CLUSTERED ([AddressID] ASC)
-- NONCLUSTERED INDEX [IX_Address_StateProvinceID] ([StateProvinceID] ASC)
SELECT	AddressID
		, AddressLine1
		, AddressLine2
		, City
		, StateProvinceID -- INDEX 4
		, PostalCode
FROM	Person.Address
WHERE	AddressID = 21
		--StateProvinceID = 79
ORDER BY AddressID;
GO

-- Clustered keys should be unique, narrow, and static.
SELECT	'dm_db_index_physical_stats'
		, DB_NAME(s.database_id) AS [database]
		, OBJECT_NAME(s.object_id) AS [table]
		--, s.index_id
		, i.name
		, s.partition_number
		, s.index_type_desc
		, s.alloc_unit_type_desc
		, s.index_depth
		, s.index_level
		, s.avg_fragmentation_in_percent
		--, fragment_count
		--, avg_fragment_size_in_pages
		, s.page_count
		, s.avg_page_space_used_in_percent
		, s.record_count
		/*, ghost_record_count
		, version_ghost_record_count
		, min_record_size_in_bytes
		, max_record_size_in_bytes
		, avg_record_size_in_bytes
		, forwarded_record_count
		, compressed_page_count
		, hobt_id
		, columnstore_delete_buffer_state
		, columnstore_delete_buffer_state*/
FROM	sys.dm_db_index_physical_stats (DB_ID(N'AdventureWorks2017')
										, OBJECT_ID (N'AdventureWorks2017.Person.Address')
										, 1, NULL, N'DETAILED') AS s
	INNER JOIN sys.indexes AS i
		ON	s.object_id = i.object_id
			AND s.index_id = i.index_id;

-- Undocumented: The function returns a row for every page used or allocated.
-- index_id: is 0 for a heap, 1 for pages of a clustered index, and a number between 2 
--			 and 1,005 for the pages of a nonclustered index.
SELECT	'dm_db_database_page_allocations'
		, database_id
		, object_id
		, index_id
		, partition_id
		/*, rowset_id
		, allocation_unit_id
		, allocation_unit_type*/
		, allocation_unit_type_desc
		/*, data_clone_id
		, clone_state
		, clone_state_desc
		, page_type*/
		, page_type_desc
		, page_level
		, allocated_page_file_id
		, allocated_page_page_id
		, next_page_file_id
		, next_page_page_id
		, previous_page_file_id
		, previous_page_page_id
		/*, extent_file_id
		, extent_page_id
		, allocated_page_iam_file_id
		, allocated_page_iam_page_id*/
		, is_allocated
		, is_iam_page
		, is_mixed_page_allocation
		, page_free_space_percent
		, is_page_compressed
		, has_ghost_records
FROM	sys.dm_db_database_page_allocations (DB_ID(N'AdventureWorks2017')
										, OBJECT_ID (N'AdventureWorks2017.Person.Address')
										, 1, NULL, N'DETAILED')
WHERE	page_level = 1 -- root page
;

-- Inspect root page contents
DBCC PAGE (AdventureWorks2017, 1, 12272, 3);
GO

DBCC TRACEON(3604);
GO

-- See message output
DBCC PAGE (AdventureWorks2017, 1, 11840, 3);
GO

DBCC TRACEOFF(3604);
GO