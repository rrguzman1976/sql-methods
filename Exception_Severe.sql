USE TSQL2012;
GO

-- Severity level from 20 through 25 are considered fatal and cause the
-- connection to be terminated *and any open transactions to be rolled back*.
/*
-- Disconnects
RAISERROR ('Severe Error Test', 25, 0)
WITH LOG -- required for severity > 18
	, NOWAIT;
*/

-- Errors with a severity level of 20 and greater that do not close connections are also
-- handled by the CATCH block.
/*
BEGIN TRY

	RAISERROR ('Normal Error Test', 20, 0)
	WITH LOG, NOWAIT;

END TRY
BEGIN CATCH
	PRINT 'Caught: ' + ERROR_MESSAGE(); -- not reached, disconnected
END CATCH
*/

-- Compile errors and some runtime errors involving statement level compilation abort
-- the batch immediately and do not pass control to the CATCH block.
-- However, open transactions are rolled back automatically.
BEGIN TRY

	RAISERROR ('Normal Error Test', 19, 0)
	WITH LOG, NOWAIT;

END TRY
BEGIN CATCH
	PRINT 'Caught: ' + ERROR_MESSAGE(); -- reached
END CATCH

-- A TRY/CATCH block does not trap errors that cause the connection to be terminated,
-- such as a fatal error or a sysadmin executing the KILL command.
-- However, open transactions are rolled back automatically.
/*
BEGIN TRY

	RAISERROR ('Severe Error Test', 25, 0)
	WITH LOG -- required for severity > 20
		, NOWAIT;

END TRY
BEGIN CATCH
	PRINT 'Caught: ' + ERROR_MESSAGE(); -- not reached, disconnected
END CATCH
*/