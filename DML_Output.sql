USE TSQL2012;
GO

/*-----------------------------------------------------
 * DML Semantics: 
 *
 *-----------------------------------------------------*/

-- OUTPUT clause: Use this over triggers because triggers 
-- because they introduce nondeterministic behavior —
-- you cannot guarantee that multiple triggers on the same 
-- table will consistently fire in the same order every time. 
-- This is often the cause of subtle bugs that can be very 
-- difficult to track down, and thus triggers should generally
-- be avoided when possible.
/*
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
CREATE TABLE dbo.T1
(
keycol INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_T1 PRIMARY KEY,
datacol NVARCHAR(40) NOT NULL
);
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
CREATE TABLE dbo.OrderDetails
(
orderid INT NOT NULL,
productid INT NOT NULL,
unitprice MONEY NOT NULL
CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
qty SMALLINT NOT NULL
CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
discount NUMERIC(4, 3) NOT NULL
CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
CONSTRAINT CHK_discount CHECK (discount BETWEEN 0 AND 1),
CONSTRAINT CHK_qty CHECK (qty > 0),
CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;
*/
DECLARE @NewRows TABLE(keycol INT, datacol NVARCHAR(40));
INSERT INTO dbo.T1(datacol)
	OUTPUT inserted.keycol, inserted.datacol INTO @NewRows
	OUTPUT inserted.keycol, inserted.datacol
SELECT lastname
FROM HR.Employees
WHERE country = N'UK';

SELECT * FROM @NewRows;
GO

-- inserted/deleted
UPDATE dbo.OrderDetails
	SET discount += 0.05
OUTPUT
	inserted.productid,
	deleted.discount AS olddiscount,
	inserted.discount AS newdiscount
WHERE productid = 51;

-- MERGE
MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
	ON TGT.custid = SRC.custid
WHEN MATCHED THEN
	UPDATE SET
		TGT.companyname = SRC.companyname,
		TGT.phone = SRC.phone,
		TGT.address = SRC.address
WHEN NOT MATCHED THEN
	INSERT (custid, companyname, phone, address)
	VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
OUTPUT $action AS theaction, inserted.custid,
	deleted.companyname AS oldcompanyname,
	inserted.companyname AS newcompanyname,
	deleted.phone AS oldphone,
	inserted.phone AS newphone,
	deleted.address AS oldaddress,
	inserted.address AS newaddress;
