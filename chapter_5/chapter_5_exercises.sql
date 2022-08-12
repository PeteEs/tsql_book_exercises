USE TSQLV4;

-- ----------------------------- Excercise 1

SELECT 
	orderid, 
	orderdate, 
	custid, 
	empid,
	DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> DATEFROMPARTS(YEAR(orderdate), 12, 31);

SELECT 
	orderid, 
	orderdate, 
	custid, 
	empid,
	endofyear
FROM (SELECT 
		orderid, 
		orderdate, 
		custid, 
		empid,
		DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
		FROM Sales.Orders) AS internal
WHERE orderdate <> endofyear;

-- ----------------------------- Excercise 2-1

SELECT * FROM Sales.Orders;

SELECT
	empid,
	MAX(orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY
	empid;

-- ----------------------------- Excercise 2-2

SELECT
	C.empid,
	C.orderdate,
	C.orderid,
	C.custid
FROM Sales.Orders C
	INNER JOIN (SELECT
					empid,
					MAX(orderdate) AS maxorderdate
				FROM Sales.Orders
				GROUP BY
					empid) IC
		ON C.empid = IC.empid
WHERE C.orderdate = IC.maxorderdate;

-- ----------------------------- Excercise 3-1

SELECT
	orderid,
	orderdate,
	custid,
	empid,
	ROW_NUMBER() OVER (ORDER BY orderdate,orderid) AS rownum
FROM Sales.Orders;

-- ----------------------------- Excercise 3-2

WITH C AS
(
	SELECT
		orderid,
		orderdate,
		custid,
		empid,
		ROW_NUMBER() OVER (ORDER BY orderdate,orderid) AS rownum
	FROM Sales.Orders
)
SELECT
	orderid,
	orderdate,
	custid,
	empid,
	rownum
FROM C
WHERE rownum BETWEEN 11 AND 20;

-- ----------------------------- Excercise 4

WITH EmpsCTE AS
(
  SELECT 
	empid, 
	mgrid, 
	firstname, 
	lastname
  FROM HR.Employees
  WHERE empid = 9

  UNION ALL

  SELECT 
	C.empid, 
	C.mgrid, 
	C.firstname, 
	C.lastname
  FROM EmpsCTE AS P
    INNER JOIN HR.Employees AS C
      ON  P.mgrid = C.empid
)
SELECT 
	empid, 
	mgrid, 
	firstname, 
	lastname
FROM EmpsCTE;

-- ----------------------------- Excercise 5-1

SELECT * FROM Sales.Orders;

SELECT * FROM Sales.OrderDetails;

DROP VIEW IF EXISTS Sales.VEmpOrders;
GO
CREATE VIEW Sales.VEmpOrders
AS
SELECT
	empid,
	YEAR(O.orderdate) AS orderyear,
	SUM(OD.qty) AS qty
FROM Sales.Orders O
	INNER JOIN Sales.OrderDetails OD
		ON O.orderid = OD.orderid
GROUP BY
	empid,
	YEAR(O.orderdate);
GO


SELECT * FROM Sales.VEmpOrders ORDER BY empid, orderyear;

-- ----------------------------- Excercise 5-2

SELECT
	empid,
	orderyear,
	qty,
	(SELECT
		SUM(O2.qty) AS runqty
	FROM Sales.VEmpOrders O2
	WHERE O2.empid = O1.empid
	AND O2.orderyear <= O1.orderyear) AS runqty
FROM Sales.VEmpOrders O1
ORDER BY
	empid,
	orderyear;

-- ----------------------------- Excercise 6-1

DROP FUNCTION IF EXISTS Production.TopProducts;
GO
CREATE FUNCTION Production.TopProducts
  (@supid AS INT, @n AS INT)
RETURNS TABLE
AS
RETURN
	SELECT TOP (@n)
		productid,
		productname,
		unitprice
	FROM Production.Products
	WHERE supplierid = @supid
	ORDER BY
		unitprice DESC;
GO

SELECT * FROM Production.TopProducts(5, 2);

-- ----------------------------- Excercise 6-2

SELECT * FROM Production.Suppliers;

SELECT 
	S.supplierid,
	S.companyname,
	P.productid,
	P.productname,
	P.unitprice
FROM Production.Suppliers S
	CROSS APPLY
		Production.TopProducts(S.supplierid, 2) AS P

-- -------------------------

DROP VIEW IF EXISTS Sales.VEmpOrders;
DROP FUNCTION IF EXISTS Production.TopProducts;