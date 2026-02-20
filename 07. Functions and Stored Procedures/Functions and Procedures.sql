/* Part I – Queries for SoftUni Database */

USE [SoftUni]
GO

-- 01. Employees with Salary Above 35000
CREATE PROCEDURE [usp_GetEmployeesSalaryAbove35000]
    AS (SELECT [FirstName]
            AS [First Name],
               [LastName]
            AS [Last Name]
          FROM [Employees]
         WHERE [Salary] > 35000)

GO

EXEC [dbo].[usp_GetEmployeesSalaryAbove35000]

GO

-- 02. Employees with Salary Above Number
CREATE PROCEDURE [usp_GetEmployeesSalaryAboveNumber] @minSalary DECIMAL(18, 4)
    AS (SELECT [FirstName]
            AS [First Name],
               [LastName]
            AS [Last Name]
          FROM [Employees]
         WHERE [Salary] >= @minSalary)

GO

EXEC [dbo].[usp_GetEmployeesSalaryAboveNumber] 35000

GO

-- 03. Town Names Starting With
CREATE PROCEDURE [usp_GetTownsStartingWith] @startingLetter VARCHAR(50)
    AS (SELECT [Name]
          FROM [Towns]
         WHERE SUBSTRING([Name], 1, LEN(@startingLetter)) = @startingLetter)

GO

EXEC [dbo].[usp_GetTownsStartingWith] b

GO

-- 04. Employees from Town
CREATE PROCEDURE [usp_GetEmployeesFromTown] @townName VARCHAR(50)
    AS (SELECT [FirstName]
            AS [First Name],
               [LastName]
            AS [Last Name]
          FROM [Employees]
            AS [e]
     LEFT JOIN [Addresses]
            AS [a]
            ON [e].[AddressID] = [a].[AddressID]
     LEFT JOIN [Towns]
            AS [t]
            ON [a].[TownID] = [t].[TownID]
         WHERE [t].[Name] = @townName
            OR ISNULL(@townName, '') = ISNULL([t].[Name], ''))
   
GO

EXEC [dbo].[usp_GetEmployeesFromTown] 'Sofia'

GO

-- 05. Salary Level Function
 CREATE OR ALTER FUNCTION [ufn_GetSalaryLevel](@salary DECIMAL(18, 4))
RETURNS VARCHAR(7)
  BEGIN 
        DECLARE @salaryLevel VARCHAR(7)
             IF @salary < 30000
          BEGIN
                SET @salaryLevel = 'Low'
            END
        ELSE IF @salary BETWEEN 30000 AND 50000
          BEGIN 
                SET @salaryLevel = 'Average'
            END
           ELSE
          BEGIN 
                SET @salaryLevel = 'High'
            END
          
 RETURN @salaryLevel
    END

GO

SELECT [Salary],
       [dbo].[ufn_GetSalaryLevel]([Salary])
    AS [Salary Level]
  FROM [Employees]

GO

-- 06. Employees by Salary Level
CREATE PROCEDURE [usp_EmployeesBySalaryLevel] @salaryLevel VARCHAR(7)
    AS (SELECT [FirstName]
            AS [First Name],
               [LastName]
            AS [Last Name]
          FROM [Employees]
         WHERE [dbo].[ufn_GetSalaryLevel]([Salary]) = @salaryLevel)

GO

EXEC [dbo].[usp_EmployeesBySalaryLevel] 'Low'

GO

-- 07. Define Function
 CREATE FUNCTION [ufn_IsWordComprised](@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
  BEGIN 
        DECLARE @wordIndex TINYINT
        DECLARE @currentChar CHAR(1)
        
          SET @wordIndex = 1
        WHILE @wordIndex <= LEN(@word)
        BEGIN
              SET @currentChar = SUBSTRING(@word, @wordIndex, 1)
               IF CHARINDEX(@currentChar, @setOfLetters) <= 0
            BEGIN 
                  RETURN 0
              END
            
              SET @wordIndex += 1
          END
        
        RETURN 1
    END
  
GO

SELECT [dbo].[ufn_IsWordComprised]('oistmiahf', 'Sofia')
SELECT [dbo].[ufn_IsWordComprised]('oistmiahf', 'halves')

GO

-- 08. Delete Employees and Departments
BACKUP DATABASE [SoftUni]
        TO DISK = '/var/opt/mssql/backup/SoftUni.bak'
    WITH FORMAT,
           INIT,
           NAME = 'Full Backup of SoftUni'

GO

CREATE PROCEDURE [usp_DeleteEmployeesFromDepartment] @departmentId INT
    AS BEGIN
             DECLARE @employeesIdsDelete TABLE ([Id] INT)
             
         INSERT INTO @employeesIdsDelete ([Id])
              SELECT [EmployeeID]
                FROM [Employees]
               WHERE [DepartmentID] = @departmentId
             
              DELETE 
                FROM [EmployeesProjects]
               WHERE [EmployeeID] IN (SELECT [Id] FROM @employeesIdsDelete)
             
              UPDATE [Employees]
                 SET [ManagerID] = NULL
               WHERE [ManagerID] IN (SELECT [Id] FROM @employeesIdsDelete)
        
         ALTER TABLE [Departments]
        ALTER COLUMN [ManagerID] INT -- Nullable
        
             UPDATE [Departments]
                SET [ManagerID] = NULL
              WHERE [ManagerID] IN (SELECT [Id] FROM @employeesIdsDelete)
        
             DELETE 
               FROM [Employees]
              WHERE [DepartmentID] = @departmentId
        
             DELETE 
               FROM [Departments]
              WHERE [DepartmentID] = @departmentId
             
             SELECT COUNT(*)
                 AS [CountOfEmployyes /Should be 0/]
               FROM [Employees]
              WHERE [DepartmentID] = @departmentId
             
        END

GO

EXEC [dbo].[usp_DeleteEmployeesFromDepartment] 1

GO

USE master
GO

ALTER DATABASE [SoftUni]
SET SINGLE_USER WITH ROLLBACK IMMEDIATE 

GO

RESTORE DATABASE [SoftUni]
       FROM DISK = '/var/opt/mssql/backup/SoftUni.bak'
    WITH REPLACE,
        RECOVERY 

GO

ALTER DATABASE [SoftUni] 
SET MULTI_USER 

GO

/* Part II – Queries for Bank Database */

USE [Bank]
GO

-- 09. Find Full Name
CREATE PROCEDURE [usp_GetHoldersFullName]
    AS (SELECT CONCAT_WS(' ', [FirstName], [LastName])
            AS [Full Name]
          FROM [AccountHolders])

GO

EXEC [dbo].[usp_GetHoldersFullName]

GO

-- 10. People with Balance Higher Than
CREATE PROCEDURE [usp_GetHoldersWithBalanceHigherThan] @number DECIMAL(18, 4)
    AS 
 BEGIN  
         SELECT [ah].[FirstName]
             AS [First Name],
                [ah].[LastName]
             AS [Last Name]
           FROM ( SELECT [ah].[Id],
                         SUM(Balance)
                      AS [Total Balance]
                    FROM [AccountHolders]
                      AS [ah]
                    JOIN [Accounts]
                      AS [a]
                      ON [ah].[Id] = [a].[AccountHolderId]
                GROUP BY [ah].[Id])
             AS [TotalBalancePerPersonQuery]
           JOIN [AccountHolders]
             AS [ah]
             ON [TotalBalancePerPersonQuery].[Id] = [ah].[Id]
          WHERE [TotalBalancePerPersonQuery].[Total Balance] > @number
       ORDER BY [First Name] ASC,
                [Last Name] ASC
   END 

GO

EXEC [dbo].[usp_GetHoldersWithBalanceHigherThan] 10000.50

GO

-- 11. Future Value Function
 CREATE FUNCTION [ufn_CalculateFutureValue](@sum DECIMAL(18, 4), @yearlyInterestRate FLOAT, @years INT)
RETURNS DECIMAL(18, 4)
  BEGIN 
        DECLARE @futureValue DECIMAL(18, 4)
            SET @futureValue = ROUND(@sum * (POWER(1 + @yearlyInterestRate, @years)), 4)
         RETURN @futureValue
    END

GO

SELECT [dbo].[ufn_CalculateFutureValue](1000, 0.1, 5)

GO

-- 12. Calculating Interest
CREATE OR ALTER PROCEDURE [usp_CalculateFutureValueForAccount] @accountId INT, @interestRate FLOAT
    AS 
 BEGIN 
       SELECT [a].[Id]
           AS [Account Id],
              [ah].[FirstName]
           AS [First Name],
              [ah].[LastName]
           AS [Last Name],
              [a].[Balance]
           AS [Current Balance],
              [dbo].[ufn_CalculateFutureValue]([a].[Balance], @interestRate, 5)
           AS [Balance in 5 years]
         FROM [AccountHolders]
           AS [ah]
         JOIN [Accounts]
           AS [a]
           ON [ah].[Id] = [a].[AccountHolderId]
        WHERE [a].[Id] = @accountId
   END
 
GO

EXEC [dbo].[usp_CalculateFutureValueForAccount] 1, 0.1

GO

/* Part III – Queries for Diablo Database */

USE [Diablo]
GO

-- 13. Table Function: Cash in User Games Odd Rows
 CREATE FUNCTION [ufn_CashInUsersGames](@gameName NVARCHAR(50))
RETURNS TABLE
           AS 
       RETURN (SELECT SUM([Cash])
                   AS [SumCash]
                 FROM (SELECT [ug].[Cash]
                           AS [Cash],
                              ROW_NUMBER() OVER (ORDER BY [ug].[Cash] DESC)
                           AS [Row Number]
                         FROM [Games]
                           AS [g]
                         JOIN [UsersGames]
                           AS [ug]
                           ON [g].[Id] = [ug].[GameId]
                        WHERE [g].[Name] = @gameName)
                   AS [rn_gameCash]
                WHERE [Row Number] % 2 != 0)

GO

SELECT * FROM [dbo].[ufn_CashInUsersGames]('Love in a mist')

GO

-- End of the script --