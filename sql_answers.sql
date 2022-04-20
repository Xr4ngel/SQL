--Project of Nir Shemri

-- Question 1

SELECT P.ProductID, Name, Color, ListPrice, Size
FROM Production.Product P
LEFT JOIN Sales.SalesOrderDetail SSOD ON P.ProductID = SSOD.ProductID
WHERE OrderQty IS NULL
ORDER BY P.ProductID;

-- Question 2

UPDATE Sales.Customer SET PersonID = CustomerID
WHERE CustomerID <= 290

UPDATE Sales.Customer SET PersonID = CustomerID + 1700
WHERE CustomerID >= 300 AND CustomerID <= 350

UPDATE Sales.Customer SET PersonID = CustomerID + 1700
WHERE CustomerID >= 352 AND CustomerID <= 701

SELECT SC.CustomerID,
CASE WHEN FirstName IS NULL THEN  'Unknown' ELSE FirstName END AS "FirstName",
CASE WHEN LastName IS NULL THEN 'Unknown' ELSE LastName END AS "LastName"
FROM Sales.Customer SC
LEFT JOIN Person.Person PP ON PP.BusinessEntityID = SC.PersonID
FULL JOIN Sales.SalesOrderHeader SSOH ON SSOH.CustomerID = SC.CustomerID
WHERE SSOH.SalesOrderID IS NULL
ORDER BY SC.CustomerID;

-- Question 3

WITH TOP_10_NumofOrders
AS
(
SELECT SC.CustomerID, PP.FirstName, PP.LastName,
COUNT(SSOH.SalesOrderID) AS "CountOfOrders"
FROM Sales.Customer SC
JOIN Person.Person PP ON PP.BusinessEntityID = SC.PersonID
JOIN Sales.SalesOrderHeader SSOH ON SSOH.CustomerID = SC.CustomerID
GROUP BY SC.CustomerID, FirstName, LastName
)
SELECT TOP 10 *
FROM TOP_10_NumofOrders
ORDER BY CountOfOrders DESC;

-- Question 4

SELECT FirstName, LastName, JobTitle, HireDate,
COUNT(JobTitle)OVER(PARTITION BY JobTitle) AS "CountOfTitle"
FROM Person.Person PP
JOIN HumanResources.Employee HRE ON PP.BusinessEntityID = HRE.BusinessEntityID;

-- Question 5

WITH Last_2_Orders
AS
(
SELECT SalesOrderID, SC.CustomerID, LastName, FirstName, OrderDate,
MAX(OrderDate)OVER(PARTITION BY SC.CustomerID ORDER BY OrderDate DESC) AS "Last Order",
LAG(OrderDate)OVER(PARTITION BY SC.CustomerID ORDER BY OrderDate) AS "Previous Order"
FROM Sales.SalesOrderHeader SSOH
JOIN Sales.Customer SC ON SSOH.CustomerID = SC.CustomerID
JOIN Person.Person PP ON SC.PersonID = PP.BusinessEntityID
)
SELECT *
FROM Last_2_Orders
WHERE [Last Order] = OrderDate;

-- Question 6

SELECT Year, SalesOrderID, LastName, FirstName, Total
FROM(
SELECT *, ROW_NUMBER()OVER(PARTITION BY YEAR ORDER BY Total DESC) AS "RN"
FROM(
SELECT YEAR(OrderDate) AS "Year", SSOH.SalesOrderID, LastName, FirstName,
SUM(LineTotal)OVER(PARTITION BY SSOH.SalesOrderID ORDER BY YEAR(OrderDate)) AS "Total"
FROM Sales.SalesOrderHeader SSOH
JOIN Sales.Customer SC ON SSOH.CustomerID = SC.CustomerID
JOIN Person.Person PP ON SC.PersonID = PP.BusinessEntityID
JOIN Sales.SalesOrderDetail SSOD ON SSOH.SalesOrderID = SSOD.SalesOrderID)a)b
WHERE RN = 1;

-- Question 7

WITH Num_of_Orders
AS
(
SELECT MONTH(OrderDate) AS "Month", YEAR(OrderDate) AS "Year", SalesOrderID
FROM Sales.SalesOrderHeader
)
SELECT *
FROM Num_of_Orders
PIVOT(COUNT(SalesOrderID) FOR YEAR IN ([2011],[2012],[2013],[2014]))PIV
ORDER BY Month;

-- Question 8

SELECT DISTINCT YEAR(OrderDate) AS "Year", STR(MONTH(OrderDate)) AS "Month",
SUM(LineTotal) OVER(PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) AS "Sum_Price",
SUM(LineTotal)OVER(PARTITION BY YEAR(OrderDate) ORDER BY YEAR(OrderDate), MONTH(OrderDate)) AS "Money"
FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
UNION
SELECT DISTINCT YEAR(OrderDate) AS "Year", 'grand_total', NULL, SUM(LineTotal) OVER(PARTITION BY YEAR(OrderDate))
FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
ORDER BY Year, Month;

-- Question 9


SELECT D.Name, E.BusinessEntityID, P.FirstName + ' ' + P.LastName AS "Employee's Full Name",  E.HireDate, EndDate,
DATEDIFF(M, HireDate, GETDATE()) AS "Seniority",
LAG(FirstName + ' ' + LastName, 1)OVER(PARTITION BY D.DepartmentID ORDER BY E.HireDate) AS "PreviousEmpName",
LAG(HireDate, 1)OVER(PARTITION BY D.DepartmentID ORDER BY HireDate) AS "PreviousEmpHDate",
DATEDIFF(DD, LAG(HireDate, 1)OVER(PARTITION BY D.DepartmentID ORDER BY HireDate), HireDate) AS "DiffDays"
FROM HumanResources.Department D
JOIN HumanResources.EmployeeDepartmentHistory EDH ON D.DepartmentID = EDH.DepartmentID
JOIN HumanResources.Employee E ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN Person.Person P ON P.BusinessEntityID = E.BusinessEntityID
WHERE EndDate IS NULL
ORDER BY D.Name, E.HireDate DESC;


-- Question 10

SELECT HireDate, D.DepartmentID, STRING_AGG(CONCAT(E.BusinessEntityID, ' ', LastName, ' ', FirstName), ', ') AS "a"
FROM HumanResources.Employee E
JOIN HumanResources.EmployeeDepartmentHistory EDH ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D ON D.DepartmentID = EDH.DepartmentID
JOIN Person.Person PP ON PP.BusinessEntityID = E.BusinessEntityID
WHERE EndDate IS NULL
GROUP BY HireDate, D.DepartmentID;
