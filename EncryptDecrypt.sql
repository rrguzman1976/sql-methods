USE Encrypt_Test2;
GO

-- Create master key
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE	name = N'##MS_DatabaseMasterKey##')
BEGIN
	CREATE MASTER KEY
	ENCRYPTION BY PASSWORD = '*********';
END
GO
/*
-- Backup master key
BACKUP MASTER KEY
	TO FILE = 'C:\MasterKey_BAK\Encrypt_Test2_master.bak'
ENCRYPTION BY PASSWORD = '*********';
*/

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = N'rko_sym1')
	DROP SYMMETRIC KEY rko_sym1;
GO
IF EXISTS (SELECT * FROM sys.asymmetric_keys WHERE name = N'rko_asym1')
	DROP ASYMMETRIC KEY rko_asym1;
GO
IF EXISTS (SELECT * FROM sys.certificates WHERE name = N'rko_cert1')
	DROP CERTIFICATE rko_cert1;
GO
DROP MASTER KEY;
GO

-- Symmetric key: much faster than asymmetric encryption.
RESTORE MASTER KEY
FROM FILE = 'C:\MasterKey_BAK\Encrypt_Test2_master.bak'
	DECRYPTION BY PASSWORD = '*********'
	ENCRYPTION BY PASSWORD = '*********';
GO
OPEN MASTER KEY	DECRYPTION BY PASSWORD = '*********';
GO

-- Returns one row for every symmetric key created with the CREATE SYMMETRIC KEY statement.
-- Master key will have a record in sys.symmetric_keys named '##MS_DatabaseMasterKey##'
-- Master key  is a symmetric key.
-- Master key's ENCRYPTION BY PASSWORD will have a record in sys.key_encryptions.
SELECT	k.name, k.create_date, k.symmetric_key_id
		, e.crypt_type_desc
FROM	sys.symmetric_keys AS k
	LEFT JOIN sys.key_encryptions AS e
		ON k.symmetric_key_id = e.key_id
WHERE name = N'##MS_DatabaseMasterKey##';

-- Certificates: used to verify identity (trust)
-- Instance Service Master Key > DB Master Key > Database Certificate
-- If a master key does not exist, then certificates can only be created using the 
-- ENCRYPTION BY PASSWORD option.
-- Certificates are used to establish trust (contain expiry, issuer, subject, etc.) 
-- See: http://www.tldp.org/HOWTO/SSL-Certificates-HOWTO/x64.html
CREATE CERTIFICATE rko_cert1
ENCRYPTION BY PASSWORD = '*********' -- required if master key isn't available
WITH SUBJECT = 'Test certificate 1'
		, START_DATE = '2013-11-25'
		, EXPIRY_DATE = '2013-12-25';
GO

-- Public/Private Key Pair: Strong protection, CPU intensive
CREATE ASYMMETRIC KEY rko_asym1
WITH ALGORITHM = RSA_2048
ENCRYPTION BY PASSWORD = '*********'; -- required if master key isn't available
GO

-- Create symmetric key
CREATE SYMMETRIC KEY rko_sym1
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = '*********';
GO
/*
SELECT	a.name AS [asymmmetric key], a.principal_id, a.asymmetric_key_id, a.pvt_key_encryption_type_desc, a.algorithm_desc, a.key_length, a.public_key
FROM	sys.asymmetric_keys AS a

SELECT	c.name AS [certificate], c.certificate_id, c.principal_id, c.pvt_key_encryption_type_desc
		, c.issuer_name, c.[subject], c.[expiry_date], c.[start_date]
FROM	sys.certificates AS c

SELECT	s.name AS [symmmetric key], s.principal_id, s.symmetric_key_id, s.key_length, s.algorithm_desc, s.key_guid
FROM	sys.symmetric_keys AS s
WHERE	name = N'##MS_DatabaseMasterKey##'

SELECT	e.key_id, e.crypt_type_desc
FROM	sys.key_encryptions AS e
*/

IF OBJECT_ID(N'dbo.EncryptColumn', N'U') IS NOT NULL 
	DROP TABLE dbo.EncryptColumn;

CREATE TABLE dbo.EncryptColumn
(
	ID INT NOT NULL IDENTITY
	, SecCol1 NVARCHAR(50) NULL
	, SecCol2 NVARCHAR(50) NULL
	, EncryptVal VARBINARY(512) NULL
);
GO

INSERT INTO dbo.EncryptColumn (SecCol1, SecCol2)
VALUES	(N'Ricardo Guzman', N'*********');

-- Encrypt by passphrase (3DES, 128 bit key)
-- The advantage of using a passphrase is that it is easier to remember
-- a meaningful phrase or sentence than to remember a comparably long string of characters.
UPDATE	dbo.EncryptColumn
	SET EncryptVal = EncryptByPassPhrase(N'This is a secure passphrase', SecCol2)
WHERE	ID = 1;

-- DecryptByPassPhrase returns VARBINARY
SELECT	ID, SecCol1, SecCol2, EncryptVal
		, CAST(DecryptByPassPhrase(N'This is a secure passphrase', EncryptVal) AS NVARCHAR(50)) AS [Decrypted]
FROM	dbo.EncryptColumn
WHERE	ID = 1
GO

INSERT INTO dbo.EncryptColumn (SecCol1, SecCol2)
VALUES	(N'Ricardo Guzman', N'*********');

-- Encrypt by symmetric key (cannot use Master Key)
-- Both encrypt/decrypt functions require the symmetric key to be open.
OPEN SYMMETRIC KEY rko_sym1
    DECRYPTION BY PASSWORD = '*********';

UPDATE	dbo.EncryptColumn
	SET EncryptVal = EncryptByKey(Key_GUID('rko_sym1'), SecCol2)
WHERE	ID = 2;

SELECT	ID, SecCol1, SecCol2, EncryptVal
		, CAST(DecryptByKey(EncryptVal) AS NVARCHAR(50)) AS [Decrypted]
FROM	dbo.EncryptColumn
WHERE	ID = 2
GO

INSERT INTO dbo.EncryptColumn (SecCol1, SecCol2)
VALUES	(N'Ricardo Guzman', N'*********');

-- Encrypt by certificate. This function encrypts data with the public key of a certificate. 
-- The ciphertext can only be decrypted with the corresponding private key. Such asymmetric
-- transformations are very costly compared to encryption and decryption using a symmetric key. 
UPDATE	dbo.EncryptColumn
	SET EncryptVal = EncryptByCert(CERT_ID('rko_cert1'), SecCol2)
WHERE	ID = 3;

-- Password (private key) not needed because certificate is encrypted by master key.
SELECT	ID, SecCol1, SecCol2, EncryptVal
		, CAST(DecryptByCert(CERT_ID('rko_cert1'), EncryptVal/*, N'Welcome123'*/) AS NVARCHAR(50)) AS [Decrypted]
FROM	dbo.EncryptColumn
WHERE	ID = 3
GO

INSERT INTO dbo.EncryptColumn (SecCol1, SecCol2)
VALUES	(N'Ricardo Guzman', N'*********');

-- Encrypt by asymmetric key (very costly compared with encryption and decryption with a symmetric key)
-- Asymmetric encryption is therefore not recommended when working with large datasets such as 
-- user data in tables.
UPDATE	dbo.EncryptColumn
	SET EncryptVal = EncryptByAsymKey(AsymKey_ID('rko_asym1'), SecCol2)
WHERE	ID = 3;

SELECT	ID, SecCol1, SecCol2, EncryptVal
		, CAST(DecryptByAsymKey(AsymKey_ID('rko_asym1'), EncryptVal, N'Welcome123') AS NVARCHAR(50)) AS [Decrypted]
FROM	dbo.EncryptColumn
WHERE	ID = 3
GO
