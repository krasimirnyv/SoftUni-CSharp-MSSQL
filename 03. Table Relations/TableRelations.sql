CREATE DATABASE [Table Relations]
GO

USE [Table Relations]
GO

-- 1. One-To-One Relationship
CREATE TABLE [Passports](
    [PassportID] INT PRIMARY KEY IDENTITY (101, 1),
    [PassportNumber] CHAR(8) UNIQUE NOT NULL 
)

CREATE TABLE [Persons](
    [PersonID] INT PRIMARY KEY IDENTITY (1, 1),
    [FirstName] VARCHAR(50) NOT NULL,
    [Salary] DECIMAL(18, 2) NOT NULL,
    [PassportID] INT FOREIGN KEY REFERENCES [Passports]([PassportID]) UNIQUE
)

INSERT INTO [Passports]([PassportNumber])
VALUES 
       ('N34FG21B'),
       ('K65LO4R7'),
       ('ZE657QP2')

INSERT INTO [Persons]([FirstName], [Salary], [PassportID])
VALUES
       ('Roberto', 43300.00, 102),
       ('Tom', 56100.00, 103),
       ('Yana', 60200.00, 101)

GO

-- 2. One-To-Many Relationship
CREATE TABLE [Manufacturers](
    [ManufacturerID] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] VARCHAR(50) UNIQUE NOT NULL,
    [EstablishedOn] DATE NOT NULL 
)

CREATE TABLE [Models](
    [ModelID] INT PRIMARY KEY IDENTITY (101, 1),
    [Name] VARCHAR(50) UNIQUE NOT NULL,
    [ManufacturerID] INT FOREIGN KEY REFERENCES [Manufacturers]([ManufacturerID])
)

INSERT INTO [Manufacturers]([Name], [EstablishedOn])
VALUES 
       ('BMW', '07/03/1916'),
       ('Tesla', '01/01/2003'),
       ('Lada', '01/05/1966')

INSERT INTO [Models]([Name], [ManufacturerID])
VALUES
       ('X1', 1),
       ('i6', 1),
       ('Model S', 2),
       ('Model X', 2),
       ('Model 3', 2),
       ('Nova', 3)

GO

-- 3. Many-To-Many Relationship
CREATE TABLE [Students](
    [StudentID] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [Exams](
    [ExamID] INT PRIMARY KEY IDENTITY (101, 1),
    [Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [StudentsExams](
    [StudentID] INT FOREIGN KEY REFERENCES [Students]([StudentID]),
    [ExamID] INT FOREIGN KEY REFERENCES [Exams]([ExamID]),
    PRIMARY KEY ([StudentID], [ExamID])
)

INSERT INTO [Students]([Name])
VALUES 
       ('Mila'),
       ('Toni'),
       ('Ron')

INSERT INTO [Exams]([Name])
VALUES 
       ('SpringMVC'),
       ('Neo4j'),
       ('Oracle 11g')

INSERT INTO [StudentsExams]([StudentID], [ExamID])
VALUES
       (1, 101),
       (1, 102),
       (2, 101),
       (3, 103),
       (2, 102),
       (2, 103)

GO

-- 4. Self-Referencing
CREATE TABLE [Teachers](
    [TeacherID] INT PRIMARY KEY IDENTITY (101, 1),
    [Name] VARCHAR(50) NOT NULL,
    [ManagerID] INT FOREIGN KEY REFERENCES [Teachers]([TeacherID])
)

GO

-- 5. Online Store Database
CREATE DATABASE [Online Store]
GO

USE [Online Store]
GO

CREATE TABLE [Cities](
    [CityID] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE [Customers](
    [CustomerID] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] VARCHAR(100) NOT NULL,
    [Birthday] DATE NOT NULL,
    [CityID] INT NOT NULL FOREIGN KEY REFERENCES [Cities]([CityID])
)

CREATE TABLE [Orders](
    [OrderID] INT PRIMARY KEY IDENTITY (1, 1),
    [CustomerID] INT NOT NULL FOREIGN KEY REFERENCES [Customers]([CustomerID]),
)

CREATE TABLE [ItemTypes](
    [ItemTypeID] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE [Items](
    [ItemID] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] VARCHAR(100) NOT NULL,
    [ItemTypeID] INT NOT NULL FOREIGN KEY REFERENCES [ItemTypes]([ItemTypeID])
)

CREATE TABLE [OrderItems](
    [OrderID] INT NOT NULL FOREIGN KEY REFERENCES [Orders]([OrderID]),
    [ItemID] INT NOT NULL FOREIGN KEY REFERENCES [Items]([ItemID]),
    PRIMARY KEY ([OrderID], [ItemID])
)

GO

-- 6. University Database
CREATE DATABASE [University]
GO

USE [University]
GO

CREATE TABLE [Subjects](
    [SubjectID] INT PRIMARY KEY IDENTITY (1, 1),
    [SubjectName] VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE [Majors](
    [MajorsID] INT PRIMARY KEY IDENTITY (1, 1),
    [Name] VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE [Students](
    [StudentID] INT PRIMARY KEY IDENTITY (1, 1),
    [StudentNumber] CHAR(10) UNIQUE NOT NULL,
    [StudentName] VARCHAR(100) NOT NULL,
    [MajorID] INT NOT NULL FOREIGN KEY REFERENCES [Majors]([MajorsID])
)

CREATE TABLE [Agenda](
    [StudentID] INT NOT NULL FOREIGN KEY REFERENCES [Students]([StudentID]),
    [SubjectID] INT NOT NULL FOREIGN KEY REFERENCES [Subjects]([SubjectID]),
    PRIMARY KEY ([StudentID], [SubjectID])
)

CREATE TABLE [Payments](
    [PaymentID] INT PRIMARY KEY IDENTITY (1, 1),
    [PaymentDate] DATETIME2 NOT NULL,
    [PaymentAmount] DECIMAL(18, 2) NOT NULL,
    [StudentID] INT NOT NULL FOREIGN KEY REFERENCES [Students]([StudentID])
)

GO

-- 9. *Peaks in Rila
USE [Geography]
GO

  SELECT [MountainRange], [PeakName], [Elevation]
    FROM [Mountains] 
      AS M JOIN [Peaks] AS P ON M.Id = P.MountainId
   WHERE [MountainRange] = 'Rila'
ORDER BY [Elevation] DESC

GO

-- End of the script