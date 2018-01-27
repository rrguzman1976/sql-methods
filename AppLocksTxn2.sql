USE Deadlock_Test;
GO

-- Session 2
DECLARE @res INT;

-- Can be used to create synchronization between sessions (i.e. critical section).
-- Transaction level app locks need to be nested in explicit transactions.
BEGIN TRANSACTION;

EXEC @res = sp_getapplock @Resource = N'myLock', @LockMode = 'Exclusive'
		, @LockOwner = 'Transaction'
		--, @LockTimeout = 0; -- don't wait for lock

-- >= 0 (success), or < 0 (failure)
PRINT @res;

EXEC @res = sp_releaseapplock @Resource = N'myLock', @LockOwner = 'Transaction';

-- COMMIT releases app lock for transaction type app lock if sp_releaseapplock not issued.
COMMIT;

PRINT @res;
GO