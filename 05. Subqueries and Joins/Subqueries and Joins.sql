/* Part I – Queries for SoftUni Database */

USE [SoftUni]
GO

-- 01. Employee Address
    SELECT TOP (5)
           [e].[EmployeeID]
        AS [EmployeeId],
           [e].[JobTitle],
           [e].[AddressID]
        AS [AddressId],
           [a].[AddressText]
      FROM [Employees]
        AS [e]
INNER JOIN [Addresses]
        AS [a]
        ON [e].[AddressID] = [a].[AddressID]
  ORDER BY [e].[AddressID] ASC
     
GO

-- 02. Addresses with Towns
  SELECT TOP (50)
         [e].[FirstName],
         [e].[LastName],
         [t].[Name]
      AS [Town],
         [a].[AddressText]
    FROM [Employees]
      AS [e]
    JOIN [Addresses]
      AS [a]
      ON [e].[AddressID] = [a].[AddressID]
    JOIN [Towns]
      AS [t]
      ON [a].[TownID] = [t].[TownID]
ORDER BY [e].[FirstName] ASC,
         [e].[LastName] ASC
  
GO

-- 03. Sales Employee
  SELECT [e].[EmployeeID],
         [e].[FirstName],
         [e].[LastName],
         [d].[Name]
      AS [DepartmentName]
    FROM [Employees]
      AS [e]
    JOIN [Departments]
      AS [d]
      ON [e].[DepartmentID] = [d].[DepartmentID]
   WHERE [d].[Name] = 'Sales'
ORDER BY [e].[EmployeeID] ASC
  
GO

-- 04. Employee Departments
  SELECT TOP (5)
         [e].[EmployeeID],
         [e].[FirstName],
         [e].[Salary],
         [d].[Name]
      AS [DepartmentName]
    FROM [Employees]
      AS [e]
    JOIN [Departments]
      AS [d]
      ON [e].[DepartmentID] = [d].[DepartmentID]
   WHERE [e].[Salary] > 15000
ORDER BY [e].[DepartmentID] ASC
  
GO

-- 05. Employees Without Project
   SELECT TOP (3)
          [e].[EmployeeID],
          [e].[FirstName]
     FROM [Employees]
       AS [e]
LEFT JOIN [EmployeesProjects]
       AS [ep]
       ON [e].[EmployeeID] = [ep].[EmployeeID]
    WHERE [ep].[EmployeeID] IS NULL
 ORDER BY [e].[EmployeeID] ASC
   
GO

-- 06. Employees Hired After
  SELECT [e].[FirstName],
         [e].[LastName],
         [e].[HireDate],
         [d].[Name]
      AS [DeptName]
    FROM [Employees]
      AS [e]
    JOIN [Departments]
      AS [d]
      ON [e].[DepartmentID] = [d].[DepartmentID]
   WHERE [e].[HireDate] > '1999-01-01'
     AND [d].[Name] IN ('Sales', 'Finance')
ORDER BY [e].[HireDate] ASC
  
GO

-- 07. Employees with Project
  SELECT TOP (5)
         [e].[EmployeeID],
         [e].[FirstName],
         [p].[Name]
      AS [ProjectName]
    FROM [Employees]
      AS [e]
    JOIN [EmployeesProjects]
      AS [ep]
      ON [e].[EmployeeID] = [ep].[EmployeeID]
    JOIN [Projects]
      AS [p]
      ON [ep].[ProjectID] = [p].[ProjectID]
   WHERE [p].[StartDate] > '2002-08-13'
     AND [p].[EndDate] IS NULL
ORDER BY [e].[EmployeeID] ASC
  
GO

-- 08. Employee 24
SELECT [EmployeeID],
       [FirstName],
       CASE 
           WHEN DATEPART(YEAR, [StartDate]) >= 2005 THEN NULL
           ELSE [Name]
       END
    AS [ProjectName]
  FROM (SELECT [e].[EmployeeID],
               [e].[FirstName],
               [p].[Name],
               [p].[StartDate]
          FROM [Employees]
            AS [e]
          JOIN [EmployeesProjects]
            AS [ep]
            ON [e].[EmployeeID] = [ep].[EmployeeID]
          JOIN [Projects]
            AS [p]
            ON [ep].[ProjectID] = [p].[ProjectID]
         WHERE [e].[EmployeeID] = 24)
    AS [ProjectsOfEmployeeWithId24]

GO

-- 09. Employee Manager
  SELECT [e].[EmployeeID],
         [e].[FirstName],
         [e].[ManagerID],
         [m].[FirstName]
      AS [ManagerName]
    FROM [Employees]
      AS [e]
    JOIN [Employees]
      AS [m]
      ON [e].[ManagerID] = [m].[EmployeeID]
   WHERE [e].[ManagerID] IN (3, 7)
ORDER BY [e].[EmployeeID] ASC
  
GO

-- 10. Employees Summary
  SELECT TOP (50)
         [e].[EmployeeID],
         CONCAT_WS(' ', [e].[FirstName], [e].[LastName])
      AS [EmployeeName],
         CONCAT_WS(' ', [m].[FirstName], [m].[LastName])
      AS [ManagerName],
         [d].[Name]
      AS [DepartmentName]
    FROM [Employees]
      AS [e]
    JOIN [Employees]
      AS [m]
      ON [e].[ManagerID] = [m].[EmployeeID]
    JOIN [Departments]
      AS [d]
      ON [e].[DepartmentID] = [d].[DepartmentID]
ORDER BY [e].[EmployeeID] ASC
  
GO

-- 11. Min Average Salary
SELECT MIN(AverageSalaryTable.AverageSalary)
    AS [MinAverageSalary]
  FROM (
        SELECT [e].[DepartmentID],
               AVG([e].[Salary])
            AS [AverageSalary]
          FROM [Employees]
            AS [e]
      GROUP BY [e].[DepartmentID])
    AS [AverageSalaryTable]
  
GO

/* Part II – Queries for Geography Database */

USE Geography
GO

-- 12. Highest Peaks in Bulgaria
  SELECT [c].[CountryCode],
         [m].[MountainRange],
         [p].[PeakName],
         [p].[Elevation]
    FROM [Countries]
      AS [c]
    JOIN [MountainsCountries]
      AS [mc]
      ON [c].[CountryCode] = [mc].[CountryCode]
    JOIN [Mountains]
      AS [m]
      ON [mc].[MountainId] = [m].[Id]
    JOIN [Peaks]
      AS [p]
      ON [m].[Id] = [p].[MountainId]
   WHERE [c].[CountryName] = 'Bulgaria'
     AND [p].[Elevation] > 2835
ORDER BY [p].[Elevation] DESC

GO

-- 13. Count Mountain Ranges
  SELECT [c].[CountryCode],
         COUNT([m].[MountainRange])
      AS [MountainRanges]
    FROM [Countries]
      AS [c]
    JOIN [MountainsCountries] 
      AS [mc]  
      ON [c].[CountryCode] = [mc].[CountryCode]
    JOIN [Mountains]
      AS [m]
      ON [mc].[MountainId] = [m].[Id]
   WHERE [c].[CountryName] IN ('United States', 'Russia', 'Bulgaria')
GROUP BY [c].[CountryCode]
  
GO

-- 14. Countries With or Without Rivers
   SELECT TOP (5)
          [c].[CountryName],
          [r].[RiverName]
     FROM [Continents]
       AS [con] 
     JOIN [Countries]
       AS [c]
       ON [con].[ContinentCode] = [c].[ContinentCode]
LEFT JOIN [CountriesRivers]
       AS [cr]
       ON [c].[CountryCode] = [cr].[CountryCode]
LEFT JOIN [Rivers]
       AS [r]
       ON [cr].[RiverId] = [r].[Id]
    WHERE [con].[ContinentName] = 'Africa'
 ORDER BY [c].[CountryName] ASC
   
GO

-- 15. Continents and Currencies
  SELECT [cu].[ContinentCode],
         [cu].[CurrencyCode],
         [cu].[CurrencyUsage]
    FROM (  
            SELECT [c].[ContinentCode],
                   [ctry].[CurrencyCode],
                   COUNT(DISTINCT [ctry].[CountryCode])
                AS [CurrencyUsage],
                   RANK() OVER (PARTITION BY [c].[ContinentCode] ORDER BY COUNT(DISTINCT [ctry].[CountryCode]) DESC)
                AS [rankCur]
              FROM [Continents]
                AS [c]
              JOIN [Countries]
                AS [ctry]
                ON [c].[ContinentCode] = [ctry].[ContinentCode]
              JOIN [Currencies]
                AS [curr]
                ON [ctry].[CurrencyCode] = [curr].[CurrencyCode]
          GROUP BY [c].[ContinentCode], 
                   [ctry].[CurrencyCode]
          HAVING COUNT(DISTINCT [ctry].[CountryCode]) > 1)
      AS [cu]
   WHERE [rankCur] = 1
ORDER BY [cu].[ContinentCode]
  
GO

-- 16. Countries Without Any Mountains
   SELECT COUNT([c].[CountryCode])
       AS [Count]
     FROM [Countries]
       AS [c]
LEFT JOIN [MountainsCountries]
       AS [mc]
       ON [c].[CountryCode] = [mc].[CountryCode]
    WHERE [mc].[MountainId] IS NULL 
   
GO

-- 17. Highest Peak and Longest River by Country
   SELECT TOP (5)
          COALESCE([Peaks].[CountryName], [Rivers].[CountryName])
       AS [CountryName],
          [HighestPeakElevation],
          [LongestRiverLength]
        FROM
             (SELECT [PeaksToFilter].[CountryName],
                     [PeaksToFilter].[Elevation]
                  AS [HighestPeakElevation]
                FROM (SELECT [c].[CountryName],
                             [p].[Elevation],
                             DENSE_RANK() OVER (PARTITION BY [c].[CountryName] ORDER BY [p].[Elevation] DESC)
                          AS [RankElevation]
                        FROM [Countries]
                          AS [c]
                   LEFT JOIN [MountainsCountries]
                          AS [mc]
                          ON [c].[CountryCode] = [mc].[CountryCode]
                   LEFT JOIN [Mountains]
                          AS [m]
                          ON [mc].MountainId = [m].[Id]
                   LEFT JOIN [Peaks]
                          AS [p]
                          ON [m].[Id] = [p].[MountainId]
                    GROUP BY [c].[CountryName],
                             [m].[MountainRange],
                             [p].[Elevation])
                  AS [PeaksToFilter]
               WHERE [PeaksToFilter].[RankElevation] = 1)
       AS [Peaks]
FULL JOIN
             (SELECT [RiversToFilter].[CountryName],
                    [RiversToFilter].[Length]
                 AS [LongestRiverLength]
               FROM (SELECT [c].[CountryName],
                        [r].[Length],
                        DENSE_RANK() OVER (PARTITION BY [c].[CountryName] ORDER BY [r].[Length] DESC)
                     AS [RankLength]
                   FROM [Countries]
                     AS [c]
              LEFT JOIN [CountriesRivers]
                     AS [cr]
                     ON [c].[CountryCode] = [cr].[CountryCode]
              LEFT JOIN [Rivers]
                     AS [r]
                     ON [cr].[RiverId] = [r].[Id]
               GROUP BY [c].[CountryName],
                        [r].[Length])
                 AS [RiversToFilter]
              WHERE [RiversToFilter].[RankLength] = 1)
       AS [Rivers]
       ON [Peaks].[CountryName] = [Rivers].[CountryName]
ORDER BY [HighestPeakElevation] DESC,
         [LongestRiverLength] DESC,
         [CountryName] ASC
    
GO

-- 18. Highest Peak Name and Elevation by Country
  SELECT TOP (5)
         [Country],
         ISNULL([Highest Peak Name], '(no highest peak)'),
         ISNULL([Highest Peak Elevation], 0),
         ISNULL([Mountain], '(no mountain)')
    FROM (SELECT [c].[CountryName]
               AS [Country],
                  [p].[PeakName]
               AS [Highest Peak Name],
                  [p].[Elevation]
               AS [Highest Peak Elevation],
                  [m].[MountainRange]
               AS [Mountain],
                  DENSE_RANK() OVER (PARTITION BY [c].[CountryName] ORDER BY [p].[Elevation] DESC)
               AS [RankElevation]
             FROM [Countries]
               AS [c]
        LEFT JOIN [MountainsCountries]
               AS [mc]
               ON [c].[CountryCode] = [mc].[CountryCode]
        LEFT JOIN [Mountains]
               AS [m]
               ON [mc].MountainId = [m].[Id]
        LEFT JOIN [Peaks]
               AS [p]
               ON [m].[Id] = [p].[MountainId])
      AS [PeaksToFilter]
   WHERE [PeaksToFilter].[RankElevation] = 1
ORDER BY [Country] ASC,
         [Highest Peak Name] ASC
  
GO

-- End of the script