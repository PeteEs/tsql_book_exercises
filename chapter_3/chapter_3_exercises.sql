USE TSQLV4;

-- -------------------- Exercise 1-1

SELECT * FROM dbo.Nums;

SELECT * FROM HR.Employees;

SELECT
	E.empid,
	E.firstname,
	E.lastname,
	N.n
FROM HR.Employees E
	CROSS JOIN dbo.Nums N
WHERE N.n < 6
ORDER BY
	N.n,E.empid;

-- -------------------- Exercise 1-2

SELECT 
	E.empid,
	DATEADD(day, Nums.n - 1, CAST('20160612' AS DATE)) AS dt
FROM dbo.Nums
  CROSS JOIN HR.Employees AS E
WHERE Nums.n <= DATEDIFF(day, '20160612', '20160616') + 1
ORDER BY
	E.empid,dt;

-- -------------------- Exercise 2

SELECT 
	C.custid, 
	C.companyname, 
	O.orderid, 
	O.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON C.custid = O.custid;

-- -------------------- Exercise 3

SELECT * FROM Sales.Customers;

SELECT * FROM Sales.Orders;

SELECT * FROM Sales.OrderDetails;

-- -----------

SELECT
	C.custid,
	COUNT(DISTINCT SO.orderid) AS numorders,
	SUM(SOD.qty) AS totalqty
FROM Sales.Customers C
	LEFT OUTER JOIN 
		(Sales.Orders SO
			INNER JOIN Sales.OrderDetails SOD
				ON SO.orderid = SOD.orderid)
		ON C.custid = SO.custid
WHERE C.country = 'USA'
GROUP BY
	C.custid
ORDER BY
	C.custid;

-- -------------------- Exercise 4

SELECT * FROM Sales.Customers;

SELECT * FROM Sales.Orders;

SELECT
	C.custid,
	C.companyname,
	O.orderid,
	O.orderdate
FROM Sales.Customers C
	LEFT JOIN Sales.Orders O
		ON C.custid = O.custid;

-- -------------------- Exercise 5

SELECT
	C.custid,
	C.companyname,
	O.orderid,
	O.orderdate
FROM Sales.Customers C
	LEFT JOIN Sales.Orders O
		ON C.custid = O.custid
WHERE O.orderid IS NULL;

-- -------------------- Exercise 6

SELECT
	C.custid,
	C.companyname,
	O.orderid,
	O.orderdate
FROM Sales.Customers C
	LEFT JOIN Sales.Orders O
		ON C.custid = O.custid
WHERE O.orderdate = '20160212';

-- -------------------- Exercise 7

SELECT
	C.custid,
	C.companyname,
	O.orderid,
	O.orderdate
FROM Sales.Customers C
	LEFT OUTER JOIN Sales.Orders O
		ON C.custid = O.custid
		AND O.orderdate = '20160212';

-- -------------------- Exercise 8

SELECT 
	C.custid, 
	C.companyname, 
	O.orderid, 
	O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20160212'
   OR O.orderid IS NULL;

   -- because it doesn't have all of the customers

-- -------------------- Exercise 9

SELECT
	C.custid,
	C.companyname,
	CASE O.orderid WHEN '20160212' THEN 'Yes' ELSE 'No' END AS HasOrderOn20160212
FROM Sales.Customers C
	LEFT OUTER JOIN Sales.Orders O
		ON C.custid = O.custid
		AND O.orderdate = '20160212';


