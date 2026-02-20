/* Part I – Queries for Gringotts Database */

USE [Gringotts]
GO

-- 01. Records' Count
SELECT COUNT([Id])
    AS [Count]
  FROM [WizzardDeposits]

GO

-- 02. Longest Magic Wand
  SELECT TOP (1)
         [MagicWandSize]
      AS [LongestMagicWand]
    FROM [WizzardDeposits]
ORDER BY [MagicWandSize] DESC 

GO

-- 03. Longest Magic Wand Per Deposit Groups
  SELECT [DepositGroup],
         MAX([MagicWandSize])
      AS [LongestMagicWand]
    FROM [WizzardDeposits]
GROUP BY [DepositGroup]
  
GO

-- 04. Smallest Deposit Group Per Magic Wand Size
  SELECT TOP (2)
         [DepositGroup]
    FROM [WizzardDeposits]
GROUP BY [DepositGroup]
ORDER BY AVG([MagicWandSize]) ASC 

GO

-- 05. Deposits Sum
  SELECT [DepositGroup],
         SUM([DepositAmount])
      AS [TotalSum]
    FROM [WizzardDeposits]
GROUP BY [DepositGroup]
  
GO

-- 06. Deposits Sum for Ollivander Family
  SELECT [DepositGroup],
         SUM([DepositAmount])
      AS [TotalSum]
    FROM [WizzardDeposits]
   WHERE [MagicWandCreator] = 'Ollivander family'
GROUP BY [DepositGroup]
  
GO

-- 07. Deposits Filter
  SELECT [DepositGroup],
         SUM([DepositAmount])
      AS [TotalSum]
    FROM [WizzardDeposits]
   WHERE [MagicWandCreator] = 'Ollivander family'
GROUP BY [DepositGroup]
  HAVING SUM([DepositAmount]) < 150000
ORDER BY SUM([DepositAmount]) DESC 

GO

-- 08. Deposit Charge
  SELECT [DepositGroup],
         [MagicWandCreator],
         MIN([DepositCharge])
      AS [MinDepositCharge]
    FROM [WizzardDeposits]
GROUP BY [DepositGroup],
         [MagicWandCreator]
ORDER BY [MagicWandCreator] ASC,
         [DepositGroup] ASC 
  
GO

-- 09. Age Groups
  SELECT [wdag].[AgeGroup],
         COUNT([wdag].[AgeGroup])
    FROM (SELECT 
            CASE
                WHEN [Age] BETWEEN 0 AND 10 THEN '[0-10]'
                WHEN [Age] BETWEEN 11 AND 20 THEN '[11-20]'
                WHEN [Age] BETWEEN 21 AND 30 THEN '[21-30]'
                WHEN [Age] BETWEEN 31 AND 40 THEN '[31-40]'
                WHEN [Age] BETWEEN 41 AND 50 THEN '[41-50]'
                WHEN [Age] BETWEEN 51 AND 60 THEN '[51-60]'
                WHEN [Age] >= 61 THEN '[61+]'
                ELSE NULL
            END 
         AS [AgeGroup]
       FROM [WizzardDeposits])
      AS [wdag]
GROUP BY [wdag].[AgeGroup]
  
GO

-- 10. First Letter
  SELECT SUBSTRING([FirstName], 1, 1)
      AS [FirstLetter]
    FROM [WizzardDeposits]
   WHERE [DepositGroup] = 'Troll Chest'
GROUP BY SUBSTRING([FirstName], 1, 1)
  
GO

-- 11. Average Interest 
SELECT [DepositGroup],
       [IsDepositExpired],
       AVG(DepositInterest)
    AS [AverageInterest]
  FROM [WizzardDeposits]
WHERE [DepositStartDate] > '1985-01-01'
GROUP BY [DepositGroup],
         [IsDepositExpired]
ORDER BY [DepositGroup] DESC,
         [IsDepositExpired] ASC 

GO

-- 12. Rich Wizard, Poor Wizard
SELECT SUM([Host Wizard Deposit] - [Guest Wizard Deposit])
    AS [SumDifference]
  FROM (SELECT [FirstName]
            AS [Host Wizard],
               [DepositAmount]
            AS [Host Wizard Deposit],
               LEAD([FirstName]) OVER (ORDER BY [Id])
            AS [Guest Wizard],
               LEAD([DepositAmount]) OVER (ORDER BY [Id])
            AS [Guest Wizard Deposit]
          FROM [WizzardDeposits])
    AS [HostGuest]
 WHERE [Guest Wizard] IS NOT NULL 

GO

/* Part II – Queries for SoftUni Database */
    
USE [SoftUni]
GO

-- 13. Departments Total Salaries
  SELECT [DepartmentID],
         SUM([Salary])
      AS [TotalSalary]
    FROM [Employees]
GROUP BY [DepartmentID]
ORDER BY [DepartmentID] ASC 
  
GO

-- 14. Employees Minimum Salaries
  SELECT [DepartmentID],
         MIN(Salary)
      AS [MinimumSalary]
    FROM [Employees]
   WHERE [DepartmentID] IN (2, 5, 7)
     AND [HireDate] > 2000-01-01
GROUP BY [DepartmentID]
  
GO

-- 15. Employees Average Salaries
SELECT *
  INTO [#EmployeesAbove30000TempTable]
  FROM [Employees]
 WHERE [Salary] > 30000

DELETE 
  FROM [#EmployeesAbove30000TempTable]
 WHERE [ManagerID] = 42

UPDATE [#EmployeesAbove30000TempTable]
   SET [Salary] += 5000
 WHERE [DepartmentID] = 1

  SELECT [DepartmentID],
         AVG([Salary])
      AS [AverageSalary]
    FROM [#EmployeesAbove30000TempTable]
GROUP BY [DepartmentID]

GO

-- 16. Employees Maximum Salaries
  SELECT [DepartmentID],
         MAX([Salary])
      AS [MaxSalary]
    FROM [Employees]
GROUP BY [DepartmentID]
  HAVING MAX([Salary]) NOT BETWEEN 30000 AND 70000
  
GO

-- 17. Employees Count Salaries
SELECT COUNT([EmployeeID])
    AS [Count]
  FROM [Employees]
 WHERE [ManagerID] IS NULL 

GO

-- 18. 3-rd Highest Salary
SELECT DISTINCT 
       [DepartmentID],
       [Salary]
    AS [ThirdHighestSalary]
  FROM (SELECT [DepartmentID],
               [Salary],
               DENSE_RANK() OVER (PARTITION BY [DepartmentID] ORDER BY [Salary] DESC)
            AS [SalaryRank]
          FROM [Employees])
   AS [SalaryRanking]
WHERE [SalaryRank] = 3

GO

-- 19. Salary Challenge
  SELECT TOP (10)
         [e].[FirstName],
         [e].[LastName],
         [e].[DepartmentID]
    FROM [Employees]
      AS [e]
   WHERE [e].Salary > (SELECT AVG([e_dep_avg].[Salary])
                           AS [AvgSalary]
                         FROM [Employees]
                           AS [e_dep_avg]
                        WHERE [e_dep_avg].[DepartmentID] = [e].[DepartmentID]
                     GROUP BY [e_dep_avg].[DepartmentID])
ORDER BY [DepartmentID] ASC
  
GO

-- End of the script