USE TSQL2012;
GO

/*
 * We do not need to explicitly invoke ROLLBACK in our code; when XACT_ABORT 
 * is set to ON, it all happens automatically.
 *
 * XACT_ABORT with TRY/CATCH should be done if you want to log the error as
 * part of the batch. Otherwise, the TRY/CATCH can be ommitted (and no explicit)
 * ROLLBACK is necessary because the transaction will be automatically rolled
 * back when the batch exits. As a best practice, issue an explicit rollback
 * in the catch.
 */

SET XACT_ABORT ON;
BEGIN TRY

	BEGIN TRANSACTION;
	
	SELECT 1/0;
	SELECT	'After div zero';

	COMMIT TRANSACTION;
	
END TRY

BEGIN CATCH

	SELECT 'CATCH' AS [In Catch];
	SELECT @@TRANCOUNT AS TRANCOUNT, XACT_STATE() AS [XACT_STATE()];
        
    --ROLLBACK TRANSACTION;

	SELECT @@TRANCOUNT AS TRANCOUNT, XACT_STATE() AS [XACT_STATE()];

END CATCH
GO

SELECT @@TRANCOUNT AS TRANCOUNT, XACT_STATE() AS [XACT_STATE()];
