USE ScratchDB;
GO

--END CONVERSATION N'17A7F509-2603-E811-BF09-645A04937ADF';
SELECT	N'conversation_endpoints', state_desc, *
FROM	sys.conversation_endpoints
ORDER BY lifetime DESC;

SELECT	N'sys.service_queues', * 
FROM	sys.service_queues;

/*
 * A SELECT statement on a queue may cause blocking. When using a SELECT statement on a queue, specify 
 * the NOLOCK hint to avoid blocking applications that use the queue.
 */
-- Easy way: Inspect queue without draining message.
/*
SELECT	*
FROM	TargetQueue1DB WITH (NOLOCK);
*/

-- Hard way: Sample to show the content of a message, then return
-- the message to the queue. This may be useful to determine
-- whether a specific message cannot be processed due to the
-- content of the message.

-- Every exit path from the transaction rolls back the transaction.
-- This code is intended to inspect the message, not remove the
-- message from the queue permanently. The transaction must roll
-- back to return the message to the queue.

BEGIN TRANSACTION ;

  -- To print the body, the code needs the message_body and
  -- the encoding_format.

  DECLARE @messageBody VARBINARY(MAX),
          @validation NCHAR ;

  -- Receive the message. The WAITFOR handles the case where
  -- an application is attempting to process the message when
  -- this batch is submitted. Replace the name of the queue and
  -- the conversation_handle value.

  WAITFOR(
    RECEIVE TOP(1) 
            @messageBody = message_body,
            @validation = validation
      FROM dbo.TargetQueue1DB
      WHERE conversation_handle = 'e29059bb-9922-40f4-a575-66b2e4c70cf9'
  ), TIMEOUT 2000 ;

  -- Roll back and exit if the message is not available
  -- in two seconds.

  IF @@ROWCOUNT = 0
    BEGIN
      ROLLBACK TRANSACTION ;
      PRINT 'No message available.' ;
      RETURN ;
    END

  -- Print the message based on the encoding format of
  -- the message body.

  IF (@validation = 'E')
    BEGIN
      PRINT 'Empty message.' ;
    END ;
  ELSE IF (@validation = 'X')
    BEGIN
      PRINT CONVERT(nvarchar(MAX), @messageBody) ;
    END ;
  ELSE IF (@validation = 'N')
    BEGIN
      PRINT 'No validation -- binary message:'
      PRINT @messageBody ;
    END

ROLLBACK TRANSACTION
GO