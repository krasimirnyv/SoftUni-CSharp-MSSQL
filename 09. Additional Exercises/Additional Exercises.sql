/* PART I – Queries for Diablo Database */

USE [Diablo]
GO

-- 01. Number of Users for Email Provider
  SELECT SUBSTRING([Email], CHARINDEX('@', [Email]) + 1, LEN([Email]))
      AS [Email Provider],
         COUNT([Id])
      AS [Number Of Users]
    FROM [Users]
GROUP BY SUBSTRING([Email], CHARINDEX('@', [Email]) + 1, LEN([Email]))
ORDER BY [Number Of Users] DESC,
         [Email Provider] ASC
  
GO

-- 02. All User in Games
  SELECT [g].[Name]
      AS [Game],
         [gt].[Name]
      AS [Game Type],
         [u].[Username],
         [ug].[Level],
         [ug].[Cash],
         [ch].[Name]
      AS [Character]
    FROM [UsersGames]
      AS [ug]
    JOIN [Users]
      AS [u]
      ON [ug].[UserId] = [u].[Id]
    JOIN [Characters]
      AS [ch]
      ON [ug].[CharacterId] = [ch].[Id]
    JOIN [Games]
      AS [g]
      ON [ug].[GameId] = [g].[Id]
    JOIN [GameTypes]
      AS [gt]
      ON [g].[GameTypeId] = [gt].[Id]
ORDER BY [ug].[Level] DESC,
         [u].[Username] ASC,
         [g].[Name] ASC
  
GO

-- 03. Users in Games with Their Items
  SELECT [u1].[Username],
         [g1].[Name]
      AS [Game],
         [groupedItems].[Items Count],
         [groupedItems].[Items Price]
    FROM ( SELECT [u].[Id]
               AS [UserId],
                  [g].[Id]
               AS [GameId],
                  COUNT([it].[Id])
               AS [Items Count],
                  SUM([it].[Price])
               AS [Items Price]
             FROM [UsersGames]
               AS [ug]
             JOIN [Users]
               AS [u]
               ON [ug].[UserId] = [u].[Id]
             JOIN [Games]
               AS [g]
               ON [ug].[GameId] = [g].[Id]
             JOIN [UserGameItems]
               AS [ugit]
               ON [ug].[Id] = [ugit].[UserGameId]
             JOIN [Items]
               AS [it]
               ON [ugit].[ItemId] = [it].[Id]
         GROUP BY [u].[Id],
                  [g].[Id])
      AS [groupedItems]
    JOIN [Games]
      AS [g1]
      ON [groupedItems].[GameId] = [g1].[Id]
    JOIN [Users]
      AS [u1]
      ON [groupedItems].[UserId] = [u1].[Id]
   WHERE [groupedItems].[Items Count] >= 10
ORDER BY [groupedItems].[Items Count] DESC,
         [groupedItems].[Items Price] DESC,
         [u1].[Username] ASC
  
GO

-- 04. User in Games with Their Statistics
  SELECT [u].[Username],
         [g].[Name]
      AS [Game],
         MAX([ch].[Name])
      AS [Character],
         SUM(st_item.Strength) + MAX(st_char.Strength) + MAX(st_game.Strength)
      AS [Strength],
         SUM(st_item.Defence) + MAX(st_char.Defence) + MAX(st_game.Defence)
      AS [Defence],
         SUM(st_item.Speed) + MAX(st_char.Speed) + MAX(st_game.Speed)
      AS [Speed],
         SUM(st_item.Mind) + MAX(st_char.Mind) + MAX(st_game.Mind)
      AS [Mind],
         SUM(st_item.Luck) + MAX(st_char.Luck) + MAX(st_game.Luck)
      AS [Luck]
    FROM [UsersGames]
      AS [ug]
    JOIN [Users]
      AS [u]
      ON [ug].[UserId] = [u].[Id] -- USERNAME
    JOIN [Games]
      AS [g]
      ON [ug].[GameId] = [g].[Id] -- GAME
    JOIN [GameTypes]
      AS [gt]
      ON [g].[GameTypeId] = [gt].[Id] -- game type
    JOIN [Statistics]
      AS [st_game]
      ON [gt].[BonusStatsId] = [st_game].[Id] -- GAME TYPE STATS
    JOIN [Characters]
      AS [ch]
      ON [ug].[CharacterId] = [ch].[Id] -- CHARACTER
    JOIN [Statistics]
      AS [st_char]
      ON [ch].[StatisticId] = [st_char].[Id] -- CHARACTER STATS
    JOIN [UserGameItems]
      AS [ugit]
      ON [ug].[Id] = [ugit].[UserGameId] -- user game item
    JOIN [Items]
      AS [it]
      ON [ugit].[ItemId] = [it].[Id] -- item
    JOIN [Statistics]
      AS [st_item]
      ON [it].[StatisticId] = [st_item].[Id] -- ITEM STATS
GROUP BY [u].[Username],
         [g].[Name]
ORDER BY [Strength] DESC,
         [Defence] DESC,
         [Speed] DESC,
         [Mind] DESC,
         [Luck] DESC
  
GO

-- 05. All Items with Greater than Average Statistics
  SELECT [it].[Name],
         [it].[Price],
         [it].[MinLevel],
         [st].[Strength],
         [st].[Defence],
         [st].[Speed],
         [st].[Luck],
         [st].[Mind]
    FROM [Items]
      AS [it]
    JOIN [Statistics]
      AS [st]
      ON [it].[StatisticId] = [st].[Id]
   WHERE [st].[Speed] > (SELECT AVG([Speed])
                             AS [AverageSpeed]
                           FROM [Statistics])
     AND [st].[Luck] >  (SELECT AVG([Luck])
                             AS [AverageLuck]
                           FROM [Statistics])
     AND [st].[Mind] >  (SELECT AVG([Mind])
                             AS [AverageMind]
                           FROM [Statistics])
ORDER BY [it].[Name] ASC
  
GO

-- 06. Display All Items with Information about Forbidden Game Type
   SELECT [it].[Name]
       AS [Item],
          [it].[Price],
          [it].[MinLevel],
          [gt].[Name]
       AS [Forbidden Game Type]
     FROM [Items]
       AS [it]
LEFT JOIN [GameTypeForbiddenItems]
       AS [gtfit]
       ON [it].[Id] = [gtfit].[ItemId]
LEFT JOIN [GameTypes]
       AS [gt]
       ON [gtfit].[GameTypeId] = [gt].[Id]
 ORDER BY [gt].[Name] DESC,
          [it].[Name] ASC
   
GO

-- 07. Buy Items for User in Game
 DECLARE @userGameId INT
 
  SELECT @userGameId = [ug].[Id]
    FROM [UsersGames]
      AS [ug]
    JOIN [Users]
      AS [u]
      ON [ug].[UserId] = [u].[Id]
    JOIN [Games]
      AS [g]
      ON [ug].[GameId] = [g].[Id]
   WHERE [u].[Username] = 'Alex'
     AND [g].[Name] = 'Edinburgh'
 
 DECLARE @totalSum MONEY
 
  SELECT [Id],
         [Price]
    INTO #SelectedItems
    FROM [Items]
   WHERE [Name] IN ('Blackguard',
                    'Bottomless Potion of Amplification',
                    'Eye of Etlich (Diablo III)',
                    'Gem of Efficacious Toxin',
                    'Golden Gorget of Leoric',
                    'Hellfire Amulet')
 
  SELECT @totalSum = SUM(Price)
    FROM #SelectedItems
 
  UPDATE [UsersGames]
     SET [Cash] -= @totalSum
   WHERE [Id] = @userGameId
 
  INSERT INTO [UserGameItems]([ItemId], [UserGameId])
  SELECT [Id],
         @userGameId
    FROM #SelectedItems
 
GO

  SELECT [u].[Username],
         [g].[Name],
         [ug].[Cash],
         [it].[Name]
      AS [Item Name]
    FROM [Users]
      AS [u]
    JOIN [UsersGames]
      AS [ug]
      ON [u].[Id] = [ug].[UserId]
    JOIN [Games]
      AS [g]
      ON [ug].[GameId] = [g].[Id]
    JOIN [UserGameItems]
      AS [ugit]
      ON [ug].[Id] = [ugit].[UserGameId]
    JOIN [Items]
      AS [it]
      ON [ugit].[ItemId] = [it].[Id]
   WHERE [g].[Name] = 'Edinburgh'
ORDER BY [it].[Name] ASC
  
GO

/* PART II – Queries for Geography Database */

USE [Geography]
GO

-- 08. Peaks and Mountains
  SELECT [p].[PeakName],
         [m].[MountainRange]
      AS [Mountain],
         [p].[Elevation]
    FROM [Peaks]
      AS [p]
    JOIN [Mountains]
      AS [m]
      ON [p].[MountainId] = [m].[Id]
ORDER BY [p].[Elevation] DESC,
         [p].[PeakName] ASC
  
GO

-- 09. Peaks with Their Mountain, Country and Continent
  SELECT [p].[PeakName],
         [m].[MountainRange]
      AS [Mountain],
         [c].[CountryName],
         [cont].[ContinentName]
    FROM [Peaks]
      AS [p]
    JOIN [Mountains]
      AS [m]
      ON [p].[MountainId] = [m].[Id]
    JOIN [MountainsCountries]
      AS [mc]
      ON [m].[Id] = [mc].[MountainId]
    JOIN [Countries]
      AS [c]
      ON [mc].[CountryCode] = [c].[CountryCode]
    JOIN [Continents]
      AS [cont]
      ON [c].[ContinentCode] = [cont].[ContinentCode]
ORDER BY [p].[PeakName] ASC,
         [c].[CountryName] ASC
  
GO

-- 10. Rivers by Country
  SELECT [coun].[CountryName],
         [cont].[ContinentName],
         [agregateRivers].[RiversCount],
         [agregateRivers].[TotalLength]
    FROM (   SELECT [c].[CountryCode],
                    ISNULL(COUNT([r].[Id]), 0)
                 AS [RiversCount],
                    ISNULL(SUM([r].[Length]), 0)
                 AS [TotalLength]
               FROM [Rivers]
                 AS [r]
          FULL JOIN [CountriesRivers]
                 AS [cr]
                 ON [r].[Id] = [cr].[RiverId]
          FULL JOIN [Countries]
                 AS [c]
                 ON [cr].[CountryCode] = [c].[CountryCode]
           GROUP BY [c].[CountryCode])
      AS [agregateRivers]
    JOIN [Countries]
      AS [coun]
      ON [agregateRivers].[CountryCode] = [coun].[CountryCode]
    JOIN [Continents]
      AS [cont]
      ON [coun].[ContinentCode] = [cont].[ContinentCode]
ORDER BY [agregateRivers].[RiversCount] DESC,
         [agregateRivers].[TotalLength] DESC,
         [coun].[CountryName] ASC
  
GO

-- 11. Count of Countries by Currency
   SELECT [curs].[CurrencyCode]
       AS [CurrencyCode],
          [curs].[Description]
       AS [Currency],
          COUNT([coun].[CountryCode])
       AS [NumberOfCountries]
     FROM [Currencies]
       AS [curs]
LEFT JOIN [Countries]
       AS [coun]
       ON [curs].[CurrencyCode] = [coun].[CurrencyCode]
 GROUP BY [curs].[CurrencyCode],
          [curs].[Description]
 ORDER BY [NumberOfCountries] DESC,
          [Currency] ASC
   
GO

-- 12. Population and Area by Continent
  SELECT [con].[ContinentName],
         ISNULL(SUM([ctr].[AreaInSqKm]), 0)
      AS [CountriesArea],
         ISNULL(SUM(CAST([ctr].[Population] AS BIGINT)), 0)
      AS [CountriesPopulation]
    FROM [Continents]
      AS [con]
    JOIN [Countries]
      AS [ctr]
      ON [con].[ContinentCode] = [ctr].[ContinentCode]
GROUP BY [con].[ContinentName]
ORDER BY [CountriesPopulation] DESC
  
GO

-- 13. Monasteries by Country
CREATE TABLE [Monasteries](
    [Id] INT PRIMARY KEY IDENTITY(1, 1),
    [Name] VARCHAR(150) NOT NULL,
    [CountryCode] CHAR(2) NOT NULL REFERENCES [Countries]([CountryCode])
)

GO

INSERT INTO [Monasteries]([Name], [CountryCode])
VALUES
       ('Rila Monastery “St. Ivan of Rila”', 'BG'),
       ('Bachkovo Monastery “Virgin Mary”', 'BG'),
       ('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
       ('Kopan Monastery', 'NP'),
       ('Thrangu Tashi Yangtse Monastery', 'NP'),
       ('Shechen Tennyi Dargyeling Monastery', 'NP'),
       ('Benchen Monastery', 'NP'),
       ('Southern Shaolin Monastery', 'CN'),
       ('Dabei Monastery', 'CN'),
       ('Wa Sau Toi', 'CN'),
       ('Lhunshigyia Monastery', 'CN'),
       ('Rakya Monastery', 'CN'),
       ('Monasteries of Meteora', 'GR'),
       ('The Holy Monastery of Stavronikita', 'GR'),
       ('Taung Kalat Monastery', 'MM'),
       ('Pa-Auk Forest Monastery', 'MM'),
       ('Taktsang Palphug Monastery', 'BT'),
       ('Sümela Monastery', 'TR')

GO

ALTER TABLE [Countries]
ADD [IsDeleted] BIT NOT NULL DEFAULT 0

GO

UPDATE [Countries]
   SET [IsDeleted] = 1
 WHERE [CountryCode] IN (SELECT [c].[CountryCode]
                           FROM [Countries]
                             AS [c]
                           JOIN [CountriesRivers]
                             AS [cr]
                             ON [c].[CountryCode] = [cr].[CountryCode]
                           JOIN [Rivers] 
                             AS [r]
                             ON [cr].[RiverId] = [r].[Id]
                       GROUP BY [c].[CountryCode]
                         HAVING COUNT(r.Id) > 3)

GO

  SELECT [m].[Name]
      AS [Monastery],
         [c].[CountryName]
      AS [Country]
    FROM [Monasteries]
      AS [m]
    JOIN [Countries]
      AS [c]
      ON [m].[CountryCode] = [c].[CountryCode]
   WHERE [c].[IsDeleted] = 0
ORDER BY [Monastery] ASC
  
GO

-- 14. Monasteries by Continents and Countries
UPDATE [Countries]
   SET [CountryName] = 'Burma'
 WHERE [CountryName] = 'Myanmar'

GO

INSERT INTO [Monasteries]([Name], [CountryCode])
VALUES
       ('Hanga Abbey', (SELECT [CountryCode] FROM [Countries] WHERE [CountryName] = 'Tanzania')),
       ('Myin-Tin-Daik', (SELECT [CountryCode] FROM [Countries] WHERE [CountryName] = 'Myanmar'))

GO

   SELECT [con].[ContinentName],
          [ctr].[CountryName],
          COUNT([m].[Id])
       AS [MonasteriesCount]
     FROM [Continents]
       AS [con]
     JOIN [Countries]
       AS [ctr]
       ON [con].[ContinentCode] = [ctr].[ContinentCode]
LEFT JOIN [Monasteries]
       AS [m]
       ON [ctr].[CountryCode] = [m].[CountryCode]
    WHERE [ctr].[IsDeleted] = 0
 GROUP BY [ctr].[CountryName],
          [con].[ContinentName]
 ORDER BY [MonasteriesCount] DESC,
          [ctr].[CountryName] ASC

GO

-- End of the script --