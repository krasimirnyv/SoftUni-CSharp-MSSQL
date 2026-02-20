-- 1. Create Database
CREATE DATABASE [Minions]

GO

USE [Minions]

GO

-- From now on, every SQL query will be executed in the Minions database
-- 2. Create Tables
CREATE TABLE [Minions] (
    [Id] INT PRIMARY KEY,
    [Name] NVARCHAR(80) NOT NULL,
    [Age] TINYINT NOT NULL,
)

CREATE TABLE [Towns] (
    [Id] INT PRIMARY KEY,
    [Name] NVARCHAR(100) NOT NULL,
)

GO

-- 3. Alter Minions Table
ALTER TABLE [Minions]
ADD [TownId] INT

ALTER TABLE [Minions]
ADD FOREIGN KEY ([TownId]) REFERENCES [Towns]([Id])

ALTER TABLE [Minions]
ALTER COLUMN [Age] TINYINT -- nullable

GO

-- 4. Insert Records in Both Tables
INSERT INTO [Towns] ([Id], [Name])
VALUES 
    (1, 'Sofia'),
    (2, 'Plovdiv'),
    (3, 'Varna')

INSERT INTO [Minions] ([Id], [Name], [Age], [TownId])
VALUES 
    (1, 'Kevin', 22, 1),
    (2, 'Bob', 15, 3),
    (3, 'Steward', NULL, 2)

GO

-- 5. Truncate Table Minions - Deletes the data of the table, but not the table!
TRUNCATE TABLE [Minions]

GO

-- 6. Drop All Tables - Deletes the table and its data
DROP TABLE [Minions]
DROP TABLE [Towns]

GO

-- 7. Create Table People
CREATE TABLE [People](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] NVARCHAR(200) NOT NULL,
    [Picture] VARBINARY(MAX),
    [Height] DECIMAL(3, 2),
    [Weight] DECIMAL(5, 2),
    [Gender] CHAR(1) NOT NULL CHECK ([Gender] IN ('m', 'f')),
    [Birthdate] DATE NOT NULL,
    [Biography] NVARCHAR(MAX)
)

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

INSERT INTO [People] ([Name], [Picture], [Height], [Weight], [Gender], [Birthdate], [Biography])
VALUES
    (N'Иван Петров', NULL, NULL, NULL, 'm', '1995-04-12',  NULL),
    (N'Мария Георгиева', NULL, 1.65, 60.20, 'f', '1998-11-23', N'Мария е учителка по математика. Тя се интересува от литература и доброволчество.'),
    (N'Красимир Красимиров Найденов', (SELECT * FROM OPENROWSET(BULK N'/var/opt/mssql/tmpimages/PassportPhoto1.jpg', SINGLE_BLOB) AS img),
     1.82, 86.00, 'm', '2002-12-10', N'Краси е завършил за филмов сценарис, но тъй като няма пари, е решил да се преквалифицира.'),
    (N'Елена Николова', NULL, 1.72, 63.40, 'f', '1992-01-15', N'Елена е лекар и има страст към изкуството и рисуването.'),
    (N'Петър Стоянов', NULL, 1.76, 82.10, 'm', '2000-09-30', N'Петър е студент по информатика и обича шах и видеоигри.')

-- Проверка дали колоната Picture не е NULL и колко байта е
SELECT
    [Name],
    DATALENGTH([Picture]) AS PictureSize
FROM
    [People]
WHERE
    [Picture] IS NOT NULL;

GO

-- 8. Create Table Users
CREATE TABLE [Users](
    [Id] BIGINT PRIMARY KEY IDENTITY (1, 1),
    [Username] VARCHAR(30) NOT NULL UNIQUE,
    [Password] VARCHAR(26) NOT NULL,
    [ProfilePicture] VARBINARY(MAX) CHECK (DATALENGTH([ProfilePicture]) <= 900 * 1024),
    [LastLoginTime] DATETIME2,
    [IsDeleted] BIT NOT NULL DEFAULT 0
)

INSERT INTO [Users] ([Username], [Password], [ProfilePicture], [LastLoginTime], [IsDeleted])
VALUES
    ('ivan_petrov', 'IvanPass123', NULL, NULL, 0),
    ('maria_georgieva', 'MariaPass456', NULL, '2025-09-14 12:30:00', 0),
    ('krasi_naydenov', 'KrasiPass789',
     (SELECT * FROM OPENROWSET(BULK N'/var/opt/mssql/tmpimages/PassportPhoto1.jpg', SINGLE_BLOB) AS img),
     '2025-09-14 15:45:00', 0),
    ('elena_nikolova', 'ElenaPass321', NULL, '2025-09-13 18:20:00', 0),
    ('petar_stoyanov', 'PetarPass654', NULL, NULL, 0)

-- Маркира се профила като изтрит
UPDATE Users
SET [IsDeleted] = 1
WHERE [Id] = 5;

-- Проверка за активни профили
SELECT * FROM Users
WHERE [IsDeleted] = 1;

GO

-- 9. Change Primary Key
sp_helpconstraint Users;

-- Съдържат се уникални имена и след изтриването им, при ново стартиране ще са други, затова са закоментирани
/*ALTER TABLE [Users]
DROP CONSTRAINT PK__Users__3214EC0711FC62D2*/

SELECT name
FROM Minions.sys.key_constraints
WHERE parent_object_id = OBJECT_ID('Users')
AND type = 'UQ'

/*ALTER TABLE [Users]
DROP CONSTRAINT UQ__Users__536C85E4536D53C4*/

ALTER TABLE [Users]
ADD CONSTRAINT PK_Users_Id_Username PRIMARY KEY ([Id], [Username])

GO

-- 10. Add Check Constraint
ALTER TABLE [Users]
ADD CONSTRAINT CHK_Users_Password_Length
CHECK (LEN([Password]) >= 5)

INSERT INTO Users ([Username], [Password], [LastLoginTime], [IsDeleted]) -- Valid
VALUES ('TestUser1', 'MyPass123', GETDATE(), 0);

INSERT INTO Users ([Username], [Password], [LastLoginTime], [IsDeleted]) -- Invalid
VALUES ('TestUser2', '1234', GETDATE(), 0);

GO

-- 11. Set Default Value of a Field
ALTER TABLE [Users]
ADD CONSTRAINT DF_Users_LastLoginTime
DEFAULT GETDATE() FOR [LastLoginTime]

INSERT INTO Users ([Username], [Password],[IsDeleted])
VALUES ('newuser', 'StrongPass1', 0);

GO

-- 12. Set Unique Field
sp_helpconstraint 'Users'

ALTER TABLE [Users]
DROP CONSTRAINT PK_Users_Id_Username

ALTER TABLE [Users]
ADD CONSTRAINT PK_Users_Id PRIMARY KEY ([Id])

ALTER TABLE [Users]
ADD CONSTRAINT UQ_Users_Username UNIQUE ([Username])

ALTER TABLE [Users]
ADD CONSTRAINT CHK_Users_Username_Length CHECK (LEN([Username]) >= 3)

GO

-- 13. Movies Database
CREATE DATABASE [MoviesDB]
GO

USE [MoviesDB]
GO

CREATE TABLE [Directors](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [DirectorName] NVARCHAR(100) NOT NULL,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [Genres](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [GenreName] NVARCHAR(50) NOT NULL,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [Categories](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [CategoryName] NVARCHAR(50) NOT NULL,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [Movies](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [Title] NVARCHAR(250) NOT NULL,
    [DirectorId] INT NOT NULL REFERENCES [Directors]([Id]),
    [CopyrightYear] SMALLINT NOT NULL,
    [Length] SMALLINT NOT NULL,
    [GenreId] INT NOT NULL REFERENCES [Genres]([Id]),
    [CategoryId] INT NOT NULL REFERENCES [Categories]([Id]),
    [Rating] DECIMAL(3, 1),
    [Notes] NVARCHAR(500)
)

GO

INSERT INTO [Directors] ([DirectorName], [Notes])
VALUES
    (N'Christopher Nolan', N'Известен с научнофантастични филми'),
    (N'Steven Spielberg', N'Легендарен режисьор на приключенски филми'),
    (N'Quentin Tarantino', N'Известен с насилие и черен хумор'),
    (N'Martin Scorsese', N'Режисьор на класически криминални филми'),
    (N'Ridley Scott', NULL)

INSERT INTO [Genres] ([GenreName], [Notes]) 
VALUES
    (N'Action', N'Бойни сцени, приключения'),
    (N'Drama', N'Сериозни истории, емоции'),
    (N'Comedy', N'Хумористични филми'),
    (N'Sci-Fi', N'Научна фантастика'),
    (N'Horror', NULL)

INSERT INTO [Categories] ([CategoryName], [Notes]) 
VALUES
    (N'Blockbuster', N'Филми с голям бюджет'),
    (N'Indie', N'Независими филми'),
    (N'Classic', N'Класически филми'),
    (N'Animated', N'Анимационни филми'),
    (N'Documentary', NULL)

INSERT INTO [Movies] ([Title], [DirectorId], [CopyrightYear], [Length], [GenreId], [CategoryId], [Rating], [Notes])
VALUES
(N'Inception', 1, 2010, 148, 4, 1, NULL, N'Научна фантастика, сънуване в сънища'),
(N'Jurassic Park', 2, 1993, 127, 1, 1, 8.1, N'Приключенски филм с динозаври'),
(N'Pulp Fiction', 3, 1994, 154, 2, 3, 8.9, N'Класически криминален филм с черен хумор'),
(N'The Wolf of Wall Street', 4, 2013, 180, 2, 1, 8.2, N'Драма за финансова измама и алчност'),
(N'Gladiator', 5, 2000, 155, 1, 3, 8.5, NULL)

GO

-- 14. Car Rental Database
CREATE DATABASE [CarRentalDB]
GO

USE [CarRentalDB]
GO

CREATE TABLE [Categories](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [CategoryName] NVARCHAR(50) NOT NULL,
    [DailyRate] DECIMAL(8, 2) NOT NULL,
    [WeeklyRate] DECIMAL(8, 2) NOT NULL,
    [MonthlyRate] DECIMAL(8, 2) NOT NULL,
    [WeekendRate] DECIMAL(8, 2) NOT NULL
)

CREATE TABLE [Cars](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [PlateNumber] NVARCHAR(10) UNIQUE NOT NULL,
    [Manufacturer] NVARCHAR(100) NOT NULL,
    [Model] NVARCHAR(50) NOT NULL,
    [CarYear] SMALLINT NOT NULL,
    [CategoryId] INT NOT NULL REFERENCES [Categories]([Id]),
    [Doors] TINYINT NOT NULL,
    [Picture] VARBINARY(MAX),
    [Condition] NVARCHAR(50) NOT NULL,
    [Available] BIT NOT NULL
)

CREATE TABLE [Employees](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [FirstName] NVARCHAR(50) NOT NULL,
    [LastName] NVARCHAR(50) NOT NULL,
    [Title] NVARCHAR(100) NOT NULL,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [Customers](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [DriverLicenceNumber] NVARCHAR(20) UNIQUE NOT NULL,
    [FullName] NVARCHAR(100) NOT NULL,
    [Address] NVARCHAR(200) NOT NULL,
    [City] NVARCHAR(50) NOT NULL,
    [ZIPCode] NVARCHAR(10) NOT NULL,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [RentalOrders](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [EmployeeId] INT NOT NULL REFERENCES [Employees]([Id]),
    [CustomerId] INT NOT NULL REFERENCES [Customers]([Id]),
    [CarId] INT NOT NULL REFERENCES [Cars]([Id]),
    [TankLevel] TINYINT NOT NULL CHECK ([TankLevel] BETWEEN 0 AND 100),
    [KilometrageStart] INT NOT NULL,
    [KilometrageEnd] INT,
    [TotalKilometrage] AS ([KilometrageEnd] - [KilometrageStart]),
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [TotalDays] AS (DATEDIFF(DAY, [StartDate], [EndDate])),
    [RateApplied] DECIMAL(10, 2) NOT NULL,
    [TaxRate] DECIMAL(5, 2),
    [OrderStatus] NVARCHAR(50),
    [Notes] NVARCHAR(500)
)

GO

INSERT INTO [Categories] ([CategoryName], [DailyRate], [WeeklyRate], [MonthlyRate], [WeekendRate])
VALUES
    (N'Economy', 30.00, 180.00, 700.00, 50.00),
    (N'SUV', 60.00, 360.00, 1400.00, 100.00),
    (N'Luxury', 120.00, 720.00, 2800.00, 200.00)

INSERT INTO [Cars] ([PlateNumber], [Manufacturer], [Model], [CarYear], [CategoryId], [Doors], [Picture], [Condition], [Available])
VALUES
    (N'CA1234AB', N'Toyota', N'Yaris', 2020, 1, 4, NULL, N'Good', 1),
    (N'CB5678CD', N'BMW', N'X5', 2021, 2, 5, NULL, N'Excellent', 1),
    (N'CC9999EE', N'Mercedes', N'S-Class', 2022, 3, 4, NULL, N'New', 0)

INSERT INTO [Employees] ([FirstName], [LastName], [Title], [Notes])
VALUES
    (N'Ivan', N'Petrov', N'Manager', N'Oversees operations'),
    (N'Maria', N'Georgieva', N'Clerk', NULL),
    (N'Georgi', N'Dimitrov', N'Mechanic', N'Responsible for car maintenance')

INSERT INTO [Customers] ([DriverLicenceNumber], [FullName], [Address], [City], [ZIPCode], [Notes])
VALUES
    (N'BG123456', N'Petar Ivanov', N'ul. Rakovski 12', N'Sofia', 1000, NULL),
    (N'BG654321', N'Elena Petrova', N'ul. Tsar Simeon 45', N'Plovdiv', 4000, N'VIP customer'),
    (N'BG789012', N'Stoyan Kolev', N'ul. Slivnitsa 78', N'Varna', 9000, NULL)

INSERT INTO [RentalOrders] ([EmployeeId], [CustomerId], [CarId], [TankLevel], [KilometrageStart], [KilometrageEnd],
                            [StartDate], [EndDate], [RateApplied], [TaxRate], [OrderStatus], [Notes])
VALUES
    (1, 1, 1, 80, 10000, 10200, '2025-09-01', '2025-09-05', 30.00, 20.00, N'Closed', N'First rental'),
    (2, 2, 2, 90, 5000, 5500, '2025-09-03', '2025-09-10', 60.00, 20.00, N'Closed', NULL),
    (3, 3, 3, 100, 200, 200, '2025-09-10', '2025-09-15', 120.00, 20.00, N'Active', N'Luxury booking')

GO

-- 15. Hotel Database
CREATE DATABASE [HotelDB]
GO

USE [HotelDB]
GO

CREATE TABLE [Employees](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [FirstName] NVARCHAR(80) NOT NULL,
    [LastName] NVARCHAR(80) NOT NULL,
    [Title] NVARCHAR(50) NOT NULL,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [Customers](
    [AccountNumber] INT PRIMARY KEY IDENTITY (1, 1),
    [FirstName] NVARCHAR(80) NOT NULL,
    [LastName] NVARCHAR(80) NOT NULL,
    [PhoneNumber] NVARCHAR(20) UNIQUE NOT NULL,
    [EmergencyName] NVARCHAR(100),
    [EmergencyNumber] NVARCHAR(20),
    [Notes] NVARCHAR(500)
)

CREATE TABLE [RoomStatus](
    [RoomStatus] NVARCHAR(50) PRIMARY KEY,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [RoomTypes](
    [RoomType] NVARCHAR(20) PRIMARY KEY,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [BedTypes](
    [BedType] NVARCHAR(10) PRIMARY KEY,
    [Notes] NVARCHAR(500)
)

CREATE TABLE [Rooms](
    [RoomNumber] INT PRIMARY KEY,
    [RoomType] NVARCHAR(20) NOT NULL REFERENCES [RoomTypes]([RoomType]),
    [BedType] NVARCHAR(10) NOT NULL REFERENCES [BedTypes]([BedType]),
    [Rate] DECIMAL(10, 2) NOT NULL,
    [RoomStatus] NVARCHAR(50) NOT NULL REFERENCES [RoomStatus]([RoomStatus]),
    [Notes] NVARCHAR(500)
)

CREATE TABLE [Payments](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [EmployeeId] INT NOT NULL REFERENCES [Employees]([Id]),
    [PaymentDate] DATETIME2 NOT NULL,
    [AccountNumber] INT NOT NULL REFERENCES [Customers]([AccountNumber]),
    [FirstDateOccupied] DATE NOT NULL,
    [LastDateOccupied] DATE NOT NULL,
    [TotalDays] AS (DATEDIFF(DAY, [FirstDateOccupied], [LastDateOccupied])),
    [AmountCharged] DECIMAL(10, 2) NOT NULL,
    [TaxRate] DECIMAL(5, 2) NOT NULL,
    [TaxAmount] AS (CAST([AmountCharged] * [TaxRate] / 100 AS DECIMAL(5,2))),
    [PaymentTotal] AS (CAST([AmountCharged] + ([AmountCharged] * [TaxRate] / 100) AS DECIMAL(10,2))),
    [Notes] NVARCHAR(500)
)

CREATE TABLE [Occupancies](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [EmployeeId] INT NOT NULL REFERENCES [Employees]([Id]),
    [DateOccupied] DATE NOT NULL,
    [AccountNumber] INT NOT NULL REFERENCES [Customers]([AccountNumber]),
    [RoomNumber] INT NOT NULL REFERENCES [Rooms]([RoomNumber]),
    [RateApplied] DECIMAL(10, 2) NOT NULL,
    [PhoneCharge] DECIMAL(7, 2),
    [Notes] NVARCHAR(500)
)

GO

INSERT INTO [Employees] ([FirstName], [LastName], [Title], [Notes])
VALUES
    (N'Иван', N'Петров', N'Мениджър', N'Отговаря за резервациите'),
    (N'Мария', N'Георгиева', N'Рецепционист', N'Работи на смени'),
    (N'Георги', N'Димитров', N'Счетоводител', NULL)

INSERT INTO [Customers] ([FirstName], [LastName], [PhoneNumber], [EmergencyName], [EmergencyNumber], [Notes])
VALUES
    (N'Иван', N'Иванов', N'0888123456', N'Мария Иванова', N'0888765432', N'Редовен клиент'),
    (N'Мария', N'Петрова', N'0899123456', N'Петър Петров', N'0899765432', N'Няма специални забележки'),
    (N'Георги', N'Димитров', N'0877123456', NULL, NULL, NULL)

INSERT INTO [RoomStatus] ([RoomStatus], [Notes])
VALUES
    (N'Available', N'Room is free for booking'),
    (N'Occupied', N'Room currently occupied by a guest'),
    (N'Maintenance', N'Room under maintenance')

INSERT INTO [RoomTypes] ([RoomType], [Notes])
VALUES
    (N'Single', N'Room suitable for one person'),
    (N'Double', N'Room suitable for two persons'),
    (N'Suite', N'Luxury room with extra amenities')

INSERT INTO [BedTypes] ([BedType], [Notes])
VALUES
    (N'Twin', N'Two single beds'),
    (N'Queen', N'One queen-size bed'),
    (N'King', N'One king-size bed')

INSERT INTO [Rooms] ([RoomNumber], [RoomType], [BedType], [Rate], [RoomStatus], [Notes])
VALUES
    (101, N'Single', N'Twin', 50.00, N'Available', N'First floor, near the elevator'),
    (202, N'Double', N'Queen', 80.00, N'Occupied', N'Second floor, corner room'),
    (303, N'Suite', N'King', 150.00, N'Maintenance', NULL)

INSERT INTO [Payments] ([EmployeeId], [PaymentDate], [AccountNumber], [FirstDateOccupied], [LastDateOccupied], [AmountCharged], [TaxRate], [Notes])
VALUES
    (1, '2025-09-01 10:30:00', 1, '2025-08-25', '2025-08-28', 200.00, 10.00, N'Paid in cash'),
    (2, '2025-09-02 14:45:00', 2, '2025-08-20', '2025-08-22', 150.00, 12.50, N'Paid by card'),
    (3, '2025-09-03 09:15:00', 3, '2025-08-28', '2025-08-30', 300.00, 8.00, N'Paid online');

INSERT INTO [Occupancies] ([EmployeeId], [DateOccupied], [AccountNumber], [RoomNumber], [RateApplied], [PhoneCharge], [Notes])
VALUES
    (1, '2025-08-25', 1, 101, 50.00, 5.00, N'Guest requested extra towels'),
    (2, '2025-08-20', 2, 202, 80.00, 0.00, N'No additional charges'),
    (3, '2025-08-28', 3, 303, 150.00, NULL, NULL);

GO

-- 16. Create SoftUni Database
CREATE DATABASE [SoftUni]
GO

USE [SoftUni]
GO

CREATE TABLE [Towns](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] NVARCHAR(80) NOT NULL
)

CREATE TABLE [Addresses](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [AddressText] NVARCHAR(200) NOT NULL,
    [TownId] INT NOT NULL REFERENCES [Towns]([Id])
)

CREATE TABLE [Departments](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE [Employees](
    [Id] INT PRIMARY KEY IDENTITY (1, 1),
    [FirstName] NVARCHAR(80) NOT NULL,
    [MiddleName] NVARCHAR(80),
    [LastName] NVARCHAR(80) NOT NULL,
    [JobTitle] NVARCHAR(100) NOT NULL,
    [DepartmentId] INT NOT NULL REFERENCES [Departments]([Id]),
    [HireDate] DATE NOT NULL,
    [Salary] DECIMAL(10, 2) NOT NULL,
    [AddressId] INT NOT NULL REFERENCES [Addresses]([Id])
)

GO

-- 17. Backup Database, Drop Database, Restore Database
BACKUP DATABASE [SoftUni] -- Backup the SoftUni database
    TO DISK = '/var/opt/mssql/backup/softuni-backup.bak'
    WITH FORMAT, INIT;

GO

USE [master] -- Switch to master database to drop SoftUni database
ALTER DATABASE [SoftUni] SET SINGLE_USER WITH ROLLBACK IMMEDIATE 
DROP DATABASE [SoftUni]

GO

RESTORE FILELISTONLY -- Check the logical file names in the backup
    FROM DISK = '/var/opt/mssql/backup/softuni-backup.bak'

GO

RESTORE DATABASE [SoftUni] -- Restore the SoftUni database
    FROM DISK = '/var/opt/mssql/backup/softuni-backup.bak'
WITH
    MOVE 'SoftUni' TO '/var/opt/mssql/data/SoftUni.mdf',
    MOVE 'SoftUni_log' TO '/var/opt/mssql/data/SoftUni_log.ldf',
REPLACE

GO

-- 18. Basic Insert
INSERT INTO [Towns]([Name])
VALUES
    (N'Sofia'),
    (N'Plovdiv'),
    (N'Varna'),
    (N'Burgas')

INSERT INTO [Addresses] ([AddressText], [TownId])
VALUES
    (N'ул. „Витоша“ 12', 1),
    (N'бул. „Цар Борис III“ 45', 2),
    (N'ул. „Отец Паисий“ 7', 3),
    (N'ул. „Алеко Константинов“ 3', 1),
    (N'бул. „Славянска“ 8', 4);

INSERT INTO [Departments]([Name])
VALUES 
    ('Engineering'),
    ('Sales'),
    ('Marketing'),
    ('Software Development'),
    ('Quality Assurance')

INSERT INTO [Employees] ([FirstName], [MiddleName], [LastName], [JobTitle], [DepartmentId], [HireDate], [Salary], [AddressId])
VALUES
    (N'Ivan', N'Ivanov', N'Ivanov', N'.NET Developer', 4, '2013-02-01', 3500.00, 1),
    (N'Petar', N'Petrov', N'Petrov', N'Senior Engineer', 1, '2004-03-02', 4000.00, 2),
    (N'Maria', N'Petrova', N'Ivanova', N'Intern', 5, '2016-08-28', 525.25, 3),
    (N'Georgi', N'Teziev', N'Ivanov', N'CEO', 2, '2007-12-09', 3000.00, 4),
    (N'Peter', N'Pan', N'Pan', N'Intern', 3, '2016-08-28', 599.88, 5);

GO

-- 19. Basic Select All Fields
SELECT * FROM [Towns]
GO

SELECT * FROM [Departments]
GO

SELECT * FROM [Employees]
GO

-- 20. Basic Select All Fields and Order Them
SELECT * FROM [Towns]
ORDER BY [Name] ASC

GO

SELECT * FROM [Departments]
ORDER BY [Name] ASC

GO

SELECT * FROM [Employees]
ORDER BY [Salary] DESC

GO

-- 21. Basic Select Some Fields
SELECT [Name] FROM [Towns]
ORDER BY [Name] ASC

GO

SELECT [Name] FROM [Departments]
ORDER BY [Name] ASC

GO

SELECT [FirstName], [LastName], [JobTitle], [Salary] FROM [Employees]
ORDER BY [Salary] DESC

GO

-- 22. Increase Employees Salary
UPDATE [Employees]
SET [Salary] = [Salary] * 1.10

SELECT [Salary] FROM [Employees]

GO

-- 23. Decrease Tax Rate
UPDATE [Payments]
SET [TaxRate] = CAST([TaxRate] * 0.97 AS DECIMAL(5,2));

SELECT [TaxRate] FROM [Payments]

GO

-- 24. Delete All Records
DELETE FROM [Occupancies]

SELECT * FROM [Occupancies]

GO

-- End of Script