USE TSQLV4;

-- Exercise 1

SELECT
	orderid,
	orderdate,
	custid,
	empid
FROM Sales.Orders
WHERE orderdate BETWEEN '20150601' AND '20150630'
ORDER BY orderdate;

-- Exercise 2

SELECT
	orderid,
	orderdate,
	custid,
	empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

-- Exercise 3

SELECT
	empid,
	firstname,
	lastname
FROM HR.Employees
WHERE lastname LIKE '%e%e%';

-- Exercise 4

SELECT * FROM Sales.OrderDetails;

SELECT
	orderid,
	SUM(qty * unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY
	orderid
HAVING
	SUM(qty * unitprice) > 10000
ORDER BY
	totalvalue DESC;

-- Exercise 5

SELECT * FROM HR.Employees;

SELECT
	empid,
	lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';

-- Exercise 6

-- Query 1
SELECT 
	empid, 
	COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;

-- Query 2
SELECT 
	empid, 
	COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501';

-- 

SELECT * FROM Sales.Orders;

-- Exercise 7

SELECT * FROM Sales.Orders;

SELECT TOP (3)
	shipcountry,
	AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate < '20160101'
GROUP BY
	shipcountry
ORDER BY
	avgfreight DESC;

-- Exercise 8

SELECT * FROM Sales.Orders;

SELECT
	custid,
	orderdate,
	orderid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderdate,orderid) AS rownum
FROM Sales.Orders
ORDER BY
	custid,rownum;

-- Exercise 9

SELECT
	empid,
	firstname,
	lastname,
	titleofcourtesy,
	CASE 
		WHEN titleofcourtesy = 'Ms.' THEN 'Female'
		WHEN titleofcourtesy = 'Mrs.' THEN 'Female'
		WHEN titleofcourtesy = 'Mr.' THEN 'Male'
	ELSE 'Unknow' 
	END	AS gender
FROM HR.Employees;

-- --

SELECT empid, firstname, lastname, titleofcourtesy,
  CASE titleofcourtesy
    WHEN 'Ms.'  THEN 'Female'
    WHEN 'Mrs.' THEN 'Female'
    WHEN 'Mr.'  THEN 'Male'
    ELSE             'Unknown'
  END AS gender
FROM HR.Employees;

-- --

SELECT empid, firstname, lastname, titleofcourtesy,
  CASE
    WHEN titleofcourtesy IN('Ms.', 'Mrs.') THEN 'Female'
    WHEN titleofcourtesy = 'Mr.'           THEN 'Male'
    ELSE                                        'Unknown'
  END AS gender
FROM HR.Employees;

-- Exercise 10

SELECT * FROM Sales.Customers;

SELECT
	custid,
	region
FROM Sales.Customers
ORDER BY
	CASE WHEN region IS NULL THEN 1 ELSE 0 END;

