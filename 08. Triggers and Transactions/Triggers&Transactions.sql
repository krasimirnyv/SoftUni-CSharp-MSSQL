/* Part I - Queries for Bank Database */

USE [Bank]
GO

-- 01. Create Table Logs
CREATE TABLE [Logs](
    [LogId] INT PRIMARY KEY IDENTITY(1, 1),
    [AccountId] INT NOT NULL,
    [OldSum] DECIMAL(18, 4) NOT NULL,
    [NewSum] DECIMAL(18, 4) NOT NULL,
    CONSTRAINT FK_LogsAccountId_AccountsId FOREIGN KEY (AccountId) REFERENCES Accounts(Id)
)

GO

CREATE OR ALTER TRIGGER [tr_AddToLogsOnAccountUpdate]
    ON [Accounts] 
 AFTER UPDATE
    AS 
       INSERT INTO Logs([AccountId], [OldSum], [NewSum])
       SELECT i.Id,
              d.Balance,
              i.Balance
         FROM inserted
           AS i
         JOIN deleted
           AS d
           ON i.Id = d.Id
        WHERE i.Balance != d.Balance
    
GO

SELECT * FROM [Accounts];

UPDATE [Accounts]
SET [Balance] = [Balance] + 100
WHERE [Id] = 1;

SELECT * FROM [Logs];

GO

-- 02. Create Table Emails
CREATE TABLE [NotificationEmails](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [Recipient] VARCHAR(320) NOT NULL,
    [Subject] NVARCHAR(250) NOT NULL,
    [Body] NVARCHAR(MAX) NOT NULL
)

GO

CREATE OR ALTER TRIGGER [tr_CreateEmailOnLogsInsert]
    ON [Logs]
 AFTER INSERT
    AS
       INSERT INTO [NotificationEmails]([Recipient], [Subject], [Body])
       SELECT [i].[AccountId],
              CONCAT('Balance change for account: ', [i].[AccountId]),
              CONCAT('On ', GETDATE(), ' your balance was changed from ', [i].[OldSum], ' to ', [i].[NewSum], '.')
         FROM inserted
           AS [i]
    
GO

SELECT * FROM [NotificationEmails]

GO

-- 03. Deposit Money
CREATE OR ALTER PROCEDURE [usp_DepositMoney] @accountId INT, @moneyAmount DECIMAL(18, 4)
    AS
 BEGIN
          SET NOCOUNT ON
          
           IF @moneyAmount <= 0
        BEGIN
              RAISERROR('Deposit amount must be positive and greater than 0.', 16, 1)
          END
           IF NOT EXISTS (SELECT 1 
                            FROM Accounts 
                           WHERE Id = @accountId)
        BEGIN
              RAISERROR('Account does not exist.', 16, 1)
          END 
        
       UPDATE [Accounts]
          SET [Balance] += @moneyAmount
        WHERE [Id] = @accountId
   END 

GO

EXEC [usp_DepositMoney] 1, 10

GO

-- 04. Withdraw Money Procedure
CREATE OR ALTER PROCEDURE [usp_WithdrawMoney] @accountId INT, @moneyAmount DECIMAL(18, 4)
    AS
 BEGIN
          SET NOCOUNT ON
          
           IF @moneyAmount <= 0
        BEGIN
              RAISERROR('Withdraw amount must be positive.', 16, 1)
          END

      DECLARE @currentBalance DECIMAL(18, 4)
        
       SELECT @currentBalance = [Balance]
         FROM [Accounts]
        WHERE [Id] = @accountId
          
           IF @currentBalance IS NULL
        BEGIN
              RAISERROR('Account does not exist.', 16, 1)
          END
        
           IF @currentBalance < @moneyAmount
        BEGIN
              RAISERROR('Insufficient funds. Withdrawal would cause negative balance.', 16, 1)
          END
              
       UPDATE [Accounts]
          SET [Balance] -= @moneyAmount
        WHERE [Id] = @accountId
   END 

GO

EXEC [usp_WithdrawMoney] 5, 25

GO

-- 05. Money Transfer
CREATE OR ALTER PROCEDURE [usp_TransferMoney] @senderId INT, @receiverId INT, @amount DECIMAL(18, 4)
    AS
 BEGIN
         SET NOCOUNT ON
         SET XACT_ABORT ON
             
          IF @amount < 0
       BEGIN
             RAISERROR('Amount must be positive and greater than 0.', 16, 1);
         END     
       
       BEGIN TRY
                 BEGIN TRANSACTION
                  EXEC [usp_WithdrawMoney] @senderId, @amount
                  EXEC [usp_DepositMoney] @receiverId, @amount
                COMMIT TRANSACTION 
         END TRY
       BEGIN CATCH
                   IF @@TRANCOUNT > 0
                   ROLLBACK TRANSACTION
             THROW 
         END CATCH
   END

GO

EXEC usp_TransferMoney 5, 1, 5000
EXEC usp_TransferMoney 5, 1, -10

GO

/* Part II - Queries for Diablo Database */

USE [Diablo]
GO

-- 06. Trigger
 CREATE TRIGGER [tr_RestrictHighLevelItems]
     ON [UserGameItems]
INSTEAD OF INSERT 
     AS
  BEGIN 
             SET NOCOUNT ON
        
          INSERT INTO [UserGameItems]([ItemId], [UserGameId])
          SELECT [i].[ItemId],
                 [i].[UserGameId]
            FROM inserted
              AS [i]
            JOIN [UsersGames]
              AS [ug]
              ON i.[UserGameId] = [ug].[Id]
            JOIN [Items]
              AS [it]
              ON i.[ItemId] = [it].[Id]
           WHERE [ug].[Level] >= [it].[MinLevel]
    END
  
GO

UPDATE [ug]
   SET [ug].[Cash] += 50000
  FROM [UsersGames]
    AS [ug]
  JOIN [Users]
    AS [u]
    ON [ug].[UserId] = [u].[Id]
  JOIN [Games]
    AS [g]
    ON [ug].[GameId] = [g].[Id]
 WHERE [g].[Name] = 'Bali'
   AND [u].[Username] IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')

GO

INSERT INTO [UserGameItems]([ItemId], [UserGameId])
SELECT DISTINCT 
       [it].[Id],
       [ug].[Id]
  FROM [Items]
    AS [it]
  JOIN [UsersGames]
    AS [ug]
    ON [ug].[GameId] = (SELECT [Id] FROM [Games] WHERE [Name] = 'Bali')
  JOIN [Users]
    AS [u]
    ON [ug].[UserId] = [u].[Id]
 WHERE [u].[Username] IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
   AND ([it].[Id] BETWEEN 251 AND 299 OR [it].[Id] BETWEEN 501 AND 539)
   
GO

UPDATE [ug]
   SET [ug].[Cash] -=  [totals].[TotalPrice]
  FROM [UsersGames]
    AS [ug]
  JOIN ( SELECT [ugi].[UserGameId],
                SUM([it].[Price])
             AS [TotalPrice]
           FROM [UserGameItems]
             AS [ugi]
           JOIN [Items]
             AS [it] 
             ON [ugi].[ItemId] = [it].[Id] -- Items
       GROUP BY [ugi].[UserGameId] )
    AS [totals] 
    ON [ug].[Id] = [totals].[UserGameId]
  JOIN [Users]
    AS [u]
    ON [ug].[UserId] = [u].[Id] -- Username
  JOIN [Games]
    AS [g]
    ON [ug].[GameId] = [g].[Id] -- GameName
 WHERE [g].[Name] = 'Bali'
   AND [u].[Username] IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')

GO

   SELECT [u].[Username],
          [g].[Name],
          [ug].[Cash],
          [it].[Name]
       AS [Item Name]
     FROM [UsersGames] -- Cash
       AS [ug]
     JOIN [Users]
       AS [u]
       ON [ug].[UserId] = [u].[Id] -- Username
     JOIN [Games]
       AS [g]
       ON [ug].[GameId] = [g].[Id] -- GameName
LEFT JOIN [UserGameItems]
       AS [ugi]
       ON [ug].[Id] = [ugi].[UserGameId]
LEFT JOIN [Items]
       AS [it]
       ON [ugi].[ItemId] = [it].[Id] -- Item
    WHERE [g].[Name] = 'Bali'
 ORDER BY [u].[Username] ASC,
          [it].[Name] ASC

GO

-- 07. Massive Shopping - Мое решение (не минаващо Judge)
DECLARE @usersGamesId INT

SELECT @usersGamesId = [ug].[Id]
  FROM [UsersGames]
    AS [ug]
  JOIN [Users]
    AS [u]
    ON [ug].[UserId] = [u].[Id]
  JOIN [Games]
    AS [g]
    ON [ug].[GameId] = [g].[Id]
 WHERE [u].[Username] = 'Stamat'
   AND [g].[Name] = 'Safflower'

-- Transaction for items with MinLevel = 11 & 12
BEGIN TRANSACTION
      -- Take the Stamat's cash
      DECLARE @cash MONEY

       SELECT @cash = [Cash]
         FROM [UsersGames]
        WHERE [Id] = @usersGamesId

      -- Take the total sum for selected items
      DECLARE @totalSum MONEY

       SELECT @totalSum = COALESCE(SUM([it].[Price]), 0)
         FROM [Items]
           AS [it]
        WHERE [it].[MinLevel] BETWEEN 11 AND 12
          AND NOT EXISTS(SELECT 1
                           FROM [UserGameItems]
                             AS [ugi]
                          WHERE [ugi].ItemId = [it].[Id]
                            AND [ugi].[UserGameId] = @usersGamesId)

      -- Rollback if cash < totalSum
           IF @cash < @totalSum
        BEGIN
              ROLLBACK TRANSACTION
          END
         ELSE 
        BEGIN 
              -- Add items
              INSERT INTO [UserGameItems]([ItemId], [UserGameId])
              SELECT [it].[Id],
                     @usersGamesId
                FROM [Items]
                  AS [it]
               WHERE [it].[MinLevel] BETWEEN 11 AND 12
                 AND NOT EXISTS(SELECT 1 
                                  FROM [UserGameItems]
                                    AS [ugi]
                                 WHERE [ugi].ItemId = [it].[Id]
                                   AND [ugi].[UserGameId] = @usersGamesId)
         
              -- Withdraw money
              UPDATE [UsersGames]
                 SET [Cash] -= @totalSum
               WHERE [Id] = @usersGamesId
              
              COMMIT TRANSACTION
          END

-- Transaction for items with MinLevel = 19 & 21
BEGIN TRANSACTION
      -- Take the Stamat's cash      
       SELECT @cash = [Cash]
         FROM [UsersGames]
        WHERE [Id] = @usersGamesId
      
      -- Take the total sum for selected items      
       SELECT @totalSum = COALESCE(SUM([it].[Price]), 0)
         FROM [Items]
           AS [it]
        WHERE [it].[MinLevel] BETWEEN 19 AND 21
          AND NOT EXISTS(SELECT 1
                           FROM [UserGameItems]
                             AS [ugi]
                          WHERE [ugi].ItemId = [it].[Id]
                            AND [ugi].[UserGameId] = @usersGamesId)

      -- Rollback if cash < totalSum
           IF @cash < @totalSum
        BEGIN
              ROLLBACK TRANSACTION
          END
         ELSE
        BEGIN 
             -- Add items
              INSERT INTO [UserGameItems]([ItemId], [UserGameId])
              SELECT [it].[Id],
                     @usersGamesId
                FROM [Items]
                  AS [it]
               WHERE [it].[MinLevel] BETWEEN 19 AND 21
                 AND NOT EXISTS(SELECT 1
                                  FROM [UserGameItems]
                                    AS [ugi]
                                 WHERE [ugi].ItemId = [it].[Id]
                                   AND [ugi].[UserGameId] = @usersGamesId)
             
             -- Withdraw money
              UPDATE [UsersGames]
                 SET [Cash] -= @totalSum
               WHERE [Id] = @usersGamesId
              
              COMMIT TRANSACTION
          END

  SELECT [it].[Name]
      AS [Item Name]
    FROM [UserGameItems]
      AS [ugi]
    JOIN [Items]
      AS [it]
      ON [ugi].[ItemId] = [it].[Id]
   WHERE [ugi].[UserGameId] = @usersGamesId
ORDER BY [it].[Name] ASC

GO

-- 07. Massive Shopping - Чуждо решение (минаващо Judge)
DECLARE @gameName NVARCHAR(50) = 'Safflower';
DECLARE @username NVARCHAR(50) = 'Stamat';

DECLARE @userGameId INT =
    (
        SELECT ug.[Id]
        FROM [UsersGames] AS ug
                 JOIN [Users] AS u ON ug.[UserId] = u.[Id]
                 JOIN [Games] AS g ON ug.[GameId] = g.[Id]
        WHERE u.[Username] = @username
          AND g.[Name] = @gameName
    );

DECLARE @userGameLevel INT = (
    SELECT [Level]
    FROM [UsersGames]
    WHERE [Id] = @userGameId
);

DECLARE @itemsCost MONEY, @availableCash MONEY, @minLevel INT, @maxLevel INT;

SET @minLevel = 11;
SET @maxLevel = 12;

SET @availableCash = (
    SELECT [Cash] FROM [UsersGames] WHERE [Id] = @userGameId
);

SET @itemsCost = (
    SELECT SUM([Price])
    FROM [Items]
    WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel
);

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)
    BEGIN
        BEGIN TRANSACTION;

        UPDATE [UsersGames]
        SET [Cash] = [Cash] - @itemsCost
        WHERE [Id] = @userGameId;

        IF (@@ROWCOUNT <> 1)
            BEGIN
                ROLLBACK;
                RAISERROR('Could not make payment', 16, 1);
            END
        ELSE
            BEGIN
                INSERT INTO [UserGameItems] ([ItemId], [UserGameId])
                SELECT [Id], @userGameId
                FROM [Items]
                WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel;

                IF ((SELECT COUNT(*) FROM [Items] WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
                    BEGIN
                        ROLLBACK;
                        RAISERROR('Could not buy items', 16, 1);
                    END
                ELSE
                    COMMIT;
            END
    END

SET @minLevel = 19;
SET @maxLevel = 21;

SET @availableCash = (
    SELECT [Cash] FROM [UsersGames] WHERE [Id] = @userGameId
);

SET @itemsCost = (
    SELECT SUM([Price])
    FROM [Items]
    WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel
);

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)
    BEGIN
        BEGIN TRANSACTION;

        UPDATE [UsersGames]
        SET [Cash] = [Cash] - @itemsCost
        WHERE [Id] = @userGameId;

        IF (@@ROWCOUNT <> 1)
            BEGIN
                ROLLBACK;
                RAISERROR('Could not make payment', 16, 1);
            END
        ELSE
            BEGIN
                INSERT INTO [UserGameItems] ([ItemId], [UserGameId])
                SELECT [Id], @userGameId
                FROM [Items]
                WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel;

                IF ((SELECT COUNT(*) FROM [Items] WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
                    BEGIN
                        ROLLBACK;
                        RAISERROR('Could not buy items', 16, 1);
                    END
                ELSE
                    COMMIT;
            END
    END

SELECT [i].[Name] AS [Item Name]
FROM [UserGameItems] AS ugi
         JOIN [Items] AS i  ON i.[Id] = ugi.[ItemId]
         JOIN [UsersGames] AS ug ON ug.[Id] = ugi.[UserGameId]
         JOIN [Games] AS g  ON g.[Id] = ug.[GameId]
WHERE g.[Name] = @gameName
ORDER BY [Item Name];

GO

/* Part III - Queries for SoftUni Database */

USE [SoftUni]
GO

-- 08. Employees with Three Projects
CREATE PROCEDURE [usp_AssignProject] @employeeId INT, @projectID INT
    AS 
 BEGIN 
        BEGIN TRANSACTION 
      
      DECLARE @projectCount INT
       SELECT @projectCount = COUNT(*)
         FROM [EmployeesProjects]
        WHERE [EmployeeID] = @employeeId

           IF @projectCount >= 3
        BEGIN
              ROLLBACK
              RAISERROR('The employee has too many projects!', 16, 1)
              RETURN
          END

       INSERT INTO [EmployeesProjects]([EmployeeID], [ProjectID])
       VALUES (@employeeId, @projectID)
        
       COMMIT TRANSACTION;
   END
 
GO

-- 09. Delete Employees
CREATE TABLE [Deleted_Employees](
    [EmployeeId] INT PRIMARY KEY IDENTITY (1, 1),
    [FirstName] VARCHAR(50) NOT NULL,
    [LastName] VARCHAR(50) NOT NULL,
    [MiddleName] VARCHAR(50),
    [JobTitle] VARCHAR(50) NOT NULL,
    [DepartmentId] INT FOREIGN KEY REFERENCES [Departments]([DepartmentID]),
    [Salary] MONEY NOT NULL 
)

GO

CREATE TRIGGER dbo.tr_Employees_AfterDelete_Log
    ON dbo.Employees
    AFTER DELETE
    AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Deleted_Employees
    (FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
    SELECT
        d.FirstName,
        d.LastName,
        d.MiddleName,
        d.JobTitle,
        d.DepartmentID,
        d.Salary
    FROM deleted AS d;
END;

GO

-- End of the script --