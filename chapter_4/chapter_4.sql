USE TSQLV4;

DECLARE @maxid AS INT = (SELECT MAX(orderid)
                         FROM Sales.Orders);

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = @maxid;

-- -------------- SELF CONTAINED

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = (SELECT MAX(O.orderid)
                 FROM Sales.Orders AS O);

SELECT orderid
FROM Sales.Orders
WHERE empid =
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'C%');

SELECT orderid
FROM Sales.Orders
WHERE empid =
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'D%');

SELECT orderid
FROM Sales.Orders
WHERE empid =
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'A%');

SELECT orderid
FROM Sales.Orders
WHERE empid IN
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'D%');

SELECT O.orderid
FROM HR.Employees AS E
  INNER JOIN Sales.Orders AS O
    ON E.empid = O.empid
WHERE E.lastname LIKE N'D%';

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid IN
  (SELECT C.custid
   FROM Sales.Customers AS C
   WHERE C.country = N'USA');

SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN
  (SELECT O.custid
   FROM Sales.Orders AS O);


DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders(orderid INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY);

INSERT INTO dbo.Orders(orderid)
  SELECT orderid
  FROM Sales.Orders
  WHERE orderid % 2 = 0;

SELECT * FROM dbo.Orders;

SELECT
	MAX(orderid) AS max
FROM dbo.Orders;

SELECT
	MIN(orderid) AS min
FROM dbo.Orders;


SELECT
	n AS orderid
FROM dbo.Nums
WHERE n BETWEEN 
(SELECT
	MIN(O.orderid) AS min
FROM dbo.Orders O)
AND
(SELECT
	MAX(O.orderid) AS max
FROM dbo.Orders O)
AND n NOT IN
(SELECT 
	O.orderid
FROM dbo.Orders O);

DROP TABLE IF EXISTS dbo.Orders;

-- ----------------------- CORRELATED

SELECT 
	custid, 
	orderid, 
	orderdate, 
	empid
FROM Sales.Orders AS O1
WHERE orderid =
  (SELECT MAX(O2.orderid)
   FROM Sales.Orders AS O2
   WHERE O2.custid = O1.custid);

-- --------------

SELECT * FROM Sales.OrderValues;

SELECT
	orderid,
	custid,
	val,
	CAST(100. * val / 
	(SELECT
		SUM(OV2.val) AS total
	FROM Sales.OrderValues OV2
	WHERE OV2.custid = OV1.custid
	GROUP BY
		custid) AS DECIMAL(10,2)) AS [%oftotal]
FROM Sales.OrderValues OV1;

-- ---------------------------- EXISTS

SELECT 
	custid, 
	companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND EXISTS
    (SELECT * FROM Sales.Orders AS O
     WHERE O.custid = C.custid);

SELECT 
	custid, 
	companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND NOT EXISTS
    (SELECT * FROM Sales.Orders AS O
     WHERE O.custid = C.custid);

-- ---------------------------------------------

SELECT 
	orderid, 
	orderdate, 
	empid, 
	custid,
	(SELECT
		MAX(O2.orderid)
	FROM Sales.Orders AS O2
	WHERE O2.orderid < O1.orderid) AS prevorderid
FROM Sales.Orders AS O1;

SELECT 
	orderid, 
	orderdate, 
	empid, 
	custid,
	(SELECT 
		MIN(O2.orderid)
	FROM Sales.Orders AS O2
	WHERE O2.orderid > O1.orderid) AS nextorderid
FROM Sales.Orders AS O1;

-- -----------------

SELECT 
	orderyear, 
	qty
FROM Sales.OrderTotalsByYear;


SELECT
	orderyear,
	qty,
	(SELECT
		SUM(O2.qty)
   FROM Sales.OrderTotalsByYear AS O2
   WHERE O2.orderyear <= O1.orderyear) AS runningqty
FROM Sales.OrderTotalsByYear O1
ORDER BY
	orderyear;


-- ---------------------------------

INSERT INTO Sales.Orders
  (custid, empid, orderdate, requireddate, shippeddate, shipperid,
   freight, shipname, shipaddress, shipcity, shipregion,
   shippostalcode, shipcountry)
  VALUES(NULL, 1, '20160212', '20160212',
         '20160212', 1, 123.00, N'abc', N'abc', N'abc',
         N'abc', N'abc', N'abc');

SELECT
	custid, 
	companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid
                    FROM Sales.Orders AS O);

SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid
                    FROM Sales.Orders AS O
                    WHERE O.custid IS NOT NULL);

SELECT custid, companyname
FROM Sales.Customers AS C
WHERE NOT EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid);

DELETE FROM Sales.Orders WHERE custid IS NULL;

-- --------------------------

DROP TABLE IF EXISTS Sales.MyShippers;

CREATE TABLE Sales.MyShippers
(
  shipper_id  INT          NOT NULL,
  companyname NVARCHAR(40) NOT NULL,
  phone       NVARCHAR(24) NOT NULL,
  CONSTRAINT PK_MyShippers PRIMARY KEY(shipper_id)
);

INSERT INTO Sales.MyShippers(shipper_id, companyname, phone)
  VALUES(1, N'Shipper GVSUA', N'(503) 555-0137'),
        (2, N'Shipper ETYNR', N'(425) 555-0136'),
        (3, N'Shipper ZHISN', N'(415) 555-0138');

SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT shipper_id
   FROM Sales.Orders
   WHERE custid = 43);

SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT O.shipperid
   FROM Sales.Orders AS O
   WHERE O.custid = 43);

DROP TABLE IF EXISTS Sales.MyShippers;