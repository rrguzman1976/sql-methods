 USE master;
 GO
 
 -- Show currently active requests to the lock manager for locks that have been granted
-- or are waiting to be granted.
SELECT	'sys.dm_tran_locks', request_session_id, resource_type, resource_subtype
		, resource_description, request_mode, request_type, request_status, request_owner_type --, *
FROM	sys.dm_tran_locks
WHERE	request_session_id IN (55, 56, 60)
ORDER BY request_session_id

-- Displays the open transactions at the database level
SELECT	s.session_id, s.is_user_transaction, s.is_local, s.open_transaction_count
		, DB_NAME(t.database_id) AS [db], t.*
FROM	sys.dm_tran_database_transactions AS t
	LEFT JOIN sys.dm_tran_session_transactions AS s -- Map txns and sessions
		ON t.transaction_id = s.transaction_id
WHERE	s.session_id IN (55, 56, 60)
;

-- Wait list
SELECT	'sys.dm_os_waiting_tasks (wait list)', session_id, wait_type, wait_duration_ms, blocking_session_id, resource_description--, *
FROM	sys.dm_os_waiting_tasks
WHERE	session_id IN (55, 56, 60)

-- Runnable queue
SELECT	'sys.dm_exec_requests (runnable queue)', session_id, status, command
		, blocking_session_id, wait_type, wait_time, wait_resource
		, open_transaction_count, scheduler_id, deadlock_priority
FROM	sys.dm_exec_requests
WHERE	session_id IN (75, 76)

-- Open sessions (SPIDs)
SELECT	'sys.dm_exec_sessions', session_id, status, open_transaction_count --, *
FROM	sys.dm_exec_sessions
WHERE	session_id IN (75, 76)

