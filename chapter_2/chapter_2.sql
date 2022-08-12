USE TSQLV4;

SELECT 
	empid, 
	YEAR(orderdate) AS orderyear, 
	COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

SELECT 
	orderid, 
	custid, 
	empid, 
	orderdate, 
	freight
FROM Sales.Orders;

SELECT orderid, empid, orderdate, freight
FROM Sales.Orders
WHERE custid = 71;

-- --------------------------------- GROUP BY

SELECT 
	empid,
	YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)

-- --------------------------------- GROUP / SUM

SELECT
  empid,
  YEAR(orderdate) AS orderyear,
  SUM(freight) AS totalfreight,
  COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);

-- --------------------------------- COUNT DISTINCT

SELECT
  empid,
  YEAR(orderdate) AS orderyear,
  COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY empid, YEAR(orderdate);

-- --------------------------------- HAVING

SELECT 
	empid, 
	YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;


-- --------------------------------- SELECT DISTINCT

SELECT DISTINCT 
	empid, 
	YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

-- ---------------------------------

SELECT *
FROM Sales.Shippers;

-- ---------------------------------

SELECT orderid,
  YEAR(orderdate) AS orderyear,
  YEAR(orderdate) + 1 AS nextyear
FROM Sales.Orders;

-- --------------------------------- ORDER BY

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

-- --------------------------------- ORDER BY

SELECT 
	empid, 
	firstname, 
	lastname, 
	country
FROM HR.Employees
ORDER BY hiredate;

-- --------------------------------- ORDER BY DISTINCT

SELECT DISTINCT country
FROM HR.Employees
ORDER BY country;

-- --------------------------------- TOP

SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC;

SELECT TOP (5) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

-- ----------------------------- WINDOW FUNCTIONS

SELECT orderid, custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid
                    ORDER BY val) AS rownum
FROM Sales.OrderValues
ORDER BY custid, val;

-- ----------------------------- IN

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid IN(10248, 10249, 10250);

-- ----------------------------- BETWEEN

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid BETWEEN 10300 AND 10310;

-- ----------------------------- LIKE

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

-- ----------------------------- OPERATORS

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20160101';

-- ----------------------------- AND / OR

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20160101'
  AND empid IN(1, 3, 5);

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE
        custid = 1
    AND empid IN(1, 3, 5)
    OR  custid = 85
    AND empid IN(2, 4, 6);

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE
      (custid = 1
        AND empid IN(1, 3, 5))
    OR
      (custid = 85
        AND empid IN(2, 4, 6));

-- ----------------------------- OPERATORS

SELECT orderid, productid, qty, unitprice, discount,
  qty * unitprice * (1 - discount) AS val
FROM Sales.OrderDetails;

-- ----------------------------- CASE

SELECT productid, productname, categoryid,
  CASE categoryid
    WHEN 1 THEN 'Beverages'
    WHEN 2 THEN 'Condiments'
    WHEN 3 THEN 'Confections'
    WHEN 4 THEN 'Dairy Products'
    WHEN 5 THEN 'Grains/Cereals'
    WHEN 6 THEN 'Meat/Poultry'
    WHEN 7 THEN 'Produce'
    WHEN 8 THEN 'Seafood'
    ELSE 'Unknown Category'
  END AS categoryname
FROM Production.Products;

SELECT orderid, custid, val,
  CASE
    WHEN val < 1000.00                   THEN 'Less than 1000'
    WHEN val BETWEEN 1000.00 AND 3000.00 THEN 'Between 1000 and 3000'
    WHEN val > 3000.00                   THEN 'More than 3000'
    ELSE 'Unknown'
  END AS valuecategory
FROM Sales.OrderValues;

-- ----------------------------------- NULL

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region = N'WA';

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA';

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS NULL;

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA'
   OR region IS NULL;

-- ---------------------------- COLLATION

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = N'davis';

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS = N'davis';

-- ----------------------------- OPERATORS AND FUNCTIONS

SELECT 
	empid, 
	firstname + N' ' + lastname AS fullname
FROM HR.Employees;

SELECT 
	custid, 
	country, 
	region, 
	city,
	country + N',' + region + N',' + city AS location
FROM Sales.Customers;

SELECT 
	custid, 
	country, 
	region, 
	city,
	country + COALESCE( N',' + region, N'') + N',' + city AS location
FROM Sales.Customers;

SELECT
	custid, 
	country, 
	region, 
	city,
	CONCAT(country, N',' + region, N',' + city) AS location
FROM Sales.Customers;

SELECT 
	empid, 
	lastname,
	LEN(lastname) - LEN(REPLACE(lastname, 'e', '')) AS numoccur
FROM HR.Employees;

SELECT 
	supplierid,
	RIGHT(REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)), 10) AS strsupplierid
FROM Production.Suppliers;

SELECT CAST(value AS INT) AS myvalue
FROM STRING_SPLIT('10248,10249,10250', ',') AS S;

-- -------------------------- LIKE

SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'_e%';

SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[ABC]%';

SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[A-E]%';

SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[^A-E]%';

-- ----------------------- DATE AND TIME

SELECT 
	orderid, 
	custid, 
	empid, 
	orderdate
FROM Sales.Orders
WHERE orderdate = '20160212';

SELECT 
	orderid, 
	custid, 
	empid, 
	orderdate
FROM Sales.Orders
WHERE orderdate = CAST('20160212' AS DATE);

SELECT CONVERT(DATE, '02/12/2016', 101);

SELECT CONVERT(DATE, '02/12/2016', 103);

SELECT PARSE('02/12/2016' AS DATE USING 'en-US');

SELECT PARSE('02/12/2016' AS DATE USING 'en-GB');

-- ------------

DROP TABLE IF EXISTS Sales.Orders2;

SELECT 
	orderid, 
	custid, 
	empid, 
	CAST(orderdate AS DATETIME) AS orderdate
INTO Sales.Orders2
FROM Sales.Orders;

SELECT *
FROM Sales.Orders2;

SELECT *
FROM Sales.Orders;

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders2
WHERE orderdate = '20160212';

ALTER TABLE Sales.Orders2
  ADD CONSTRAINT CHK_Orders2_orderdate
  CHECK( CONVERT(CHAR(12), orderdate, 114) = '00:00:00:000' );

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders2
WHERE orderdate >= '20160212'
  AND orderdate < '20160213';

 DROP TABLE IF EXISTS Sales.Orders2;

 -- --------

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE YEAR(orderdate) = 2016 AND MONTH(orderdate) = 2;

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20160201' AND orderdate < '20160301';

-- ---------

SELECT
  GETDATE()           AS [GETDATE],
  CURRENT_TIMESTAMP   AS [CURRENT_TIMESTAMP],
  GETUTCDATE()        AS [GETUTCDATE],
  SYSDATETIME()       AS [SYSDATETIME],
  SYSUTCDATETIME()    AS [SYSUTCDATETIME],
  SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

SELECT
  CAST(SYSDATETIME() AS DATE) AS [current_date],
  CAST(SYSDATETIME() AS TIME) AS [current_time];


SELECT CAST(SYSDATETIME() AS DATE);
SELECT CAST(SYSDATETIME() AS TIME);

SELECT CONVERT(DATETIME, CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112), 112);

SELECT PARSE('02/12/2016' AS DATETIME USING 'en-US');
SELECT PARSE('02/12/2016' AS DATETIME USING 'en-GB');

SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '-05:00');

SELECT
  CAST('20160212 12:00:00.0000000' AS DATETIME2)
    AT TIME ZONE 'Pacific Standard Time' AS val1,
  CAST('20160812 12:00:00.0000000' AS DATETIME2)
    AT TIME ZONE 'Pacific Standard Time' AS val2;

-- ---------

SELECT DATEADD(year, 1, '20160212');

SELECT DATEDIFF(day, '20150212', '20160212');

SELECT
  DATEADD(
    day,
    DATEDIFF(day, '19000101', SYSDATETIME()), '19000101');

SELECT
  DATEADD(
    month,
    DATEDIFF(month, '19000101', SYSDATETIME()), '19000101');

SELECT
  DATEADD(
    year,
    DATEDIFF(year, '18991231', SYSDATETIME()), '18991231');

-- -------------------

SELECT
  DAY('20160212') AS theday,
  MONTH('20160212') AS themonth,
  YEAR('20160212') AS theyear;

SELECT DATENAME(month, '20160212');

SELECT DATENAME(year, '20160212');

SELECT
  DATEFROMPARTS(2016, 02, 12),
  DATETIME2FROMPARTS(2016, 02, 12, 13, 30, 5, 1, 7),
  DATETIMEFROMPARTS(2016, 02, 12, 13, 30, 5, 997),
  DATETIMEOFFSETFROMPARTS(2016, 02, 12, 13, 30, 5, 1, -8, 0, 7),
  SMALLDATETIMEFROMPARTS(2016, 02, 12, 13, 30),
  TIMEFROMPARTS(13, 30, 5, 1, 7);

SELECT 
	orderid, 
	orderdate, 
	custid, 
	empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

-- ------------------------------------------------

USE TSQLV4;

SELECT SCHEMA_NAME(schema_id) AS table_schema_name, name AS table_name
FROM sys.tables;

SELECT
  name AS column_name,
  TYPE_NAME(system_type_id) AS column_type,
  max_length,
  collation_name,
  is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID(N'Sales.Orders');


SELECT 
	TABLE_SCHEMA, 
	TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = N'BASE TABLE';


SELECT
  COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
  COLLATION_NAME, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = N'Sales'
  AND TABLE_NAME = N'Orders';

EXEC sys.sp_tables;

EXEC sys.sp_help
  @objname = N'Sales.Orders';

EXEC sys.sp_columns
  @table_name = N'Orders',
  @table_owner = N'Sales';

EXEC sys.sp_helpconstraint
  @objname = N'Sales.Orders';