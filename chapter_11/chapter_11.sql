USE TSQLV4;

-- --------------------------------- VARIABLES

DECLARE @i AS INT;
SET @i = 10;
GO
DECLARE @i AS INT = 10;
GO

-- VARIABLES - SCALAR SUBQUERY

DECLARE @empname AS NVARCHAR(61);

SET @empname = (SELECT firstname + N' ' + lastname
                FROM HR.Employees
                WHERE empid = 3);

SELECT @empname AS empname;

-- TWO OR MORE VARIABLES - SCALAR SUBQUERY

DECLARE @firstname AS NVARCHAR(20), @lastname AS NVARCHAR(40);

SET @firstname = (SELECT firstname
                  FROM HR.Employees
                  WHERE empid = 3);
SET @lastname = (SELECT lastname
                 FROM HR.Employees
                 WHERE empid = 3);

SELECT @firstname AS firstname, @lastname AS lastname;

-- TWO VARIABLES - NON STANDARD

GO
DECLARE @firstname AS NVARCHAR(20), @lastname AS NVARCHAR(40);

SELECT
  @firstname = firstname,
  @lastname  = lastname
FROM HR.Employees
WHERE empid = 3;

SELECT @firstname AS firstname, @lastname AS lastname;
GO

-- TWO QUALIFYING ROWS

DECLARE @empname AS NVARCHAR(61);

SELECT @empname = firstname + N' ' + lastname
FROM HR.Employees
WHERE mgrid = 2;

SELECT @empname AS empname;

-- --------------------------------- BATCHES

-- Valid batch
PRINT 'First batch';
USE TSQLV4;
GO
-- Valid batch
PRINT 'Third batch';
SELECT empid FROM HR.Employees;
GO

-- VARIABLES IN BATCH

DECLARE @i AS INT;
SET @i = 10;
-- Succeeds
PRINT @i;
GO

-- STATEMENTS THAT CANNOT BE COMBINED IN THE SAME BATCH

-- The following statements cannot be combined with other statements in the same batch: 
-- CREATE DEFAULT, CREATE FUNCTION, CREATE PROCEDURE, CREATE RULE, CREATE SCHEMA, CREATE TRIGGER, and CREATE VIEW. 

-- THE GO n OPTION

-- --------------------------------- FLOW ELEMENTS

-- IF ELSE - BEGIN/END

IF YEAR(SYSDATETIME()) <> YEAR(DATEADD(day, 1, SYSDATETIME()))
  PRINT 'Today is the last day of the year.';
ELSE
  PRINT 'Today is not the last day of the year.';

-- ---

IF YEAR(SYSDATETIME()) <> YEAR(DATEADD(day, 1, SYSDATETIME()))
  PRINT 'Today is the last day of the year.';
ELSE
  IF MONTH(SYSDATETIME()) <> MONTH(DATEADD(day, 1, SYSDATETIME()))
    PRINT 'Today is the last day of the month but not the last day of the year.';
  ELSE
    PRINT 'Today is not the last day of the month.';

-- ---

IF DAY(SYSDATETIME()) = 1
BEGIN
  PRINT 'Today is the first day of the month.';
  PRINT 'Starting first-of-month-day process.';
  /* ... process code goes here ... */
  PRINT 'Finished first-of-month-day database process.';
END;
ELSE
BEGIN
  PRINT 'Today is not the first day of the month.';
  PRINT 'Starting non-first-of-month-day process.';
  /* ... process code goes here ... */
  PRINT 'Finished non-first-of-month-day process.';
END;

-- WHILE

DECLARE @i AS INT = 1;
WHILE @i <= 10
BEGIN
  PRINT @i;
  SET @i = @i + 1;
END;

-- ----

GO
DECLARE @i AS INT = 1;
WHILE @i <= 10
BEGIN
  IF @i = 6 BREAK;
  PRINT @i;
  SET @i = @i + 1;
END;
GO

-- ----

DECLARE @i AS INT = 0;
WHILE @i < 10
BEGIN
  SET @i = @i + 1;
  IF @i = 6 CONTINUE;
  PRINT @i;
END;

-- INSERT INTO

SET NOCOUNT ON;
DROP TABLE IF EXISTS dbo.Numbers;
CREATE TABLE dbo.Numbers(n INT NOT NULL PRIMARY KEY);
GO

DECLARE @i AS INT = 1;
WHILE @i <= 1000
BEGIN
  INSERT INTO dbo.Numbers(n) VALUES(@i);
  SET @i = @i + 1;
END;

-- --------------------------------- CURSORS

-- WORKING WITH CURSORS
-- 1. Declare the cursor based on a query.
-- 2. Open the cursor.
-- 3. Fetch attribute values from the first cursor record into variables.
-- 4. As long as you haven’t reached the end of the cursor (while the value of a function called
--    @@FETCH_STATUS is 0), loop through the cursor records; in each iteration of the loop, 
--    perform the processing needed for the current row, and then fetch the attribute values from the next row into the variables.
-- 5. Close the cursor.
-- 6. Deallocate the cursor.

SET NOCOUNT ON;
-- When SET NOCOUNT is ON, the count is not returned. When SET NOCOUNT is OFF, the count is returned.
-- The @@ROWCOUNT function is updated even when SET NOCOUNT is ON.

-- result table
DECLARE @Result AS TABLE
(
  custid     INT,
  ordermonth DATE,
  qty        INT,
  runqty     INT,
  PRIMARY KEY(custid, ordermonth)
);

-- variables
DECLARE
  @custid     AS INT,
  @prvcustid  AS INT,
  @ordermonth AS DATE,
  @qty        AS INT,
  @runqty     AS INT;

-- cursor
DECLARE C CURSOR FAST_FORWARD /* read only, forward only */ FOR
  SELECT custid, ordermonth, qty
  FROM Sales.CustOrders
  ORDER BY custid, ordermonth;

-- open cursor
OPEN C;

-- fetch next
FETCH NEXT FROM C INTO @custid, @ordermonth, @qty;

SELECT @prvcustid = @custid, @runqty = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @custid <> @prvcustid
    SELECT @prvcustid = @custid, @runqty = 0;

  -- runqty calculation
  SET @runqty = @runqty + @qty;
  
  -- insert into result
  INSERT INTO @Result VALUES(@custid, @ordermonth, @qty, @runqty);

  FETCH NEXT FROM C INTO @custid, @ordermonth, @qty;
END;

-- closing
CLOSE C;

-- deallocating
DEALLOCATE C;

-- SELECT FROM results
SELECT
  custid,
  CONVERT(VARCHAR(7), ordermonth, 121) AS ordermonth,
  qty,
  runqty
FROM @Result
ORDER BY custid, ordermonth;

-- --------------------------------- TEMPORARY TABLES

DROP TABLE IF EXISTS #MyOrderTotalsByYear;
GO

CREATE TABLE #MyOrderTotalsByYear
(
  orderyear INT NOT NULL PRIMARY KEY,
  qty       INT NOT NULL
);

INSERT INTO #MyOrderTotalsByYear(orderyear, qty)
  SELECT
    YEAR(O.orderdate) AS orderyear,
    SUM(OD.qty) AS qty
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON OD.orderid = O.orderid
  GROUP BY YEAR(orderdate);

-- self join
SELECT Cur.orderyear, Cur.qty AS curyearqty, Prv.qty AS prvyearqty
FROM #MyOrderTotalsByYear AS Cur
  LEFT OUTER JOIN #MyOrderTotalsByYear AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

-- --------------------------------- TABLE VARIABLES

DECLARE @MyOrderTotalsByYear TABLE
(
  orderyear INT NOT NULL PRIMARY KEY,
  qty       INT NOT NULL
);

INSERT INTO @MyOrderTotalsByYear(orderyear, qty)
  SELECT
    YEAR(O.orderdate) AS orderyear,
    SUM(OD.qty) AS qty
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON OD.orderid = O.orderid
  GROUP BY YEAR(orderdate);

-- self join
SELECT Cur.orderyear, Cur.qty AS curyearqty, Prv.qty AS prvyearqty
FROM @MyOrderTotalsByYear AS Cur
  LEFT OUTER JOIN @MyOrderTotalsByYear AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

-- --------------------------------- TYPE TABLES

GO
DROP TYPE IF EXISTS dbo.OrderTotalsByYear;

CREATE TYPE dbo.OrderTotalsByYear AS TABLE
(
  orderyear INT NOT NULL PRIMARY KEY,
  qty       INT NOT NULL
);
GO
-- using table type
DECLARE @MyOrderTotalsByYear AS dbo.OrderTotalsByYear; -- variable declaration as table type

INSERT INTO @MyOrderTotalsByYear(orderyear, qty)
  SELECT
    YEAR(O.orderdate) AS orderyear,
    SUM(OD.qty) AS qty
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON OD.orderid = O.orderid
  GROUP BY YEAR(orderdate);

SELECT orderyear, qty FROM @MyOrderTotalsByYear;
GO

-- --------------------------------- DYNAMIC SQL

--  Automating administrative tasks
--	Improving performance of certain tasks
--	Constructing elements of the code based on querying the actual data

-- EXEC COMMAND

DECLARE @sql AS VARCHAR(100);
SET @sql = 'PRINT ''This message was printed by a dynamic SQL batch.'';';
EXEC(@sql);

-- SP_EXECUTESQL STORED PROCEDURE

GO
DECLARE @sql AS NVARCHAR(100);

SET @sql = N'SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderid = @orderid;';

EXEC sp_executesql
  @stmt = @sql,
  @params = N'@orderid AS INT',
  @orderid = 10248;
GO

-- PIVOT WITH DYNAMIC SQL

SELECT *
FROM (SELECT shipperid, YEAR(orderdate) AS orderyear, freight
      FROM Sales.Orders) AS D
  PIVOT(SUM(freight) FOR orderyear IN([2014],[2015],[2016])) AS P;

-- --

DECLARE
  @sql       AS NVARCHAR(1000),
  @orderyear AS INT,
  @first     AS INT;

-- cursor declaration
DECLARE C CURSOR FAST_FORWARD FOR
  SELECT DISTINCT(YEAR(orderdate)) AS orderyear
  FROM Sales.Orders
  ORDER BY orderyear;

SET @first = 1;

-- dynamic query first part
SET @sql = N'SELECT *
FROM (SELECT shipperid, YEAR(orderdate) AS orderyear, freight
      FROM Sales.Orders) AS D
  PIVOT(SUM(freight) FOR orderyear IN(';

OPEN C;

FETCH NEXT FROM C INTO @orderyear;

WHILE @@fetch_status = 0
BEGIN
  IF @first = 0
    SET @sql += N','
  ELSE
    SET @first = 0;

  SET @sql += QUOTENAME(@orderyear);

  FETCH NEXT FROM C INTO @orderyear;
END;

CLOSE C;

DEALLOCATE C;

-- dynamic query second part
SET @sql += N')) AS P;';

EXEC sp_executesql @stmt = @sql;

-- --------------------------------- USER-DEFINED FUNCTIONS - UDFs

DROP FUNCTION IF EXISTS dbo.GetAge;
GO

CREATE FUNCTION dbo.GetAge
(
  @birthdate AS DATE,
  @eventdate AS DATE
)
RETURNS INT
AS
BEGIN
  RETURN
    DATEDIFF(year, @birthdate, @eventdate)
    - CASE WHEN 100 * MONTH(@eventdate) + DAY(@eventdate)
              < 100 * MONTH(@birthdate) + DAY(@birthdate)
           THEN 1 ELSE 0
      END;
END;
GO

SELECT
  empid, firstname, lastname, birthdate,
  dbo.GetAge(birthdate, SYSDATETIME()) AS age
FROM HR.Employees;

-- --------------------------------- STORED PROCEDURES

-- Stored procedures encapsulate logic
-- Stored procedures give you better control of security
-- You can incorporate all error-handling code within a procedure, silently taking corrective action where relevant
-- Stored procedures give you performance benefits

DROP PROC IF EXISTS Sales.GetCustomerOrders;
GO

CREATE PROC Sales.GetCustomerOrders
  @custid   AS INT,
  @fromdate AS DATETIME = '19000101',
  @todate   AS DATETIME = '99991231',
  @numrows  AS INT OUTPUT
AS
SET NOCOUNT ON;

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE custid = @custid
  AND orderdate >= @fromdate
  AND orderdate < @todate;

SET @numrows = @@rowcount;
GO

-- EXECUTION

DECLARE @rc AS INT;

EXEC Sales.GetCustomerOrders
  @custid   = 1,
  @fromdate = '20150101',
  @todate   = '20160101',
  @numrows  = @rc OUTPUT;

SELECT @rc AS numrows;

-- --------------------------------- TRIGGERS

-- ---------- DML TRIGGERS

DROP TABLE IF EXISTS dbo.T1_Audit, dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.T1_Audit
(
  audit_lsn  INT          NOT NULL IDENTITY PRIMARY KEY,
  dt         DATETIME2(3) NOT NULL DEFAULT(SYSDATETIME()),
  login_name sysname      NOT NULL DEFAULT(ORIGINAL_LOGIN()),
  keycol     INT          NOT NULL,
  datacol    VARCHAR(10)  NOT NULL
);

-- TRIGGER creation

GO
CREATE TRIGGER trg_T1_insert_audit ON dbo.T1 AFTER INSERT
AS
SET NOCOUNT ON;

INSERT INTO dbo.T1_Audit(keycol, datacol)
  SELECT keycol, datacol FROM inserted;
GO

INSERT INTO dbo.T1(keycol, datacol) VALUES(10, 'a');
INSERT INTO dbo.T1(keycol, datacol) VALUES(30, 'x');
INSERT INTO dbo.T1(keycol, datacol) VALUES(20, 'g');

SELECT audit_lsn, dt, login_name, keycol, datacol
FROM dbo.T1_Audit;

DROP TABLE dbo.T1_Audit, dbo.T1;

-- ---------- DDL TRIGGERS

DROP TABLE IF EXISTS dbo.AuditDDLEvents;

CREATE TABLE dbo.AuditDDLEvents
(
  audit_lsn        INT          NOT NULL IDENTITY,
  posttime         DATETIME2(3) NOT NULL,
  eventtype        sysname      NOT NULL,
  loginname        sysname      NOT NULL,
  schemaname       sysname      NOT NULL,
  objectname       sysname      NOT NULL,
  targetobjectname sysname      NULL,
  eventdata        XML          NOT NULL,
  CONSTRAINT PK_AuditDDLEvents PRIMARY KEY(audit_lsn)
);

GO
CREATE TRIGGER trg_audit_ddl_events
  ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
AS
SET NOCOUNT ON;

DECLARE @eventdata AS XML = eventdata();

INSERT INTO dbo.AuditDDLEvents(
  posttime, eventtype, loginname, schemaname,
  objectname, targetobjectname, eventdata)
  VALUES(
    @eventdata.value('(/EVENT_INSTANCE/PostTime)[1]',         'VARCHAR(23)'),
    @eventdata.value('(/EVENT_INSTANCE/EventType)[1]',        'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/LoginName)[1]',        'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/SchemaName)[1]',       'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/ObjectName)[1]',       'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/TargetObjectName)[1]', 'sysname'),
    @eventdata);
GO

CREATE TABLE dbo.T1(col1 INT NOT NULL PRIMARY KEY);
ALTER TABLE dbo.T1 ADD col2 INT NULL;
ALTER TABLE dbo.T1 ALTER COLUMN col2 INT NOT NULL;
CREATE NONCLUSTERED INDEX idx1 ON dbo.T1(col2);

SELECT * FROM dbo.AuditDDLEvents;

DROP TRIGGER IF EXISTS trg_audit_ddl_events ON DATABASE;
DROP TABLE IF EXISTS dbo.AuditDDLEvents;

-- --------------------------------- ERROR HANDLING

-- TRY / CATCH

BEGIN TRY
  PRINT 10/2;
  PRINT 'No error';
END TRY
BEGIN CATCH
  PRINT 'Error';
END CATCH;

BEGIN TRY
  PRINT 10/0;
  PRINT 'No error';
END TRY
BEGIN CATCH
  PRINT 'Error';
END CATCH;

-- ----

CREATE TABLE dbo.Employees
(
  empid   INT         NOT NULL,
  empname VARCHAR(25) NOT NULL,
  mgrid   INT         NULL,
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
  CONSTRAINT CHK_Employees_empid CHECK(empid > 0),
  CONSTRAINT FK_Employees_Employees
    FOREIGN KEY(mgrid) REFERENCES dbo.Employees(empid)
);

--

BEGIN TRY

  INSERT INTO dbo.Employees(empid, empname, mgrid)
    VALUES(1, 'Emp1', NULL);
  -- Also try with empid = 0, 'A', NULL

END TRY
BEGIN CATCH

  IF ERROR_NUMBER() = 2627
  BEGIN
    PRINT '    Handling PK violation...';
  END;
  ELSE IF ERROR_NUMBER() = 547
  BEGIN
    PRINT '    Handling CHECK/FK constraint violation...';
  END;
  ELSE IF ERROR_NUMBER() = 515
  BEGIN
    PRINT '    Handling NULL violation...';
  END;
  ELSE IF ERROR_NUMBER() = 245
  BEGIN
    PRINT '    Handling conversion error...';
  END;
  ELSE
  BEGIN
    PRINT 'Re-throwing error...';
    THROW;
  END;

  PRINT '    Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
  PRINT '    Error Message : ' + ERROR_MESSAGE();
  PRINT '    Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
  PRINT '    Error State   : ' + CAST(ERROR_STATE() AS VARCHAR(10));
  PRINT '    Error Line    : ' + CAST(ERROR_LINE() AS VARCHAR(10));
  PRINT '    Error Proc    : ' + COALESCE(ERROR_PROCEDURE(), 'Not within proc');

END CATCH;

-- example

DROP PROC IF EXISTS dbo.ErrInsertHandler;
GO

CREATE PROC dbo.ErrInsertHandler
AS
SET NOCOUNT ON;

IF ERROR_NUMBER() = 2627
BEGIN
  PRINT 'Handling PK violation...';
END;
ELSE IF ERROR_NUMBER() = 547
BEGIN
  PRINT 'Handling CHECK/FK constraint violation...';
END;
ELSE IF ERROR_NUMBER() = 515
BEGIN
  PRINT 'Handling NULL violation...';
END;
ELSE IF ERROR_NUMBER() = 245
BEGIN
  PRINT 'Handling conversion error...';
END;

PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
PRINT 'Error Message : ' + ERROR_MESSAGE();
PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
PRINT 'Error State   : ' + CAST(ERROR_STATE() AS VARCHAR(10));
PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS VARCHAR(10));
PRINT 'Error Proc    : ' + COALESCE(ERROR_PROCEDURE(), 'Not within proc');
GO

-- ----

BEGIN TRY

  INSERT INTO dbo.Employees(empid, empname, mgrid)
    VALUES(1, 'Emp1', NULL);

END TRY
BEGIN CATCH

  IF ERROR_NUMBER() IN (2627, 547, 515, 245)
    EXEC dbo.ErrInsertHandler;
  ELSE
    THROW;

END CATCH;