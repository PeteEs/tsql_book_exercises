USE TSQLV4;

-- -------------------- DERIVED TABLES

SELECT *
FROM (SELECT custid, companyname
      FROM Sales.Customers
      WHERE country = N'USA') AS USACusts;

-- --------------

SELECT 
	YEAR(orderdate) AS orderyear, 
	COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate);

SELECT 
	orderyear, 
	COUNT(DISTINCT custid) AS numcusts
FROM (SELECT 
		YEAR(orderdate) AS orderyear, -- <----- INLINE ALIASING
		custid
      FROM Sales.Orders) AS D
GROUP BY orderyear;

SELECT 
	orderyear, 
	COUNT(DISTINCT custid) AS numcusts
FROM (SELECT 
		YEAR(orderdate), 
		custid
      FROM Sales.Orders) AS D(orderyear, custid) -- <----- EXTERNAL ALIASING
GROUP BY orderyear;

-- -----------------

DECLARE @empid AS INT = 3;

SELECT 
	orderyear, 
	COUNT(DISTINCT custid) AS numcusts
FROM (SELECT 
		YEAR(orderdate) AS orderyear, 
		custid
      FROM Sales.Orders
      WHERE empid = @empid) AS D
GROUP BY orderyear;

-- --------------- NESTING

SELECT 
	orderyear, 
	numcusts
FROM (SELECT 
			orderyear, 
			COUNT(DISTINCT custid) AS numcusts
      FROM (SELECT 
				YEAR(orderdate) AS orderyear, 
				custid
            FROM Sales.Orders) AS D1
      GROUP BY orderyear) AS D2
WHERE numcusts > 70;

SELECT 
	YEAR(orderdate) AS orderyear, 
	COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT custid) > 70;

-- ------------------------

SELECT 
	Cur.orderyear,
	Cur.numcusts AS curnumcusts, 
	Prv.numcusts AS prvnumcusts,
	Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT 
			YEAR(orderdate) AS orderyear,
			COUNT(DISTINCT custid) AS numcusts
      FROM Sales.Orders
      GROUP BY YEAR(orderdate)) AS Cur
  LEFT OUTER JOIN
     (SELECT 
			YEAR(orderdate) AS orderyear,
			COUNT(DISTINCT custid) AS numcusts
      FROM Sales.Orders
      GROUP BY YEAR(orderdate)) AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

-- --------------------------------- CTE

WITH USACusts AS
(
  SELECT custid, companyname
  FROM Sales.Customers
  WHERE country = N'USA'
)
SELECT * FROM USACusts;

-- -------------

WITH C AS
(
  SELECT 
	YEAR(orderdate) AS orderyear, 
	custid
  FROM Sales.Orders
)
SELECT 
	orderyear, 
	COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

-- -------------

WITH C(orderyear, custid) AS
(
  SELECT 
	YEAR(orderdate), 
	custid
  FROM Sales.Orders
)
SELECT 
	orderyear, 
	COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

-- ----------- WITH ARGS

DECLARE @empiidd AS INT = 3;

WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
  WHERE empid = @empiidd
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

-- ------------ MULTIPLE CTE

WITH C1 AS
(
  SELECT 
	YEAR(orderdate) AS orderyear, 
	custid
  FROM Sales.Orders
),
C2 AS
(
  SELECT 
	orderyear, 
	COUNT(DISTINCT custid) AS numcusts
  FROM C1
  GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;

-- -------------- MULTIPLE REFERENCES CTE

WITH YearlyCount AS
(
  SELECT 
	YEAR(orderdate) AS orderyear,
    COUNT(DISTINCT custid) AS numcusts
  FROM Sales.Orders
  GROUP BY YEAR(orderdate)
)
SELECT 
	Cur.orderyear,
	Cur.numcusts AS curnumcusts, 
	Prv.numcusts AS prvnumcusts,
	Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
  LEFT OUTER JOIN YearlyCount AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

-- ------------------------ RECURSIVE CTEs

WITH EmpsCTE AS
(
  SELECT 
	empid, 
	mgrid, 
	firstname, 
	lastname
  FROM HR.Employees
  WHERE empid = 2

  UNION ALL

  SELECT 
	C.empid, 
	C.mgrid, 
	C.firstname, 
	C.lastname
  FROM EmpsCTE AS P
    INNER JOIN HR.Employees AS C
      ON C.mgrid = P.empid
)
SELECT 
	empid, 
	mgrid, 
	firstname, 
	lastname
FROM EmpsCTE;

-- ------------------------------------ VIEWS

DROP VIEW IF EXISTS Sales.USACusts;
GO
CREATE VIEW Sales.USACusts
AS

SELECT
	custid, 
	companyname, 
	contactname, 
	contacttitle, 
	address,
	city, 
	region, 
	postalcode, 
	country, 
	phone, 
	fax
FROM Sales.Customers
WHERE country = N'USA';
GO

SELECT custid, companyname
FROM Sales.USACusts;

-- ------------- VIEWS AND ORDER BY

SELECT 
	custid, 
	companyname, 
	region
FROM Sales.USACusts
ORDER BY region;

-- ENCRYPTION 

GO
ALTER VIEW Sales.USACusts
AS
SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));

GO
ALTER VIEW Sales.USACusts WITH ENCRYPTION
AS
SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

EXEC sp_helptext 'Sales.USACusts';

-- SCHEMABINDING

GO
ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS
SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

ALTER TABLE Sales.Customers DROP COLUMN address;

-- CHECK OPTION

INSERT INTO Sales.USACusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
 VALUES(
  N'Customer ABCDE', N'Contact ABCDE', N'Title ABCDE', N'Address ABCDE',
  N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');

SELECT custid, companyname, country
FROM Sales.USACusts
WHERE companyname = N'Customer ABCDE';

SELECT custid, companyname, country
FROM Sales.Customers
WHERE companyname = N'Customer ABCDE';

GO
ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS
SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
WITH CHECK OPTION;
GO

-- -------

DELETE FROM Sales.Customers
WHERE custid > 91;

DROP VIEW IF EXISTS Sales.USACusts;

-- ------------------------------ INLINE TVFs


DROP FUNCTION IF EXISTS dbo.GetCustOrders;

GO
CREATE FUNCTION dbo.GetCustOrders
  (@cid AS INT) RETURNS TABLE
AS
RETURN
  SELECT orderid, custid, empid, orderdate, requireddate,
    shippeddate, shipperid, freight, shipname, shipaddress, shipcity,
    shipregion, shippostalcode, shipcountry
  FROM Sales.Orders
  WHERE custid = @cid;
GO

SELECT orderid, custid
FROM dbo.GetCustOrders(1) AS O;

SELECT O.orderid, O.custid, OD.productid, OD.qty
FROM dbo.GetCustOrders(1) AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid;

DROP FUNCTION IF EXISTS dbo.GetCustOrders;

-- ---------------------- APPLY OPERATOR

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS JOIN HR.Employees AS E;

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS APPLY HR.Employees AS E;

-- CROSS APPLY
SELECT 
	C.custid, 
	A.orderid, 
	A.orderdate
FROM Sales.Customers AS C
  CROSS APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC) AS A;

SELECT 
	C.custid, 
	A.orderid, 
	A.orderdate
FROM Sales.Customers AS C
  CROSS APPLY
    (SELECT orderid, empid, orderdate, requireddate
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC
     OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY) AS A;

-- OUTER APPLY
SELECT 
	C.custid, 
	A.orderid, 
	A.orderdate
FROM Sales.Customers AS C
  OUTER APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC) AS A;

-- WITH TVFs

DROP FUNCTION IF EXISTS dbo.TopOrders;
GO
CREATE FUNCTION dbo.TopOrders
  (@custid AS INT, @n AS INT)
  RETURNS TABLE
AS
RETURN
  SELECT TOP (@n) orderid, empid, orderdate, requireddate
  FROM Sales.Orders
  WHERE custid = @custid
  ORDER BY orderdate DESC, orderid DESC;
GO

SELECT
  C.custid, 
  C.companyname,
  A.orderid, 
  A.empid, 
  A.orderdate, 
  A.requireddate
FROM Sales.Customers AS C
  CROSS APPLY 
	dbo.TopOrders(C.custid, 3) AS A;