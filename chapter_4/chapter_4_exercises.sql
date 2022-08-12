USE TSQLV4;

-- ----------------------- Exercise 1

SELECT *
FROM Sales.Orders;

SELECT
	orderid,
	orderdate,
	custid,
	empid
FROM  Sales.Orders
WHERE orderdate IN
	(SELECT
		MAX(O2.orderdate)
	FROM Sales.Orders O2);

-- ----------------------- Exercise 2

SELECT
	custid,
	orderid,
	orderdate,
	empid
FROM Sales.Orders
WHERE custid IN
	(SELECT TOP (1) WITH TIES
		O2.custid
	FROM Sales.Orders O2
	GROUP BY
		O2.custid
	ORDER BY
		COUNT(orderid) DESC);

-- ----------------------- Exercise 3

SELECT * FROM Sales.Orders;

SELECT
	empid,
	FirstName,
	LastName
FROM HR.Employees O1
WHERE empid NOT IN
	(SELECT
		O2.empid
	FROM Sales.Orders O2
	WHERE orderdate >= '20160501');

-- ----------------------- Exercise 4

SELECT * FROM Sales.Customers;

SELECT * FROM HR.Employees;

SELECT DISTINCT
	country
FROM Sales.Customers
WHERE country NOT IN
	(SELECT
		O2.country
	FROM HR.Employees O2);

-- ----------------------- Exercise 5

SELECT
	custid,
	orderid,
	orderdate,
	empid
FROM Sales.Orders O1
WHERE orderdate =
	(SELECT
		MAX(O2.orderdate)
	FROM Sales.Orders O2
	WHERE O2.custid = O1.custid)
ORDER BY
	custid, orderid

-- ----------------------- Exercise 6

SELECT
	custid,
	companyname
FROM Sales.Customers O1
WHERE NOT EXISTS
	(SELECT *
	FROM Sales.Orders O2
	WHERE O2.custid = O1.custid
	AND O2.orderdate BETWEEN '20160101' AND '20161231')
	AND EXISTS
	(SELECT *
	FROM Sales.Orders O2
	WHERE O2.custid = O1.custid
	AND O2.orderdate BETWEEN '20150101' AND '20151231')
ORDER BY
	custid;

-- ----------------------- Exercise 7

SELECT * FROM Sales.Customers;

SELECT * FROM Sales.Orders;

SELECT * FROM Sales.OrderDetails;

SELECT
	custid,
	companyname
FROM Sales.Customers C
WHERE custid IN
	(SELECT
		O.custid
	FROM Sales.Orders O
		INNER JOIN Sales.OrderDetails OD
			ON O.orderid = OD.orderid
	WHERE OD.productid = 12);

-- --------------

SELECT custid, companyname
FROM Sales.Customers AS C
WHERE EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
     AND EXISTS
       (SELECT *
        FROM Sales.OrderDetails AS OD
        WHERE OD.orderid = O.orderid
          AND OD.ProductID = 12));

-- ----------------------- Exercise 8

SELECT * FROM Sales.CustOrders;

SELECT
	custid,
	ordermonth AS orderdate,
	O1.qty,
	(SELECT
		SUM(O2.qty)
	FROM Sales.CustOrders O2
	WHERE O2.ordermonth <= O1.ordermonth
	AND O2.custid = O1.custid
	) AS runqty
FROM Sales.CustOrders O1
ORDER BY
	custid, ordermonth;

-- ----------------------- Exercise 9

-- DIFFERECE BETWEEN 'IN' AND 'EXISTS'

-- Whereas the IN predicate uses three-valued logic, the EXISTS predicate uses two-
-- valued logic. When no NULLs are involved in the data, IN and EXISTS give you the
-- same meaning in both their positive and negative forms (with NOT).

-- ----------------------- Exercise 10

SELECT * FROM Sales.Orders;

SELECT
	custid,
	orderdate,
	orderid
FROM Sales.Orders
ORDER BY
	custid,
	orderdate;

SELECT
	custid,
	orderdate,
	orderid,
	(SELECT
		MAX(O2.orderid)
	FROM Sales.Orders O2
	WHERE O2.custid = O1.custid
	AND O2.orderdate = O1.orderdate),
	(SELECT
		MAX(O2.orderid)
	FROM Sales.Orders O2
	WHERE O2.custid = O1.custid
	AND O2.orderdate < O1.orderdate)
FROM Sales.Orders O1
ORDER BY
	custid,
	orderdate;

-- --------------------

SELECT
	custid,
	orderdate,
	orderid,
	DATEDIFF(DAY,
	(SELECT
		MAX(O2.orderdate)
	FROM Sales.Orders O2
	WHERE O2.custid = O1.custid
	AND O2.orderdate < O1.orderdate
	AND O2.orderid < O1.orderid),
	orderdate
	) AS diff
FROM Sales.Orders O1
ORDER BY
	custid,
	orderdate;

-- ------------------------------------
-- book's solution

SELECT 
	custid, 
	orderdate, 
	orderid,
  (SELECT TOP (1) O2.orderdate
   FROM Sales.Orders AS O2
   WHERE O2.custid = O1.custid
		AND (O2.orderdate = O1.orderdate 
		AND O2.orderid < O1.orderid
		OR O2.orderdate < O1.orderdate )
   ORDER BY O2.orderdate DESC, O2.orderid DESC) AS prevdate
FROM Sales.Orders AS O1
ORDER BY custid, orderdate, orderid;

SELECT custid, orderdate, orderid,
  DATEDIFF(day,
    (SELECT TOP (1) O2.orderdate
     FROM Sales.Orders AS O2
     WHERE O2.custid = O1.custid
       AND (    O2.orderdate = O1.orderdate AND O2.orderid < O1.orderid
             OR O2.orderdate < O1.orderdate )
     ORDER BY O2.orderdate DESC, O2.orderid DESC),
    orderdate) AS diff
FROM Sales.Orders AS O1
ORDER BY custid, orderdate, orderid;