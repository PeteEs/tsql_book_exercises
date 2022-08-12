USE TSQLV4;

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid   INT        NOT NULL,
  orderdate DATE       NOT NULL,
  empid     INT        NOT NULL,
  custid    VARCHAR(5) NOT NULL,
  qty       INT        NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
  (30001, '20140802', 3, 'A', 10),
  (10001, '20141224', 2, 'A', 12),
  (10005, '20141224', 1, 'B', 20),
  (40001, '20150109', 2, 'A', 40),
  (10006, '20150118', 1, 'C', 14),
  (20001, '20150212', 2, 'B', 12),
  (40005, '20160212', 3, 'A', 10),
  (20002, '20160216', 1, 'C', 20),
  (30003, '20160418', 2, 'B', 15),
  (30004, '20140418', 3, 'C', 22),
  (30007, '20160907', 3, 'D', 30);

SELECT * FROM dbo.Orders;

-- ---------------------------------------- Exercise 1

SELECT *
FROM dbo.Orders;

SELECT
	custid,
	orderid,
	RANK() OVER(PARTITION BY custid ORDER BY qty) AS rnk,
	DENSE_RANK() OVER(PARTITION BY custid ORDER BY qty) AS drnk
FROM dbo.Orders;

-- ---------------------------------------- Exercise 2

SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;

SELECT *
FROM Sales.OrderValues;

SELECT
	val
FROM Sales.OrderValues
ORDER BY
	val ASC;

-- ------------

WITH C AS
(
	SELECT DISTINCT
		val
	FROM Sales.OrderValues
)
SELECT
	val,
	ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM C;

-- ---------------------------------------- Exercise 3

SELECT *
FROM dbo.Orders;

SELECT
	custid,
	orderid,
	qty,
	qty - (LAG(qty)  OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid)) AS diffprev,
	qty - (LEAD(qty) OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid)) AS diffnext
FROM dbo.Orders;

-- ---------------------------------------- Exercise 4

SELECT *
FROM dbo.Orders;

SELECT empid, cnt2014, cnt2015, cnt2016
FROM (SELECT empid, orderid, CONCAT('cnt',YEAR(orderdate)) AS orderdate
		FROM dbo.Orders) AS D
	PIVOT(COUNT(orderid) FOR orderdate IN(cnt2014,cnt2015,cnt2016)) AS P;

-- -----------------

SELECT empid,
  COUNT(CASE WHEN orderyear = 2014 THEN orderyear END) AS cnt2014,
  COUNT(CASE WHEN orderyear = 2015 THEN orderyear END) AS cnt2015,
  COUNT(CASE WHEN orderyear = 2016 THEN orderyear END) AS cnt2016
FROM (SELECT empid, YEAR(orderdate) AS orderyear
      FROM dbo.Orders) AS D
GROUP BY empid;

-- -----------------

SELECT empid, [2014] AS cnt2014, [2015] AS cnt2015, [2016] AS cnt2016
FROM (SELECT empid, YEAR(orderdate) AS orderyear
      FROM dbo.Orders) AS D
  PIVOT(COUNT(orderyear)
        FOR orderyear IN([2014], [2015], [2016])) AS P;

-- ---------------------------------------- Exercise 5

DROP TABLE IF EXISTS dbo.EmpYearOrders;

CREATE TABLE dbo.EmpYearOrders
(
  empid INT NOT NULL
    CONSTRAINT PK_EmpYearOrders PRIMARY KEY,
  cnt2014 INT NULL,
  cnt2015 INT NULL,
  cnt2016 INT NULL
);

INSERT INTO dbo.EmpYearOrders(empid, cnt2014, cnt2015, cnt2016)
  SELECT empid, [2014] AS cnt2014, [2015] AS cnt2015, [2016] AS cnt2016
  FROM (SELECT empid, YEAR(orderdate) AS orderyear
        FROM dbo.Orders) AS D
    PIVOT(COUNT(orderyear)
          FOR orderyear IN([2014], [2015], [2016])) AS P;

SELECT * FROM dbo.EmpYearOrders;

-- UNPIVOT

SELECT *
FROM dbo.EmpYearOrders;

SELECT
	empid,
	RIGHT(orderyear,4) AS orderyear,
	ordersnum
FROM dbo.EmpYearOrders
	UNPIVOT(ordersnum FOR orderyear IN(cnt2014,cnt2015,cnt2016)) AS U;

-- ---------------------

SELECT empid, orderyear, numorders
FROM dbo.EmpYearOrders
  CROSS APPLY (VALUES(2014, cnt2014),
                     (2015, cnt2015),
                     (2016, cnt2016)) AS A(orderyear, numorders)
WHERE numorders <> 0;

-- ----------------------

SELECT empid, CAST(RIGHT(orderyear, 4) AS INT) AS orderyear, numorders
FROM dbo.EmpYearOrders
  UNPIVOT(numorders FOR orderyear IN(cnt2014, cnt2015, cnt2016)) AS U
WHERE numorders <> 0;

-- ---------------------------------------- Exercise 6

SELECT *
FROM dbo.Orders;

SELECT
	GROUPING_ID(empid, custid, YEAR(orderdate)) AS groupingset,
	empid,
	custid,
	YEAR(orderdate) AS orderyear,
	SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY
	GROUPING SETS
	(
		(empid,custid,YEAR(orderdate)),
		(empid,YEAR(orderdate)),
		(custid,YEAR(orderdate))
	)
ORDER BY
	groupingset,
	empid,
	custid,
	orderyear;
	
-- ---------------------------

DROP TABLE IF EXISTS dbo.Orders;









