USE [ScratchDB]
GO

TRUNCATE TABLE [dbo].[CSVImport];
GO

-- Character format file (from data file)
-- bcp ScratchDB.dbo.CSVImport format nul -c -x -f C:\Users\ricardogu\Desktop\CSVImport-c.xml -t, -T
-- Unicode Character format file (from data file)
-- RKOTODO: Cannot get this one to work. Further research required.
-- bcp ScratchDB.dbo.CSVImport format nul -w -x -f C:\Users\ricardogu\Desktop\CSVImport-w.xml -t, -T

-- With format file char
-- Error file must be deleted each time. Enables errors to be skipped.
BEGIN TRY
	--INSERT INTO [dbo].[CSVImport]
	SELECT	'With format file - char', 
			*
	FROM	OPENROWSET(BULK N'C:\Users\ricardogu\Desktop\MyExample.csv'
					, FORMATFILE = N'C:\Users\ricardogu\Desktop\CSVImport-c.xml'
					--, ERRORFILE = N'C:\Users\ricardogu\Desktop\MyExample.err'
					--, MAXERRORS = 10
					, FIRSTROW = 2
					, FORMAT = 'CSV') AS csv;  
END TRY
BEGIN CATCH
	SELECT	ERROR_NUMBER(), ERROR_MESSAGE();
END CATCH
GO

-- Blob storage
/*
SELECT	*
FROM	sys.symmetric_keys
WHERE	name = N'##MS_DatabaseMasterKey##'

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '[hahahaha!]';
 
IF EXISTS (	SELECT	*
			FROM	sys.external_data_sources
			WHERE	name = N'PEPMInvoices')
	DROP EXTERNAL DATA SOURCE PEPMInvoices;
GO

IF EXISTS (SELECT	*
			FROM	sys.database_scoped_credentials
			WHERE	name = N'PEPMUpload')
	DROP DATABASE SCOPED CREDENTIAL PEPMUpload;
GO

CREATE DATABASE SCOPED CREDENTIAL PEPMUpload
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = '[Waaaaaahaaahahaha!!!]';
GO

CREATE EXTERNAL DATA SOURCE PEPMInvoices
WITH  (
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://d365demo02.blob.core.windows.net/pepm',
    CREDENTIAL = PEPMUpload
);
*/

SELECT	'From Azure Blob as CLOB!',
		* 
FROM	OPENROWSET(BULK N'MyExample.csv'
				, DATA_SOURCE = N'PEPMInvoices'
				, SINGLE_CLOB) AS csv;
GO

--INSERT INTO [dbo].[CSVImport]
SELECT	'From Azure Blob!', 
		*
FROM	OPENROWSET(BULK N'MyExample.csv'
				, DATA_SOURCE = N'PEPMInvoices'
				, FORMATFILE = N'CSVImport-c.xml'
				, FORMATFILE_DATA_SOURCE = N'PEPMInvoices'
				--, MAXERRORS = 10
				--, ERRORFILE = N'MyExample.err'
				--, ERRORFILE_DATASOURCE = N'PEPMInvoices'
				, FIRSTROW = 2
				, FORMAT = 'CSV') AS csv;  
GO