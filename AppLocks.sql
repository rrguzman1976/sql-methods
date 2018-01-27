USE Deadlock_Test;
GO

-- Run from separate sessions.
DECLARE @res INT;

-- Can be used to create synchronization between sessions (i.e. critical section).
-- Transaction level app locks need to be nested in explicit transactions.
EXEC @res = sp_getapplock @Resource = N'myLock', @LockMode = 'Exclusive'
		, @LockOwner = 'Session' -- 'Transaction'
		--, @LockTimeout = 0; -- don't wait for lock

-- >= 0 (success), or < 0 (failure)
PRINT @res;

WAITFOR DELAY '00:00:05';

-- Session level app locks are released when the session ends or sp_releaseapplock.
EXEC @res = sp_releaseapplock @Resource = N'myLock', @LockOwner = 'Session';

PRINT @res;
GO