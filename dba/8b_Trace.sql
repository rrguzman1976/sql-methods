/****************************************************/
/* Created by: SQL Server 2017 Profiler          */
/* Date: 03/15/2018  08:50:35 PM         */
/****************************************************/

-- Create a Queue
DECLARE @traceFile NVARCHAR(245) = N'C:\Users\rguzman\Documents\GitHub\sql-tuning\Sample004';
DECLARE @NTUserName NVARCHAR(256) = N'rguzman';
DECLARE @HostName NVARCHAR(256) = N'ALLORNOTHING';
DECLARE @DatabaseName NVARCHAR(256) = N'ScratchDB';
declare @TraceID int;
declare @maxfilesize bigint = 50; -- MB

exec sp_trace_create 
	@traceid = @TraceID output
	, @options = 2 -- rollover
	, @tracefile = @traceFile
	, @maxfilesize = @maxfilesize
	, @stoptime = NULL
	, @filecount = 5;

declare @on bit = 1;

-- Set the SQL:StmtCompleted event
exec sp_trace_setevent @TraceID, 41, 1, @on; -- TextData
--exec sp_trace_setevent @TraceID, 41, 3, @on
exec sp_trace_setevent @TraceID, 41, 5, @on; -- LineNumber
exec sp_trace_setevent @TraceID, 41, 6, @on; -- NTUserName
exec sp_trace_setevent @TraceID, 41, 7, @on; -- NTDomainName
exec sp_trace_setevent @TraceID, 41, 8, @on; -- HostName
exec sp_trace_setevent @TraceID, 41, 10, @on; -- ApplicationName
exec sp_trace_setevent @TraceID, 41, 11, @on; -- LoginName
exec sp_trace_setevent @TraceID, 41, 12, @on; -- SPID
exec sp_trace_setevent @TraceID, 41, 14, @on; -- StartTime
exec sp_trace_setevent @TraceID, 41, 15, @on; -- EndTime
exec sp_trace_setevent @TraceID, 41, 26, @on; -- ServerName
exec sp_trace_setevent @TraceID, 41, 35, @on; -- DatabaseName
exec sp_trace_setevent @TraceID, 41, 48, @on; -- RowCounts
exec sp_trace_setevent @TraceID, 41, 51, @on; -- EventSequence
exec sp_trace_setevent @TraceID, 41, 64, @on; -- SessionLoginName

-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 6, 0, 6, @NTUserName; -- NTUserName
exec sp_trace_setfilter @TraceID, 8, 0, 6, @HostName; -- HostName
--exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - c7afa416-1f7c-469a-a926-ff39fbd80401'
exec sp_trace_setfilter @TraceID, 35, 0, 6, @DatabaseName; -- DatabaseName

-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select @TraceID AS TraceID;
go

-- Stop and close
/*
exec sp_trace_setstatus {TraceID}, 0;
exec sp_trace_setstatus {TraceID}, 2;
*/