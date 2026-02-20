/* Part I – Queries for SoftUni Database */

USE [SoftUni]
GO

-- 01. Find Names of All Employees by First Name
SELECT [FirstName],
       [LastName]
  FROM [Employees]
 WHERE [FirstName] LIKE 'Sa%'

GO

-- 02. Find Names of All Employees by Last Name 
SELECT [FirstName],
       [LastName]
  FROM [Employees]
 WHERE [LastName] LIKE '%ei%'

GO

-- 03. Find First Names of All Employees
SELECT [FirstName]
  FROM [Employees]
 WHERE [DepartmentID] IN (3, 10) AND
       DATEPART(YEAR, [HireDate]) BETWEEN 1995 AND 2005

GO

-- 04. Find All Employees Except Engineers
SELECT [FirstName],
       [LastName]
  FROM [Employees]
 WHERE CHARINDEX('engineer', LOWER([JobTitle])) = 0

GO

-- 05. Find Towns with Name Length
  SELECT [Name]
    FROM [Towns]
   WHERE LEN([Name]) BETWEEN 5 AND 6
ORDER BY [Name] ASC
  
GO

-- 06. Find Towns Starting With
  SELECT [TownID],
         [Name]
    FROM [Towns]
   WHERE LEFT([Name], 1) IN ('M', 'K', 'B', 'E')
ORDER BY [Name] ASC
  
GO

-- 07. Find Towns Not Starting With
  SELECT [TownID],
         [Name]
    FROM [Towns]
   WHERE LEFT([Name], 1) NOT IN ('R', 'B', 'D')
ORDER BY [Name] ASC
  
GO

-- 08. Create View Employees Hired After 2000 Year
CREATE VIEW V_EmployeesHiredAfter2000 AS
     SELECT [FirstName],
            [LastName]
       FROM [Employees]
      WHERE DATEPART(YEAR, [HireDate]) > 2000

GO

-- 09. Length of Last Name
SELECT [FirstName],
       [LastName]
  FROM [Employees]
 WHERE LEN([LastName]) = 5

GO

-- 10. Rank Employees by Salary
  SELECT [EmployeeID],
         [FirstName],
         [LastName],
         [Salary],
         DENSE_RANK() OVER (PARTITION BY [Salary] ORDER BY [EmployeeID])
      AS [Rank]
    FROM [Employees]
   WHERE [Salary] BETWEEN 10000 AND 50000
ORDER BY [Salary] DESC
  
GO

-- 11. Find All Employees with Rank 2
  SELECT *
    FROM (SELECT [EmployeeID],
                 [FirstName],
                 [LastName],
                 [Salary],
                 DENSE_RANK() OVER (PARTITION BY [Salary] ORDER BY [EmployeeID])
              AS [Rank]
            FROM [Employees]
           WHERE [Salary] BETWEEN 10000 AND 50000)
      AS [EmployeesRanked]
   WHERE [Rank] = 2
ORDER BY [Salary] DESC

GO

/* Part II – Queries for Geography Database */

USE [Geography]
GO

-- 12. Countries Holding 'A' 3 or More Times
  SELECT [CountryName],
         [IsoCode]
    FROM [Countries]
   WHERE LEN([CountryName]) - LEN(REPLACE(LOWER([CountryName]), 'a', '')) >= 3
ORDER BY [IsoCode] ASC
  
GO

-- 13. Mix of Peak and River Names
  SELECT [p].[PeakName],
         [r].[RiverName],
         LOWER(STUFF([PeakName], LEN([PeakName]), 1, [RiverName]))
      AS [Mix]
    FROM [Peaks]
      AS [p],
         [Rivers]
      AS [r]
   WHERE RIGHT([p].[PeakName], 1) = LEFT([r].[RiverName], 1)
ORDER BY [Mix] ASC
  
GO

/* Part III – Queries for Diablo Database */

USE [Diablo]
GO

-- 14. Games from 2011 and 2012 Year
SELECT TOP 50 [Name],
              FORMAT([Start], 'yyyy-MM-dd')
    AS [Start]
  FROM [Games]
 WHERE DATEPART(YEAR, [Start]) IN (2011, 2012)
ORDER BY [Start] ASC,
         [Name] ASC

GO

-- 15. User Email Providers
  SELECT [Username],
         SUBSTRING([Email], CHARINDEX('@', [Email]) + 1, LEN([Email]))
      AS [Email Provider]
    FROM [Users]
ORDER BY [Email Provider] ASC,
         [Username] ASC

GO

-- 16. Get Users with IP Address Like Pattern
  SELECT [Username],
         [IpAddress]
    FROM [Users]
   WHERE [IpAddress] LIKE '___.1%.%.___'
ORDER BY [Username] ASC
  
GO

-- 17. Show All Games with Duration and Part of the Day
  SELECT [Name],
         CASE 
             WHEN DATEPART(HOUR, [Start]) BETWEEN 0 AND 11 THEN 'Morning'
             WHEN DATEPART(HOUR, [Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
         END
      AS [Part of the Day],
         CASE 
             WHEN [Duration] <= 3 THEN 'Extra Short'
             WHEN [Duration] BETWEEN 4 AND 6 THEN 'Short'
             WHEN [Duration] > 6 THEN 'Long'
             WHEN [Duration] IS NULL THEN 'Extra Long'
         END
      AS [Duration]
    FROM [Games]
ORDER BY [Name] ASC,
         [Duration] ASC,
         [Part of the Day] ASC
  
GO

/* Part IV – Date Functions Queries */

USE [Orders]
GO

-- 18. Orders Table
SELECT [ProductName],
       [OrderDate],
       DATEADD(DAY, 3, [OrderDate])
    AS [Pay Due],
       DATEADD(MONTH, 1, [OrderDate])
    AS [Deliver Due]
  FROM [Orders]

GO

-- End of the script